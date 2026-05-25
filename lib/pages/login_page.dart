// lib/pages/login_page.dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user_role.dart';
import '../widgets/bottom_nav.dart';
import '../services/fcm_service.dart';
import '../services/fcm_token_service.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailC = TextEditingController();
  final passC = TextEditingController();
  final emailFocus = FocusNode();
  final passFocus = FocusNode();
  bool loading = false;

  void _focusPasswordIfEmailFilled() {
    final email = emailC.text.trim();
    if (email.contains('@') && email.contains('.') && passC.text.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) passFocus.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    emailC.dispose();
    passC.dispose();
    emailFocus.dispose();
    passFocus.dispose();
    super.dispose();
  }

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

              Semantics(
                label: 'login_email_field',
                textField: true,
                child: TextField(
                  key: const ValueKey('login_email_field'),
                  controller: emailC,
                  focusNode: emailFocus,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(labelText: "Email"),
                  onTap: _focusPasswordIfEmailFilled,
                  onSubmitted: (_) => passFocus.requestFocus(),
                ),
              ),

              SizedBox(height: 12),

              Semantics(
                label: 'login_password_field',
                textField: true,
                child: TextField(
                  key: const ValueKey('login_password_field'),
                  controller: passC,
                  focusNode: passFocus,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(labelText: "Password"),
                  onSubmitted: (_) => _login(),
                ),
              ),

              SizedBox(height: 20),

              loading
                  ? CircularProgressIndicator()
                  : Semantics(
                      label: 'login_button',
                      button: true,
                      child: ElevatedButton(
                        key: const ValueKey('login_button'),
                        onPressed: _login,
                        child: Text("Login"),
                      ),
                    ),

              const SizedBox(height: 8),
              TextButton(
                onPressed: loading
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const RegisterPage()),
                        );
                      },
                child: const Text("Belum punya akun? Daftar"),
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

      if (!mounted) return;
      setState(() => loading = false);

      if (user == null) {
        _showErrorDialog("Email atau password salah");
        return;
      }

      // Simpan FCM token untuk siswa/orang tua setelah login berhasil
      if (user.role == UserRole.student || user.role == UserRole.parent) {
        final fcmTokenService = FCMTokenService();
        final fcmToken = await FCMService.getToken();
        if (fcmToken != null) {
          await fcmTokenService.saveTokenForUser(user.id, fcmToken, user.role);
        }
      }

      if (!mounted) return;
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
        case UserRole.parent:
          home = BottomNavBar(user: user);
          break;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => home),
      );
    } catch (e) {
      if (!mounted) return;
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
