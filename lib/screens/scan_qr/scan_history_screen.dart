import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:ss_universal/api/api_service.dart';
import 'package:ss_universal/model/scan_history_model.dart';

import 'package:ss_universal/screens/scan_qr/scan_qr_screen.dart';
import 'package:ss_universal/shared_pref/shared_pref_helper.dart';
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
  DateTime selectedDate = DateTime.now();

  bool showHistory = false;
  bool loading = false;

  List<ScanHistoryModel> historyList = [];

  @override
  void initState() {
    super.initState();

    // Auto load history for today's date
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadHistory();
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _loadHistory() async {
    setState(() {
      loading = true;
      showHistory = true;
    });

    final userSrNo = await SharedPrefHelper.getUserId();
    if (userSrNo == null) return;

    final dateStr = DateFormat('dd-MM-yyyy').format(selectedDate);

    final list = await ApiService.getScanHistory(
      userSrNo: userSrNo,
      date: dateStr,
    );

    setState(() {
      historyList = list;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final w = MQ.width(context);
    final h = MQ.height(context);
    final df = DateFormat("dd/MM/yyyy");

    return Scaffold(
      backgroundColor: AppColor.background,
      drawer: CommonDrawer(onClose: () => Navigator.pop(context)),
      body: SafeArea(
        child: Column(
          children: [
            /// APP BAR (UNCHANGED)
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: w * 0.04,
                vertical: h * 0.015,
              ),
              child: Row(
                children: [
                  Builder(
                    builder: (context) => InkWell(
                      onTap: () => Scaffold.of(context).openDrawer(),
                      child: const Icon(Icons.menu, size: 28),
                    ),
                  ),
                  const Spacer(),
                  Image.asset(
                    "assets/images/ss-universal-logo.png",
                    height: 38.h,
                  ),
                  const Spacer(),
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

            Text(
              "Scan History",
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: AppColor.textPrimary,
              ),
            ),

            SizedBox(height: h * 0.025),

            /// SINGLE DATE PICKER
            Padding(
              padding: EdgeInsets.symmetric(horizontal: w * 0.06),
              child: Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F4F7),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: _dateField(
                  label: "Select Date",
                  value: df.format(selectedDate),
                  onTap: _pickDate,
                ),
              ),
            ),

            SizedBox(height: 16.h),

            SizedBox(
              width: 100.w,
              height: 32.h,
              child: ElevatedButton(
                onPressed: _loadHistory,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC107),
                ),
                child: const Text("View"),
              ),
            ),

            SizedBox(height: h * 0.025),

            /// HISTORY LIST
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: w * 0.06),
                child: !showHistory
                    ? const Center(
                        child: Text(
                          "No records found",
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : loading
                    ? const Center(child: CircularProgressIndicator())
                    : historyList.isEmpty
                    ? const Center(
                        child: Text(
                          "No records found",
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: historyList.length,
                        itemBuilder: (context, index) {
                          final item = historyList[index];
                          return Container(
                            margin: EdgeInsets.only(bottom: 12.h),
                            padding: EdgeInsets.all(14.w),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF2F4F7),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Client: ${item.clientName}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Divider(),
                                Text(
                                  "Time: ${DateFormat('hh:mm a').format(item.dateTime)}",
                                ),
                                const Divider(),
                                Text("User: ${item.userName}"),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// DATE FIELD WIDGET (REUSED – SAME STYLE AS YOUR APP)
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
