// lib/pages/admin/export_page.dart
import 'package:flutter/material.dart';
import '../../services/export_service.dart';

class ExportPage extends StatelessWidget {
  const ExportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Export Laporan")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: () async {
                await ExportService().exportCSV();
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text("CSV berhasil dibuat")));
              },
              icon: Icon(Icons.table_chart),
              label: Text("Export CSV"),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () async {
                await ExportService().exportPDF();
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text("PDF berhasil dibuat")));
              },
              icon: Icon(Icons.picture_as_pdf),
              label: Text("Export PDF"),
            ),
          ],
        ),
      ),
    );
  }
}
