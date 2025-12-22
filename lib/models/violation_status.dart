// lib/models/violation_status.dart

import 'package:flutter/material.dart';
enum ViolationStatus {
  pending,
  approved,
  rejected,
}

extension ViolationStatusExt on ViolationStatus {
  static ViolationStatus fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'approved':
        return ViolationStatus.approved;
      case 'rejected':
        return ViolationStatus.rejected;
      case 'pending':
      default:
        return ViolationStatus.pending;
    }
  }

  String get name {
    switch (this) {
      case ViolationStatus.approved:
        return 'approved';
      case ViolationStatus.rejected:
        return 'rejected';
      case ViolationStatus.pending:
        return 'pending';
    }
  }

  String get label {
    switch (this) {
      case ViolationStatus.approved:
        return 'Disetujui';
      case ViolationStatus.rejected:
        return 'Ditolak';
      case ViolationStatus.pending:
        return 'Menunggu';
    }
  }

  Color get color {
    switch (this) {
      case ViolationStatus.approved:
        return Colors.green;
      case ViolationStatus.rejected:
        return Colors.red;
      case ViolationStatus.pending:
        return Colors.orange;
    }
  }
}
