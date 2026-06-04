package app.timeserver.bridge

import kotlin.math.abs

/**
 * Process-global GPS-disciplined clock, ported from the original `TimeStorage`.
 * Holds the last satellite time + the system time it was acquired, and
 * extrapolates the current time. Read by both the UI bridge and the NTP server.
 */
object TimeStore {
    @Volatile private var satelliteMillis: Long? = null
    @Volatile private var acquiredMillis: Long = 0L

    @Volatile var latitude: Double? = null
    @Volatile var longitude: Double? = null
    @Volatile var accuracyMeters: Double? = null

    fun setGps(millis: Long) {
        satelliteMillis = millis
        acquiredMillis = System.currentTimeMillis()
    }

    fun setLocation(lat: Double, lon: Double, accuracy: Double) {
        latitude = lat
        longitude = lon
        accuracyMeters = accuracy
    }

    fun hasFix(): Boolean = satelliteMillis != null

    /** Satellite time + elapsed system time since the fix; system time fallback. */
    fun adjustedMillis(): Long {
        val s = satelliteMillis ?: return System.currentTimeMillis()
        return s + (System.currentTimeMillis() - acquiredMillis)
    }

    fun offsetMillis(): Long {
        val s = satelliteMillis ?: return 0L
        return abs(s - acquiredMillis)
    }

    fun toMap(): Map<String, Any?> = mapOf(
        "gpsMillis" to adjustedMillis(),
        "systemMillis" to System.currentTimeMillis(),
        "offsetMillis" to offsetMillis(),
        "hasFix" to hasFix(),
        "latitude" to latitude,
        "longitude" to longitude,
        "accuracy" to accuracyMeters
    )
}
