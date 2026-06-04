package app.timeserver.gnss

import android.annotation.SuppressLint
import android.content.Context
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.location.GnssStatus
import android.location.Location
import android.location.LocationListener
import android.location.LocationManager
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import app.timeserver.bridge.TimeStore
import io.flutter.plugin.common.EventChannel
import java.util.Timer
import java.util.TimerTask

/**
 * Native GPS time + GNSS satellite status + compass heading. No Flutter plugin
 * exposes the GnssStatus fields (Cn0/azimuth/elevation/usedInFix/carrier), so
 * this is the bridge. Ports `LocationHelper`/`SatelliteLocationListener`.
 */
class GnssController(private val context: Context) {
    private val locationManager =
        context.getSystemService(Context.LOCATION_SERVICE) as LocationManager
    private val sensorManager =
        context.getSystemService(Context.SENSOR_SERVICE) as SensorManager
    private val mainHandler = Handler(Looper.getMainLooper())

    private var gpsTimeSink: EventChannel.EventSink? = null
    private var satSink: EventChannel.EventSink? = null
    private var compassSink: EventChannel.EventSink? = null
    private var ticker: Timer? = null
    private var started = false

    private val locationListener = object : LocationListener {
        override fun onLocationChanged(location: Location) {
            TimeStore.setGps(location.time)
            TimeStore.setLocation(location.latitude, location.longitude, location.accuracy.toDouble())
            emitGpsTime()
        }

        override fun onStatusChanged(provider: String?, status: Int, extras: Bundle?) {}
        override fun onProviderEnabled(provider: String) {}
        override fun onProviderDisabled(provider: String) {}
    }

    private val gnssCallback = object : GnssStatus.Callback() {
        override fun onSatelliteStatusChanged(status: GnssStatus) = emitSatellites(status)
    }

    private val sensorListener = object : SensorEventListener {
        private val rotation = FloatArray(9)
        private val orientation = FloatArray(3)
        override fun onSensorChanged(event: SensorEvent) {
            if (event.sensor.type != Sensor.TYPE_ROTATION_VECTOR) return
            SensorManager.getRotationMatrixFromVector(rotation, event.values)
            SensorManager.getOrientation(rotation, orientation)
            var deg = Math.toDegrees(orientation[0].toDouble())
            if (deg < 0) deg += 360
            val d = deg
            compassSink?.let { s -> mainHandler.post { s.success(d) } }
        }

        override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {}
    }

    @SuppressLint("MissingPermission")
    fun start(): Boolean {
        if (started) return true
        return try {
            locationManager.requestLocationUpdates(
                LocationManager.GPS_PROVIDER, 1000L, 0f, locationListener
            )
            // Single-arg overload is API 24 (matches minSdk); callbacks arrive
            // on the calling thread's looper (the main thread here).
            locationManager.registerGnssStatusCallback(gnssCallback)
            sensorManager.getDefaultSensor(Sensor.TYPE_ROTATION_VECTOR)?.let {
                sensorManager.registerListener(sensorListener, it, SensorManager.SENSOR_DELAY_UI)
            }
            startTicker()
            started = true
            true
        } catch (e: SecurityException) {
            false
        }
    }

    fun stop(): Boolean {
        locationManager.removeUpdates(locationListener)
        locationManager.unregisterGnssStatusCallback(gnssCallback)
        sensorManager.unregisterListener(sensorListener)
        ticker?.cancel()
        ticker = null
        started = false
        return true
    }

    fun setGpsTimeSink(s: EventChannel.EventSink?) { gpsTimeSink = s }
    fun setSatSink(s: EventChannel.EventSink?) { satSink = s }
    fun setCompassSink(s: EventChannel.EventSink?) { compassSink = s }

    private fun startTicker() {
        ticker?.cancel()
        ticker = Timer(true).also {
            it.scheduleAtFixedRate(object : TimerTask() {
                override fun run() = emitGpsTime()
            }, 0, 500)
        }
    }

    private fun emitGpsTime() {
        val sink = gpsTimeSink ?: return
        val map = TimeStore.toMap()
        mainHandler.post { sink.success(map) }
    }

    private fun emitSatellites(status: GnssStatus) {
        val sink = satSink ?: return
        val list = ArrayList<Map<String, Any?>>()
        for (i in 0 until status.satelliteCount) {
            val constellation = status.getConstellationType(i)
            val carrier = if (Build.VERSION.SDK_INT >= 26 && status.hasCarrierFrequencyHz(i)) {
                status.getCarrierFrequencyHz(i) / 1e6
            } else {
                null
            }
            list.add(
                mapOf(
                    "svid" to status.getSvid(i),
                    "constellation" to constellation,
                    "constellationName" to constellationName(constellation),
                    "cn0DbHz" to status.getCn0DbHz(i),
                    "azimuth" to status.getAzimuthDegrees(i),
                    "elevation" to status.getElevationDegrees(i),
                    "usedInFix" to status.usedInFix(i),
                    "hasEphemeris" to status.hasEphemerisData(i),
                    "hasAlmanac" to status.hasAlmanacData(i),
                    "carrierMhz" to carrier,
                    "band" to carrier?.let { bandFor(it) }
                )
            )
        }
        mainHandler.post { sink.success(list) }
    }

    private fun constellationName(type: Int): String = when (type) {
        GnssStatus.CONSTELLATION_GPS -> "GPS"
        GnssStatus.CONSTELLATION_GLONASS -> "GLONASS"
        GnssStatus.CONSTELLATION_GALILEO -> "GALILEO"
        GnssStatus.CONSTELLATION_BEIDOU -> "BEIDOU"
        GnssStatus.CONSTELLATION_QZSS -> "QZSS"
        GnssStatus.CONSTELLATION_SBAS -> "SBAS"
        else -> "UNKNOWN"
    }

    private fun bandFor(mhz: Double): String? = when {
        mhz in 1574.0..1577.0 -> "L1"
        mhz in 1226.0..1229.0 -> "L2"
        mhz in 1174.0..1178.0 -> "L5"
        mhz in 1598.0..1606.0 -> "G1"
        mhz in 1559.0..1592.0 -> "E1"
        else -> null
    }
}
