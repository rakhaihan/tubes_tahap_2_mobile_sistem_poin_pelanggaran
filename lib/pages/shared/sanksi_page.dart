import 'package:flutter/material.dart';

import '../../models/sanction.dart';
import '../../models/user.dart';
import '../../models/user_role.dart';
import '../../services/sanction_service.dart';
import '../../services/user_service.dart';
import '../../services/violation_service.dart';
import '../../models/violation_status.dart';

class SanctionPage extends StatefulWidget {
  final User user;
  const SanctionPage({super.key, required this.user});

  @override
  State<SanctionPage> createState() => _SanctionPageState();
}

class _SanctionPageState extends State<SanctionPage> {
  final _service = SanctionService();
  final _userService = UserService();
  final _violationService = ViolationService();

  bool get _isAdmin => widget.user.role == UserRole.admin;
  bool get _isStudent => widget.user.role == UserRole.student;
  bool get _isParent => widget.user.role == UserRole.parent;

  void _openSanctionForm({Sanction? sanction}) {
    final tingkatCtrl = TextEditingController(text: sanction?.tingkat ?? '');
    final keteranganCtrl = TextEditingController(
      text: sanction?.keterangan ?? '',
    );
    final minCtrl = TextEditingController(
      text: sanction?.minPoin.toString() ?? '',
    );
    final maxCtrl = TextEditingController(
      text: sanction?.maxPoin.toString() ?? '',
    );

    final keteranganFocus = FocusNode();
    final minFocus = FocusNode();
    final maxFocus = FocusNode();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(sanction == null ? 'Tambah Sanksi' : 'Ubah Sanksi'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  key: const ValueKey('sanksi_tingkat_field'),
                  controller: tingkatCtrl,
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) => keteranganFocus.requestFocus(),
                  decoration: const InputDecoration(
                    labelText: 'Tingkat (Ringan/Sedang/Berat)',
                  ),
                ),
                TextField(
                  key: const ValueKey('sanksi_keterangan_field'),
                  controller: keteranganCtrl,
                  focusNode: keteranganFocus,
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) => minFocus.requestFocus(),
                  decoration: const InputDecoration(labelText: 'Keterangan'),
                  maxLines: 2,
                ),
                TextField(
                  key: const ValueKey('sanksi_min_poin_field'),
                  controller: minCtrl,
                  focusNode: minFocus,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) => maxFocus.requestFocus(),
                  decoration: const InputDecoration(labelText: 'Min Poin'),
                ),
                TextField(
                  key: const ValueKey('sanksi_max_poin_field'),
                  controller: maxCtrl,
                  focusNode: maxFocus,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(labelText: 'Max Poin'),
                ),
              ],
            ),
          ),
          actions: [
            Semantics(
              label: 'sanction_cancel_button',
              button: true,
              child: TextButton(
                key: const ValueKey('sanction_cancel_button'),
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
            ),
            Semantics(
              label: 'sanction_save_button',
              button: true,
              child: ElevatedButton(
                key: const ValueKey('sanction_save_button'),
                onPressed: () async {
                  final tingkat = tingkatCtrl.text.trim();
                  final keterangan = keteranganCtrl.text.trim();
                  final min = int.tryParse(minCtrl.text) ?? -1;
                  final max = int.tryParse(maxCtrl.text) ?? -1;

                  if (tingkat.isEmpty ||
                      keterangan.isEmpty ||
                      min < 0 ||
                      max < 0 ||
                      min > max) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Periksa input sanksi')),
                    );
                    return;
                  }

                  try {
                    if (sanction == null) {
                      final newSanction = Sanction(
                        tingkat: tingkat,
                        keterangan: keterangan,
                        minPoin: min,
                        maxPoin: max,
                      );
                      await _service.addSanction(newSanction);
                    } else {
                      final updated = sanction.copyWith(
                        tingkat: tingkat,
                        keterangan: keterangan,
                        minPoin: min,
                        maxPoin: max,
                      );
                      await _service.updateSanction(updated);
                    }
                    if (mounted) Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Gagal menyimpan: $e')),
                    );
                  }
                },
                child: const Text('Simpan'),
              ),
            ),
          ],
        );
      },
    ).whenComplete(() {
      tingkatCtrl.dispose();
      keteranganCtrl.dispose();
      minCtrl.dispose();
      maxCtrl.dispose();
      keteranganFocus.dispose();
      minFocus.dispose();
      maxFocus.dispose();
    });
  }

  void _confirmDelete(Sanction s) {
    if (s.id == null) return;
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Hapus Sanksi'),
        content: Text('Hapus sanksi "${s.tingkat}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _service.deleteSanction(s.id!);
                if (mounted) Navigator.pop(c);
              } catch (e) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Gagal menghapus: $e')));
              }
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  // return a MaterialColor for consistent shades
  MaterialColor _levelMaterialColor(String tingkat) {
    final t = tingkat.toLowerCase();
    if (t.contains('berat')) return Colors.red;
    if (t.contains('sedang')) return Colors.orange;
    return Colors.yellow;
  }

  Color _levelTextColor(String tingkat) {
    final m = _levelMaterialColor(tingkat);
    return m.shade700;
  }

  Widget _levelChip(String tingkat) {
    final base = _levelMaterialColor(tingkat);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: base.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        tingkat,
        style: TextStyle(
          color: _levelTextColor(tingkat),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sanksi & Pembinaan'),
        actions: [
          if (_isAdmin)
            Semantics(
              label: 'sanction_add_appbar_button',
              button: true,
              child: IconButton(
                key: const ValueKey('sanction_add_appbar_button'),
                icon: const Icon(Icons.add),
                onPressed: () => _openSanctionForm(),
                tooltip: 'Tambah sanksi',
              ),
            ),
        ],
      ),
      floatingActionButton: _isAdmin
          ? Semantics(
              label: 'sanction_add_fab',
              button: true,
              child: FloatingActionButton(
                key: const ValueKey('sanction_add_fab'),
                onPressed: () => _openSanctionForm(),
                child: const Icon(Icons.add),
              ),
            )
          : null,
      body: StreamBuilder<List<Sanction>>(
        stream: _service.streamSanctions(),
        builder: (context, sancSnap) {
          if (sancSnap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (sancSnap.hasError) {
            return Center(child: Text('Error: ${sancSnap.error}'));
          }

          final allSanctions = sancSnap.data ?? [];
          if (allSanctions.isEmpty) {
            return const Center(child: Text('Belum ada data sanksi.'));
          }

          // Jika student/orang tua, filter sanksi yang relevan untuk siswa terkait
          if (_isStudent || _isParent) {
            final targetStudentId = _isParent
                ? (widget.user.linkedStudentId ?? '')
                : widget.user.id;
            if (targetStudentId.isEmpty) {
              return const Center(
                child: Text('Akun orang tua belum terhubung ke siswa.'),
              );
            }

            return FutureBuilder<Map<String, int>>(
              future: _computeTotalPointsPerStudent(),
              builder: (context, ptsSnap) {
                if (ptsSnap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (ptsSnap.hasError) {
                  return Center(
                    child: Text('Error poin murid: ${ptsSnap.error}'),
                  );
                }

                final totals = ptsSnap.data ?? {};
                final studentPoints = totals[targetStudentId] ?? 0;

                // Filter sanksi yang sesuai dengan poin student
                final relevantSanctions = allSanctions.where((s) {
                  return studentPoints >= s.minPoin && studentPoints <= s.maxPoin;
                }).toList();

                if (relevantSanctions.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle_outline,
                            size: 64, color: Colors.green),
                        const SizedBox(height: 16),
                        Text(
                          _isParent
                              ? 'Siswa terkait belum masuk kategori sanksi'
                              : 'Anda tidak masuk ke dalam kategori sanksi',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isParent
                              ? 'Total poin siswa terkait: $studentPoints'
                              : 'Total poin Anda: $studentPoints',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: relevantSanctions.length,
                  itemBuilder: (context, i) {
                    final s = relevantSanctions[i];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ExpansionTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.indigo.shade100,
                          child: Text(
                            s.tingkat.isNotEmpty ? s.tingkat[0] : '?',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                s.tingkat,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _levelChip(s.tingkat),
                          ],
                        ),
                        subtitle: Text(
                          'Poin: ${s.minPoin} - ${s.maxPoin}\n${s.keterangan}',
                          style: const TextStyle(height: 1.4),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Status Sanksi',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                FutureBuilder<User?>(
                                  future: _isParent
                                      ? _userService.getStudentById(targetStudentId)
                                      : Future.value(widget.user),
                                  builder: (context, linkedSnap) {
                                    final student = linkedSnap.data;
                                    return ListTile(
                                      dense: true,
                                      contentPadding: EdgeInsets.zero,
                                      leading: const Icon(Icons.person, size: 20),
                                      title: Text(student?.name ?? '-'),
                                      subtitle: Text(
                                        'Kelas: ${student?.kelas ?? '-'} • Poin: $studentPoints',
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          }

          // Untuk admin/teacher: tampilkan semua sanksi dengan semua murid
          return StreamBuilder<List<User>>(
            stream: _userService.streamAllStudents(),
            builder: (context, stuSnap) {
              if (stuSnap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (stuSnap.hasError) {
                return Center(child: Text('Error murid: ${stuSnap.error}'));
              }

              final students = stuSnap.data ?? [];
              if (students.isEmpty) {
                return const Center(child: Text('Belum ada murid terdaftar.'));
              }

              return FutureBuilder<Map<String, int>>(
                future: _computeTotalPointsPerStudent(),
                builder: (context, ptsSnap) {
                  if (ptsSnap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (ptsSnap.hasError) {
                    return Center(
                      child: Text('Error poin murid: ${ptsSnap.error}'),
                    );
                  }

                  final totals = ptsSnap.data ?? {};

                  return ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: allSanctions.length,
                    itemBuilder: (context, i) {
                      final s = allSanctions[i];

                      // Auto-assign murid ke sanksi berdasarkan total poin
                      final matched =
                          students.where((u) {
                            final pts = totals[u.id] ?? 0;
                            return pts >= s.minPoin && pts <= s.maxPoin;
                          }).toList()..sort((a, b) {
                            final pa = totals[a.id] ?? 0;
                            final pb = totals[b.id] ?? 0;
                            return pb.compareTo(
                              pa,
                            ); // yang poinnya lebih besar di atas
                          });

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ExpansionTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.indigo.shade100,
                            child: Text(
                              s.tingkat.isNotEmpty ? s.tingkat[0] : '?',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  s.tingkat,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              _levelChip(s.tingkat),
                            ],
                          ),
                          subtitle: Text(
                            'Poin: ${s.minPoin} - ${s.maxPoin}\n${s.keterangan}',
                            style: const TextStyle(height: 1.4),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Murid pada rentang poin ini',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  if (matched.isEmpty)
                                    const Text(
                                      '- Tidak ada murid pada rentang ini -',
                                    )
                                  else
                                    ...matched.map((u) {
                                      final pts = totals[u.id] ?? 0;
                                      return ListTile(
                                        dense: true,
                                        contentPadding: EdgeInsets.zero,
                                        leading: const Icon(
                                          Icons.person,
                                          size: 20,
                                        ),
                                        title: Text(u.name),
                                        subtitle: Text(
                                          'Kelas: ${u.kelas ?? '-'} • Poin: $pts',
                                        ),
                                      );
                                    }),
                                ],
                              ),
                            ),
                            if (_isAdmin)
                              Padding(
                                padding: const EdgeInsets.only(
                                  right: 8,
                                  bottom: 8,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton.icon(
                                      onPressed: () =>
                                          _openSanctionForm(sanction: s),
                                      icon: const Icon(Icons.edit),
                                      label: const Text('Ubah'),
                                    ),
                                    const SizedBox(width: 8),
                                    TextButton.icon(
                                      onPressed: () => _confirmDelete(s),
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      label: const Text(
                                        'Hapus',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<Map<String, int>> _computeTotalPointsPerStudent() async {
    final violations = await _violationService.fetchAll();
    final Map<String, int> totals = {};
    for (final v in violations) {
      // Hanya hitung pelanggaran yang sudah disetujui
      if (v.status != ViolationStatus.approved) continue;
      final id = v.studentId;
      if (id.isEmpty) continue;
      totals[id] = (totals[id] ?? 0) + v.points;
    }
    return totals;
  }
}
