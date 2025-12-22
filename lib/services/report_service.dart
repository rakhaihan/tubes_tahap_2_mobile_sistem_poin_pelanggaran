// lib/services/report_service.dart

import '../models/violation.dart';
import 'violation_service.dart';

class ReportService {
  final ViolationService violationService;

  ReportService({required this.violationService});

  Future<List<Violation>> rekapPelanggaran({
    required String kelas,
    DateTime? from,
    DateTime? to,
  }) async {
    final list = await violationService
        .getViolationsByClass(kelas)
        .first; // get once (not stream)

    if (from == null && to == null) return list;

    final f = from ?? DateTime(1970);
    final t = to ?? DateTime.now();

    return list
        .where((v) => v.createdAt.isAfter(f) && v.createdAt.isBefore(t))
        .toList();
  }
}
