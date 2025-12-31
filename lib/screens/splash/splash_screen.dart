import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ss_universal/screens/home_screen/home_screen.dart';
import 'package:ss_universal/screens/login/login_screen.dart';
import 'package:ss_universal/shared_pref/shared_pref_helper.dart';
import 'package:ss_universal/utils/app_colors.dart';
import 'package:ss_universal/utils/media_query.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 2), () async {
      final isLogged = await SharedPrefHelper.isLoggedIn();

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => isLogged ? const HomeScreen() : const LoginScreen(),
        ),
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MQ.width(context);
    final h = MQ.height(context);

    return Scaffold(
      backgroundColor: AppColor.background,
      body: SafeArea(
        child: Center(
          child: Image.asset(
            "assets/images/ss-universal-logo.png",
            width: w * 0.55,
          ),
        ),
      ),
    );
  }
}
