// lib/services/user_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user.dart';

class UserService {
  final _db = FirebaseFirestore.instance;

  /// Ambil semua murid berdasarkan kelas
  Stream<List<User>> getStudentsByClass(String kelas) {
    debugPrint("Query kelas: $kelas");
    return _db
        .collection('users')
        .where('role', isEqualTo: 'student')
        .where('kelas', isEqualTo: kelas)
        .snapshots()
        .map((snapshot) {
          debugPrint("Docs ditemukan: ${snapshot.docs.length}");
          return snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return User.fromJson(data);
          }).toList();
        });
  }

  /// Ambil detail murid berdasarkan ID
  Future<User?> getStudentById(String id) async {
    final doc = await _db.collection('users').doc(id).get();
    if (!doc.exists) return null;
    final data = doc.data()!..['id'] = doc.id;
    return User.fromJson(data);
  }

  /// Ambil semua guru
  Stream<List<User>> getTeachers() {
    return _db
        .collection('users')
        .where('role', isEqualTo: 'teacher')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return User.fromJson(data);
          }).toList();
        });
  }

  /// Ambil semua murid (once, bukan stream)
  Future<List<User>> fetchAllStudents() async {
    final snapshot = await _db
        .collection('users')
        .where('role', isEqualTo: 'student')
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return User.fromJson(data);
    }).toList();
  }
}
