package com.example.ss_universal

import android.os.Bundle
import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel


class MainActivity : FlutterActivity() {

    private val CHANNEL = "alarm_channel"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "scheduleAlarm" -> {
                        AlarmScheduler.scheduleAlarm(this)
                        result.success(true)
                    }
 
                    "stopAlarm" -> {
                        stopService(Intent(this, AlarmService::class.java))
                        result.success(true)
                    }

                    "cancelAlarm" -> {
                        AlarmScheduler.cancelAlarm(this)
                        stopService(Intent(this, AlarmService::class.java))
                        result.success(true)
                    }

                    else -> result.notImplemented()
                }

            }

            intent?.getStringExtra("open_screen")?.let { screen ->
            if (screen == "scan_qr") {
                flutterEngine.navigationChannel.pushRoute("/scan_qr");
            }
        }
    }
}
