// lib/pages/student/student_home_page.dart
import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../models/violation.dart';
import '../../models/violation_status.dart';
import '../../models/violation_option.dart';
import '../../services/violation_service.dart';
import '../shared/sanksi_page.dart';

class StudentHomePage extends StatefulWidget {
  final User user;
  const StudentHomePage({super.key, required this.user});

  @override
  State<StatefulWidget> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  final _violationService = ViolationService();

  void _showViolationListDialog(List<Violation> violations) {
    final approved = violations
        .where((v) => v.status == ViolationStatus.approved)
        .toList();
    final totalPoints = approved.fold<int>(0, (sum, v) => sum + v.points);

    // Group violations by description and count occurrences
    final Map<String, int> violationCounts = {};
    final Map<String, int> violationPoints = {};

    for (final v in violations) {
      if (v.status == ViolationStatus.approved) {
        violationCounts[v.description] =
            (violationCounts[v.description] ?? 0) + 1;
        violationPoints[v.description] = v.points;
      }
    }

    // Filter out "Pilih Jenis Pelanggaran" option
    final allViolationOptions = violationOptions
        .where((opt) => opt.label != 'Pilih Jenis Pelanggaran')
        .toList();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: double.maxFinite,
          constraints: const BoxConstraints(maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.indigo,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.list, color: Colors.white),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Daftar Pelanggaran',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              // Summary
              Container(
                padding: const EdgeInsets.all(12),
                color: Colors.grey[100],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          "${approved.length}",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo,
                          ),
                        ),
                        const Text(
                          "Pelanggaran",
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    Container(width: 1, height: 40, color: Colors.grey[300]),
                    Column(
                      children: [
                        Text(
                          "$totalPoints",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                        const Text(
                          "Total Poin",
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // List of all violations (all rules)
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(8),
                  itemCount: allViolationOptions.length,
                  itemBuilder: (context, index) {
                    final option = allViolationOptions[index];
                    final hasViolation = violationCounts.containsKey(
                      option.label,
                    );
                    final count = hasViolation
                        ? violationCounts[option.label]!
                        : 0;

                    return Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: hasViolation
                              ? Colors.red.shade300
                              : Colors.grey[300]!,
                          width: hasViolation ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        color: hasViolation
                            ? Colors.red.shade50
                            : Colors.transparent,
                      ),
                      child: ListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: hasViolation
                            ? Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              )
                            : const SizedBox(width: 24),
                        title: Text(
                          option.label,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: hasViolation
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: hasViolation
                                ? Colors.red.shade900
                                : Colors.black87,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (count > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'x$count',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red.shade900,
                                  ),
                                ),
                              ),
                            if (count > 0) const SizedBox(width: 8),
                            Text(
                              '${option.points} poin',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: hasViolation
                                    ? Colors.red.shade700
                                    : Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Footer with close button
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.grey[300]!)),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Tutup'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final studentId = widget.user.id;
    if (studentId.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text('User ID kosong, tidak bisa memuat pelanggaran.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Pelanggaran Saya"),
        actions: [
          StreamBuilder<List<Violation>>(
            stream: _violationService.getViolationsForStudent(studentId),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                return IconButton(
                  icon: const Icon(Icons.list),
                  tooltip: 'Lihat Daftar Pelanggaran',
                  onPressed: () => _showViolationListDialog(snapshot.data!),
                );
              }
              return const SizedBox.shrink();
            },
          ),
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
      body: StreamBuilder<List<Violation>>(
        stream: _violationService.getViolationsForStudent(studentId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final violations = snapshot.data ?? [];
          if (violations.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 64,
                    color: Colors.green,
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Belum ada pelanggaran.",
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            );
          }

          // Hanya pelanggaran yang sudah disetujui yang dihitung poinnya
          final approved = violations
              .where((v) => v.status == ViolationStatus.approved)
              .toList();
          final totalPoints = approved.fold<int>(0, (sum, v) => sum + v.points);

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.indigo.shade50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Total Pelanggaran Disetujui:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "${approved.length}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "Total Poin:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "$totalPoints",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: violations.length,
                  itemBuilder: (context, index) {
                    final v = violations[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: v.status == ViolationStatus.approved
                              ? Colors.green.shade100
                              : v.status == ViolationStatus.rejected
                              ? Colors.red.shade100
                              : Colors.orange.shade100,
                          child: Icon(
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
                        ),
                        title: Text(
                          v.description,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              "Poin: ${v.points} | Status: ${v.status.label}",
                            ),
                            Text(
                              "${v.createdAt.day}/${v.createdAt.month}/${v.createdAt.year}",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
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
  }
}
