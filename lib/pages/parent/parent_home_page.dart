import 'package:flutter/material.dart';

import '../../models/user.dart';
import '../../models/violation.dart';
import '../../models/violation_status.dart';
import '../../services/user_service.dart';
import '../../services/violation_service.dart';

class ParentHomePage extends StatefulWidget {
  final User user;
  const ParentHomePage({super.key, required this.user});

  @override
  State<ParentHomePage> createState() => _ParentHomePageState();
}

class _ParentHomePageState extends State<ParentHomePage> {
  final UserService _userService = UserService();
  final ViolationService _violationService = ViolationService();

  @override
  Widget build(BuildContext context) {
    final linkedStudentId = widget.user.linkedStudentId ?? '';
    if (linkedStudentId.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text('Akun orang tua belum terhubung ke siswa.'),
        ),
      );
    }

    return FutureBuilder<User?>(
      future: _userService.getStudentById(linkedStudentId),
      builder: (context, studentSnap) {
        if (studentSnap.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (studentSnap.hasError) {
          return Scaffold(
            body: Center(child: Text('Gagal memuat data siswa: ${studentSnap.error}')),
          );
        }

        final student = studentSnap.data;
        if (student == null) {
          return const Scaffold(
            body: Center(child: Text('Data siswa terkait tidak ditemukan.')),
          );
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Pelanggaran Anak')),
          body: StreamBuilder<List<Violation>>(
            stream: _violationService.getViolationsForStudent(linkedStudentId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final violations = snapshot.data ?? [];
              final approved = violations
                  .where((v) => v.status == ViolationStatus.approved)
                  .toList();
              final totalPoints = approved.fold<int>(0, (sum, v) => sum + v.points);

              return Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    color: Colors.indigo.shade50,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Siswa: ${student.name}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text('Kelas: ${student.kelas ?? '-'}'),
                        Text('Total poin disetujui: $totalPoints'),
                      ],
                    ),
                  ),
                  Expanded(
                    child: violations.isEmpty
                        ? const Center(
                            child: Text('Belum ada pelanggaran untuk siswa ini.'),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(8),
                            itemCount: violations.length,
                            itemBuilder: (context, index) {
                              final v = violations[index];
                              return Card(
                                child: ListTile(
                                  leading: Icon(
                                    v.status == ViolationStatus.approved
                                        ? Icons.check_circle
                                        : v.status == ViolationStatus.rejected
                                            ? Icons.cancel
                                            : Icons.pending,
                                    color: v.status == ViolationStatus.approved
                                        ? Colors.green
                                        : v.status == ViolationStatus.rejected
                                            ? Colors.red
                                            : Colors.orange,
                                  ),
                                  title: Text(v.description),
                                  subtitle: Text(
                                    'Poin: ${v.points} • Status: ${v.status.label}',
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
