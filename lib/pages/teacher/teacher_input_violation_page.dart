// lib/pages/teacher/teacher_input_violation_page.dart
import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../models/evidence_type.dart';
import '../../models/violation.dart';
import '../../models/violation_status.dart';
import '../../models/violation_option.dart'; // import baru
import '../../services/file_upload_service.dart';
import '../../services/user_service.dart';
import '../../services/violation_service.dart';

class TeacherInputViolationPage extends StatefulWidget {
  final User teacher;

  const TeacherInputViolationPage({super.key, required this.teacher});

  @override
  State<TeacherInputViolationPage> createState() =>
      _TeacherInputViolationPageState();
}

class _TeacherInputViolationPageState extends State<TeacherInputViolationPage> {
  final _userService = UserService();
  final _violationService = ViolationService();
  final _fileUploadService = FileUploadService();

  User? selectedStudent;
  ViolationOption? selectedOption; // ganti dari TextField ke dropdown option
  final pointC = TextEditingController();

  EvidenceType? evidenceType;
  String? evidenceUrl;

  List<User> students = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    loadStudents();
    selectedOption =
        violationOptions.first; // default "Pilih Jenis Pelanggaran"
  }

  Future<void> loadStudents() async {
    final kelas = widget.teacher.kelas;
    if (kelas == null || kelas.isEmpty) {
      students = [];
      setState(() {});
      return;
    }
    final snapshot = await _userService.getStudentsByClass(kelas).first;
    students = snapshot;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tambah Rekap Pelanggaran")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            DropdownButton<User>(
              isExpanded: true,
              value: selectedStudent,
              hint: const Text("Pilih Murid"),
              items: students
                  .map((s) => DropdownMenuItem(value: s, child: Text(s.name)))
                  .toList(),
              onChanged: (v) => setState(() => selectedStudent = v),
            ),

            const SizedBox(height: 12),

            DropdownButton<ViolationOption>(
              isExpanded: true,
              value: selectedOption,
              items: violationOptions.map((opt) {
                return DropdownMenuItem(value: opt, child: Text(opt.label));
              }).toList(),
              onChanged: (opt) => setState(() => selectedOption = opt),
            ),

            // Tambahkan ini tepat di bawah dropdown
            if (selectedOption != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  "Poin: ${selectedOption!.points}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
              ),

            const SizedBox(height: 16),
            const Divider(),

            Text(
              "Upload Bukti:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            Row(
              children: [
                ElevatedButton(
                  onPressed: _pickImage,
                  child: const Text("Foto"),
                ),
              ],
            ),

            if (evidenceUrl != null)
              Padding(
                padding: const EdgeInsets.all(12),
                child: const Text("Bukti diunggah ✓"),
              ),

            const SizedBox(height: 24),

            loading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _submit,
                    child: const Text("Kirim"),
                  ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final url = await _fileUploadService.pickAndUploadImage();
    if (url == null) return;
    evidenceType = EvidenceType.image;
    evidenceUrl = url;
    setState(() {});
  }

  Future<void> _submit() async {
    if (selectedStudent == null || selectedOption == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Lengkapi semua data")));
      return;
    }

    if (selectedOption!.points == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pilih jenis pelanggaran yang valid")),
      );
      return;
    }

    setState(() => loading = true);

    final newId = DateTime.now().millisecondsSinceEpoch.toString();

    final v = Violation(
      id: newId,
      studentId: selectedStudent!.id,
      studentName: selectedStudent!.name,
      kelas: selectedStudent!.kelas ?? "",
      points: selectedOption!.points,
      description: selectedOption!.label,
      createdBy: widget.teacher.id,
      createdAt: DateTime.now(),
      status: ViolationStatus.pending,
      evidenceType: evidenceType,
      evidenceUrl: evidenceUrl,
    );

    await _violationService.addViolation(v);

    setState(() => loading = false);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pelanggaran berhasil dikirim")),
      );
      Navigator.pop(context);
    }
  }
}
