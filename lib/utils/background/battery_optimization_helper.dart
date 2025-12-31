import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

class BatteryOptimizationHelper {
  static Future<bool> isIgnored() async {
    if (!Platform.isAndroid) return true;
    return await Permission.ignoreBatteryOptimizations.isGranted;
  }

  static Future<void> request() async {
    if (!Platform.isAndroid) return;
    await Permission.ignoreBatteryOptimizations.request();
  }

  static Future<String> getBrand() async {
    final info = DeviceInfoPlugin();
    final android = await info.androidInfo;
    return android.manufacturer.toLowerCase();
  }
}
