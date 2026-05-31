import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:hero/app/app_routes.dart';
import 'package:hero/core/enums/app_role.dart';
import 'package:hero/core/repositories/menu_repository.dart';
import 'package:hero/features/menu/pages/menu_screen.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

const String _headingFont = 'Poppins';
const String _bodyFont = 'Poppins';

class HomeShell extends StatefulWidget {
  const HomeShell({
    super.key,
    required this.role,
    required this.menuRepository,
  });

  final AppRole role;
  final MenuRepository menuRepository;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;

  final List<_TabData> _tabs = const [
    _TabData(label: 'Home', active: PhosphorIconsFill.house, inactive: PhosphorIconsRegular.house),
    _TabData(label: 'Tasks', active: PhosphorIconsFill.checkSquareOffset, inactive: PhosphorIconsRegular.checkSquareOffset),
    _TabData(label: 'Profile', active: PhosphorIconsFill.user, inactive: PhosphorIconsRegular.user),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFF),
      body: Stack(
        children: [
          const _ProfessionalBackground(),
          SafeArea(
            child: IndexedStack(
              index: _currentIndex,
              children: [
                _DashboardHome(onOpenMenu: _openMenu),
                _TasksPage(onOpenMenu: _openMenu),
                const _ProfilePage(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _GlobalBottomNavigation(
        currentIndex: _currentIndex,
        tabs: _tabs,
        onChanged: (value) => setState(() => _currentIndex = value),
      ),
    );
  }

  void _openMenu(String title) {
    final normalized = title.toLowerCase().trim();

    switch (normalized) {
      case 'attendance':
        Navigator.of(context).pushNamed(AppRoutes.attendance);
      case 'revisi absen':
        Navigator.of(context).pushNamed(AppRoutes.attendanceRevision);
      case 'struktur organisasi':
        Navigator.of(context).pushNamed(AppRoutes.organizationStructure);
      case 'leave':
        Navigator.of(context).pushNamed(AppRoutes.leave);
      case 'roster':
        Navigator.of(context).pushNamed(AppRoutes.roster);
      case 'absen makan':
        Navigator.of(context).pushNamed(AppRoutes.mealAttendance);
      case 'her registration':
        Navigator.of(context).pushNamed(AppRoutes.herRegistration);
      case 'revisi jadwal':
        Navigator.of(context).pushNamed(AppRoutes.scheduleRevision);
      case 'payslip':
        Navigator.of(context).pushNamed(AppRoutes.payslip);
      default:
        Navigator.of(context).pushNamed(MenuScreen.routeName, arguments: title);
    }
  }
}

class _DashboardHome extends StatefulWidget {
  const _DashboardHome({required this.onOpenMenu});

  final ValueChanged<String> onOpenMenu;

  @override
  State<_DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<_DashboardHome> {
  late List<_MenuItemData> _quickItems;

  @override
  void initState() {
    super.initState();
    _quickItems = _allQuickMenus.take(6).toList();
  }

  void _openEditSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditQuickAccessSheet(
        selected: List<_MenuItemData>.from(_quickItems),
        onSave: (updated) => setState(() => _quickItems = updated),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _AppearUp(delayMs: 20, child: _Header()),
          const SizedBox(height: 22),
          const _AppearUp(delayMs: 80, child: _SummaryPanel()),
          const SizedBox(height: 18),
          const _AppearUp(delayMs: 140, child: _HeroBanner()),
          const SizedBox(height: 20),
          _AppearUp(
            delayMs: 190,
            child: _SectionHeader(
              title: 'Quick Access',
              actionText: 'Edit',
              onTap: _openEditSheet,
            ),
          ),
          const SizedBox(height: 12),
          _AppearUp(
            delayMs: 250,
            child: _QuickAccessGrid(
              items: _quickItems,
              onOpenMenu: widget.onOpenMenu,
            ),
          ),
          const SizedBox(height: 22),
          const _AppearUp(
            delayMs: 300,
            child: _SectionHeader(
              title: 'Recent Activity',
              actionText: 'View all',
              onTap: _noop,
            ),
          ),
          const SizedBox(height: 12),
          const _AppearUp(delayMs: 360, child: _RecentActivityCard()),
        ],
      ),
    );
  }
}

void _noop() {}

const List<_MenuItemData> _allQuickMenus = [
  _MenuItemData(
    title: 'Attendance',
    icon: PhosphorIconsFill.calendarCheck,
    active: true,
    color: Color(0xFF156DFF),
    bgColor: Color(0xFFEAF2FF),
  ),
  _MenuItemData(
    title: 'Revisi Absen',
    icon: PhosphorIconsFill.calendarX,
    color: Color(0xFFD97706),
    bgColor: Color(0xFFFEF3C7),
  ),
  _MenuItemData(
    title: 'Leave',
    icon: PhosphorIconsFill.umbrella,
    color: Color(0xFF7C3AED),
    bgColor: Color(0xFFF3E8FF),
  ),
  _MenuItemData(
    title: 'Roster',
    icon: PhosphorIconsFill.clipboardText,
    color: Color(0xFF0891B2),
    bgColor: Color(0xFFECFEFF),
  ),
  _MenuItemData(
    title: 'Struktur Organisasi',
    icon: PhosphorIconsFill.gitBranch,
    color: Color(0xFF0E7490),
    bgColor: Color(0xFFE0F2FE),
  ),
  _MenuItemData(
    title: 'Absen Makan',
    icon: PhosphorIconsFill.forkKnife,
    color: Color(0xFF16A34A),
    bgColor: Color(0xFFDCFCE7),
  ),
  _MenuItemData(
    title: 'Her Registration',
    icon: PhosphorIconsFill.identificationCard,
    color: Color(0xFF1D4ED8),
    bgColor: Color(0xFFEFF6FF),
  ),
  _MenuItemData(
    title: 'Revisi Jadwal',
    icon: PhosphorIconsFill.calendarSlash,
    color: Color(0xFFDC2626),
    bgColor: Color(0xFFFEE2E2),
  ),
  _MenuItemData(
    title: 'Payslip',
    icon: PhosphorIconsFill.money,
    color: Color(0xFF059669),
    bgColor: Color(0xFFECFDF5),
  ),
];

class _TasksPage extends StatelessWidget {
  const _TasksPage({required this.onOpenMenu});

  final ValueChanged<String> onOpenMenu;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
      children: [
        const _AppearUp(
          delayMs: 20,
          child: Text(
            'Task Center',
            style: TextStyle(
              color: _Palette.navy,
              fontFamily: _headingFont,
              fontSize: 30,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 8),
        const _AppearUp(
          delayMs: 70,
          child: Text(
            'Kelola persetujuan dan pekerjaan harian Anda.',
            style: TextStyle(
              color: _Palette.muted,
              fontFamily: _bodyFont,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 18),
        _AppearUp(
          delayMs: 130,
          child: _TaskCard(
            title: 'Attendance Approval',
            subtitle: '2 pending items',
            icon: PhosphorIconsRegular.clockCountdown,
            onTap: () => onOpenMenu('Attendance'),
          ),
        ),
        const SizedBox(height: 12),
        _AppearUp(
          delayMs: 190,
          child: _TaskCard(
            title: 'Leave Requests',
            subtitle: 'Coming soon',
            icon: PhosphorIconsRegular.notebook,
            onTap: () => onOpenMenu('Requests'),
          ),
        ),
      ],
    );
  }
}

// ─── Profile Page ────────────────────────────────────────────────────────────

class _ProfilePage extends StatefulWidget {
  const _ProfilePage();

  @override
  State<_ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<_ProfilePage> {
  bool _notifEnabled = true;
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 32),
      children: [
        // ── Hero Header ─────────────────────────────────────────────────────
        _AppearUp(
          delayMs: 0,
          child: _ProfileHeroHeader(
            name: 'Lulus Bagos H',
            position: 'IT Application Developer',
            department: 'Technology & Information',
            employeeId: 'EMP-2024-0089',
            joinDate: 'Maret 2024',
            status: 'Aktif',
          ),
        ),

        // ── Stats row ───────────────────────────────────────────────────────
        _AppearUp(
          delayMs: 60,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              children: [
                _ProfileStatTile(
                  label: 'Kehadiran',
                  value: '96%',
                  sub: 'Bulan ini',
                  icon: PhosphorIconsFill.calendarCheck,
                  accent: const Color(0xFF156DFF),
                ),
                const SizedBox(width: 10),
                _ProfileStatTile(
                  label: 'Sisa Cuti',
                  value: '12',
                  sub: 'Hari',
                  icon: PhosphorIconsFill.umbrella,
                  accent: const Color(0xFF7C3AED),
                ),
                const SizedBox(width: 10),
                _ProfileStatTile(
                  label: 'Lembur',
                  value: '8',
                  sub: 'Jam/bln',
                  icon: PhosphorIconsFill.clock,
                  accent: const Color(0xFF059669),
                ),
              ],
            ),
          ),
        ),

        // ── Informasi Pribadi ────────────────────────────────────────────────
        _AppearUp(
          delayMs: 100,
          child: _ProfileSection(
            title: 'Informasi Pribadi',
            icon: PhosphorIconsFill.userCircle,
            accent: const Color(0xFF156DFF),
            items: const [
              _ProfileInfoRow(
                icon: PhosphorIconsRegular.envelopeSimple,
                label: 'Email',
                value: 'lulus.bagos@indeximcoalindo.co.id',
              ),
              _ProfileInfoRow(
                icon: PhosphorIconsRegular.phone,
                label: 'Telepon',
                value: '+62 812-3456-7890',
              ),
              _ProfileInfoRow(
                icon: PhosphorIconsRegular.cake,
                label: 'Tanggal Lahir',
                value: '15 Agustus 1996',
              ),
              _ProfileInfoRow(
                icon: PhosphorIconsRegular.mapPin,
                label: 'Alamat',
                value: 'Sangatta, Kalimantan Timur',
              ),
            ],
          ),
        ),

        // ── Informasi Pekerjaan ──────────────────────────────────────────────
        _AppearUp(
          delayMs: 140,
          child: _ProfileSection(
            title: 'Informasi Pekerjaan',
            icon: PhosphorIconsFill.briefcase,
            accent: const Color(0xFF7C3AED),
            items: const [
              _ProfileInfoRow(
                icon: PhosphorIconsRegular.identificationCard,
                label: 'NIK Karyawan',
                value: 'EMP-2024-0089',
              ),
              _ProfileInfoRow(
                icon: PhosphorIconsRegular.suitcase,
                label: 'Jabatan',
                value: 'IT Application Developer',
              ),
              _ProfileInfoRow(
                icon: PhosphorIconsRegular.buildings,
                label: 'Divisi',
                value: 'Technology & Information',
              ),
              _ProfileInfoRow(
                icon: PhosphorIconsRegular.mapTrifold,
                label: 'Lokasi Kerja',
                value: 'Head Office – Sangatta',
              ),
              _ProfileInfoRow(
                icon: PhosphorIconsRegular.calendarBlank,
                label: 'Bergabung',
                value: 'Maret 2024',
              ),
              _ProfileInfoRow(
                icon: PhosphorIconsRegular.timer,
                label: 'Shift',
                value: 'Reguler 08:00 – 17:00',
              ),
            ],
          ),
        ),

        // ── Pengaturan ───────────────────────────────────────────────────────
        _AppearUp(
          delayMs: 180,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Container(
              decoration: _softCardDecoration(radius: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
                    child: Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0E7490).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            PhosphorIconsFill.gear,
                            color: Color(0xFF0E7490),
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Pengaturan',
                          style: TextStyle(
                            fontFamily: _headingFont,
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: _Palette.navy,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  // Notifikasi toggle
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 4,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          PhosphorIconsRegular.bell,
                          color: _Palette.muted,
                          size: 20,
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Notifikasi',
                                style: TextStyle(
                                  fontFamily: _bodyFont,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: _Palette.navy,
                                ),
                              ),
                              Text(
                                'Aktifkan push notification',
                                style: TextStyle(
                                  fontFamily: _bodyFont,
                                  fontSize: 12,
                                  color: _Palette.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch.adaptive(
                          value: _notifEnabled,
                          activeThumbColor: Colors.white,
                          activeTrackColor: _Palette.blue,
                          onChanged: (v) =>
                              setState(() => _notifEnabled = v),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  // Dark mode toggle
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 4,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          PhosphorIconsRegular.moon,
                          color: _Palette.muted,
                          size: 20,
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tema Gelap',
                                style: TextStyle(
                                  fontFamily: _bodyFont,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: _Palette.navy,
                                ),
                              ),
                              Text(
                                'Tampilan dark mode',
                                style: TextStyle(
                                  fontFamily: _bodyFont,
                                  fontSize: 12,
                                  color: _Palette.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch.adaptive(
                          value: _darkMode,
                          activeThumbColor: Colors.white,
                          activeTrackColor: _Palette.blue,
                          onChanged: (v) =>
                              setState(() => _darkMode = v),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  // Ubah Password
                  _ProfileSettingTile(
                    icon: PhosphorIconsRegular.lockKey,
                    label: 'Ubah Password',
                    onTap: () {},
                  ),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  // Bahasa
                  _ProfileSettingTile(
                    icon: PhosphorIconsRegular.translate,
                    label: 'Bahasa',
                    trailing: const Text(
                      'Indonesia',
                      style: TextStyle(
                        fontFamily: _bodyFont,
                        fontSize: 13,
                        color: _Palette.muted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onTap: () {},
                  ),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  // Tentang Aplikasi
                  _ProfileSettingTile(
                    icon: PhosphorIconsRegular.info,
                    label: 'Tentang Aplikasi',
                    onTap: () => _showAboutDialog(context),
                  ),
                  const SizedBox(height: 6),
                ],
              ),
            ),
          ),
        ),

        // ── Versi ────────────────────────────────────────────────────────────
        _AppearUp(
          delayMs: 200,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
            child: Center(
              child: Text(
                'HERO v1.0.0 • PT INDEXIM COALINDO',
                style: TextStyle(
                  fontFamily: _bodyFont,
                  fontSize: 11,
                  color: _Palette.muted.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),

        // ── Logout Button ────────────────────────────────────────────────────
        _AppearUp(
          delayMs: 220,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFEF2F2),
                  foregroundColor: const Color(0xFFDC2626),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(
                      color: Color(0xFFFECACA),
                    ),
                  ),
                ),
                icon: const Icon(PhosphorIconsFill.signOut, size: 20),
                label: const Text(
                  'Keluar',
                  style: TextStyle(
                    fontFamily: _headingFont,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                onPressed: () => _showLogoutDialog(context),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'HERO App',
          style: TextStyle(
            fontFamily: _headingFont,
            fontWeight: FontWeight.w800,
            color: _Palette.navy,
          ),
        ),
        content: const Text(
          'HR Employee Online — Aplikasi manajemen SDM PT INDEXIM COALINDO.\n\nVersi: 1.0.0\nDibuat dengan Flutter.',
          style: TextStyle(
            fontFamily: _bodyFont,
            color: _Palette.muted,
            height: 1.6,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Tutup',
              style: TextStyle(
                fontFamily: _headingFont,
                fontWeight: FontWeight.w700,
                color: _Palette.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Keluar',
          style: TextStyle(
            fontFamily: _headingFont,
            fontWeight: FontWeight.w800,
            color: _Palette.navy,
          ),
        ),
        content: const Text(
          'Apakah Anda yakin ingin keluar dari aplikasi?',
          style: TextStyle(fontFamily: _bodyFont, color: _Palette.muted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Batal',
              style: TextStyle(
                fontFamily: _bodyFont,
                fontWeight: FontWeight.w600,
                color: _Palette.muted,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pushNamedAndRemoveUntil(
                AppRoutes.login,
                (_) => false,
              );
            },
            child: const Text(
              'Keluar',
              style: TextStyle(
                fontFamily: _headingFont,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Profile Hero Header ──────────────────────────────────────────────────────

class _ProfileHeroHeader extends StatelessWidget {
  const _ProfileHeroHeader({
    required this.name,
    required this.position,
    required this.department,
    required this.employeeId,
    required this.joinDate,
    required this.status,
  });

  final String name;
  final String position;
  final String department;
  final String employeeId;
  final String joinDate;
  final String status;

  @override
  Widget build(BuildContext context) {
    // Split initials from name
    final parts = name.trim().split(' ');
    final initials = parts.length >= 2
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : name.substring(0, 2).toUpperCase();

    return Container(
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF061B49), Color(0xFF0A2E7A)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 28),
          child: Column(
            children: [
              // Avatar
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 86,
                    height: 86,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF156DFF), Color(0xFF0A4FCC)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF156DFF).withValues(alpha: 0.5),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        initials,
                        style: const TextStyle(
                          fontFamily: _headingFont,
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  // Camera badge
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF061B49),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      PhosphorIconsFill.camera,
                      size: 14,
                      color: _Palette.navy,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Name
              Text(
                name,
                style: const TextStyle(
                  fontFamily: _headingFont,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 4),

              // Position
              Text(
                position,
                style: TextStyle(
                  fontFamily: _bodyFont,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.75),
                ),
              ),
              const SizedBox(height: 4),

              // Department chip
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF156DFF).withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: const Color(0xFF156DFF).withValues(alpha: 0.5),
                  ),
                ),
                child: Text(
                  department,
                  style: const TextStyle(
                    fontFamily: _bodyFont,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // ID + Status row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    PhosphorIconsRegular.identificationCard,
                    size: 14,
                    color: Colors.white.withValues(alpha: 0.55),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    employeeId,
                    style: TextStyle(
                      fontFamily: _bodyFont,
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF16A34A).withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFF4ADE80),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          status,
                          style: const TextStyle(
                            fontFamily: _bodyFont,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF4ADE80),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Profile Stat Tile ────────────────────────────────────────────────────────

class _ProfileStatTile extends StatelessWidget {
  const _ProfileStatTile({
    required this.label,
    required this.value,
    required this.sub,
    required this.icon,
    required this.accent,
  });

  final String label;
  final String value;
  final String sub;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A061B49),
              blurRadius: 12,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: accent, size: 16),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontFamily: _headingFont,
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: accent,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              sub,
              style: const TextStyle(
                fontFamily: _bodyFont,
                fontSize: 10,
                color: _Palette.muted,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: _bodyFont,
                fontSize: 11,
                color: _Palette.navy,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Profile Section ──────────────────────────────────────────────────────────

class _ProfileSection extends StatelessWidget {
  const _ProfileSection({
    required this.title,
    required this.icon,
    required this.accent,
    required this.items,
  });

  final String title;
  final IconData icon;
  final Color accent;
  final List<_ProfileInfoRow> items;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        decoration: _softCardDecoration(radius: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: accent, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: _headingFont,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: _Palette.navy,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            ...items.map((item) {
              final idx = items.indexOf(item);
              return Column(
                children: [
                  item,
                  if (idx < items.length - 1)
                    const Divider(
                      height: 1,
                      indent: 52,
                      color: Color(0xFFF1F5F9),
                    ),
                ],
              );
            }),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}

// ─── Profile Info Row ─────────────────────────────────────────────────────────

class _ProfileInfoRow extends StatelessWidget {
  const _ProfileInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: _Palette.muted),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: _bodyFont,
                    fontSize: 11,
                    color: _Palette.muted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontFamily: _bodyFont,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _Palette.navy,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Profile Setting Tile ─────────────────────────────────────────────────────

class _ProfileSettingTile extends StatelessWidget {
  const _ProfileSettingTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: _Palette.muted),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontFamily: _bodyFont,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _Palette.navy,
                ),
              ),
            ),
            trailing ??
                const Icon(
                  PhosphorIconsRegular.caretRight,
                  size: 16,
                  color: _Palette.muted,
                ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good morning,',
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: _bodyFont,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF334155),
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Hai Lulus Bagos H',
                style: TextStyle(
                  fontSize: 33,
                  fontFamily: _headingFont,
                  fontWeight: FontWeight.w800,
                  color: _Palette.navy,
                  height: 1.06,
                  letterSpacing: -0.6,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Your workspace overview',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: _bodyFont,
                  color: _Palette.muted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        const _HeaderActions(),
      ],
    );
  }
}

class _HeaderActions extends StatelessWidget {
  const _HeaderActions();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _HeaderIconButton(
          icon: PhosphorIconsRegular.bell,
          showDot: true,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const _NotificationCenterPage(),
              ),
            );
          },
        ),
        const SizedBox(width: 10),
        CircleAvatar(
          radius: 24,
          backgroundColor: Colors.white,
          child: CircleAvatar(
            radius: 21,
            backgroundColor: Color(0xFFEAF2FF),
            child: Icon(PhosphorIconsFill.user, color: _Palette.blue),
          ),
        ),
      ],
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    this.showDot = false,
    this.onTap,
  });

  final IconData icon;
  final bool showDot;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onTap,
            child: Container(
              width: 52,
              height: 52,
              decoration: _softCardDecoration(radius: 18),
              child: Icon(icon, color: _Palette.navy),
            ),
          ),
        ),
        if (showDot)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: _Palette.blue,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
      ],
    );
  }
}

