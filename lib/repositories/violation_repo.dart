// // lib/repositories/violation_repo.dart
// import '../models/violation.dart';
// import '../models/violation_status.dart';
// import '../models/evidence_type.dart';

// class ViolationRepository {
//   final List<Violation> _violations = [];

//   Future<List<Violation>> getViolationsByStudent(String studentId) async {
//     await Future.delayed(Duration(milliseconds: 300));
//     return _violations.where((v) => v.studentId == studentId).toList();
//   }

//   Future<List<Violation>> getPendingViolations() async {
//     await Future.delayed(Duration(milliseconds: 300));
//     return _violations.where((v) => v.status == ViolationStatus.pending).toList();
//   }

//   Future<List<Violation>> getViolationsByClass(String kelas) async {
//     await Future.delayed(Duration(milliseconds: 300));
//     return _violations.where((v) => v.kelas == kelas).toList();
//   }

//   Future<void> addViolation(Violation violation) async {
//     _violations.add(violation);
//   }

//   Future<void> approveViolation(String id) async {
//     final index = _violations.indexWhere((v) => v.id == id);
//     if (index != -1) {
//       final old = _violations[index];
//       _violations[index] = Violation(
//         id: old.id,
//         studentId: old.studentId,
//         studentName: old.studentName,
//         kelas: old.kelas,
//         points: old.points,
//         description: old.description,
//         evidenceType: old.evidenceType,
//         evidenceUrl: old.evidenceUrl,
//         createdBy: old.createdBy,
//         createdAt: old.createdAt,
//         status: ViolationStatus.approved,
//       );
//     }
//   }

//   Future<void> rejectViolation(String id) async {
//     final index = _violations.indexWhere((v) => v.id == id);
//     if (index != -1) {
//       final old = _violations[index];
//       _violations[index] = Violation(
//         id: old.id,
//         studentId: old.studentId,
//         studentName: old.studentName,
//         kelas: old.kelas,
//         points: old.points,
//         description: old.description,
//         evidenceType: old.evidenceType,
//         evidenceUrl: old.evidenceUrl,
//         createdBy: old.createdBy,
//         createdAt: old.createdAt,
//         status: ViolationStatus.rejected,
//       );
//     }
//   }
// }
