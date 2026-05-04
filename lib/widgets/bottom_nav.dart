// lib/widgets/bottom_nav.dart
import 'package:flutter/material.dart';

import '../models/user.dart';
import '../models/user_role.dart';
import '../pages/admin/admin_home_page.dart';
import '../pages/parent/parent_home_page.dart';
import '../pages/shared/dashboard_page.dart';
import '../pages/shared/profile_page.dart';
import '../pages/shared/sanksi_page.dart';
import '../pages/student/student_home_page.dart';
import '../pages/teacher/teacher_home_page.dart';

/// Bottom navigation yang menyesuaikan role user.
///
/// - Siswa: Pelanggaran, Sanksi, Profil
/// - Guru:  Siswa, Sanksi, Profil
/// - Admin: Approval, Sanksi, Profil
/// - Orang Tua: Anak, Sanksi, Profil
class BottomNavBar extends StatefulWidget {
  final User user;
  const BottomNavBar({super.key, required this.user});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final role = widget.user.role;

    final pages = <Widget>[];
    final items = <BottomNavigationBarItem>[];

    // Dashboard tab
    pages.add(DashboardPage(user: widget.user));
    items.add(
      const BottomNavigationBarItem(
        icon: Icon(Icons.dashboard),
        label: 'Dashboard',
      ),
    );

    // Role-specific home tab
    Widget? homePage;
    BottomNavigationBarItem homeItem;
    switch (role) {
      case UserRole.student:
        homePage = StudentHomePage(user: widget.user);
        homeItem = const BottomNavigationBarItem(
          icon: Icon(Icons.warning),
          label: 'Pelanggaran',
        );
        break;
      case UserRole.teacher:
        homePage = TeacherHomePage(user: widget.user);
        homeItem = const BottomNavigationBarItem(
          icon: Icon(Icons.people),
          label: 'Siswa',
        );
        break;
      case UserRole.admin:
        homePage = AdminHomePage(user: widget.user);
        homeItem = const BottomNavigationBarItem(
          icon: Icon(Icons.verified),
          label: 'Approval',
        );
        break;
      case UserRole.parent:
        homePage = ParentHomePage(user: widget.user);
        homeItem = const BottomNavigationBarItem(
          icon: Icon(Icons.family_restroom),
          label: 'Anak',
        );
        break;
    }
    // homePage selalu terisi berdasarkan role
    pages.add(homePage);
    items.add(homeItem);

    // Sanksi tab (semua role bisa lihat, hanya admin yang bisa edit di dalam halaman)
    pages.add(SanctionPage(user: widget.user));
    items.add(
      const BottomNavigationBarItem(icon: Icon(Icons.gavel), label: 'Sanksi'),
    );

    // Profile tab
    pages.add(ProfilePage(user: widget.user));
    items.add(
      const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
    );

    final index = _selectedIndex.clamp(0, pages.length - 1);

    return Scaffold(
      body: pages[index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,
        items: items,
      ),
    );
  }
}
