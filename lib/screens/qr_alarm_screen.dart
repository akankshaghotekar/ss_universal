import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class QrAlarmScreen extends StatefulWidget {
  const QrAlarmScreen({super.key});

  @override
  State<QrAlarmScreen> createState() => _QrAlarmScreenState();
}

class _QrAlarmScreenState extends State<QrAlarmScreen> {
  static const _channel = MethodChannel('alarm_channel');

  @override
  void initState() {
    super.initState();
    _startAlarm();
  }

  Future<void> _startAlarm() async {
    await _channel.invokeMethod('startAlarm');
  }

  Future<void> _stopAlarm() async {
    await _channel.invokeMethod('stopAlarm');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'QR SCAN REQUIRED',
              style: TextStyle(
                color: Colors.red,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _stopAlarm,
              child: const Text('Scan QR / Stop Alarm'),
            ),
          ],
        ),
      ),
    );
  }
}
