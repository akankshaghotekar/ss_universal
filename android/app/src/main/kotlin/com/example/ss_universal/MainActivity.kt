package com.example.ss_universal

import android.os.Build
import android.os.Bundle
import android.content.Intent
import android.os.BatteryManager
import android.content.Context
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel


class MainActivity : FlutterActivity() {

    private val CHANNEL = "alarm_channel"

    private fun requestExactAlarmPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val intent = Intent(
                android.provider.Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM
            )
            intent.data = android.net.Uri.parse("package:$packageName")
            startActivity(intent)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "scheduleAlarm" -> {
                        requestExactAlarmPermission()
                        AlarmScheduler.scheduleAlarm(this)
                        result.success(true)
                    }
 
                    "stopAlarm" -> {
                        stopService(Intent(this, AlarmService::class.java))
                        result.success(true)
                    }

                    "cancelAlarm" -> {
                        AlarmService.isFinalStop = true
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

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "battery_channel"
        ).setMethodCallHandler { call, result ->
            if (call.method == "getBatteryLevel") {
                val batteryManager = getSystemService(Context.BATTERY_SERVICE) as BatteryManager
                val batteryLevel =
                    batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
                result.success(batteryLevel)
            } else {
                result.notImplemented()
            }
        }

    }
}
