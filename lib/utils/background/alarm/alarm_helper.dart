import 'package:flutter/services.dart';

class AlarmHelper {
  static const MethodChannel _channel = MethodChannel('alarm_channel');

  static Future<void> startAlarm() async {
    try {
      await _channel.invokeMethod('scheduleAlarm');
    } catch (e) {
      // log only, don’t crash attendance flow
      print("Alarm start failed: $e");
    }
  }

  static Future<void> stopAlarm() async {
    try {
      await _channel.invokeMethod('stopAlarm');
    } catch (e) {
      print("Alarm stop failed: $e");
    }
  }
}
