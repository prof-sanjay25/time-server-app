package app.timeserver.bridge

/** Channel names shared with the Dart side (see lib/platform/channels.dart). */
object Channels {
    const val NTP_METHOD = "app.timeserver/ntp"
    const val NTP_STATUS = "app.timeserver/ntp/status"
    const val NTP_LOGS = "app.timeserver/ntp/logs"

    const val GPS_METHOD = "app.timeserver/gps"
    const val GPS_TIME = "app.timeserver/gps/time"

    const val GNSS = "app.timeserver/gnss/satellites"

    const val POWER = "app.timeserver/power"

    const val NETWORK = "app.timeserver/network"
    const val NETWORK_EVENT = "app.timeserver/network/changes"

    const val COMPASS = "app.timeserver/compass"
}
