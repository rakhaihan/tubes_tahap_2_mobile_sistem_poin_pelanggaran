/// Memvalidasi input form sanksi.
/// Mengembalikan pesan error jika gagal, atau null jika valid.
String? validateSanctionInput({
  required String tingkat,
  required String keterangan,
  required int min,
  required int max,
}) {
  if (tingkat.isEmpty ||
      keterangan.isEmpty ||
      min < 0 ||
      max < 0 ||
      min > max) {
    return 'Periksa input sanksi';
  }
  return null;
}
