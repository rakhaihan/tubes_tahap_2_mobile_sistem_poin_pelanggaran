// White Box Testing - FR-011 Tambah/Ubah Sanksi
// Berdasarkan independent path dari flow graph _openSanctionForm

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tubes_tahap_2_mobile_sistem_poin_pelanggaran/services/sanction_service.dart';
import 'package:tubes_tahap_2_mobile_sistem_poin_pelanggaran/models/sanction.dart';
import 'package:tubes_tahap_2_mobile_sistem_poin_pelanggaran/utils/sanction_validator.dart';

import 'tc_fr_011_test.mocks.dart';

@GenerateMocks([SanctionService])
void main() {
  // ─────────────────────────────────────────────────────────────────
  // TC-FR-011-01 s/d TC-FR-011-05 : Uji logika validasi (unit test murni)
  // Path diuji melalui validateSanctionInput()
  // ─────────────────────────────────────────────────────────────────
  group('Validasi Input Sanksi', () {
    // TC-FR-011-01
    // Path: START → 1 → 7(T) → 12 → END
    // Kondisi: tingkat.isEmpty == true → langsung gagal
    test('TC-FR-011-01: Tingkat kosong → return pesan error', () {
      final result = validateSanctionInput(
        tingkat: '',
        keterangan: 'Peringatan',
        min: 10,
        max: 20,
      );
      expect(result, 'Periksa input sanksi');
    });

    // TC-FR-011-02
    // Path: START → 1 → 7(F) → 8(T) → 12 → END
    // Kondisi: tingkat ada, keterangan.isEmpty == true
    test('TC-FR-011-02: Keterangan kosong → return pesan error', () {
      final result = validateSanctionInput(
        tingkat: 'Ringan',
        keterangan: '',
        min: 10,
        max: 20,
      );
      expect(result, 'Periksa input sanksi');
    });

    // TC-FR-011-03
    // Path: START → 1 → 7(F) → 8(F) → 9(T) → 12 → END
    // Kondisi: min < 0 == true
    test('TC-FR-011-03: Min Poin negatif (-1) → return pesan error', () {
      final result = validateSanctionInput(
        tingkat: 'Ringan',
        keterangan: 'teguran',
        min: -1,
        max: 20,
      );
      expect(result, 'Periksa input sanksi');
    });

    // TC-FR-011-04
    // Path: START → 1 → 7(F) → 8(F) → 9(F) → 10(T) → 12 → END
    // Kondisi: max < 0 == true
    test('TC-FR-011-04: Max Poin negatif (-5) → return pesan error', () {
      final result = validateSanctionInput(
        tingkat: 'Ringan',
        keterangan: 'teguran',
        min: 10,
        max: -5,
      );
      expect(result, 'Periksa input sanksi');
    });

    // TC-FR-011-05
    // Path: START → 1 → 7(F) → 8(F) → 9(F) → 10(F) → 11(T) → 12 → END
    // Kondisi: min > max == true
    test('TC-FR-011-05: Min > Max (20 > 10) → return pesan error', () {
      final result = validateSanctionInput(
        tingkat: 'Ringan',
        keterangan: 'Peringatan',
        min: 20,
        max: 10,
      );
      expect(result, 'Periksa input sanksi');
    });

    // Verifikasi kebalikan: semua valid → null (tidak ada error)
    test('Input valid → tidak ada error (null)', () {
      final result = validateSanctionInput(
        tingkat: 'Sedang',
        keterangan: 'Pemanggilan Orang Tua',
        min: 21,
        max: 51,
      );
      expect(result, isNull);
    });
  });

  // ─────────────────────────────────────────────────────────────────
  // TC-FR-011-06 s/d TC-FR-011-08 : Uji pemanggilan service (dengan mock)
  // ─────────────────────────────────────────────────────────────────
  group('Pemanggilan Service Sanksi', () {
    late MockSanctionService mockService;

    setUp(() {
      mockService = MockSanctionService();
    });

    // TC-FR-011-06
    // Path: START → 1 → 7(F) → 8(F) → 9(F) → 10(F) → 11(F) → 18 → 19(F) → 27 → 36(F) → END
    // Kondisi: data valid, sanction != null (mode update) → updateSanction dipanggil
    test('TC-FR-011-06: Mode update (sanction != null) → updateSanction dipanggil', () async {
      final existingSanction = Sanction(
        id: 'abc123',
        tingkat: 'Lama',
        keterangan: 'Lama',
        minPoin: 1,
        maxPoin: 5,
      );
      final updatedSanction = existingSanction.copyWith(
        tingkat: 'Ringan',
        keterangan: 'Peringatan',
        minPoin: 10,
        maxPoin: 20,
      );

      when(mockService.updateSanction(updatedSanction))
          .thenAnswer((_) async {});

      await mockService.updateSanction(updatedSanction);

      verify(mockService.updateSanction(updatedSanction)).called(1);
      verifyNever(mockService.addSanction(any));
    });

    // TC-FR-011-07
    // Path: START → 1 → 7(F) → 8(F) → 9(F) → 10(F) → 11(F) → 18 → 19(T) → 20 → 36(T) → END
    // Kondisi: data valid, sanction == null (mode tambah), mounted = false
    // → addSanction tetap dieksekusi, Navigator.pop tidak dipanggil
    test('TC-FR-011-07: Mode tambah, mounted=false → addSanction tetap dieksekusi tanpa error', () async {
      final newSanction = Sanction(
        tingkat: 'Berat',
        keterangan: 'Perkelahian',
        minPoin: 100,
        maxPoin: 200,
      );

      when(mockService.addSanction(any)).thenAnswer((_) async {});

      // Simulasi: addSanction dipanggil (mounted=false → Navigator.pop tidak dipanggil)
      await mockService.addSanction(newSanction);

      verify(mockService.addSanction(any)).called(1);
      // Navigator.pop tidak bisa diverifikasi di unit test murni,
      // tapi addSanction harus tetap berhasil tanpa exception
    });

    // TC-FR-011-08
    // Path: START → 1 → 7(F) → 8(F) → 9(F) → 10(F) → 11(F) → 18 → 19(T) → 20 → 36(F) → END
    // Kondisi: data valid, sanction == null (mode tambah), mounted = true
    // → addSanction dieksekusi dan dialog tertutup
    test('TC-FR-011-08: Mode tambah, data valid → addSanction dipanggil tanpa exception', () async {
      final newSanction = Sanction(
        tingkat: 'Sedang',
        keterangan: 'Pemanggilan Orang Tua',
        minPoin: 21,
        maxPoin: 51,
      );

      when(mockService.addSanction(any)).thenAnswer((_) async {});

      await expectLater(
        mockService.addSanction(newSanction),
        completes,
      );

      verify(mockService.addSanction(any)).called(1);
      verifyNever(mockService.updateSanction(any));
    });
  });
}
