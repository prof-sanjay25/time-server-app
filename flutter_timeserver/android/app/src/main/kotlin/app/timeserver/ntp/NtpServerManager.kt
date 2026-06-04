package app.timeserver.ntp

import android.content.Context
import android.os.Handler
import android.os.Looper
import app.timeserver.bridge.TimeStore
import app.timeserver.net.NetworkController
import io.flutter.plugin.common.EventChannel
import java.net.DatagramPacket
import java.net.DatagramSocket
import java.util.Timer
import java.util.TimerTask
import java.util.concurrent.ConcurrentHashMap

/**
 * Process-global UDP NTP server (the socket survives as long as the foreground
 * service keeps the process alive). Port of `SimpleNTPServer` + the logging in
 * `ServerLogDataPointGrouper`, with the original's broken rate limiter and
 * memory leak fixed.
 */
object NtpServerManager {
    @Volatile
    var running = false
        private set

    var port = 1234
    var stratum = 1
    var packetLimit = 0 // 0 = unlimited
    var interfaceName: String? = null
    var ip = "0.0.0.0"
    var rootRedirected = false

    private var socket: DatagramSocket? = null
    private var thread: Thread? = null
    private val mainHandler = Handler(Looper.getMainLooper())
    private var statusSink: EventChannel.EventSink? = null
    private var logsSink: EventChannel.EventSink? = null
    private var logTimer: Timer? = null

    // minute epoch (ms, floored to minute) -> [inbound, outbound]
    private val buckets = ConcurrentHashMap<Long, IntArray>()

    fun setStatusSink(s: EventChannel.EventSink?) {
        statusSink = s
        if (s != null) emitStatus()
    }

    fun setLogsSink(s: EventChannel.EventSink?) {
        logsSink = s
        if (s != null) emitLogs()
    }

    fun configure(ctx: Context, p: Int, strat: Int, limit: Int, iface: String?) {
        port = if (p > 0) p else 1234
        stratum = strat
        packetLimit = limit
        val nc = NetworkController(ctx)
        if (!iface.isNullOrEmpty()) {
            interfaceName = iface
            ip = nc.ipFor(iface)
        } else {
            val best = nc.bestInterface()
            interfaceName = best?.first
            ip = best?.second ?: "0.0.0.0"
        }
    }

    @Synchronized
    fun start(ctx: Context): Map<String, Any?> {
        if (running) return statusMap()
        if (interfaceName == null) configure(ctx, port, stratum, packetLimit, null)
        socket = DatagramSocket(port)
        running = true
        thread = Thread { loop() }.apply { isDaemon = true; start() }
        startLogTimer()
        emitStatus()
        return statusMap()
    }

    @Synchronized
    fun stop() {
        running = false
        socket?.close()
        socket = null
        thread?.interrupt()
        thread = null
        logTimer?.cancel()
        logTimer = null
        emitStatus()
    }

    fun applyStratum(v: Int) { stratum = v; emitStatus() }
    fun applyPacketLimit(v: Int) { packetLimit = v }
    fun setInterface(ctx: Context, name: String) {
        interfaceName = name
        ip = NetworkController(ctx).ipFor(name)
        emitStatus()
    }
    fun markRootRedirected(v: Boolean) { rootRedirected = v; emitStatus() }

    private fun loop() {
        val buffer = ByteArray(48)
        val request = DatagramPacket(buffer, buffer.size)
        while (running) {
            try {
                val s = socket ?: break
                request.length = buffer.size
                s.receive(request)
                val recvMillis = TimeStore.adjustedMillis()
                record(true)
                if (NtpCodec.mode(request.data) == NtpCodec.MODE_CLIENT && allowResponse()) {
                    val refId = if (TimeStore.hasFix()) NtpCodec.REF_ID_GPS else NtpCodec.REF_ID_LOCAL
                    val resp = NtpCodec.buildResponse(
                        request.data.copyOf(48), recvMillis, TimeStore.adjustedMillis(), stratum, refId
                    )
                    s.send(DatagramPacket(resp, resp.size, request.address, request.port))
                    record(false)
                }
            } catch (e: Exception) {
                // Socket closed on shutdown, or a malformed packet — keep serving.
                if (!running) break
            }
        }
    }

    private fun currentMinute(): Long = (System.currentTimeMillis() / 60000L) * 60000L

    private fun record(inbound: Boolean) {
        val m = currentMinute()
        val arr = buckets.getOrPut(m) { IntArray(2) }
        if (inbound) arr[0]++ else arr[1]++
        val cutoff = m - 3600000L
        for (k in buckets.keys) if (k < cutoff) buckets.remove(k)
    }

    private fun allowResponse(): Boolean {
        if (packetLimit <= 0) return true
        val arr = buckets[currentMinute()] ?: return true
        return arr[1] < packetLimit
    }

    private fun packetsPerMin(): Int {
        val arr = buckets[currentMinute()] ?: return 0
        return arr[0] + arr[1]
    }

    fun statusMap(): Map<String, Any?> = mapOf(
        "running" to running,
        "ip" to ip,
        "port" to port,
        "interface" to interfaceName,
        "stratum" to stratum,
        "rootRedirected" to rootRedirected,
        "packetsPerMin" to packetsPerMin()
    )

    private fun emitStatus() {
        val sink = statusSink ?: return
        val map = statusMap()
        mainHandler.post { sink.success(map) }
    }

    private fun emitLogs() {
        val sink = logsSink ?: return
        val end = currentMinute()
        val list = ArrayList<Map<String, Any?>>(60)
        for (i in 59 downTo 0) {
            val m = end - i * 60000L
            val arr = buckets[m]
            list.add(
                mapOf(
                    "timeReceived" to m,
                    "inbound" to (arr?.get(0) ?: 0),
                    "outbound" to (arr?.get(1) ?: 0)
                )
            )
        }
        mainHandler.post { sink.success(list) }
    }

    private fun startLogTimer() {
        logTimer?.cancel()
        logTimer = Timer(true).also {
            it.scheduleAtFixedRate(object : TimerTask() {
                override fun run() {
                    emitLogs()
                    emitStatus()
                }
            }, 0, 2000)
        }
    }
}
