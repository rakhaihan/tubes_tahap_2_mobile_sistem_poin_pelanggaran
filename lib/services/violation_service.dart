import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/violation.dart';
import '../models/violation_status.dart';

class ViolationService {
  final _db = FirebaseFirestore.instance;

  Future<void> migrateCreatedAtToTimestamp() async {
    final snapshot = await _db.collection('violations').get();

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final createdAt = data['createdAt'];

      // Kalau masih string, ubah ke Timestamp
      if (createdAt is String) {
        try {
          final parsed = DateTime.tryParse(createdAt);
          if (parsed != null) {
            await doc.reference.update({
              'createdAt': Timestamp.fromDate(parsed),
            });
            print("Updated ${doc.id} → $parsed");
          }
        } catch (e) {
          print("Gagal parse createdAt di ${doc.id}: $e");
        }
      }
    }
  }

  /// Tambah pelanggaran baru
  Future<void> addViolation(Violation v) async {
    final doc = _db.collection('violations').doc(v.id);

    await doc.set({
      'id': v.id,
      'studentId': v.studentId,
      'studentName': v.studentName,
      'kelas': v.kelas,
      'points': v.points,
      'description': v.description,
      'evidenceType': v.evidenceType?.name,
      'evidenceUrl': v.evidenceUrl,
      'createdBy': v.createdBy,
      'createdAt': FieldValue.serverTimestamp(), // ✅ timestamp otomatis
      'status': v.status.name.isNotEmpty ? v.status.name : 'pending',
    });
  }

  /// Ambil pelanggaran milik murid tertentu
  Stream<List<Violation>> getViolationsForStudent(String studentId) {
    // Guard: jangan kirim stream kosong kalau studentId kosong
    if (studentId.isEmpty) {
      return const Stream<List<Violation>>.empty();
    }

    return _db
        .collection('violations')
        .where('studentId', isEqualTo: studentId) // penting: harus 'studentId'
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) {
          return snap.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return Violation.fromJson(data);
          }).toList();
        });
  }

  /// Ambil pelanggaran berdasarkan kelas
  Stream<List<Violation>> getViolationsByClass(String kelas) {
    return _db
        .collection('violations')
        .where('kelas', isEqualTo: kelas)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(_mapSnapshot);
  }

  /// Approve pelanggaran
  Future<void> approveViolation(String violationId) async {
    await _db.collection('violations').doc(violationId).update({
      'status': ViolationStatus.approved.name,
      'approvedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Reject pelanggaran
  Future<void> rejectViolation(
    String violationId, {
    required String reason,
    required String rejectedBy,
  }) async {
    await _db.collection('violations').doc(violationId).update({
      'status': ViolationStatus.rejected.name,
      'rejectedAt': FieldValue.serverTimestamp(),
      'rejectedBy': rejectedBy,
      'rejectReason': reason,
    });
  }

  /// Ambil pelanggaran pending untuk admin BK
  Stream<List<Violation>> getPendingApproval() {
    return _db
        .collection('violations')
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(_mapSnapshot);
  }

  /// Ambil semua pelanggaran (rekap)
  Future<List<Violation>> fetchAll() async {
    final snapshot = await _db.collection('violations').get();
    return snapshot.docs
        .map((doc) => Violation.fromJson(doc.data()..['id'] = doc.id))
        .toList();
  }

  /// Helper untuk mapping snapshot
  List<Violation> _mapSnapshot(QuerySnapshot<Map<String, dynamic>> snapshot) {
    debugPrint('Docs ditemukan: ${snapshot.docs.length}');
    return snapshot.docs
        .map((d) => Violation.fromJson(d.data()..['id'] = d.id))
        .toList();
  }
}
