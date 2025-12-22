import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../services/user_service.dart';
import '../shared/sanksi_page.dart';
import 'teacher_input_violation_page.dart';

class TeacherHomePage extends StatefulWidget {
  final User user;
  const TeacherHomePage({super.key, required this.user});

  @override
  State<TeacherHomePage> createState() => _TeacherHomePageState();
}

class _TeacherHomePageState extends State<TeacherHomePage> {
  final UserService _userService = UserService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Daftar Siswa - ${widget.user.kelas ?? ''}"),
        actions: [
          IconButton(
            icon: const Icon(Icons.gavel),
            tooltip: 'Lihat Sanksi',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SanctionPage(user: widget.user),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Input Pelanggaran',
        child: const Icon(Icons.add),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TeacherInputViolationPage(teacher: widget.user),
          ),
        ),
      ),
      body: StreamBuilder<List<User>>(
        stream: _userService.getStudentsByClass(widget.user.kelas ?? ""),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final students = snapshot.data ?? [];
          if (students.isEmpty) {
            return const Center(
              child: Text("Belum ada murid pada kelas ini."),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: students.length,
            itemBuilder: (context, i) {
              final s = students[i];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.indigo.shade100,
                    child: Text(
                      s.name.isNotEmpty ? s.name[0].toUpperCase() : '?',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                  ),
                  title: Text(
                    s.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Kelas: ${s.kelas ?? '-'}'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    debugPrint("Klik murid: ${s.name}");
                    // bisa diarahkan ke halaman detail murid
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
