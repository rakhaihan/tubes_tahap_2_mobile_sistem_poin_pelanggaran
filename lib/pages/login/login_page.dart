// lib/pages/login/login_page.dart
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../models/user_role.dart';
import '../admin/admin_home_page.dart';
import '../teacher/teacher_home_page.dart';
import '../student/student_home_page.dart';
import '../../widgets/bottom_nav.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _passwordFocus = FocusNode();
  final AuthService _auth = AuthService();
  bool _loading = false;

  Future<void> _submit() async {
    setState(() => _loading = true);
    try {
      final user = await _auth.login(_email.text.trim(), _password.text.trim());
      if (user == null) throw Exception("Login gagal.");

      // Route by role
      switch (user.role) {
        case UserRole.admin:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => AdminHomePage(user: user)),
          );
          break;
        case UserRole.teacher:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => TeacherHomePage(user: user)),
          );
          break;
        case UserRole.student:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => StudentHomePage(user: user)),
          );
          break;
        case UserRole.parent:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => BottomNavBar(user: user)),
          );
          break;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Masuk — Rekap Pelanggaran')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              key: const ValueKey('email_field'),
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => _passwordFocus.requestFocus(),
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 8),
            TextField(
              key: const ValueKey('password_field'),
              controller: _password,
              focusNode: _passwordFocus,
              obscureText: true,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text('Masuk'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
