package app.timeserver.net

import android.content.Context
import android.net.ConnectivityManager
import android.net.Network
import android.net.NetworkRequest
import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.EventChannel
import java.net.Inet4Address
import java.net.NetworkInterface
import java.util.Collections

/**
 * Enumerates usable interfaces and resolves IPv4 addresses (port of
 * `NetworkInterfaceHelper`), and streams connectivity changes.
 */
class NetworkController(private val context: Context) : EventChannel.StreamHandler {
    private val mainHandler = Handler(Looper.getMainLooper())
    private var sink: EventChannel.EventSink? = null
    private var callback: ConnectivityManager.NetworkCallback? = null

    fun listInterfaces(): List<Map<String, Any?>> {
        val result = mutableListOf<Map<String, Any?>>()
        try {
            for (ni in Collections.list(NetworkInterface.getNetworkInterfaces())) {
                if (ni.isVirtual || !ni.isUp) continue
                val ipv4 = Collections.list(ni.inetAddresses)
                    .firstOrNull { it is Inet4Address }?.hostAddress ?: continue
                result.add(mapOf("name" to ni.name, "ipv4" to ipv4, "up" to true))
            }
        } catch (_: Exception) {
        }
        return result
    }

    fun ipFor(name: String): String {
        return try {
            val ni = NetworkInterface.getByName(name) ?: return "0.0.0.0"
            Collections.list(ni.inetAddresses)
                .firstOrNull { it is Inet4Address }?.hostAddress ?: "0.0.0.0"
        } catch (_: Exception) {
            "0.0.0.0"
        }
    }

    /** Preferred interface (eth0 > wlan0 > usb0 > any) as (name, ipv4). */
    fun bestInterface(): Pair<String, String>? {
        val all = listInterfaces()
        for (p in listOf("eth0", "wlan0", "usb0")) {
            all.firstOrNull { it["name"] == p }?.let { return Pair(p, it["ipv4"] as String) }
        }
        all.firstOrNull()?.let { return Pair(it["name"] as String, it["ipv4"] as String) }
        return null
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        sink = events
        val cm = context.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
        callback = object : ConnectivityManager.NetworkCallback() {
            override fun onAvailable(network: Network) = emit()
            override fun onLost(network: Network) = emit()
        }
        cm.registerNetworkCallback(NetworkRequest.Builder().build(), callback!!)
    }

    override fun onCancel(arguments: Any?) {
        callback?.let {
            (context.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager)
                .unregisterNetworkCallback(it)
        }
        callback = null
        sink = null
    }

    private fun emit() {
        mainHandler.post { sink?.success(System.currentTimeMillis()) }
    }
}
