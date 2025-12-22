// lib/pages/teacher/rekap_semester_page.dart
import 'package:flutter/material.dart';
import '../../models/violation.dart';
import '../../services/violation_service.dart';

class RekapSemesterPage extends StatefulWidget {
  const RekapSemesterPage({super.key});

  @override
  State<RekapSemesterPage> createState() => _RekapSemesterPageState();
}

class _RekapSemesterPageState extends State<RekapSemesterPage> {
  final _violationService = ViolationService();
  List<Violation> violations = [];
  String semester = "2025-Ganjil";
  bool loading = false;

  @override
  void initState() {
    super.initState();
    loadSemester();
  }

  Future<void> loadSemester() async {
    setState(() => loading = true);
    final all = await _violationService.fetchAll();
    final range = _rangeForSemester(semester);
    violations = all
        .where(
          (v) =>
              v.createdAt.isAfter(range.start) &&
              v.createdAt.isBefore(range.end),
        )
        .toList();
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Rekap Pelanggaran Semester")),
      body: Column(
        children: [
          DropdownButton<String>(
            value: semester,
            items: [
              "2025-Ganjil",
              "2025-Genap",
              "2026-Ganjil",
              "2026-Genap",
            ].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            onChanged: (v) {
              setState(() => semester = v!);
              loadSemester();
            },
          ),
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: violations.length,
                    itemBuilder: (context, i) {
                      final v = violations[i];
                      return Card(
                        child: ListTile(
                          title: Text("${v.studentName} - ${v.description}"),
                          subtitle: Text(
                            "Poin: ${v.points} | Kelas: ${v.kelas}",
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  DateTimeRange _rangeForSemester(String value) {
    late DateTime start;
    late DateTime end;
    final parts = value.split("-");
    final year = int.tryParse(parts.first) ?? DateTime.now().year;
    final semesterName = parts.length > 1 ? parts[1].toLowerCase() : 'ganjil';
    if (semesterName == 'ganjil') {
      start = DateTime(year, 7, 1);
      end = DateTime(year, 12, 31, 23, 59, 59);
    } else {
      start = DateTime(year, 1, 1);
      end = DateTime(year, 6, 30, 23, 59, 59);
    }
    return DateTimeRange(start: start, end: end);
  }
}
