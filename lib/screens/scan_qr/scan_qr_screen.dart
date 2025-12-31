import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:ss_universal/utils/app_colors.dart';
import 'package:ss_universal/utils/media_query.dart';

class ScanQrScreen extends StatefulWidget {
  const ScanQrScreen({super.key});

  @override
  State<ScanQrScreen> createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends State<ScanQrScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _isScanned = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isScanned) return;

    final barcode = capture.barcodes.first;
    if (barcode.rawValue == null) return;

    _isScanned = true;

    final String qrValue = barcode.rawValue!;

    // 🔹 Handle scanned result here
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Scanned: $qrValue")));

    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      Navigator.pop(context, qrValue);
    });
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
                  color: Colors.black,
                ),
              ),
            ),

            /// CAMERA VIEW
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  /// CAMERA
                  MobileScanner(controller: _controller, onDetect: _onDetect),

                  /// GREEN SCAN FRAME
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

  /// GREEN CORNER UI
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
                ? BorderSide(color: Colors.green, width: 4)
                : BorderSide.none,
            bottom: bottom != null
                ? BorderSide(color: Colors.green, width: 4)
                : BorderSide.none,
            left: left != null
                ? BorderSide(color: Colors.green, width: 4)
                : BorderSide.none,
            right: right != null
                ? BorderSide(color: Colors.green, width: 4)
                : BorderSide.none,
          ),
        ),
      ),
    );
  }
}
