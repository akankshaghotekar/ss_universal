import 'package:flutter/services.dart';

class AttendanceAlarmScheduler {
  static const _channel = MethodChannel('attendance_alarm');

  static Future<void> startAlarm({required int minutes}) async {
    await _channel.invokeMethod('startAlarm', {'minutes': minutes});
  }

  static Future<void> stopAlarm() async {
    await _channel.invokeMethod('stopAlarm');
  }
}
