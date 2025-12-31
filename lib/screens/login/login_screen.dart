import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ss_universal/api/api_service.dart';
import 'package:ss_universal/screens/home_screen/home_screen.dart';
import 'package:ss_universal/shared_pref/shared_pref_helper.dart';
import 'package:ss_universal/utils/animation_helper/animated_page_route.dart';
import 'package:ss_universal/utils/app_colors.dart';
import 'package:ss_universal/utils/media_query.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final mobileController = TextEditingController();
  final otpController = TextEditingController();

  bool showOtp = false;
  bool isLoading = false;

  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _slide = Tween<Offset>(
      begin: const Offset(0, -0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  void _sendOtp() async {
    if (mobileController.text.length != 10) {
      _showMsg("Enter valid mobile number");
      return;
    }

    setState(() => isLoading = true);

    final res = await ApiService.sendOtp(mobileController.text);

    if (!mounted) return;

    setState(() => isLoading = false);

    if (res['status'] == 0) {
      setState(() => showOtp = true);
      _controller.forward();
    } else {
      _showMsg(res['message'] ?? "Failed to send OTP");
    }
  }

  void _login() async {
    if (otpController.text.isEmpty) {
      _showMsg("Enter OTP");
      return;
    }

    setState(() => isLoading = true);

    final res = await ApiService.login(
      mobile: mobileController.text,
      otp: otpController.text,
    );

    print("LOGIN RESPONSE => $res");

    if (!mounted) return;
    setState(() => isLoading = false);

    if (res['status'] == 0 && res['data'] != null && res['data'].isNotEmpty) {
      final user = res['data'][0];
      final userId = user['usersrno'];
      final userName = user['name'];

      await SharedPrefHelper.saveLogin(
        userId: userId,
        mobile: mobileController.text,
        name: userName,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        AnimatedPageRoute(page: const HomeScreen()),
      );
    } else {
      _showMsg(res['message'] ?? "Login failed");
    }
  }

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final w = MQ.width(context);
    final h = MQ.height(context);

    return Scaffold(
      backgroundColor: AppColor.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: w * 0.06),
          child: Column(
            children: [
              SizedBox(height: h * 0.06),

              /// LOGO
              Image.asset("assets/images/ss-universal-logo.png", height: 90.h),

              SizedBox(height: h * 0.05),

              /// MOBILE
              _inputField(
                controller: mobileController,
                hint: "Mobile Number",
                keyboard: TextInputType.phone,
              ),

              SizedBox(height: 16.h),

              /// OTP (Animated)
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: showOtp
                    ? FadeTransition(
                        opacity: _fade,
                        child: SlideTransition(
                          position: _slide,
                          child: _inputField(
                            controller: otpController,
                            hint: "OTP",
                            keyboard: TextInputType.number,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),

              SizedBox(height: 30.h),

              /// BUTTON
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          if (!showOtp) {
                            _sendOtp();
                          } else {
                            _login();
                          }
                        },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                  ),
                  child: isLoading
                      ? SizedBox(
                          height: 22.h,
                          width: 22.h,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          showOtp ? "LOGIN" : "Send OTP",
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
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required TextInputType keyboard,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      style: TextStyle(fontSize: 14.sp),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: AppColor.textHint, fontSize: 14.sp),
        filled: true,
        fillColor: AppColor.inputBg,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6.r),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
