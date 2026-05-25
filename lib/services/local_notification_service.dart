// // lib/services/local_notification_service.dart

// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';

// class LocalNotificationService {
//   static final FlutterLocalNotificationsPlugin _notifications =
//       FlutterLocalNotificationsPlugin();

//   /// Inisialisasi local notifications
//   static Future<void> initialize() async {
//     // Android initialization settings
//     const AndroidInitializationSettings androidSettings =
//         AndroidInitializationSettings('@mipmap/ic_launcher');

//     // iOS initialization settings (optional, untuk iOS)
//     const DarwinInitializationSettings iosSettings =
//         DarwinInitializationSettings(
//       requestAlertPermission: true,
//       requestBadgePermission: true,
//       requestSoundPermission: true,
//     );

//     const InitializationSettings initSettings = InitializationSettings(
//       android: androidSettings,
//       iOS: iosSettings,
//     );

//     final bool? initialized = await _notifications.initialize(
//       initSettings,
//       onDidReceiveNotificationResponse: (NotificationResponse response) {
//         // Handle notification tap
//         print('📬 Notification tapped: ${response.payload}');
//       },
//     );

//     if (initialized != true) {
//       print('❌ Failed to initialize local notifications');
//       return;
//     }

//     // Buat notification channel untuk Android (wajib untuk Android 8.0+)
//     const AndroidNotificationChannel channel = AndroidNotificationChannel(
//       'high_importance_channel', // id
//       'High Importance Notifications', // name
//       description: 'This channel is used for important notifications.',
//       importance: Importance.max,
//       //priority: Priority.max,
//       playSound: true,
//       enableVibration: true,
//       enableLights: true,
//     );

//     final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
//         _notifications.resolvePlatformSpecificImplementation<
//             AndroidFlutterLocalNotificationsPlugin>();

//     if (androidPlugin != null) {
//       await androidPlugin.createNotificationChannel(channel);
//       print('✅ Android notification channel created');
//     } else {
//       print('❌ Failed to create Android notification channel');
//     }

//     print('✅ Local notifications initialized');
//   }

//   /// Menampilkan notifikasi local
//   static Future<void> showNotification({
//     required String title,
//     required String body,
//     Map<String, dynamic>? data,
//     int notificationId = 0,
//   }) async {
//     const AndroidNotificationDetails androidDetails =
//         AndroidNotificationDetails(
//       'high_importance_channel', // channel id (harus sama dengan channel yang dibuat)
//       'High Importance Notifications', // channel name
//       channelDescription: 'This channel is used for important notifications.',
//       importance: Importance.max,
//       priority: Priority.max,
//       showWhen: true,
//       playSound: true,
//       enableVibration: true,
//       enableLights: true,
//       visibility: NotificationVisibility.public,
//     );

//     const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
//       presentAlert: true,
//       presentBadge: true,
//       presentSound: true,
//     );

//     const NotificationDetails notificationDetails = NotificationDetails(
//       android: androidDetails,
//       iOS: iosDetails,
//     );

//     await _notifications.show(
//       notificationId,
//       title,
//       body,
//       notificationDetails,
//       payload: data != null ? data.toString() : null,
//     );

//     print('✅ Local notification displayed: $title');
//   }

//   /// Menampilkan notifikasi dari FCM message (untuk foreground)
//   static Future<void> showNotificationFromFCM(RemoteMessage message) async {
//     final notification = message.notification;
//     if (notification == null) return;

//     await showNotification(
//       title: notification.title ?? 'Notifikasi',
//       body: notification.body ?? '',
//       data: message.data,
//       notificationId: message.hashCode,
//     );
//   }

//   /// Test notification untuk memastikan sistem notifikasi lokal bekerja
//   static Future<void> showTestNotification() async {
//     await showNotification(
//       title: 'Test Notification',
//       body: 'Ini adalah notifikasi test untuk memastikan sistem bekerja',
//       notificationId: DateTime.now().millisecondsSinceEpoch,
//     );
//   }
// }
//

