import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ss_universal/api/api_service.dart';
import 'package:ss_universal/shared_pref/shared_pref_helper.dart';

DateTime? lastRecordedTime;
const Duration updateInterval = Duration(minutes: 1);

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

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}

StreamSubscription<Position>? positionSub;

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  if (service is AndroidServiceInstance) {
    service.setAsForegroundService();
    service.setForegroundNotificationInfo(
      title: "SS Universal Active",
      content: "Location tracking is running",
    );
  }

  service.on('startTracking').listen((event) async {
    if (service is AndroidServiceInstance) {
      service.setAsForegroundService();
      service.setForegroundNotificationInfo(
        title: "SS Universal – Attendance Active",
        content: "Live location tracking is running",
      );
    }
  });

  positionSub =
      Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          distanceFilter: 0,
        ),
      ).listen((position) async {
        final now = DateTime.now();

        if (lastRecordedTime == null ||
            now.difference(lastRecordedTime!) >= updateInterval) {
          lastRecordedTime = now;

          final userSrNo = await SharedPrefHelper.getUserId();

          if (userSrNo != null) {
            await ApiService.sendLiveLocation(
              userSrNo: userSrNo,
              lat: position.latitude.toString(),
              lng: position.longitude.toString(),
            );
          }

          /// UPDATE FOREGROUND NOTIFICATION WITH LIVE LAT/LNG
          if (service is AndroidServiceInstance) {
            await service.setForegroundNotificationInfo(
              title: "SS Universal – Attendance Active",
              content:
                  "Lat: ${position.latitude.toStringAsFixed(5)}, "
                  "Lng: ${position.longitude.toStringAsFixed(5)}",
            );
          }
        }
      });

  service.on('stopTracking').listen((event) async {
    await positionSub?.cancel();
    service.stopSelf();
  });
}