class _SummaryPanel extends StatelessWidget {
  const _SummaryPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _softCardDecoration(radius: 24),
      child: const Row(
        children: [
          Expanded(
            child: _SummaryItem(
              icon: PhosphorIconsRegular.calendar,
              title: 'Attendance',
              value: '88%',
              subtitle: 'Checked in today',
              active: true,
            ),
          ),
          Expanded(
            child: _SummaryItem(
              icon: PhosphorIconsRegular.fileText,
              title: 'Requests',
              value: '—',
              subtitle: 'Coming Soon',
            ),
          ),
          Expanded(
            child: _SummaryItem(
              icon: PhosphorIconsRegular.users,
              title: 'People',
              value: '—',
              subtitle: 'Coming Soon',
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
    this.active = false,
  });

  final IconData icon;
  final String title;
  final String value;
  final String subtitle;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: active ? 1 : 0.58,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: active ? const Color(0xFFBFD7FF) : const Color(0xFFE8EEF8),
          ),
          color: Colors.white,
        ),
        child: Column(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: active ? const Color(0xFFEAF2FF) : const Color(0xFFF3F6FA),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: active ? _Palette.blue : const Color(0xFF9AA6B7)),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _Palette.navy,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              value,
              style: TextStyle(
                color: active ? _Palette.blue : const Color(0xFFB7C0CC),
                fontSize: 30,
                fontWeight: FontWeight.w800,
                height: 1,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _Palette.muted,
                fontSize: 11.8,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroBanner extends StatefulWidget {
  const _HeroBanner();

  @override
  State<_HeroBanner> createState() => _HeroBannerState();
}

class _HeroBannerState extends State<_HeroBanner> {
  late final PageController _pageController;
  Timer? _autoSlideTimer;
  int _currentIndex = 0;

  static const List<_BannerData> _banners = [
    _BannerData(
      title: 'HERO is here to simplify\nyour workday.',
      subtitle: 'Attendance is active.\nMore features coming soon!',
      icon: PhosphorIconsFill.calendarCheck,
      colors: [Color(0xFF2F80FF), Color(0xFF0A4FD7)],
    ),
    _BannerData(
      title: 'Track attendance\nwith trusted GPS.',
      subtitle: 'Anti-mock checks are enabled\nfor safer validation.',
      icon: PhosphorIconsFill.mapPin,
      colors: [Color(0xFF00A59A), Color(0xFF037971)],
    ),
    _BannerData(
      title: 'Quick access for\nyour daily actions.',
      subtitle: 'Open Attendance and tasks\nin one tap from Home.',
      icon: PhosphorIconsFill.lightning,
      colors: [Color(0xFF4D6CFF), Color(0xFF2C42CE)],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 1);
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!_pageController.hasClients || _banners.length <= 1) {
        return;
      }
      final nextPage = (_currentIndex + 1) % _banners.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 188,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFFF3F8FF), Color(0xFFEAF2FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: const Color(0xFFD9E7FF)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            const Positioned.fill(child: _BannerAccentPainterWidget()),
            PageView.builder(
              controller: _pageController,
              itemCount: _banners.length,
              onPageChanged: (index) {
                setState(() => _currentIndex = index);
              },
              itemBuilder: (context, index) {
                return _BannerSlide(data: _banners[index]);
              },
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 14,
              child: Row(
                children: List.generate(
                  _banners.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    margin: EdgeInsets.only(right: index == _banners.length - 1 ? 0 : 6),
                    width: _currentIndex == index ? 18 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: _currentIndex == index
                          ? _Palette.blue
                          : _Palette.blue.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BannerSlide extends StatelessWidget {
  const _BannerSlide({required this.data});

  final _BannerData data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 16, 30),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: const TextStyle(
                    color: _Palette.navy,
                    fontSize: 31,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  data.subtitle,
                  style: const TextStyle(
                    color: _Palette.muted,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 114,
            height: 114,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: data.colors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              data.icon,
              color: Colors.white,
              size: 48,
            ),
          ),
        ],
      ),
    );
  }
}

class _BannerData {
  const _BannerData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.colors,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> colors;
}

class _QuickAccessGrid extends StatelessWidget {
  const _QuickAccessGrid({
    required this.items,
    required this.onOpenMenu,
  });

