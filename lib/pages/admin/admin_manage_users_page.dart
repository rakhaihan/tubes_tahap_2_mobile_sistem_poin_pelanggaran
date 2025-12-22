// lib/pages/admin/admin_manage_users_page.dart
import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../services/user_service.dart';

class AdminManageUsersPage extends StatefulWidget {
  const AdminManageUsersPage({super.key});

  @override
  State<AdminManageUsersPage> createState() => _AdminManageUsersPageState();
}

class _AdminManageUsersPageState extends State<AdminManageUsersPage> {
  final UserService _userService = UserService();
  String kelas = 'XII RPL 1';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manajemen Murid')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextFormField(
              initialValue: kelas,
              decoration: const InputDecoration(labelText: 'Kelas'),
              onFieldSubmitted: (value) => setState(() => kelas = value),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<User>>(
              stream: _userService.getStudentsByClass(kelas),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final students = snapshot.data ?? [];
                if (students.isEmpty) {
                  return const Center(
                    child: Text('Belum ada murid pada kelas ini.'),
                  );
                }
                return ListView.builder(
                  itemCount: students.length,
                  itemBuilder: (context, i) {
                    final u = students[i];
                    return ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(u.name),
                      subtitle: Text('Kelas: ${u.kelas ?? "-"}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          // TODO: implement delete user if needed.
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
