// lib/pages/shared/student_detail_page.dart
import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../models/violation.dart';
import '../../models/violation_status.dart';
import '../../services/violation_service.dart';

class StudentDetailPage extends StatefulWidget {
  final User student;
  const StudentDetailPage({super.key, required this.student});

  @override
  State<StudentDetailPage> createState() => _StudentDetailPageState();
}

class _StudentDetailPageState extends State<StudentDetailPage> {
  final _violationService = ViolationService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Detail Murid")),
      body: Column(
        children: [
          ListTile(
            title: Text(
              widget.student.name,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            subtitle: Text("Kelas: ${widget.student.kelas}"),
          ),
          Divider(),
          Expanded(
            child: StreamBuilder<List<Violation>>(
              stream: _violationService.getViolationsForStudent(
                widget.student.id,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final violations = snapshot.data ?? [];
                final totalPoints = violations.fold<int>(
                  0,
                  (sum, v) => sum + v.points,
                );
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        "Total Poin Pelanggaran: $totalPoints",
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                    const Divider(),
                    Expanded(
                      child: ListView.builder(
                        itemCount: violations.length,
                        itemBuilder: (context, i) {
                          final v = violations[i];
                          return ListTile(
                            title: Text(v.description),
                            subtitle: Text(
                              "Poin: ${v.points} | Status: ${v.status.label}",
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
