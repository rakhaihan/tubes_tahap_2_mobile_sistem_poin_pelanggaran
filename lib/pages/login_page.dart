// lib/pages/login_page.dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user_role.dart';
import '../widgets/bottom_nav.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailC = TextEditingController();
  final passC = TextEditingController();
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: Center(
        child: Container(
          width: 360,
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(blurRadius: 8, color: Colors.black26)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Sistem Poin SMK Merdeka",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),

              SizedBox(height: 24),

              TextField(
                controller: emailC,
                decoration: InputDecoration(labelText: "Email"),
              ),

              SizedBox(height: 12),

              TextField(
                controller: passC,
                obscureText: true,
                decoration: InputDecoration(labelText: "Password"),
              ),

              SizedBox(height: 20),

              loading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _login,
                      child: Text("Login"),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _login() async {
    // Validasi input kosong
    if (emailC.text.trim().isEmpty || passC.text.trim().isEmpty) {
      _showErrorDialog("Email atau password tidak boleh kosong");
      return;
    }

    setState(() => loading = true);

    try {
      final user =
          await AuthService().login(emailC.text.trim(), passC.text.trim());

      setState(() => loading = false);

      if (user == null) {
        _showErrorDialog("Email atau password salah");
        return;
      }

      // Setelah login, bungkus ke dalam bottom navigation yang role-aware
      Widget home;
      switch (user.role) {
        case UserRole.student:
          home = BottomNavBar(user: user);
          break;
        case UserRole.teacher:
          home = BottomNavBar(user: user);
          break;
        case UserRole.admin:
          home = BottomNavBar(user: user);
          break;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => home),
      );
    } catch (e) {
      setState(() => loading = false);
      _showErrorDialog("Email atau password salah");
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
}
