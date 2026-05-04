// lib/pages/admin/violation_approval_page.dart
import 'package:flutter/material.dart';
import '../../services/violation_service.dart';
import '../../models/violation.dart';

class ViolationApprovalPage extends StatelessWidget {
  const ViolationApprovalPage({super.key});

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
            itemCount: list.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final v = list[i];
              return ListTile(
                title: Text(v.description),
                subtitle: Text(
                  'Siswa: ${v.studentName} • Poin: ${v.points} • Kelas: ${v.kelas}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check, color: Colors.green),
                      onPressed: () async {
                        await violationService.approveViolation(v.id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Pelanggaran disetujui'),
                            ),
                          );
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () async {
                        await violationService.rejectViolation(
                          v.id,
                          reason: 'Ditolak oleh BK',
                          rejectedBy: 'admin',
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Pelanggaran ditolak'),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
