import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class Push {
  static final _fln = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    // --- Локальные уведомления (для отображения пуша при открытом приложении)
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _fln.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );

    try {
      // --- Firebase init (разное для Web и Mobile)
      await Firebase.initializeApp();

      final fm = FirebaseMessaging.instance;

      // --- Запрашиваем разрешение (особенно важно для iOS и Web)
      await fm.requestPermission();

      // --- Получение токена
      String? token;
      if (Platform.isAndroid || Platform.isIOS) {
        token = await fm.getToken();
      } else if (kIsWeb) {
        token = await fm.getToken(
          vapidKey:
              "ТВОЙ_PUBLIC_VAPID_KEY", // вставь из Firebase Console → Cloud Messaging
        );
      }

      print("🔑 FCM Token: $token");

      // --- Обработка сообщений в фоне (только mobile)
      FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);

      // --- Обработка входящих сообщений при активном приложении
      FirebaseMessaging.onMessage.listen((m) async {
        await _fln.show(
          0,
          m.notification?.title ?? 'Сообщение',
          m.notification?.body ?? '',
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'default',
              'General',
              importance: Importance.max,
              priority: Priority.high,
            ),
            iOS: DarwinNotificationDetails(),
          ),
        );
      });
    } catch (e) {
      print("⚠️ Firebase не настроен или ошибка: $e");
    }
  }

  // --- Обработчик фоновых сообщений (обязателен для Android/iOS)
  static Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
    print("📩 Получено в фоне: ${message.notification?.title}");
  }

  // --- Тестовое локальное уведомление
  static Future<void> sendTestNotification() async {
    await _fln.show(
      999,
      "Привет 👋",
      "Это тестовое уведомление (локальное)",
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'test_channel',
          'Test Notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }
}