  final List<_MenuItemData> items;
  final ValueChanged<String> onOpenMenu;

  List<_MenuItemData> get _padded {
    const blank = _MenuItemData(
      title: '',
      icon: PhosphorIconsRegular.plus,
      color: Color(0xFF94A3B8),
      bgColor: Color(0xFFF8FAFC),
    );
    final list = List<_MenuItemData>.from(items);
    while (list.length < 8) {
      list.add(blank);
    }
    return list.take(8).toList();
  }

  @override
  Widget build(BuildContext context) {
    final menus = _padded;
    return GridView.builder(
      itemCount: menus.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      itemBuilder: (context, index) {
        final item = menus[index];
        return _QuickAccessTile(
          data: item,
          onTap: () {
            if (item.title.isNotEmpty) {
              onOpenMenu(item.title);
            }
          },
        );
      },
    );
  }
}

class _MenuItemData {
  const _MenuItemData({
    required this.title,
    required this.icon,
    this.active = false,
    this.color = _Palette.blue,
    this.bgColor = const Color(0xFFEAF2FF),
  });

  final String title;
  final IconData icon;
  final bool active;
  final Color color;
  final Color bgColor;
}

class _QuickAccessTile extends StatefulWidget {
  const _QuickAccessTile({required this.data, required this.onTap});

