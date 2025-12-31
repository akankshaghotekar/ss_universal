import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:ss_universal/api/api_service.dart';
import 'package:ss_universal/model/completed_task_model.dart';
import 'package:ss_universal/screens/activities/client_list_screen.dart';
import 'package:ss_universal/shared_pref/shared_pref_helper.dart';
import 'package:ss_universal/utils/animation_helper/animated_page_route.dart';
import 'package:ss_universal/utils/app_colors.dart';
import 'package:ss_universal/utils/common_drawer.dart';
import 'package:ss_universal/utils/media_query.dart';

class ActivitiesScreen extends StatefulWidget {
  const ActivitiesScreen({super.key});

  @override
  State<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreen> {
  DateTime selectedDate = DateTime.now();

  List<CompletedTaskModel> completedTasks = [];
  bool isLoading = true;

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
        isLoading = true;
      });
      _loadTasks();
    }
  }

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final userSrNo = await SharedPrefHelper.getUserId();
    if (userSrNo == null) return;

    final formattedDate = DateFormat('dd-MM-yyyy').format(selectedDate);

    final data = await ApiService.getCompletedTaskList(
      userSrNo: userSrNo,
      date: formattedDate,
    );

    if (!mounted) return;

    setState(() {
      completedTasks = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final w = MQ.width(context);
    final h = MQ.height(context);

    final formattedDate = DateFormat('dd MMM yyyy').format(selectedDate);

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

                  /// ADD BUTTON
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        AnimatedPageRoute(page: const ClientsListScreen()),
                      );
                    },
                    child: Container(
                      height: 42.h,
                      width: 42.h,
                      decoration: BoxDecoration(
                        color: AppColor.addButton,
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: AppColor.addBorder, width: 1),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: h * 0.02),

            /// TITLE
            Text(
              "Activities",
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.w600,
                color: AppColor.textPrimary,
              ),
            ),

            SizedBox(height: h * 0.03),

            /// DATE ROW
            Padding(
              padding: EdgeInsets.symmetric(horizontal: w * 0.06),
              child: Row(
                children: [
                  Text(
                    "Date: $formattedDate",
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColor.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () => _pickDate(context),
                    child: Icon(
                      Icons.calendar_today_outlined,
                      size: 20.sp,
                      color: AppColor.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: h * 0.025),

            /// EMPTY STATE
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : completedTasks.isEmpty
                  ? Center(
                      child: Text(
                        "No records found",
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColor.textHint,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: w * 0.06),
                      itemCount: completedTasks.length,
                      itemBuilder: (context, index) {
                        final task = completedTasks[index];
                        return Container(
                          margin: EdgeInsets.only(bottom: 14.h),
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 12.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              /// LEFT INDICATOR
                              Container(
                                width: 4.w,
                                height: 60.h,
                                decoration: BoxDecoration(
                                  color: AppColor.primary,
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                              ),

                              SizedBox(width: 12.w),

                              /// CONTENT
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    /// CLIENT NAME
                                    Text(
                                      task.clientName,
                                      style: TextStyle(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w600,
                                        color: AppColor.textPrimary,
                                      ),
                                    ),

                                    SizedBox(height: 6.h),

                                    /// TASK NAME
                                    Text(
                                      task.taskName,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black87,
                                      ),
                                    ),

                                    SizedBox(height: 8.h),

                                    /// FOOTER ROW
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.person_outline,
                                          size: 14.sp,
                                          color: AppColor.textHint,
                                        ),
                                        SizedBox(width: 4.w),
                                        Text(
                                          task.userName,
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            color: AppColor.textHint,
                                          ),
                                        ),
                                        const Spacer(),
                                        Icon(
                                          Icons.check_circle,
                                          size: 14.sp,
                                          color: Colors.green,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
