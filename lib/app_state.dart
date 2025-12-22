// lib/app_state.dart
import 'package:flutter/foundation.dart';

import 'models/violation.dart';
import 'services/violation_service.dart';

/// AppState sekarang berfungsi sebagai state global ringan
/// untuk menyimpan ringkasan/statistik yang diambil dari Firestore.
///
/// Tidak lagi menyimpan data master murid/sanksi di memori lokal,
/// karena itu sudah ditangani oleh Firestore + services.
class AppState extends ChangeNotifier {
  AppState._private();
  static final AppState instance = AppState._private();

  final ViolationService _violationService = ViolationService();

  bool _loadingSummary = false;
  int _totalViolations = 0;
  int _totalStudentsWithViolation = 0;
  List<Violation> _latestViolations = const [];

  bool get loadingSummary => _loadingSummary;
  int get totalViolations => _totalViolations;
  int get totalStudentsWithViolation => _totalStudentsWithViolation;
  List<Violation> get latestViolations => List.unmodifiable(_latestViolations);

  /// Muat ringkasan global pelanggaran sekali panggil.
  Future<void> loadSummary() async {
    _loadingSummary = true;
    notifyListeners();

    final all = await _violationService.fetchAll();
    _totalViolations = all.length;
    _totalStudentsWithViolation =
        all.map((v) => v.studentId).toSet().length;
    _latestViolations = all
        .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    if (_latestViolations.length > 5) {
      _latestViolations = _latestViolations.sublist(0, 5);
    }

    _loadingSummary = false;
    notifyListeners();
  }
}
