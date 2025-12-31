import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ss_universal/screens/login/login_screen.dart';
import 'package:ss_universal/screens/qr_alarm_screen.dart';
import 'package:ss_universal/screens/splash/splash_screen.dart';
import 'package:ss_universal/utils/background/alarm/hourly_alarm_helper.dart';
import 'package:ss_universal/utils/background/location_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeService();

  await initNotifications();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(411, 923),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) => MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {'/': (context) => const SplashScreen()},
      ),
    );
  }
}
