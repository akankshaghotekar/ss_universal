import 'package:permission_handler/permission_handler.dart';

Future<void> ensureNotificationPermission() async {
  final status = await Permission.notification.status;
  if (!status.isGranted) {
    await Permission.notification.request();
  }
}
