import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin notifications =
  FlutterLocalNotificationsPlugin();

  static Future init() async {
    const android = AndroidInitializationSettings("@mipmap/ic_launcher");

    const settings = InitializationSettings(
      android: android,
    );

    await notifications.initialize(settings);

    await notifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static Future showPaymentSuccess() async {
    await notifications.show(
      0,
      "Pembayaran Berhasil 🎉",
      "Premium MangaZone berhasil diaktifkan.",
      const NotificationDetails(
        android: AndroidNotificationDetails(
          "premium_channel",
          "Premium Notification",
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }
}