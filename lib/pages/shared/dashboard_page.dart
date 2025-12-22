// lib/pages/shared/dashboard_page.dart
import 'package:flutter/material.dart';
import '../../app_state.dart';
import '../../models/user.dart';
import '../../models/user_role.dart';
import '../../models/violation.dart';
import '../../models/violation_status.dart';
import '../../services/violation_service.dart';
import '../admin/rekap_page.dart';
import '../admin/violation_approval_page.dart';
import '../teacher/teacher_input_violation_page.dart';

class DashboardPage extends StatefulWidget {
  final User user;
  const DashboardPage({super.key, required this.user});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final AppState _appState = AppState.instance;
  final ViolationService _violationService = ViolationService();

  @override
  void initState() {
    super.initState();
    _appState.addListener(_onStateChanged);
    _appState.loadSummary();
  }

  @override
  void dispose() {
    _appState.removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _onRefresh() => _appState.loadSummary();

  @override
  Widget build(BuildContext context) {
    final isAdmin = widget.user.role == UserRole.admin;
    final isTeacher = widget.user.role == UserRole.teacher;
    final isStudent = widget.user.role == UserRole.student;

    if (isStudent) {
      return _buildStudentDashboard();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _appState.loadingSummary ? null : _appState.loadSummary,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildGreeting(),
            const SizedBox(height: 16),
            _buildSummaryCards(),
            const SizedBox(height: 24),
            if (isAdmin || isTeacher) _buildQuickActions(isAdmin, isTeacher),
            if (isAdmin || isTeacher) const SizedBox(height: 24),
            _buildLatestViolations(),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentDashboard() {
    final studentId = widget.user.id;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      body: StreamBuilder<List<Violation>>(
        stream: _violationService.getViolationsForStudent(studentId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final violations = snapshot.data ?? [];
          final approved = violations
              .where((v) => v.status == ViolationStatus.approved)
              .toList();
          final totalPoints = approved.fold<int>(0, (sum, v) => sum + v.points);

          return RefreshIndicator(
            onRefresh: () async => setState(() {}),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildGreeting(),
                const SizedBox(height: 16),
                _buildStudentSummary(
                  totalViolations: approved.length,
                  totalPoints: totalPoints,
                ),
                const SizedBox(height: 24),
                _buildStudentLatest(violations),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildGreeting() {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.indigo.shade100,
          child: const Icon(Icons.person, color: Colors.indigo),
        ),
        title: Text('Halo, ${widget.user.name}!'),
        subtitle: Text(
          'Peran: ${widget.user.role.label}'
          '${widget.user.kelas != null ? ' • Kelas ${widget.user.kelas}' : ''}',
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    if (_appState.loadingSummary) {
      return const Center(child: CircularProgressIndicator());
    }

    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            color: Colors.indigo,
            title: 'Total Pelanggaran',
            value: _appState.totalViolations.toString(),
            icon: Icons.warning,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            color: Colors.deepOrange,
            title: 'Siswa Terlibat',
            value: _appState.totalStudentsWithViolation.toString(),
            icon: Icons.people,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(bool isAdmin, bool isTeacher) {
    final actions = <Widget>[];

    if (isAdmin) {
      actions.addAll([
        _QuickActionButton(
          icon: Icons.verified,
          label: 'Approval Pelanggaran',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ViolationApprovalPage()),
          ),
        ),
        _QuickActionButton(
          icon: Icons.file_copy,
          label: 'Rekap Laporan',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RekapPage()),
          ),
        ),
      ]);
    }

    if (isTeacher) {
      actions.add(
        _QuickActionButton(
          icon: Icons.add_circle,
          label: 'Input Pelanggaran',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TeacherInputViolationPage(teacher: widget.user),
            ),
          ),
        ),
      );
    }

    return Wrap(spacing: 12, runSpacing: 12, children: actions);
  }

  Widget _buildLatestViolations() {
    final latest = _appState.latestViolations;
    if (_appState.loadingSummary) {
      return const SizedBox.shrink();
    }

    if (latest.isEmpty) {
      return const Text('Belum ada pelanggaran tercatat.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pelanggaran Terbaru',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...latest.map(
          (v) => Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.indigo.shade50,
                child: const Icon(Icons.warning, color: Colors.indigo),
              ),
              title: Text(v.description),
              subtitle: Text(
                '${v.studentName} • ${v.points} poin • ${v.kelas}',
              ),
              trailing: Text(
                v.status.label,
                style: TextStyle(
                  color: _statusColor(v),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStudentSummary({
    required int totalViolations,
    required int totalPoints,
  }) {
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            color: Colors.indigo,
            title: 'Total Pelanggaran',
            value: totalViolations.toString(),
            icon: Icons.warning,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            color: Colors.deepOrange,
            title: 'Total Poin',
            value: totalPoints.toString(),
            icon: Icons.score,
          ),
        ),
      ],
    );
  }

  Widget _buildStudentLatest(List<Violation> violations) {
    if (violations.isEmpty) {
      return const Text('Belum ada pelanggaran tercatat.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pelanggaran Saya',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...violations.map(
          (v) => Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.indigo.shade50,
                child: const Icon(Icons.warning, color: Colors.indigo),
              ),
              title: Text(v.description),
              subtitle: Text('${v.points} poin • ${v.kelas ?? '-'}'),
              trailing: Text(
                v.status.label,
                style: TextStyle(
                  color: _statusColor(v),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _statusColor(Violation v) {
    switch (v.status) {
      case ViolationStatus.pending:
        return Colors.orange;
      case ViolationStatus.approved:
        return Colors.green;
      case ViolationStatus.rejected:
        return Colors.red;
    }
  }
}

class _SummaryCard extends StatelessWidget {
  final Color color;
  final String title;
  final String value;
  final IconData icon;

  const _SummaryCard({
    required this.color,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(label, textAlign: TextAlign.center),
      ),
    );
  }
}
