// lib/services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';
import '../models/user_role.dart';

class AuthService {
  AuthService._internal();
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;

  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? _currentUser;
  User? get currentUser => _currentUser;

  bool get isLoggedIn => _auth.currentUser != null;

  /// Restore user session on app start
  Future<bool> restoreUser() async {
    final fbUser = _auth.currentUser;
    if (fbUser == null) return false;

    final doc = await _db.collection('users').doc(fbUser.uid).get();
    if (!doc.exists) return false;

    _currentUser = User.fromJson(doc.data()!..['id'] = fbUser.uid);
    return true;
  }

  Future<User?> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    String? kelas,
  }) async {
    final result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await _db.collection('users').doc(result.user!.uid).set({
      'id': result.user!.uid,
      'name': name,
      'email': email,
      'role': role.raw,
      'kelas': kelas,
    });

    return User(
      id: result.user!.uid,
      name: name,
      email: email,
      role: role,
      kelas: kelas,
    );
  }

  /// Login
  Future<User?> login(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final doc = await _db.collection('users').doc(result.user!.uid).get();

      if (!doc.exists) throw Exception("User tidak ditemukan di Firestore.");

      _currentUser = User.fromJson(doc.data()!..['id'] = result.user!.uid);
      return _currentUser;
    } on fb.FirebaseAuthException catch (e) {
      // Handle Firebase Auth errors
      if (e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-email' ||
          e.code == 'invalid-credential') {
        throw Exception("Email atau password salah");
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  /// Logout
  Future<void> logout() async {
    _currentUser = null;
    await _auth.signOut();
  }

  // Role helpers
  bool isStudent() => _currentUser?.role == UserRole.student;
  bool isTeacher() => _currentUser?.role == UserRole.teacher;
  bool isAdmin() => _currentUser?.role == UserRole.admin;
}
