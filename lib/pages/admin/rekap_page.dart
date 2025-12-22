// lib/pages/admin/rekap_page.dart
import 'package:flutter/material.dart';
import '../../models/violation.dart';
import '../../services/report_service.dart';
import '../../services/violation_service.dart';

class RekapPage extends StatefulWidget {
  const RekapPage({super.key});

  @override
  State<RekapPage> createState() => _RekapPageState();
}

class _RekapPageState extends State<RekapPage> {
  final ReportService _report = ReportService(
    violationService: ViolationService(),
  );
  String _kelas = 'XII RPL 1';
  int _semester = 1;
  bool _loading = false;
  List<Violation> _data = [];

  Future<void> _load() async {
    setState(() => _loading = true);
    final now = DateTime.now();
    final year = now.year;
    final range = _semester == 1
        ? DateTimeRange(
            start: DateTime(year, 1, 1),
            end: DateTime(year, 6, 30, 23, 59, 59),
          )
        : DateTimeRange(
            start: DateTime(year, 7, 1),
            end: DateTime(year, 12, 31, 23, 59, 59),
          );
    final list = await _report.rekapPelanggaran(
      kelas: _kelas,
      from: range.start,
      to: range.end,
    );
    setState(() {
      _data = list;
      _loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rekap Pelanggaran')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(labelText: 'Kelas'),
                    onChanged: (v) => setState(() => _kelas = v),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 120,
                  child: TextField(
                    decoration: const InputDecoration(labelText: 'Semester'),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => setState(() {
                      _semester = int.tryParse(v) ?? 1;
                    }),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _load,
                  child: const Text('Tampilkan'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _data.isEmpty
                  ? const Center(child: Text('Belum ada data'))
                  : ListView.separated(
                      itemCount: _data.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, i) {
                        final v = _data[i];
                        return ListTile(
                          title: Text('${v.description} • ${v.points} poin'),
                          subtitle: Text(
                            'Siswa: ${v.studentName} • Kelas: ${v.kelas}',
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
