import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ss_universal/api/api_service.dart';
import 'package:ss_universal/shared_pref/shared_pref_helper.dart';
import 'package:ss_universal/utils/app_colors.dart';
import 'package:ss_universal/utils/background/battery_optimization_helper.dart';
import 'package:ss_universal/utils/common_drawer.dart';
import 'package:ss_universal/utils/media_query.dart';

class MarkAttendanceScreen extends StatefulWidget {
  const MarkAttendanceScreen({super.key});

  @override
  State<MarkAttendanceScreen> createState() => _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends State<MarkAttendanceScreen> {
  bool isMarking = false;
  bool isLoggingOut = false;

  Future<void> _markAttendance() async {
    if (isMarking) return;

    final ok = await _checkPermissions();
    if (!ok) return;

    setState(() => isMarking = true);

    final userSrNo = await SharedPrefHelper.getUserId();
    if (userSrNo == null) {
      setState(() => isMarking = false);
      return;
    }

    final res = await ApiService.markAttendance(userSrNo: userSrNo);

    if (!mounted) return;
    setState(() => isMarking = false);

    if (res['status'] == 0) {
      final service = FlutterBackgroundService();
      final isRunning = await service.isRunning();

      if (!isRunning) {
        await service.startService();
        await Future.delayed(const Duration(milliseconds: 800));
      }

      service.invoke('startTracking');

      _showMsg("Attendance marked & tracking started");
    } else {
      _showMsg(res['message'] ?? "Failed");
    }
  }

  Future<void> _dayLogOff() async {
    if (isLoggingOut) return;

    setState(() => isLoggingOut = true);

    final userSrNo = await SharedPrefHelper.getUserId();
    if (userSrNo == null) {
      setState(() => isLoggingOut = false);
      return;
    }

    final res = await ApiService.dayLogOff(userSrNo: userSrNo);

    if (!mounted) return;
    setState(() => isLoggingOut = false);

    if (res['status'] == 0) {
      final service = FlutterBackgroundService();
      service.invoke('stopTracking');

      _showMsg("Day logged off & tracking stopped");
    } else {
      _showMsg(res['message'] ?? "Failed");
    }
  }

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<bool> _checkPermissions() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      _showMsg("Location permission required");
      return false;
    }

    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      _showMsg("Please enable location services");
      return false;
    }

    return true;
  }

  Future<void> _showBatteryDialog() async {
    final brand = await BatteryOptimizationHelper.getBrand();

    String extra = '';
    if (brand.contains('xiaomi') || brand.contains('redmi')) {
      extra = '\n\nXiaomi: Battery Saver → No restrictions + Autostart';
    } else if (brand.contains('vivo')) {
      extra = '\n\nVivo: Battery → App battery management → No restrictions';
    } else if (brand.contains('realme')) {
      extra =
          '\n\nRealme: Battery → App battery usage → Allow background activity';
    }

    if (!mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Allow Background Tracking'),
        content: Text(
          'To track your location continuously during work hours, '
          'please allow battery usage as "No restrictions".$extra',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await BatteryOptimizationHelper.request();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _requestNotificationPermission() async {
    if (!Platform.isAndroid) return;

    final status = await Permission.notification.status;
    if (!status.isGranted) {
      await Permission.notification.request();
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _requestNotificationPermission();
      await _precheckPermissions();
    });
  }

  Future<void> _precheckPermissions() async {
    // Location
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      await Geolocator.requestPermission();
    }

    // GPS
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      await Geolocator.openLocationSettings();
    }

    // Battery optimization (dialog only once)
    final ignored = await BatteryOptimizationHelper.isIgnored();
    if (!ignored) {
      await _showBatteryDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MQ.width(context);
    final h = MQ.height(context);

    return Scaffold(
      backgroundColor: AppColor.background,

      /// DRAWER
      drawer: CommonDrawer(onClose: () => Navigator.pop(context)),

      body: SafeArea(
        child: Column(
          children: [
            /// TOP BAR
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: w * 0.04,
                vertical: h * 0.015,
              ),
              child: Row(
                children: [
                  /// MENU
                  Builder(
                    builder: (context) => InkWell(
                      onTap: () => Scaffold.of(context).openDrawer(),
                      child: const Icon(Icons.menu, size: 28),
                    ),
                  ),

                  const Spacer(),

                  /// LOGO
                  Image.asset(
                    "assets/images/ss-universal-logo.png",
                    height: 38.h,
                  ),

                  const Spacer(),
                ],
              ),
            ),

            SizedBox(height: h * 0.05),

            /// TITLE
            Text(
              "Mark Attendance",
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.w600,
                color: AppColor.textPrimary,
              ),
            ),

            SizedBox(height: h * 0.04),

            /// USER ICON
            Container(
              height: 90.h,
              width: 90.h,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFFFC107), // Yellow
              ),
              child: const Icon(
                Icons.person_outline,
                size: 48,
                color: Colors.black,
              ),
            ),

            SizedBox(height: h * 0.05),

            /// MARK ATTENDANCE BUTTON
            SizedBox(
              width: w * 0.7,
              height: 48.h,
              child: ElevatedButton(
                onPressed: _markAttendance,

                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3CCF5A), // Green
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
                child: isMarking
                    ? SizedBox(
                        height: 22.h,
                        width: 22.h,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        "Mark Attendance",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),

            SizedBox(height: h * 0.02),

            /// LOG OUT BUTTON
            SizedBox(
              width: w * 0.7,
              height: 48.h,
              child: ElevatedButton(
                onPressed: _dayLogOff,

                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0B7DB3), // Blue
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
                child: Text(
                  "Log out for the Day",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
