package app.timeserver.ntp

import java.io.BufferedReader
import java.io.InputStreamReader

/**
 * Optional root enhancement: redirect UDP 123 -> 1234 via iptables so standard
 * NTP clients can reach the server. Ports `PortForwardingHelper`. No-op (returns
 * false) on non-rooted devices.
 */
object PortForwarding {

    fun isRootAvailable(): Boolean = runSu("id").let { it != null && it.contains("uid=0") }

    /** Returns true if the redirect was installed. */
    fun tryRedirect(sourcePort: Int = 123, destPort: Int = 1234): Boolean {
        if (!isRootAvailable()) return false
        // Best-effort enable forwarding for all interfaces.
        runSu("for f in /proc/sys/net/ipv4/conf/*/forwarding; do echo 1 > \$f; done")
        val out = runSu(
            "iptables -t nat -C PREROUTING -p udp --dport $sourcePort -j REDIRECT --to-port $destPort " +
                "|| iptables -t nat -I PREROUTING -p udp --dport $sourcePort -j REDIRECT --to-port $destPort"
        )
        return out != null
    }

    private fun runSu(command: String): String? {
        return try {
            val process = Runtime.getRuntime().exec(arrayOf("su", "-c", command))
            val reader = BufferedReader(InputStreamReader(process.inputStream))
            val output = reader.readText()
            process.waitFor()
            if (process.exitValue() == 0) output else null
        } catch (e: Exception) {
            null
        }
    }
}
