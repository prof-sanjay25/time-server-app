package app.timeserver

import android.content.Intent
import androidx.core.content.ContextCompat
import app.timeserver.bridge.Channels
import app.timeserver.bridge.TimeStore
import app.timeserver.gnss.GnssController
import app.timeserver.net.NetworkController
import app.timeserver.ntp.NtpForegroundService
import app.timeserver.ntp.NtpServerManager
import app.timeserver.ntp.PortForwarding
import app.timeserver.power.PowerController
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private lateinit var gnss: GnssController
    private lateinit var power: PowerController
    private lateinit var network: NetworkController

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val messenger = flutterEngine.dartExecutor.binaryMessenger

        gnss = GnssController(applicationContext)
        power = PowerController(this, applicationContext)
        network = NetworkController(applicationContext)

        // ---- GPS ----
        MethodChannel(messenger, Channels.GPS_METHOD).setMethodCallHandler { call, result ->
            when (call.method) {
                "startLocation" -> result.success(gnss.start())
                "stopLocation" -> result.success(gnss.stop())
                "getTime" -> result.success(TimeStore.toMap())
                else -> result.notImplemented()
            }
        }
        EventChannel(messenger, Channels.GPS_TIME).setStreamHandler(sinkHandler(gnss::setGpsTimeSink))
        EventChannel(messenger, Channels.GNSS).setStreamHandler(sinkHandler(gnss::setSatSink))
        EventChannel(messenger, Channels.COMPASS).setStreamHandler(sinkHandler(gnss::setCompassSink))

        // ---- NTP server ----
        MethodChannel(messenger, Channels.NTP_METHOD).setMethodCallHandler { call, result ->
            when (call.method) {
                "startServer" -> {
                    val port = call.argument<Int>("port") ?: 1234
                    val stratum = call.argument<Int>("stratum") ?: 1
                    val limit = call.argument<Int>("packetLimit") ?: 0
                    val iface = call.argument<String>("interface")
                    NtpServerManager.configure(applicationContext, port, stratum, limit, iface)
                    try {
                        val status = NtpServerManager.start(applicationContext)
                        ContextCompat.startForegroundService(
                            this, Intent(this, NtpForegroundService::class.java)
                        )
                        result.success(status)
                    } catch (e: Exception) {
                        result.error("START_FAILED", e.message, null)
                    }
                }
                "stopServer" -> {
                    stopService(Intent(this, NtpForegroundService::class.java))
                    NtpServerManager.stop()
                    result.success(true)
                }
                "getStatus" -> result.success(NtpServerManager.statusMap())
                "setStratum" -> {
                    NtpServerManager.applyStratum(call.argument<Int>("stratum") ?: 1)
                    result.success(true)
                }
                "setPacketLimit" -> {
                    NtpServerManager.applyPacketLimit(call.argument<Int>("limit") ?: 0)
                    result.success(true)
                }
                "setInterface" -> {
                    NtpServerManager.setInterface(applicationContext, call.argument<String>("name") ?: "")
                    result.success(true)
                }
                "tryRootRedirect" -> {
                    val rooted = PortForwarding.isRootAvailable()
                    val redirected = if (rooted) PortForwarding.tryRedirect(123, NtpServerManager.port) else false
                    NtpServerManager.markRootRedirected(redirected)
                    result.success(mapOf("rooted" to rooted, "redirected" to redirected))
                }
                else -> result.notImplemented()
            }
        }
        EventChannel(messenger, Channels.NTP_STATUS).setStreamHandler(sinkHandler(NtpServerManager::setStatusSink))
        EventChannel(messenger, Channels.NTP_LOGS).setStreamHandler(sinkHandler(NtpServerManager::setLogsSink))

        // ---- Power ----
        MethodChannel(messenger, Channels.POWER).setMethodCallHandler { call, result ->
            when (call.method) {
                "isIgnoringBatteryOptimizations" -> result.success(power.isIgnoring())
                "requestIgnoreBatteryOptimizations" -> {
                    power.request()
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }

        // ---- Network ----
        MethodChannel(messenger, Channels.NETWORK).setMethodCallHandler { call, result ->
            when (call.method) {
                "listInterfaces" -> result.success(network.listInterfaces())
                "ipFor" -> result.success(network.ipFor(call.argument<String>("name") ?: ""))
                else -> result.notImplemented()
            }
        }
        EventChannel(messenger, Channels.NETWORK_EVENT).setStreamHandler(network)
    }

    private fun sinkHandler(setter: (EventChannel.EventSink?) -> Unit) =
        object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) = setter(events)
            override fun onCancel(arguments: Any?) = setter(null)
        }
}
