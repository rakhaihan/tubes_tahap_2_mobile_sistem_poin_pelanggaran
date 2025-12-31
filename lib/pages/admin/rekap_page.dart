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
  String? _errorMessage;

  final List<String> _kelasOptions = ['XII RPL 1', 'XII RPL 2', 'XII RPL 3'];
  final List<int> _semesterOptions = [1, 2];

  Future<void> _load() async {
    // Validasi input
    if (_kelas.trim().isEmpty) {
      setState(() {
        _errorMessage = "Data tidak ditemukan";
        _data = [];
        _loading = false;
      });
      _showErrorDialog("Data tidak ditemukan");
      return;
    }

    if (_semester != 1 && _semester != 2) {
      setState(() {
        _errorMessage = "Data tidak ditemukan";
        _data = [];
        _loading = false;
      });
      _showErrorDialog("Data tidak ditemukan");
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
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
        kelas: _kelas.trim(),
        from: range.start,
        to: range.end,
      );

      setState(() {
        _data = list;
        _loading = false;
        _errorMessage = list.isEmpty ? "Data tidak ditemukan" : null;
      });

      // Tampilkan dialog jika data tidak ditemukan
      if (list.isEmpty) {
        _showErrorDialog("Data tidak ditemukan");
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Data tidak ditemukan";
        _data = [];
        _loading = false;
      });
      _showErrorDialog("Data tidak ditemukan");
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Peringatan"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
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
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    value: _kelas,
                    decoration: const InputDecoration(
                      labelText: 'Kelas',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    items: _kelasOptions.map((String kelas) {
                      return DropdownMenuItem<String>(
                        value: kelas,
                        child: Text(kelas),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _kelas = newValue;
                        });
                      }
                    },
                    isExpanded: true,
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 80,
                  child: DropdownButtonFormField<int>(
                    value: _semester,
                    decoration: const InputDecoration(
                      labelText: 'Semester',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    items: _semesterOptions.map((int semester) {
                      return DropdownMenuItem<int>(
                        value: semester,
                        child: Text(semester.toString()),
                      );
                    }).toList(),
                    onChanged: (int? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _semester = newValue;
                        });
                      }
                    },
                    isExpanded: true,
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
                  : _data.isEmpty || _errorMessage != null
                  ? Center(
                      child: Text(
                        _errorMessage ?? 'Belum ada data',
                        style: TextStyle(
                          fontSize: 16,
                          color: _errorMessage != null
                              ? Colors.red
                              : Colors.grey,
                        ),
                      ),
                    )
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
