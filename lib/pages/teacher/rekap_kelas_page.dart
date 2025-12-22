// lib/pages/teacher/rekap_kelas_page.dart
import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../models/violation.dart';
import '../../models/violation_status.dart';
import '../../services/violation_service.dart';

class RekapKelasPage extends StatefulWidget {
  final User teacher;
  const RekapKelasPage({super.key, required this.teacher});

  @override
  State<RekapKelasPage> createState() => _RekapKelasPageState();
}

class _RekapKelasPageState extends State<RekapKelasPage> {
  final _violationService = ViolationService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Rekap Pelanggaran Kelas")),
      body: StreamBuilder<List<Violation>>(
        stream:
            _violationService.getViolationsByClass(widget.teacher.kelas ?? ""),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final violations = snapshot.data ?? [];
          if (violations.isEmpty) {
            return const Center(child: Text("Belum ada data pelanggaran."));
          }
          return ListView.builder(
            itemCount: violations.length,
            itemBuilder: (context, i) {
              final v = violations[i];
              return Card(
                child: ListTile(
                  title: Text("${v.studentName} - ${v.description}"),
                  subtitle:
                      Text("Poin: ${v.points} | Status: ${v.status.label}"),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
