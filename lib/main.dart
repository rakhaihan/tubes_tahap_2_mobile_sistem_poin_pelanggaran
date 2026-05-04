// main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'firebase_options.dart';
import 'pages/login_page.dart';
import 'services/fcm_service.dart';
import 'background_message_handler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Firebase untuk semua service (Auth, Firestore, Storage, dll)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Setup background message handler (harus sebelum runApp)
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Setup foreground message handler untuk FCM
  FCMService.setupForegroundMessageHandler();

  // Inisialisasi FCM token setelah delay untuk memastikan plugin sudah ter-load
  Future.delayed(const Duration(seconds: 1), () async {
    try {
      await FCMService.initializeAndGetToken();
    } catch (e) {
      print('⚠️ Warning: FCM initialization failed: $e');
      print('💡 This might be normal if running on unsupported platform');
    }
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Catatan Pelanggaran (Flutter)',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: false,
        primarySwatch: Colors.indigo,
      ),
      home: const LoginPage(),
    );
  }
}