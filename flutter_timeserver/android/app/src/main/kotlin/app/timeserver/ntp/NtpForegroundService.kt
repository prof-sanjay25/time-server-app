package app.timeserver.ntp

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.net.ConnectivityManager
import android.net.Network
import android.net.NetworkRequest
import android.os.Build
import android.os.IBinder
import android.os.PowerManager
import androidx.core.app.NotificationCompat
import app.timeserver.MainActivity
import app.timeserver.R

/**
 * Keeps the process alive (so the UDP socket survives backgrounding), holds a
 * PARTIAL_WAKE_LOCK, shows the persistent notification with a Stop action, and
 * refreshes the IP/interface on connectivity changes. Port of `NtpService`
 * (the socket itself lives in [NtpServerManager]).
 */
class NtpForegroundService : Service() {
    private var wakeLock: PowerManager.WakeLock? = null
    private var netCallback: ConnectivityManager.NetworkCallback? = null

    companion object {
        const val CHANNEL_ID = "NTP_SERVICE"
        const val SERVICE_ID = 1
        const val ACTION_STOP = "app.timeserver.STOP_NTP"
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent?.action == ACTION_STOP) {
            stopEverything()
            return START_NOT_STICKY
        }
        createChannel()
        startForegroundCompat()
        acquireWakeLock()
        registerNetCallback()
        return START_STICKY
    }

    private fun startForegroundCompat() {
        val n = buildNotification()
        if (Build.VERSION.SDK_INT >= 34) {
            startForeground(SERVICE_ID, n, ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE)
        } else {
            startForeground(SERVICE_ID, n)
        }
    }

    private fun createChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val chan = NotificationChannel(CHANNEL_ID, "NTP Server", NotificationManager.IMPORTANCE_LOW)
            chan.setShowBadge(false)
            (getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager)
                .createNotificationChannel(chan)
        }
    }

    private fun buildNotification(): Notification {
        val flags = PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        val openIntent = PendingIntent.getActivity(
            this, 0, Intent(this, MainActivity::class.java), flags
        )
        val stopIntent = PendingIntent.getService(
            this, 1,
            Intent(this, NtpForegroundService::class.java).setAction(ACTION_STOP),
            flags
        )
        val status = NtpServerManager.statusMap()
        val iface = status["interface"] as? String
        val base = "${status["ip"]}:${status["port"]}"
        val endpoint = if (iface.isNullOrEmpty()) base else "$iface, $base"

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle("NTP Server Running")
            .setContentText("Running on $endpoint")
            .setOngoing(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setContentIntent(openIntent)
            .addAction(0, "Stop NTP Server", stopIntent)
            .build()
    }

    private fun rebuildNotification() {
        (getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager)
            .notify(SERVICE_ID, buildNotification())
    }

    private fun acquireWakeLock() {
        val pm = getSystemService(Context.POWER_SERVICE) as PowerManager
        wakeLock = pm.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, "timeserver:ntp").also { it.acquire() }
    }

    private fun registerNetCallback() {
        val cm = getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
        netCallback = object : ConnectivityManager.NetworkCallback() {
            override fun onAvailable(network: Network) = refresh()
            override fun onLost(network: Network) = refresh()
        }
        cm.registerNetworkCallback(NetworkRequest.Builder().build(), netCallback!!)
    }

    private fun refresh() {
        NtpServerManager.interfaceName?.let { NtpServerManager.setInterface(applicationContext, it) }
        rebuildNotification()
    }

    private fun stopEverything() {
        NtpServerManager.stop()
        releaseWakeLock()
        unregisterNetCallback()
        stopForeground(STOP_FOREGROUND_REMOVE)
        stopSelf()
    }

    override fun onDestroy() {
        NtpServerManager.stop()
        releaseWakeLock()
        unregisterNetCallback()
        super.onDestroy()
    }

    private fun releaseWakeLock() {
        wakeLock?.let { if (it.isHeld) it.release() }
        wakeLock = null
    }

    private fun unregisterNetCallback() {
        netCallback?.let {
            (getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager)
                .unregisterNetworkCallback(it)
        }
        netCallback = null
    }
}
