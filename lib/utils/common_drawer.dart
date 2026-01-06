import 'package:flutter/material.dart';
import 'package:ss_universal/screens/activities/activities_screen.dart';
import 'package:ss_universal/screens/home_screen/home_screen.dart';
import 'package:ss_universal/screens/login/login_screen.dart';
import 'package:ss_universal/screens/mark_attendance/mark_attendance_screen.dart';
import 'package:ss_universal/screens/scan_qr/scan_history_screen.dart';
import 'package:ss_universal/screens/scan_qr/scan_qr_screen.dart';
import 'package:ss_universal/shared_pref/shared_pref_helper.dart';
import 'package:ss_universal/utils/media_query.dart';

class CommonDrawer extends StatelessWidget {
  final VoidCallback onClose;

  const CommonDrawer({super.key, required this.onClose});

  Future<void> _navigate(BuildContext context, String menuName) async {
    Navigator.pop(context);

    Widget? page;

    switch (menuName) {
      case "Home":
        page = HomeScreen();
        break;

      case "Mark Attendance":
        page = MarkAttendanceScreen();
        break;

      case "Activities":
        page = ActivitiesScreen();
        break;

      case "Scan QR":
        page = ScanHistoryScreen();
        break;

      case "Logout":
        await SharedPrefHelper.logout();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
        return;
    }

    if (page != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => page!),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MQ.width(context);
    final height = MQ.height(context);

    final List<String> menuItems = [
      "Home",
      "Mark Attendance",
      "Activities",
      "Scan QR",
    ];

    return Drawer(
      width: width * 0.78,
      backgroundColor: const Color(0xFFF5F8FC),
      child: SafeArea(
        child: Column(
          children: [
            SizedBox(height: height * 0.02),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.04),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: onClose,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 1.5),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: const Icon(Icons.close, size: 26),
                    ),
                  ),
                  SizedBox(width: width * 0.15),
                  Image.asset(
                    "assets/images/ss_spotless_sulution_logo.png",
                    width: width * 0.33,
                  ),
                ],
              ),
            ),

            SizedBox(height: height * 0.025),

            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: width * 0.035),
                itemCount: menuItems.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      InkWell(
                        onTap: () => _navigate(context, menuItems[index]),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: height * 0.018,
                            horizontal: width * 0.02,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                blurRadius: 2,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            menuItems[index],
                            style: TextStyle(
                              fontSize: width * 0.042,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: height * 0.004),
                    ],
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.035),
              child: InkWell(
                onTap: () => _navigate(context, "Logout"),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: height * 0.018),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "Logout",
                    style: TextStyle(
                      fontSize: width * 0.042,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: height * 0.06),
          ],
        ),
      ),
    );
  }
}
