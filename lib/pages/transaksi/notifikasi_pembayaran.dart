import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin notifications =
  FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    // Inisialisasi ikon bawaan (menggunakan ikon bawaan aplikasi @mipmap/ic_launcher)
    const android = AndroidInitializationSettings("@mipmap/ic_launcher");

    const settings = InitializationSettings(
      android: android,
    );

    await notifications.initialize(settings);

    // Meminta izin notifikasi khusus untuk Android 13 (API 33) ke atas secara aman
    await notifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static Future<void> showPaymentSuccess() async {
    await notifications.show(
      0, // ID Unik Notifikasi
      "Pembayaran Berhasil 🎉",
      "Premium MangaZone berhasil diaktifkan.",
      const NotificationDetails(
        android: AndroidNotificationDetails(
          "premium_channel", // Channel ID wajib unik
          "Premium Notification", // Channel Name terlihat di pengaturan sistem HP
          channelDescription: "Notifikasi terkait status transaksi premium pengguna",
          importance: Importance.max,
          priority: Priority.high,
          styleInformation: BigTextStyleInformation(''), // Memastikan teks panjang tidak terpotong
          playSound: true,
        ),
      ),
    );
  }
}