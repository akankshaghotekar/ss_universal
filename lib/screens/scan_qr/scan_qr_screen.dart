import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:ss_universal/api/api_service.dart';
import 'package:ss_universal/shared_pref/shared_pref_helper.dart';
import 'package:ss_universal/utils/media_query.dart';

class ScanQrScreen extends StatefulWidget {
  const ScanQrScreen({super.key});

  @override
  State<ScanQrScreen> createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends State<ScanQrScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _isScanned = false;

  static const MethodChannel _alarmChannel = MethodChannel('alarm_channel');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isScanned) return;

    final barcode = capture.barcodes.first;
    if (barcode.rawValue == null) return;

    _isScanned = true;

    final String clientLocationSrNo = barcode.rawValue!.trim();

    try {
      // Get user ID
      final userSrNo = await SharedPrefHelper.getUserId();
      if (userSrNo == null) {
        _isScanned = false;
        return;
      }

      // Get current location
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Call QR location API
      final res = await ApiService.addBdeLocationQR(
        userSrNo: userSrNo,
        clientLocationSrNo: clientLocationSrNo,
        lat: position.latitude.toString(),
        lng: position.longitude.toString(),
      );

      // Only on SUCCESS → stop alarm
      if (res['status'] == 0) {
        await _alarmChannel.invokeMethod('stopAlarm');

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("QR scanned successfully")),
        );

        Future.delayed(const Duration(milliseconds: 800), () {
          if (!mounted) return;
          Navigator.pop(context, clientLocationSrNo);
        });
      } else {
        // API failed → alarm continues
        _isScanned = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message'] ?? "QR verification failed")),
        );
      }
    } catch (e) {
      _isScanned = false;
      debugPrint('QR scan error: $e');

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Something went wrong")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final h = MQ.height(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            /// APP BAR
            Container(
              height: 56.h,
              alignment: Alignment.center,
              child: Text(
                "Scan QR",
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),

            /// CAMERA VIEW
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  MobileScanner(controller: _controller, onDetect: _onDetect),

                  /// SCAN FRAME
                  Positioned(
                    child: Container(
                      width: 240.w,
                      height: 240.w,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.transparent),
                      ),
                      child: Stack(
                        children: [
                          _corner(top: 0, left: 0),
                          _corner(top: 0, right: 0),
                          _corner(bottom: 0, left: 0),
                          _corner(bottom: 0, right: 0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _corner({double? top, double? bottom, double? left, double? right}) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: 32.w,
        height: 32.w,
        decoration: BoxDecoration(
          border: Border(
            top: top != null
                ? const BorderSide(color: Colors.green, width: 4)
                : BorderSide.none,
            bottom: bottom != null
                ? const BorderSide(color: Colors.green, width: 4)
                : BorderSide.none,
            left: left != null
                ? const BorderSide(color: Colors.green, width: 4)
                : BorderSide.none,
            right: right != null
                ? const BorderSide(color: Colors.green, width: 4)
                : BorderSide.none,
          ),
        ),
      ),
    );
  }
}
