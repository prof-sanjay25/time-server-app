package app.timeserver.ntp

import java.nio.ByteBuffer
import java.nio.ByteOrder

/**
 * Minimal NTP/SNTP v3 codec (RFC 2030 / RFC 5905). Big-endian 48-byte packets.
 * Mirrors the pure-Dart `NtpPacket` so the server and the Dart tests agree.
 */
object NtpCodec {
    const val NTP_EPOCH_OFFSET = 2208988800L
    const val MODE_CLIENT = 3
    const val MODE_SERVER = 4

    const val REF_ID_GPS = 0x47505300       // "GPS\0"
    const val REF_ID_LOCAL = 0x4C4F434C     // "LOCL"

    private const val PRECISION = -20
    private const val ROOT_DELAY = 62
    private const val ROOT_DISPERSION = 1082

    fun mode(buf: ByteArray): Int = buf[0].toInt() and 0x7

    /** Unix millis -> 64-bit NTP timestamp (seconds since 1900 | fraction). */
    fun toNtp64(millis: Long): Long {
        val seconds = millis / 1000 + NTP_EPOCH_OFFSET
        val ms = millis % 1000
        val fraction = (ms * 0x100000000L) / 1000
        return (seconds shl 32) or (fraction and 0xFFFFFFFFL)
    }

    /**
     * Build a server reply for [request].
     * [recvMillis] = request received (t2), [transMillis] = reply sent (t3).
     */
    fun buildResponse(
        request: ByteArray,
        recvMillis: Long,
        transMillis: Long,
        stratum: Int,
        refId: Int
    ): ByteArray {
        val bb = ByteBuffer.allocate(48).order(ByteOrder.BIG_ENDIAN)
        bb.put(0, (((0 shl 6) or (3 shl 3) or MODE_SERVER)).toByte()) // LI0 VN3 Mode4
        bb.put(1, stratum.toByte())
        bb.put(2, 0)
        bb.put(3, PRECISION.toByte())
        bb.putInt(4, ROOT_DELAY)
        bb.putInt(8, ROOT_DISPERSION)
        bb.putInt(12, refId)

        val recvTs = toNtp64(recvMillis)
        bb.putLong(16, recvTs) // reference = receive
        // originate (t1) = echo client's transmit timestamp (bytes 40..47)
        for (i in 0 until 8) bb.put(24 + i, request[40 + i])
        bb.putLong(32, recvTs)                 // receive (t2)
        bb.putLong(40, toNtp64(transMillis))   // transmit (t3)
        return bb.array()
    }
}
