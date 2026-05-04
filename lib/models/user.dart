//lib/models/user.dart
import 'user_role.dart';
import 'package:flutter/foundation.dart';

class User {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? kelas; // Only for student & teacher
  final String? linkedStudentId; // Only for parent
  final String? linkedParentId; // Only for student

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.kelas,
    this.linkedStudentId,
    this.linkedParentId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    debugPrint(
      'Parsing user: ${json['name']} | kelas: ${json['kelas']} | role: ${json['role']}',
    );
    return User(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: UserRoleExt.fromString(json['role']?.toString() ?? ''),
      kelas: json['kelas']?.toString(),
      linkedStudentId: json['linkedStudentId']?.toString(),
      linkedParentId: json['linkedParentId']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "role": role.raw, // konsisten dengan fromString
    "kelas": kelas,
    "linkedStudentId": linkedStudentId,
    "linkedParentId": linkedParentId,
  };
}