  final _MenuItemData data;
  final VoidCallback onTap;

  @override
  State<_QuickAccessTile> createState() => _QuickAccessTileState();
}

class _QuickAccessTileState extends State<_QuickAccessTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final isBlank = data.title.isEmpty;
    return AnimatedScale(
      scale: _pressed ? 0.96 : 1,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: isBlank ? null : widget.onTap,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 190),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            gradient: data.active && !isBlank
                ? const LinearGradient(
                    colors: [Color(0xFF1A6BFF), Color(0xFF0A4FC9)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: data.active || isBlank ? null : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isBlank
                  ? const Color(0xFFE2E8F0)
                  : data.active
                      ? Colors.transparent
                      : data.color.withValues(alpha: 0.30),
            ),
            boxShadow: [
              BoxShadow(
                color: data.active
                    ? _Palette.blue.withValues(alpha: 0.18)
                    : Colors.black.withValues(alpha: 0.05),
                blurRadius: data.active ? 16 : 9,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: isBlank
                      ? const Color(0xFFF1F5F9)
                      : data.active
                          ? Colors.white.withValues(alpha: 0.2)
                          : data.bgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  data.icon,
                  color: isBlank
                      ? const Color(0xFF94A3B8)
                      : data.active
                          ? Colors.white
                          : data.color,
                  size: 20,
                ),
              ),
              const SizedBox(height: 9),
              Text(
                isBlank ? 'Kosong' : data.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isBlank
                      ? const Color(0xFF94A3B8)
                      : data.active
                          ? Colors.white
                          : _Palette.navy,
                  fontSize: 11.6,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditQuickAccessSheet extends StatefulWidget {
  const _EditQuickAccessSheet({
    required this.selected,
    required this.onSave,
  });

  final List<_MenuItemData> selected;
  final ValueChanged<List<_MenuItemData>> onSave;

  @override
  State<_EditQuickAccessSheet> createState() => _EditQuickAccessSheetState();
}

class _EditQuickAccessSheetState extends State<_EditQuickAccessSheet> {
  late List<_MenuItemData> _selected;

  @override
  void initState() {
    super.initState();
    _selected = List<_MenuItemData>.from(widget.selected);
  }

  bool _contains(_MenuItemData item) {
    return _selected.any((e) => e.title == item.title);
  }

  void _toggle(_MenuItemData item) {
    setState(() {
      if (_contains(item)) {
        if (item.active) {
          return;
        }
        _selected.removeWhere((e) => e.title == item.title);
      } else {
        if (_selected.length >= 8) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Maksimal 8 menu untuk Quick Access'),
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }
        _selected.add(item);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.86),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FBFF),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFD9E2EC),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 10),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Edit Quick Access',
                    style: TextStyle(
                      color: _Palette.navy,
                      fontFamily: _headingFont,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  '${_selected.length}/8',
                  style: const TextStyle(
                    color: _Palette.blue,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              itemCount: _allQuickMenus.length,
              itemBuilder: (context, index) {
                final item = _allQuickMenus[index];
                final selected = _contains(item);
                return _EditMenuTile(
                  item: item,
                  selected: selected,
                  onTap: () => _toggle(item),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  widget.onSave(List<_MenuItemData>.from(_selected));
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _Palette.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Simpan', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditMenuTile extends StatelessWidget {
  const _EditMenuTile({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _MenuItemData item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            color: selected ? item.bgColor : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? item.color.withValues(alpha: 0.45) : const Color(0xFFE5EDF7),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: selected ? item.color.withValues(alpha: 0.18) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(item.icon, color: selected ? item.color : const Color(0xFF94A3B8), size: 19),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.title,
                  style: TextStyle(
                    color: selected ? _Palette.navy : const Color(0xFF475569),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Icon(
                selected ? PhosphorIconsFill.checkCircle : PhosphorIconsRegular.circle,
                color: selected ? item.color : const Color(0xFFB6C1CD),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppearUp extends StatefulWidget {
  const _AppearUp({required this.child, this.delayMs = 0});

  final Widget child;
  final int delayMs;

  @override
  State<_AppearUp> createState() => _AppearUpState();
}

class _AppearUpState extends State<_AppearUp> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(Duration(milliseconds: widget.delayMs), () {
      if (!mounted) {
        return;
      }
      setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      offset: _visible ? Offset.zero : const Offset(0, 0.05),
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        opacity: _visible ? 1 : 0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

class _RecentActivityCard extends StatelessWidget {
  const _RecentActivityCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _softCardDecoration(radius: 22),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: const Column(
        children: [
          _ActivityItem(
            icon: PhosphorIconsRegular.checkCircle,
            title: 'Checked in',
            subtitle: 'Today, 9:02 AM  •  Office',
            badge: 'On time',
            badgeColor: Color(0xFFE8F8EF),
            badgeTextColor: Color(0xFF128645),
          ),
          Divider(height: 1, color: Color(0xFFE6ECF5)),
          _ActivityItem(
            icon: PhosphorIconsRegular.check,
            title: 'Checked out',
            subtitle: 'Yesterday, 6:01 PM  •  Office',
            badge: 'Early',
            badgeColor: Color(0xFFEAF2FF),
            badgeTextColor: _Palette.blue,
          ),
        ],
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  const _ActivityItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.badgeColor,
    required this.badgeTextColor,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String badge;
  final Color badgeColor;
  final Color badgeTextColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF2FF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: _Palette.blue, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _Palette.navy,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: _Palette.muted,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              badge,
              style: TextStyle(
                color: badgeTextColor,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: _softCardDecoration(radius: 20),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF2FF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: _Palette.blue),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: _Palette.navy,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: _Palette.muted,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(PhosphorIconsRegular.caretRight, color: _Palette.muted),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.actionText,
    required this.onTap,
  });

  final String title;
  final String actionText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: _Palette.navy,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const Spacer(),
        InkWell(
          onTap: onTap,
          child: Text(
            actionText,
            style: const TextStyle(
              color: _Palette.blue,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _NotificationCenterPage extends StatefulWidget {
  const _NotificationCenterPage();

  @override
  State<_NotificationCenterPage> createState() => _NotificationCenterPageState();
}

class _NotificationCenterPageState extends State<_NotificationCenterPage> {
  late final List<_NotificationItemData> _items = <_NotificationItemData>[
    _NotificationItemData(
      title: 'Update Her Registrasi Karyawan',
      time: 'Baru saja',
      icon: PhosphorIconsFill.identificationCard,
      accent: const Color(0xFF0284C7),
      htmlBody:
          '<p>Dokumen <strong>Her Registrasi</strong> untuk periode Mei sudah siap diperiksa.</p><p>Mohon validasi sebelum <strong>17:00 WIB</strong>.</p>',
    ),
    _NotificationItemData(
      title: 'Pengajuan Revisi Absen Disetujui',
      time: '10 menit lalu',
      icon: PhosphorIconsFill.calendarCheck,
      accent: const Color(0xFF0EA5E9),
      htmlBody:
          '<p>Request revisi absen Anda telah <strong>disetujui</strong> oleh supervisor.</p><p>Status terbaru: <em>approved</em>.</p>',
    ),
    _NotificationItemData(
      title: 'Pengingat Ulang Tahun Tim',
      time: '1 jam lalu',
      icon: PhosphorIconsFill.cake,
      accent: const Color(0xFFE11D48),
      htmlBody:
          '<p>Hari ini ada <strong>2 karyawan</strong> yang berulang tahun.</p><p>Jangan lupa kirim ucapan melalui menu People.</p>',
      isRead: true,
    ),
    _NotificationItemData(
      title: 'Jadwal Shift Diperbarui',
      time: 'Kemarin',
      icon: PhosphorIconsFill.clock,
      accent: const Color(0xFF6366F1),
      htmlBody:
          '<p>Perubahan jadwal untuk minggu depan sudah dipublish.</p><p><strong>Silakan cek roster terbaru</strong> di menu Quick Access.</p>',
      isRead: true,
    ),
  ];

  int get _unreadCount => _items.where((e) => !e.isRead).length;

  void _markAsRead(int index) {
    if (_items[index].isRead) {
      return;
    }
    setState(() {
      _items[index] = _items[index].copyWith(isRead: true);
    });
  }

  void _markAllAsRead() {
    setState(() {
      for (int i = 0; i < _items.length; i++) {
        _items[i] = _items[i].copyWith(isRead: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 8,
        title: const Text(
          'Notification Center',
          style: TextStyle(
            color: _Palette.navy,
            fontFamily: _headingFont,
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
        iconTheme: const IconThemeData(color: _Palette.navy),
        actions: [
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text(
                'Mark all read',
                style: TextStyle(
                  color: _Palette.blue,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFEAF2FF), Color(0xFFF3F8FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFD8E7FF)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: const Icon(PhosphorIconsFill.bell, color: _Palette.blue, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _unreadCount == 0
                          ? 'Semua notifikasi sudah dibaca'
                          : 'Anda memiliki $_unreadCount notifikasi baru',
                      style: const TextStyle(
                        color: _Palette.navy,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
              itemCount: _items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = _items[index];
                return _NotificationCard(
                  data: item,
                  onTap: () => _markAsRead(index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatefulWidget {
  const _NotificationCard({required this.data, required this.onTap});

  final _NotificationItemData data;
  final VoidCallback onTap;

  @override
  State<_NotificationCard> createState() => _NotificationCardState();
}

class _NotificationCardState extends State<_NotificationCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.data;
    final isRead = item.isRead;
    return AnimatedScale(
      scale: _pressed ? 0.985 : 1,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: widget.onTap,
          onTapDown: (_) => setState(() => _pressed = true),
          onTapCancel: () => setState(() => _pressed = false),
          onTapUp: (_) => setState(() => _pressed = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isRead ? const Color(0xFFF8FAFD) : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isRead ? const Color(0xFFE8EEF7) : item.accent.withValues(alpha: 0.32),
                width: isRead ? 1 : 1.4,
              ),
              boxShadow: [
                BoxShadow(
                  color: isRead
                      ? Colors.black.withValues(alpha: 0.02)
                      : item.accent.withValues(alpha: 0.10),
                  blurRadius: isRead ? 8 : 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: item.accent.withValues(alpha: isRead ? 0.10 : 0.18),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(item.icon, color: item.accent, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              style: TextStyle(
                                color: isRead ? const Color(0xFF5F6F83) : _Palette.navy,
                                fontSize: 14.5,
                                fontWeight: isRead ? FontWeight.w600 : FontWeight.w800,
                              ),
                            ),
                          ),
                          if (!isRead)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: item.accent.withValues(alpha: 0.16),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                'BARU',
                                style: TextStyle(
                                  color: item.accent,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.time,
                        style: const TextStyle(
                          color: _Palette.muted,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Html(
                        data: item.htmlBody,
                        style: {
                          'body': Style(
                            margin: Margins.zero,
                            padding: HtmlPaddings.zero,
                            fontSize: FontSize(13),
                            color: isRead ? const Color(0xFF7B8798) : const Color(0xFF2F3D52),
                            lineHeight: const LineHeight(1.35),
                            fontWeight: FontWeight.w500,
                          ),
                          'p': Style(
                            margin: Margins.only(bottom: 6),
                          ),
                          'strong': Style(
                            color: isRead ? const Color(0xFF5F6F83) : _Palette.navy,
                            fontWeight: FontWeight.w800,
                          ),
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationItemData {
  const _NotificationItemData({
    required this.title,
    required this.htmlBody,
    required this.time,
    required this.icon,
    required this.accent,
    this.isRead = false,
  });

  final String title;
  final String htmlBody;
  final String time;
  final IconData icon;
  final Color accent;
  final bool isRead;

  _NotificationItemData copyWith({bool? isRead}) {
    return _NotificationItemData(
      title: title,
      htmlBody: htmlBody,
      time: time,
      icon: icon,
      accent: accent,
      isRead: isRead ?? this.isRead,
    );
  }
}

class _GlobalBottomNavigation extends StatelessWidget {
  const _GlobalBottomNavigation({
    required this.currentIndex,
    required this.tabs,
    required this.onChanged,
  });

  final int currentIndex;
  final List<_TabData> tabs;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.98),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _Palette.navy.withValues(alpha: 0.1),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final tab = tabs[index];
          final active = index == currentIndex;
          return Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => onChanged(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: active ? const Color(0xFFEAF2FF) : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      active ? tab.active : tab.inactive,
                      color: active ? _Palette.blue : const Color(0xFF475569),
                      size: 22,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      tab.label,
                      style: TextStyle(
                        color: active ? _Palette.blue : const Color(0xFF475569),
                        fontSize: 12,
                        fontWeight: active ? FontWeight.w700 : FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _ProfessionalBackground extends StatelessWidget {
  const _ProfessionalBackground();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ProfessionalBackgroundPainter(),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFFFFF), Color(0xFFF4F8FF), Color(0xFFEDF4FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    );
  }
}

class _ProfessionalBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = _Palette.blue.withValues(alpha: 0.1)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final softLinePaint = Paint()
      ..color = const Color(0xFF0F2A5F).withValues(alpha: 0.06)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = _Palette.blue.withValues(alpha: 0.16)
      ..style = PaintingStyle.fill;

    final glowPaint = Paint()
      ..color = _Palette.blue.withValues(alpha: 0.055)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(size.width * 0.92, size.height * 0.10), 150, glowPaint);
    canvas.drawCircle(Offset(size.width * 0.10, size.height * 0.82), 170, glowPaint);

    for (int i = 0; i < 5; i++) {
      final offset = i * 18;
      canvas.drawLine(
        Offset(size.width * 0.55 + offset, 0),
        Offset(size.width + offset, size.height * 0.36),
        softLinePaint,
      );
    }

    final arcRect = Rect.fromCircle(
      center: Offset(size.width * 0.78, size.height * 0.38),
      radius: size.width * 0.42,
    );
    canvas.drawArc(arcRect, math.pi * 0.80, math.pi * 0.95, false, linePaint);

    for (int i = 0; i < 7; i++) {
      for (int j = 0; j < 6; j++) {
        canvas.drawCircle(Offset(size.width * 0.62 + i * 10, size.height * 0.33 + j * 10), 1.4, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BannerAccentPainterWidget extends StatelessWidget {
  const _BannerAccentPainterWidget();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _BannerAccentPainter());
  }
}

class _BannerAccentPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = _Palette.blue.withValues(alpha: 0.12)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = _Palette.blue.withValues(alpha: 0.06)
      ..style = PaintingStyle.fill;

    final wave = Path()
      ..moveTo(size.width * 0.38, size.height * 0.72)
      ..quadraticBezierTo(size.width * 0.56, size.height * 0.48, size.width * 0.76, size.height * 0.63)
      ..quadraticBezierTo(size.width * 0.90, size.height * 0.74, size.width, size.height * 0.48)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width * 0.38, size.height)
      ..close();

    canvas.drawPath(wave, fillPaint);

    final arcRect = Rect.fromCircle(
      center: Offset(size.width * 0.78, size.height * 0.83),
      radius: size.width * 0.25,
    );
    canvas.drawArc(arcRect, math.pi * 1.10, math.pi * 0.75, false, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Palette {
  static const navy = Color(0xFF061B49);
  static const blue = Color(0xFF156DFF);
  static const muted = Color(0xFF718096);
}

class _TabData {
  const _TabData({required this.label, required this.active, required this.inactive});

  final String label;
  final IconData active;
  final IconData inactive;
}

BoxDecoration _softCardDecoration({double radius = 22}) {
  return BoxDecoration(
    color: Colors.white.withValues(alpha: 0.95),
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: Colors.white, width: 1.2),
    boxShadow: [
      BoxShadow(
        color: _Palette.navy.withValues(alpha: 0.08),
        blurRadius: 24,
        offset: const Offset(0, 12),
      ),
    ],
  );
}
