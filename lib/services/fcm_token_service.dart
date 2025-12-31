// lib/services/fcm_token_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_role.dart';

class FCMTokenService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Menyimpan FCM token untuk user (hanya untuk siswa)
  Future<void> saveTokenForUser(String userId, String? token, UserRole role) async {
    if (role != UserRole.student) {
      // Hanya simpan token untuk siswa
      return;
    }

    if (token == null || token.isEmpty) {
      return;
    }

    try {
      await _db.collection('users').doc(userId).update({
        'fcmToken': token,
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
      });
      print('✅ FCM token saved for student: $userId');
    } catch (e) {
      print('❌ Error saving FCM token: $e');
    }
  }

  /// Mendapatkan FCM token untuk user
  Future<String?> getTokenForUser(String userId) async {
    try {
      final doc = await _db.collection('users').doc(userId).get();
      if (doc.exists) {
        final data = doc.data();
        return data?['fcmToken'] as String?;
      }
      return null;
    } catch (e) {
      print('❌ Error getting FCM token: $e');
      return null;
    }
  }

  /// Menghapus FCM token untuk user
  Future<void> deleteTokenForUser(String userId) async {
    try {
      await _db.collection('users').doc(userId).update({
        'fcmToken': FieldValue.delete(),
        'fcmTokenUpdatedAt': FieldValue.delete(),
      });
    } catch (e) {
      print('❌ Error deleting FCM token: $e');
    }
  }
}

