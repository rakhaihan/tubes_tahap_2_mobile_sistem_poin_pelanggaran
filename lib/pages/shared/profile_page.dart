// lib/pages/shared/profile_page.dart
import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../models/user_role.dart';
import '../../services/auth_service.dart';
import '../login_page.dart';

class ProfilePage extends StatelessWidget {
  final User? user;
  const ProfilePage({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();
    final current = user ?? auth.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Profil Pengguna')),
      body: current == null
          ? const Center(child: Text('Tidak ada data pengguna.'))
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 36,
                      backgroundColor: Colors.indigo.shade100,
                      child: Text(
                        current.name.isNotEmpty
                            ? current.name[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      current.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: Text(
                      current.role.label +
                          (current.kelas != null && current.kelas!.isNotEmpty
                              ? ' • Kelas ${current.kelas}'
                              : ''),
                      style: TextStyle(color: Colors.grey[700], fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _ProfileRow(label: 'Nama', value: current.name),
                        const Divider(height: 1),
                        _ProfileRow(label: 'Email', value: current.email),
                        const Divider(height: 1),
                        _ProfileRow(label: 'Peran', value: current.role.label),
                        if (current.kelas != null &&
                            current.kelas!.isNotEmpty) ...[
                          const Divider(height: 1),
                          _ProfileRow(label: 'Kelas', value: current.kelas!),
                        ],
                      ],
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.logout),
                      label: const Text('Keluar'),
                      onPressed: () async {
                        await auth.logout();
                        if (context.mounted) {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (_) => const LoginPage(),
                            ),
                            (route) => false,
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[700],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
