# tubes_tahap_2_mobile_sistem_poin_pelanggaran

Summarize:
Aplikasi ini adalah sistem manajemen pelanggaran siswa. Aplikasi ini dirancang untuk mengelola catatan pelanggaran siswa di lingkungan pendidikan dengan fitur multi-peran pengguna.

Fitur Utama:
Autentikasi Pengguna: Sistem login dengan Firebase Authentication untuk berbagai peran (Admin, Guru, Siswa)
Manajemen Pelanggaran: Guru dapat menginput pelanggaran siswa, Admin dapat menyetujui/menolak pelanggaran
Sistem Poin Sanksi: Pelacakan poin pelanggaran dan sanksi yang diterapkan
Dashboard: Halaman utama untuk setiap peran dengan informasi relevan
Laporan & Rekap: Fitur rekapitulasi pelanggaran per kelas/semester dan ekspor data
Notifikasi: Integrasi Firebase Cloud Messaging (FCM) untuk notifikasi real-time
Upload File: Dukungan upload bukti pelanggaran (gambar/dokumen)

Teknologi:
Frontend: Flutter dengan Material Design
Backend: Firebase (Authentication, Firestore, Storage, Cloud Functions, Messaging)
State Management: Provider pattern (berdasarkan struktur kode)
Platform: Cross-platform (Android, iOS, Web, Desktop)

Struktur Aplikasi:
Models: Data models untuk User, Student, Violation, Sanction, dll.
Services: Layer bisnis untuk autentikasi, pelanggaran, notifikasi, laporan, dll.
Pages: UI terpisah untuk setiap peran (Admin, Teacher, Student) plus halaman bersama
Widgets: Komponen reusable seperti bottom navigation
Aplikasi ini cocok untuk sekolah atau institusi pendidikan yang membutuhkan sistem digital untuk melacak dan mengelola pelanggaran siswa secara efisien.
