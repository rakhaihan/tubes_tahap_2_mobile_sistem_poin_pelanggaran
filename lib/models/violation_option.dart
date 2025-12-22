// lib/models/violation_option.dart
class ViolationOption {
  final String label;
  final int points;

  const ViolationOption(this.label, this.points);
}

const violationOptions = [
  ViolationOption('Pilih Jenis Pelanggaran', 0),
  ViolationOption('Membuang Sampah Sembarangan', 2),
  ViolationOption('Tidak Membawa Buku', 5),
  ViolationOption('Tidak Memakai Seragam Lengkap', 5),
  ViolationOption('Tidak Ikut Upacara', 10),
  ViolationOption('Terlambat Masuk', 10),
  ViolationOption('Keluar Lingkungan Sekolah', 10),
  ViolationOption('Membolos Tanpa Alasan', 15),
  ViolationOption('Merokok', 20),
  ViolationOption('Membawa Senjata Tajam', 20),
  ViolationOption('Berkelahi Dengan Siswa Lain', 25),
  ViolationOption('Merusak Fasilitas Sekolah', 25),
  ViolationOption('Mengonsumsi Narkotika', 30),
  ViolationOption('Melakukan Tindakan Asusila', 30),
];
