import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin notifications =
    FlutterLocalNotificationsPlugin();

Future<void> initNotifications() async {
  const android = AndroidInitializationSettings('@mipmap/ic_launcher');
  const initSettings = InitializationSettings(android: android);

  await notifications.initialize(initSettings);

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'attendance_channel',
    'Hourly Attendance',
    description: 'Scan QR every hour',
    importance: Importance.max,
  );

  final androidPlugin = notifications
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  await androidPlugin?.createNotificationChannel(channel);
}

Future<void> showAttendanceNotification() async {
  const androidDetails = AndroidNotificationDetails(
    'attendance_channel',
    'Hourly Attendance',
    channelDescription: 'Scan QR every hour',
    importance: Importance.max,
    priority: Priority.high,
    playSound: true,
    enableVibration: true,
    fullScreenIntent: true,
  );

  await notifications.show(
    1001,
    'Attendance Reminder',
    'Scan QR code to mark hourly attendance',
    const NotificationDetails(android: androidDetails),
  );
}
