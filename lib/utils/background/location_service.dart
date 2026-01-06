import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ss_universal/api/api_service.dart';
import 'package:ss_universal/shared_pref/shared_pref_helper.dart';

DateTime? lastRecordedTime;
const Duration updateInterval = Duration(minutes: 1);
final Battery _battery = Battery();

// const MethodChannel _batteryChannel = MethodChannel('battery_channel');

// Future<int?> getBatteryLevel() async {
//   try {
//     final int battery = await _batteryChannel.invokeMethod('getBatteryLevel');
//     return battery;
//   } catch (_) {
//     return null;
//   }
// }

Future<int?> getBatteryLevelSafe() async {
  try {
    return await _battery.batteryLevel;
  } catch (e) {
    return null;
  }
}

StreamSubscription<Position>? positionSub;
bool _locationStreamPaused = false;

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  WidgetsFlutterBinding.ensureInitialized();

  await service.configure(
    iosConfiguration: IosConfiguration(
      autoStart: false,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      isForegroundMode: true,
      autoStart: false,
    ),
  );
}

Future<bool> hasNetwork() async {
  try {
    final result = await InternetAddress.lookup(
      'google.com',
    ).timeout(const Duration(seconds: 3));
    return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
  } catch (_) {
    return false;
  }
}

void _startLocationStream(ServiceInstance service) {
  positionSub?.cancel();

  final locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.bestForNavigation,
    distanceFilter: 0,
  );

  positionSub = Geolocator.getPositionStream(locationSettings: locationSettings)
      .listen(
        (position) async {
          _locationStreamPaused = false;

          final now = DateTime.now();

          if (lastRecordedTime == null ||
              now.difference(lastRecordedTime!) >= updateInterval) {
            lastRecordedTime = now;

            final online = await hasNetwork();
            if (!online) {
              if (service is AndroidServiceInstance) {
                service.setForegroundNotificationInfo(
                  title: "Spotless Solutions – Internet OFF",
                  content: "Please turn ON mobile data or WiFi",
                );
              }
              return;
            }

            final userSrNo = await SharedPrefHelper.getUserId();
            if (userSrNo != null) {
              final battery = await getBatteryLevelSafe();

              await ApiService.sendLiveLocation(
                userSrNo: userSrNo,
                lat: position.latitude.toString(),
                lng: position.longitude.toString(),
                batteryPercentage: battery?.toString() ?? "0",
              );

              debugPrint(
                "Location sent - "
                "Lat=${position.latitude}, "
                "Lng=${position.longitude}, "
                "Battery=${battery ?? 'NA'}%",
              );
            }

            // final battery = await getBatteryLevelSafe();
            // debugPrint("Battery Level = $battery%");

            // final batteryText = battery != null ? " | Battery: $battery%" : "";

            if (service is AndroidServiceInstance) {
              service.setForegroundNotificationInfo(
                title: "Spotless Solutions – Attendance Active",
                content: "Welcome to Spotless Solutions",
                // "$batteryText",
              );
            }
          }
        },
        onError: (_) {
          _locationStreamPaused = true;
        },
      );
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  if (service is AndroidServiceInstance) {
    service.setAsForegroundService();
    service.setForegroundNotificationInfo(
      title: "Spotless Solutions Active",
      content: "Location tracking is running",
    );
  }

  //Start tracking (ONLY place that starts stream)
  service.on('startTracking').listen((event) async {
    if (service is AndroidServiceInstance) {
      service.setAsForegroundService();
      service.setForegroundNotificationInfo(
        title: "Spotless Solutions – Attendance Active",
        content: "Live location tracking is running",
      );
    }
    _startLocationStream(service);
  });

  //Stop tracking
  service.on('stopTracking').listen((event) async {
    await positionSub?.cancel();
    service.stopSelf();
  });

  //Watchdog: GPS + dead stream recovery
  Timer.periodic(const Duration(seconds: 20), (timer) async {
    final gpsEnabled = await Geolocator.isLocationServiceEnabled();

    if (!gpsEnabled) {
      if (service is AndroidServiceInstance) {
        service.setForegroundNotificationInfo(
          title: "Spotless Solutions – GPS OFF",
          content: "Please turn ON location services",
        );
      }
      return;
    }

    if (_locationStreamPaused) {
      _startLocationStream(service);
    }
  });
}
