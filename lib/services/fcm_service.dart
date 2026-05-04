// lib/services/fcm_service.dart

import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';

class FCMService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// Menginisialisasi FCM dan mendapatkan token
  /// Token akan ditampilkan di console/CLI
  static Future<String?> initializeAndGetToken() async {
    try {
      // Request permission untuk notification (hanya iOS yang memerlukan)
      if (Platform.isIOS) {
        NotificationSettings settings = await _messaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );

        if (settings.authorizationStatus == AuthorizationStatus.authorized) {
          print('✅ User granted permission for notifications');
        } else if (settings.authorizationStatus ==
            AuthorizationStatus.provisional) {
          print('⚠️ User granted provisional permission');
        } else {
          print('❌ User declined or has not accepted notification permissions');
          return null;
        }
      } else {
        print('✅ Android platform - permissions not required');
      }

      // Mendapatkan FCM token
      String? token = await _messaging.getToken();

      if (token != null) {
        print('\n${'=' * 60}');
        print('📱 FCM TOKEN:');
        print('=' * 60);
        print(token);
        print('=' * 60);
        print(
          '\n💡 Gunakan token ini untuk mengirim notifikasi push ke perangkat ini\n',
        );

        // Listen untuk token refresh
        _messaging.onTokenRefresh.listen((newToken) {
          print('\n${'=' * 60}');
          print('🔄 FCM TOKEN REFRESHED:');
          print('=' * 60);
          print(newToken);
          print('=' * 60);
          print('\n💡 Token baru telah di-generate\n');
        });
      } else {
        print('❌ Gagal mendapatkan FCM token');
      }

      return token;
    } catch (e) {
      print('❌ Error getting FCM token: $e');
      return null;
    }
  }

  /// Mendapatkan token tanpa inisialisasi ulang
  static Future<String?> getToken() async {
    try {
      String? token = await _messaging.getToken();
      if (token != null) {
        print('\n${'=' * 60}');
        print('📱 FCM TOKEN:');
        print('=' * 60);
        print(token);
        print('=' * 60 + '\n');
      }
      return token;
    } catch (e) {
      print('❌ Error getting FCM token: $e');
      return null;
    }
  }

  /// Setup foreground message handler
  static void setupForegroundMessageHandler() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📬 Foreground message received: ${message.messageId}');
      print('Title: ${message.notification?.title}');
      print('Body: ${message.notification?.body}');
      print('Data: ${message.data}');
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('📬 Message opened from notification: ${message.messageId}');
      print('Title: ${message.notification?.title}');
      print('Body: ${message.notification?.body}');
      print('Data: ${message.data}');
    });
  }
}
