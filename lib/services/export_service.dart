import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';

import '../models/violation.dart';
import 'violation_service.dart';

class ExportService {
  ExportService({ViolationService? violationService})
      : _violationService = violationService ?? ViolationService();

  final ViolationService _violationService;

  Future<void> exportCSV({String? kelas}) async {
    final data = await _getData(kelas);
    final rows = <List<dynamic>>[
      ['Tanggal', 'Siswa', 'Kelas', 'Deskripsi', 'Poin', 'Status'],
      ...data.map(
        (v) => [
          v.createdAt.toIso8601String(),
          v.studentName,
          v.kelas,
          v.description,
          v.points,
          v.status.name,
        ],
      ),
    ];
    final csv = const ListToCsvConverter().convert(rows);
    debugPrint(csv);
  }

  Future<void> exportPDF({String? kelas}) async {
    final data = await _getData(kelas);
    final buffer = StringBuffer()
      ..writeln('Rekap Pelanggaran (PDF placeholder)')
      ..writeln('Total data: ${data.length}');
    for (final v in data) {
      buffer.writeln(
          '- ${v.createdAt.toIso8601String()} | ${v.studentName} | ${v.kelas} | ${v.description} (${v.points} poin)');
    }
    debugPrint(buffer.toString());
  }

  Future<List<Violation>> _getData(String? kelas) async {
    final all = await _violationService.fetchAll();
    if (kelas == null || kelas.isEmpty) return all;
    return all.where((v) => v.kelas == kelas).toList();
  }
}

