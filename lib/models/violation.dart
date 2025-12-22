// lib/models/violation.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'evidence_type.dart';
import 'violation_status.dart';

class Violation {
  final String id;
  final String studentId;
  final String studentName;
  final String? kelas; // kelas bisa null
  final int points;
  final String description;
  final EvidenceType? evidenceType;
  final String? evidenceUrl;
  final String createdBy;
  final DateTime createdAt;
  final ViolationStatus status;

  Violation({
    required this.id,
    required this.studentId,
    required this.studentName,
    this.kelas,
    required this.points,
    required this.description,
    this.evidenceType,
    this.evidenceUrl,
    required this.createdBy,
    required this.createdAt,
    required this.status,
  });

  factory Violation.fromJson(Map<String, dynamic> json) {
    final rawDate = json['createdAt'];
    DateTime created;
    if (rawDate is Timestamp) {
      created = rawDate.toDate();
    } else if (rawDate is String) {
      created = DateTime.tryParse(rawDate) ?? DateTime.now();
    } else {
      created = DateTime.now();
    }

    return Violation(
      id: json['id']?.toString() ?? '',
      studentId: json['studentId']?.toString() ?? '',
      studentName: json['studentName']?.toString() ?? '',
      kelas: json['kelas']?.toString() ?? '',
      points: (json['points'] is int)
          ? json['points']
          : int.tryParse('${json['points']}') ?? 0,
      description: json['description']?.toString() ?? '',
      evidenceType: EvidenceTypeExt.fromString(
        json['evidenceType']?.toString() ?? '',
      ),
      evidenceUrl: json['evidenceUrl']?.toString(), // aman null
      createdBy: json['createdBy']?.toString() ?? '',
      createdAt: created,
      status: ViolationStatusExt.fromString(json['status']?.toString()),
    );
  }
}
