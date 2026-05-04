// lib/pages/admin/admin_home_page.dart
import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../services/violation_service.dart';
import '../../models/violation.dart';

class AdminHomePage extends StatelessWidget {
  final User user;
  const AdminHomePage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final violationService = ViolationService();

    return Scaffold(
      appBar: AppBar(title: const Text('Approval Pelanggaran')),
      body: StreamBuilder<List<Violation>>(
        stream: violationService.getPendingApproval(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final list = snapshot.data ?? [];
          if (list.isEmpty) {
            return const Center(
              child: Text('Tidak ada pelanggaran yang menunggu approval'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(8),
            itemCount: list.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final v = list[i];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.orange.shade100,
                    child: const Icon(Icons.warning, color: Colors.orange),
                  ),
                  title: Text(
                    v.description,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('Siswa: ${v.studentName}'),
                      Text('Kelas: ${v.kelas ?? '-'}'),
                      Text('Poin: ${v.points}'),
                      Text(
                        'Dibuat: ${v.createdAt.day}/${v.createdAt.month}/${v.createdAt.year}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        tooltip: 'Setujui',
                        onPressed: () async {
                          await violationService.approveViolation(v.id);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Pelanggaran disetujui'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        tooltip: 'Tolak',
                        onPressed: () async {
                          await violationService.rejectViolation(
                            v.id,
                            reason: 'Ditolak oleh BK',
                            rejectedBy: user.name,
                          );
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Pelanggaran ditolak'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
