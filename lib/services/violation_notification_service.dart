// lib/services/violation_notification_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_role.dart';
import 'fcm_token_service.dart';

class ViolationNotificationService {
  final FCMTokenService _fcmTokenService = FCMTokenService();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Mengirim notifikasi FCM ke siswa saat pelanggaran di-approve oleh admin
  Future<void> sendViolationApprovalNotification({
    required String studentId,
    required String studentName,
    required String violationDescription,
    required int violationPoints,
  }) async {
    try {
      // Dapatkan informasi siswa untuk memastikan role adalah student
      final userDoc = await _db.collection('users').doc(studentId).get();
      if (!userDoc.exists) {
        print('⚠️ Student not found: $studentId');
        return;
      }

      final userData = userDoc.data()!;
      final userRole = UserRoleExt.fromString(userData['role']?.toString());
      
      // Hanya kirim notifikasi untuk siswa
      if (userRole != UserRole.student) {
        print('ℹ️ User is not a student, notification not sent');
        return;
      }

      // Dapatkan FCM token siswa
      final fcmToken = await _fcmTokenService.getTokenForUser(studentId);
      
      if (fcmToken == null || fcmToken.isEmpty) {
        print('⚠️ No FCM token found for student: $studentId');
        return;
      }

      // Buat pesan notifikasi
      const String title = 'Pelanggaran Disetujui';
      final String body = 'Pelanggaran Anda: "$violationDescription" telah disetujui oleh admin. Poin: $violationPoints';

      // Kirim notifikasi menggunakan FCM REST API
      // Catatan: Untuk production, lebih baik menggunakan Cloud Functions
      // karena server key tidak boleh disimpan di client
      await _sendFCMNotification(
        token: fcmToken,
        title: title,
        body: body,
        data: {
          'type': 'violation_approved',
          'studentId': studentId,
          'violationDescription': violationDescription,
          'violationPoints': violationPoints.toString(),
        },
      );

      print('✅ Notification sent to student: $studentName ($studentId)');
    } catch (e) {
      print('❌ Error sending notification: $e');
    }
  }

  /// Mengirim notifikasi FCM menggunakan HTTP API
  /// Catatan: Untuk production, sebaiknya menggunakan Cloud Functions
  /// karena server key tidak boleh disimpan di client
  Future<void> _sendFCMNotification({
    required String token,
    required String title,
    required String body,
    Map<String, String>? data,
  }) async {
    // TODO: Ganti dengan server key dari Firebase Console
    // Project Settings > Cloud Messaging > Server Key
    // ATAU gunakan Cloud Functions untuk mengirim notifikasi
    const String serverKey = 'YOUR_SERVER_KEY_HERE';

    if (serverKey == 'YOUR_SERVER_KEY_HERE') {
      print('⚠️ FCM Server Key not configured. Notification not sent.');
      print('💡 Please configure server key or use Cloud Functions to send notifications');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'key=$serverKey',
        },
        body: jsonEncode({
          'to': token,
          'notification': {
            'title': title,
            'body': body,
            'sound': 'default',
          },
          'data': data ?? {},
          'priority': 'high',
        }),
      );

      if (response.statusCode == 200) {
        print('✅ FCM notification sent successfully');
      } else {
        print('❌ FCM notification failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Error sending FCM notification: $e');
    }
  }
}

