import 'package:flutter/material.dart';
import '../models/user_role.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../widgets/bottom_nav.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameC = TextEditingController();
  final _emailC = TextEditingController();
  final _passC = TextEditingController();
  final _kelasC = TextEditingController();
  final _studentEmailC = TextEditingController();
  final _userService = UserService();

  UserRole _role = UserRole.student;
  bool _loading = false;

  @override
  void dispose() {
    _nameC.dispose();
    _emailC.dispose();
    _passC.dispose();
    _kelasC.dispose();
    _studentEmailC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: const Text('Daftar Akun'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Center(
        child: Container(
          width: 420,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(blurRadius: 8, color: Colors.black26),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Buat akun baru",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameC,
                decoration: const InputDecoration(labelText: "Nama"),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _emailC,
                decoration: const InputDecoration(labelText: "Email"),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passC,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Password"),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<UserRole>(
                initialValue: _role,
                decoration: const InputDecoration(labelText: "Peran"),
                items: const [
                  DropdownMenuItem(
                    value: UserRole.student,
                    child: Text('Murid'),
                  ),
                  DropdownMenuItem(
                    value: UserRole.teacher,
                    child: Text('Guru'),
                  ),
                  DropdownMenuItem(
                    value: UserRole.parent,
                    child: Text('Orang Tua'),
                  ),
                ],
                onChanged: _loading
                    ? null
                    : (v) {
                        if (v == null) return;
                        setState(() {
                          _role = v;
                          if (_role != UserRole.parent) {
                            _studentEmailC.clear();
                          }
                        });
                      },
              ),
              const SizedBox(height: 12),
              if (_role != UserRole.parent)
                TextField(
                  controller: _kelasC,
                  decoration: const InputDecoration(
                    labelText: "Kelas (contoh: XI RPL 1)",
                  ),
                  textInputAction: TextInputAction.done,
                ),
              if (_role == UserRole.parent)
                TextField(
                  controller: _studentEmailC,
                  decoration: const InputDecoration(
                    labelText: "Email Siswa yang Ditautkan",
                    hintText: "contoh: siswa@mail.com",
                  ),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                ),
              const SizedBox(height: 20),
              _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _register,
                      child: const Text("Daftar"),
                    ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _loading ? null : () => Navigator.pop(context),
                child: const Text("Sudah punya akun? Login"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _register() async {
    final name = _nameC.text.trim();
    final email = _emailC.text.trim();
    final password = _passC.text;
    final kelas = _kelasC.text.trim();
    final studentEmail = _studentEmailC.text.trim().toLowerCase();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showErrorDialog("Nama, email, dan password tidak boleh kosong");
      return;
    }

    if (_role != UserRole.parent && kelas.isEmpty) {
      _showErrorDialog("Kelas tidak boleh kosong");
      return;
    }
    if (_role == UserRole.parent && studentEmail.isEmpty) {
      _showErrorDialog("Email siswa wajib diisi untuk akun orang tua");
      return;
    }

    setState(() => _loading = true);
    try {
      String? linkedStudentId;
      if (_role == UserRole.parent) {
        final student = await _userService.getStudentByEmail(studentEmail);
        if (student == null) {
          throw Exception(
            'Siswa dengan email tersebut tidak ditemukan',
          );
        }
        linkedStudentId = student.id;
      }

      final user = await AuthService().register(
        name: name,
        email: email,
        password: password,
        role: _role,
        kelas: _role == UserRole.parent ? null : kelas,
        linkedStudentId: linkedStudentId,
      );

      if (!mounted) return;
      setState(() => _loading = false);

      if (user == null) {
        _showErrorDialog("Gagal membuat akun");
        return;
      }

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => BottomNavBar(user: user)),
        (_) => false,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showErrorDialog(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Peringatan"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }
}

