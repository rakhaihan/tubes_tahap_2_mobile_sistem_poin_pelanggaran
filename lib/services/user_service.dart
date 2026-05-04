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

  Future<User?> getUserById(String id) async {
    if (id.isEmpty) return null;
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

  /// Ambil murid berdasarkan email untuk proses tautkan akun orang tua.
  Future<User?> getStudentByEmail(String email) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail.isEmpty) return null;

    final snapshot = await _db
        .collection('users')
        .where('email', isEqualTo: normalizedEmail)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    final doc = snapshot.docs.first;
    final data = doc.data();
    final role = (data['role'] ?? '').toString().toLowerCase();
    if (role != 'student') return null;

    data['id'] = doc.id;
    return User.fromJson(data);
  }

  Stream<List<User>> streamAllStudents() {
    return _db
        .collection('users')
        .where('role', isEqualTo: 'student')
        .snapshots()
        .map((snapshot) {
          final students = snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return User.fromJson(data);
          }).toList();
          students.sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
          );
          return students;
        });
  }
}
