import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import 'package:ss_universal/screens/scan_qr/scan_qr_screen.dart';
import 'package:ss_universal/utils/animation_helper/animated_page_route.dart';
import 'package:ss_universal/utils/app_colors.dart';

import 'package:ss_universal/utils/common_drawer.dart';
import 'package:ss_universal/utils/media_query.dart';

class ScanHistoryScreen extends StatefulWidget {
  const ScanHistoryScreen({super.key});

  @override
  State<ScanHistoryScreen> createState() => _ScanHistoryScreenState();
}

class _ScanHistoryScreenState extends State<ScanHistoryScreen> {
  DateTime fromDate = DateTime.now();
  DateTime toDate = DateTime.now();

  bool showHistory = false;

  Future<void> _pickDate(bool isFrom) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isFrom ? fromDate : toDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );

    if (picked != null) {
      setState(() {
        if (isFrom) {
          fromDate = picked;
        } else {
          toDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MQ.width(context);
    final h = MQ.height(context);
    final df = DateFormat("dd/MM/yyyy");

    return Scaffold(
      backgroundColor: AppColor.background,

      /// DRAWER
      drawer: CommonDrawer(onClose: () => Navigator.pop(context)),

      body: SafeArea(
        child: Column(
          children: [
            /// APP BAR
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

                  /// SCAN QR BUTTON
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        AnimatedPageRoute(page: const ScanQrScreen()),
                      );
                    },

                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFC107),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        "Scan QR",
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: h * 0.02),

            /// TITLE
            Text(
              "Scan History",
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: AppColor.textPrimary,
              ),
            ),

            SizedBox(height: h * 0.025),

            /// FILTER CARD (ONLY DATES)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: w * 0.06),
              child: Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F4F7),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Column(
                  children: [
                    _dateField(
                      label: "From Date",
                      value: df.format(fromDate),
                      onTap: () => _pickDate(true),
                    ),
                    SizedBox(height: 12.h),
                    _dateField(
                      label: "To Date",
                      value: df.format(toDate),
                      onTap: () => _pickDate(false),
                    ),
                  ],
                ),
              ),
            ),

            /// VIEW BUTTON (OUTSIDE CONTAINER)
            SizedBox(height: 16.h),
            SizedBox(
              width: 100.w,
              height: 32.h,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    showHistory = true;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC107),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
                child: Text(
                  "View",
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
            ),

            SizedBox(height: h * 0.025),

            /// HISTORY LIST
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: w * 0.06),
                child: showHistory
                    ? ListView.builder(
                        itemCount: 3, // mock multiple records
                        itemBuilder: (context, index) {
                          return Container(
                            margin: EdgeInsets.only(bottom: 12.h),
                            padding: EdgeInsets.all(14.w),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF2F4F7),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text("Date: 05/09/2024"),
                                Divider(),
                                Text("Time: 10:45 AM"),
                                Divider(),
                                Text("Location: Nashik"),
                              ],
                            ),
                          );
                        },
                      )
                    : Container(
                        padding: EdgeInsets.all(14.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F4F7),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          "No records found",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// DATE FIELD WIDGET
  Widget _dateField({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        SizedBox(height: 6.h),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.black)),
            ),
            child: Row(
              children: [
                Text(value),
                const Spacer(),
                const Icon(Icons.calendar_today, size: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
