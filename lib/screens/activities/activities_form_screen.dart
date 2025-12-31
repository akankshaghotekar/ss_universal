import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ss_universal/api/api_service.dart';
import 'package:ss_universal/model/task_model.dart';
import 'package:ss_universal/screens/activities/activities_screen.dart';
import 'package:ss_universal/shared_pref/shared_pref_helper.dart';

import 'package:ss_universal/utils/app_colors.dart';
import 'package:ss_universal/utils/common_drawer.dart';
import 'package:ss_universal/utils/media_query.dart';

class ActivityFormScreen extends StatefulWidget {
  final String clientSrNo;
  final String clientName;
  const ActivityFormScreen({
    super.key,
    required this.clientSrNo,
    required this.clientName,
  });

  @override
  State<ActivityFormScreen> createState() => _ActivityFormScreenState();
}

class _ActivityFormScreenState extends State<ActivityFormScreen> {
  List<TaskModel> activities = [];
  bool isLoading = true;

  final Set<int> selectedIndexes = {};
  bool isSubmitting = false;

  File? selectedImage;
  final ImagePicker _picker = ImagePicker();
  Future<void> _openCamera() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
    );

    if (photo != null) {
      setState(() {
        selectedImage = File(photo.path);
      });
    }
  }

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final data = await ApiService.getTaskList(clientSrNo: widget.clientSrNo);

    if (!mounted) return;

    setState(() {
      activities = data;
      isLoading = false;
    });
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
        child: SingleChildScrollView(
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
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.arrow_back),
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

              /// ACTIVITIES LIST
              Padding(
                padding: EdgeInsets.symmetric(horizontal: w * 0.06),
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                        children: List.generate(activities.length, (index) {
                          final isSelected = selectedIndexes.contains(index);

                          return InkWell(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  selectedIndexes.remove(index);
                                } else {
                                  selectedIndexes.add(index);
                                }
                              });
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 10.h),
                              child: Row(
                                children: [
                                  Container(
                                    height: 22.h,
                                    width: 22.h,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSelected
                                            ? AppColor.primary
                                            : Colors.grey,
                                        width: 2,
                                      ),
                                    ),
                                    child: isSelected
                                        ? Center(
                                            child: Icon(
                                              Icons.check,
                                              size: 14.sp,
                                              color: AppColor.primary,
                                            ),
                                          )
                                        : null,
                                  ),
                                  SizedBox(width: 14.w),
                                  Text(
                                    activities[index].taskName,
                                    style: TextStyle(
                                      fontSize: 15.sp,
                                      color: isSelected
                                          ? AppColor.primary
                                          : AppColor.textPrimary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
              ),

              SizedBox(height: h * 0.04),

              /// UPLOAD PHOTO
              Padding(
                padding: EdgeInsets.symmetric(horizontal: w * 0.06),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Upload Photo",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColor.textPrimary,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Container(
                      height: 110.h,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(4.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          /// IMAGE BOX
                          Container(
                            height: 110.h,
                            width: 110.h,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFF3DDC97),
                                width: 2,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: selectedImage == null
                                ? Text(
                                    "No image",
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: AppColor.textHint,
                                    ),
                                  )
                                : Image.file(
                                    selectedImage!,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                          ),

                          /// CAMERA CENTER AREA
                          Expanded(
                            child: Center(
                              child: InkWell(
                                onTap: _openCamera,
                                child: Icon(
                                  Icons.camera_alt,
                                  size: 32.sp,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: h * 0.05),

              /// SUBMIT BUTTON
              SizedBox(
                width: w * 0.45,
                height: 46.h,
                child: ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (selectedIndexes.isEmpty) {
                            _showMsg("Please select at least one activity");
                            return;
                          }

                          if (selectedImage == null) {
                            _showMsg("Please upload an image");
                            return;
                          }

                          setState(() => isSubmitting = true);

                          final userSrNo = await SharedPrefHelper.getUserId();
                          if (userSrNo == null) {
                            setState(() => isSubmitting = false);
                            return;
                          }

                          // Convert selected tasks to comma separated SRNO
                          final selectedTaskIds = selectedIndexes
                              .map((i) => activities[i].taskSrNo)
                              .join(',');

                          final res = await ApiService.addCompletedTask(
                            clientSrNo: widget.clientSrNo,
                            userSrNo: userSrNo,
                            taskSrNos: selectedTaskIds,
                            image: selectedImage!,
                          );

                          setState(() => isSubmitting = false);

                          if (res['status'] == 0) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ActivitiesScreen(),
                              ),
                              (route) => false,
                            );
                          } else {
                            _showMsg(res['message'] ?? "Failed");
                          }
                        },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  child: isSubmitting
                      ? SizedBox(
                          height: 22.h,
                          width: 22.h,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          "Submit",
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              SizedBox(height: h * 0.05),
            ],
          ),
        ),
      ),
    );
  }
}
