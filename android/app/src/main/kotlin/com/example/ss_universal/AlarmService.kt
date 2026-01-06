package com.example.ss_universal

import android.app.*
import android.content.Intent
import android.os.BatteryManager
import android.content.Context
import android.media.AudioAttributes
import android.media.MediaPlayer
import android.os.IBinder
import android.os.PowerManager
import android.util.Log
import androidx.core.app.NotificationCompat


class AlarmService : Service() {

    companion object {
        var isFinalStop = false
    }

    private var mediaPlayer: MediaPlayer? = null
    private var wakeLock: PowerManager.WakeLock? = null
    private val CHANNEL_ID = "ALARM_CHANNEL"

    private val handler = android.os.Handler()
    private val batteryRunnable = object : Runnable {
        override fun run() {
            saveBatteryToPrefs()
            handler.postDelayed(this, 60_000) // every 1 minute
        }
    }


    override fun onCreate() {
        super.onCreate()

        createNotificationChannel()

        val fullScreenIntent = Intent(this, AlarmActivity::class.java)
        val fullScreenPendingIntent = PendingIntent.getActivity(
            this,
            0,
            fullScreenIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
            .setContentTitle("Alarm Ringing")
            .setContentText("Scan QR to stop alarm")
            .setCategory(NotificationCompat.CATEGORY_ALARM)
            .setPriority(NotificationCompat.PRIORITY_MAX)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setOngoing(true)
            .setAutoCancel(false)
            .setOnlyAlertOnce(false)
            .setDefaults(Notification.DEFAULT_ALL)
            //.setFullScreenIntent(fullScreenPendingIntent, true)
            .build()

        // MUST BE FIRST
        startForeground(1, notification)

        // AFTER foreground is started
        acquireWakeLock()
        startAlarm()
        handler.post(batteryRunnable)
    }


    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        
        return START_STICKY
    }

    private fun startAlarm() {
        mediaPlayer = MediaPlayer().apply {
            setAudioAttributes(
                AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_ALARM)
                    .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                    .build()
            )
            setDataSource(this@AlarmService,
                android.provider.Settings.System.DEFAULT_ALARM_ALERT_URI)
            isLooping = true
            prepare()
            start()
        }
    }

    private fun openAlarmScreen() {
        val intent = Intent(this, AlarmActivity::class.java)
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        //startActivity(intent)
    }

    private fun acquireWakeLock() {
        val pm = getSystemService(Context.POWER_SERVICE) as PowerManager

        wakeLock = pm.newWakeLock(
            PowerManager.PARTIAL_WAKE_LOCK,
            "AlarmApp::WakeLock"
        )
        wakeLock?.acquire(10 * 60 * 1000L)
    }


    override fun onDestroy() {
        handler.removeCallbacks(batteryRunnable)
        mediaPlayer?.stop()
        mediaPlayer?.release()
        wakeLock?.release()

        if (!isFinalStop) {
            // Alarm stopped normally → schedule again
            AlarmScheduler.scheduleAlarm(this)
        } else {
            // User logged out → DO NOT reschedule
            isFinalStop = false // reset for next login
        }

        super.onDestroy()
    }


    override fun onBind(intent: Intent?): IBinder? = null

    private fun createNotificationChannel() {
        val manager = getSystemService(NotificationManager::class.java)

        
        

        if (manager.getNotificationChannel(CHANNEL_ID) == null) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Alarm Channel",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                lockscreenVisibility = Notification.VISIBILITY_PUBLIC
            }
            manager.createNotificationChannel(channel)
        }

    }

    private fun getBatteryPercentage(): Int {
        val batteryManager =
            getSystemService(Context.BATTERY_SERVICE) as BatteryManager
        return batteryManager.getIntProperty(
            BatteryManager.BATTERY_PROPERTY_CAPACITY
        )
    }

    private fun saveBatteryToPrefs() {
        val battery = getBatteryPercentage()

        val prefs = getSharedPreferences("battery_pref", Context.MODE_PRIVATE)
        prefs.edit().putInt("battery", battery).apply()

        Log.d("BATTERY_NATIVE", "Battery saved = $battery%")
    }



}
