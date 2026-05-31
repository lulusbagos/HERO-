import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hero/app/app_routes.dart';
import 'package:hero/core/enums/app_role.dart';
import 'package:hero/core/repositories/menu_repository.dart';
import 'package:hero/features/menu/pages/menu_screen.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';

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
    if (title.toLowerCase() == 'attendance') {
      Navigator.of(context).pushNamed(AppRoutes.attendance);
      return;
    }
    Navigator.of(context).pushNamed(MenuScreen.routeName, arguments: title);
  }
}

// ── Master list of ALL available Quick Access menus ─────────────────────────
const List<_MenuItemData> _allQuickMenus = [
  _MenuItemData(
    title: 'Attendance',
    icon: PhosphorIconsFill.calendarCheck,
    active: true,
    color: Color(0xFF1A6BFF),
    bgColor: Color(0xFF0A4FC9),
  ),
  _MenuItemData(
    title: 'Revisi Absen',
    icon: PhosphorIconsFill.calendarX,
    named: true,
    color: Color(0xFFD97706),
    bgColor: Color(0xFFFEF3C7),
  ),
  _MenuItemData(
    title: 'Leave',
    icon: PhosphorIconsFill.umbrella,
    named: true,
    color: Color(0xFF8B5CF6),
    bgColor: Color(0xFFF5F3FF),
  ),
  _MenuItemData(
    title: 'Roster',
    icon: PhosphorIconsFill.clipboardText,
    named: true,
    color: Color(0xFF0891B2),
    bgColor: Color(0xFFECFEFF),
  ),
  _MenuItemData(
    title: 'Absen Makan',
    icon: PhosphorIconsFill.forkKnife,
    named: true,
    color: Color(0xFF16A34A),
    bgColor: Color(0xFFDCFCE7),
  ),
  _MenuItemData(
    title: 'Revisi Jadwal',
    icon: PhosphorIconsFill.calendarSlash,
    named: true,
    color: Color(0xFFDC2626),
    bgColor: Color(0xFFFEE2E2),
  ),
  _MenuItemData(
    title: 'Lembur',
    icon: PhosphorIconsFill.clockCountdown,
    named: true,
    color: Color(0xFF7C3AED),
    bgColor: Color(0xFFEDE9FE),
  ),
  _MenuItemData(
    title: 'Reimburse',
    icon: PhosphorIconsFill.receipt,
    named: true,
    color: Color(0xFF0D9488),
    bgColor: Color(0xFFF0FDFA),
  ),
  _MenuItemData(
    title: 'Surat Tugas',
    icon: PhosphorIconsFill.newspaper,
    named: true,
    color: Color(0xFFB45309),
    bgColor: Color(0xFFFFFBEB),
  ),
  _MenuItemData(
    title: 'Pinjaman',
    icon: PhosphorIconsFill.bank,
    named: true,
    color: Color(0xFF1D4ED8),
    bgColor: Color(0xFFEFF6FF),
  ),
  _MenuItemData(
    title: 'Pengumuman',
    icon: PhosphorIconsFill.megaphone,
    named: true,
    color: Color(0xFFDB2777),
    bgColor: Color(0xFFFDF2F8),
  ),
  _MenuItemData(
    title: 'Payslip',
    icon: PhosphorIconsFill.money,
    named: true,
    color: Color(0xFF059669),
    bgColor: Color(0xFFECFDF5),
  ),
  _MenuItemData(
    title: 'Her Registrasi',
    icon: PhosphorIconsFill.identificationCard,
    named: true,
    color: Color(0xFF0284C7),
    bgColor: Color(0xFFE0F2FE),
  ),
  _MenuItemData(
    title: 'Ulang Tahun',
    icon: PhosphorIconsFill.cake,
    named: true,
    color: Color(0xFFE11D48),
    bgColor: Color(0xFFFFF1F2),
  ),
];

class _DashboardHome extends StatefulWidget {
  const _DashboardHome({required this.onOpenMenu});

  final ValueChanged<String> onOpenMenu;

  @override
  State<_DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<_DashboardHome> {
  // Default: first 8 items from master list (incl. 3 blanks)
  late List<_MenuItemData> _quickItems;

  @override
  void initState() {
    super.initState();
    _quickItems = _allQuickMenus.take(5).toList();
  }

  void _openEditSheet() {
    showModalBottomSheet(
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

class _TasksPage extends StatelessWidget {
  const _TasksPage({required this.onOpenMenu});

  final ValueChanged<String> onOpenMenu;

  // ── Task data ──────────────────────────────────────────────────────────────
  static const _categories = [
    _TaskCategory('Aktif', Color(0xFF156DFF)),
    _TaskCategory('Selesai', Color(0xFF22C55E)),
    _TaskCategory('Semua', Color(0xFF8B5CF6)),
  ];

  static const _stats = [
    _TaskStat('2', 'Pending', Color(0xFFF59E0B), Color(0xFFFEF3C7)),
    _TaskStat('1', 'In Review', Color(0xFF06B6D4), Color(0xFFECFEFF)),
    _TaskStat('12', 'Selesai', Color(0xFF22C55E), Color(0xFFDCFCE7)),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 0, 22, 32),
      children: [
        // ── Header gradient banner ────────────────────────────────────────────
        _AppearUp(
          delayMs: 0,
          child: Container(
            margin: const EdgeInsets.only(top: 22, bottom: 22),
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1A6BFF), Color(0xFF0A3DB0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF156DFF).withValues(alpha: 0.35),
                  blurRadius: 28,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // title row
                Row(
                  children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(PhosphorIconsFill.checkSquareOffset, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 14),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Task Center',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                        Text(
                          'Kelola persetujuan harian Anda',
                          style: TextStyle(
                            color: Color(0xFFB8D0FF),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // stats row
                Row(
                  children: _stats.map((s) {
                    return Expanded(
                      child: Container(
                        margin: EdgeInsets.only(
                          right: s == _stats.last ? 0 : 10,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                        ),
                        child: Column(
                          children: [
                            Text(
                              s.value,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                height: 1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              s.label,
                              style: const TextStyle(
                                color: Color(0xFFB8D0FF),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),

        // ── Category chips ────────────────────────────────────────────────────
        const _AppearUp(
          delayMs: 60,
          child: _TaskCategoryChips(),
        ),
        const SizedBox(height: 20),

        // ── Section: Perlu Tindakan ───────────────────────────────────────────
        const _AppearUp(
          delayMs: 100,
          child: _TaskSectionLabel(
            title: 'PERLU TINDAKAN',
            icon: PhosphorIconsFill.warningCircle,
            color: Color(0xFFF59E0B),
          ),
        ),
        const SizedBox(height: 10),
        _AppearUp(
          delayMs: 140,
          child: _PremiumTaskCard(
            title: 'Attendance Approval',
            subtitle: 'Tinjau permintaan kehadiran karyawan',
            tag: '2 Pending',
            tagColor: const Color(0xFFF59E0B),
            tagBg: const Color(0xFFFEF3C7),
            icon: PhosphorIconsFill.clockCountdown,
            iconBg: const Color(0xFFFEF3C7),
            iconColor: const Color(0xFFD97706),
            statusBar: const Color(0xFFF59E0B),
            onTap: () => onOpenMenu('Attendance'),
          ),
        ),
        const SizedBox(height: 10),
        _AppearUp(
          delayMs: 180,
          child: _PremiumTaskCard(
            title: 'Overtime Request',
            subtitle: 'Persetujuan lembur bulan ini',
            tag: '1 Baru',
            tagColor: const Color(0xFF06B6D4),
            tagBg: const Color(0xFFECFEFF),
            icon: PhosphorIconsFill.moon,
            iconBg: const Color(0xFFECFEFF),
            iconColor: const Color(0xFF0891B2),
            statusBar: const Color(0xFF06B6D4),
            onTap: () {},
          ),
        ),
        const SizedBox(height: 24),

        // ── Section: Coming Soon ──────────────────────────────────────────────
        const _AppearUp(
          delayMs: 220,
          child: _TaskSectionLabel(
            title: 'SEGERA HADIR',
            icon: PhosphorIconsFill.hourglass,
            color: Color(0xFF8B5CF6),
          ),
        ),
        const SizedBox(height: 10),
        _AppearUp(
          delayMs: 260,
          child: _ComingSoonTaskCard(
            title: 'Leave Requests',
            subtitle: 'Pengajuan cuti & izin',
            icon: PhosphorIconsFill.umbrella,
            iconColor: const Color(0xFF8B5CF6),
            iconBg: const Color(0xFFF5F3FF),
          ),
        ),
        const SizedBox(height: 10),
        _AppearUp(
          delayMs: 300,
          child: _ComingSoonTaskCard(
            title: 'Reimbursement',
            subtitle: 'Klaim penggantian biaya',
            icon: PhosphorIconsFill.receipt,
            iconColor: const Color(0xFF22C55E),
            iconBg: const Color(0xFFDCFCE7),
          ),
        ),
        const SizedBox(height: 10),
        _AppearUp(
          delayMs: 340,
          child: _ComingSoonTaskCard(
            title: 'Training & Development',
            subtitle: 'Jadwal pelatihan karyawan',
            icon: PhosphorIconsFill.graduationCap,
            iconColor: const Color(0xFF156DFF),
            iconBg: const Color(0xFFEAF2FF),
          ),
        ),
        const SizedBox(height: 10),
        _AppearUp(
          delayMs: 380,
          child: _ComingSoonTaskCard(
            title: 'Performance Review',
            subtitle: 'Evaluasi kinerja periodik',
            icon: PhosphorIconsFill.chartLineUp,
            iconColor: const Color(0xFF0EA5E9),
            iconBg: const Color(0xFFE0F2FE),
          ),
        ),
      ],
    );
  }
}

// ── Task section label ────────────────────────────────────────────────────────
class _TaskSectionLabel extends StatelessWidget {
  const _TaskSectionLabel({
    required this.title,
    required this.icon,
    required this.color,
  });
  final String title;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(
            color: color,
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(child: Divider(color: color.withValues(alpha: 0.18), height: 1)),
      ],
    );
  }
}

// ── Category chips (stateful) ─────────────────────────────────────────────────
class _TaskCategoryChips extends StatefulWidget {
  const _TaskCategoryChips();

  @override
  State<_TaskCategoryChips> createState() => _TaskCategoryChipsState();
}

class _TaskCategoryChipsState extends State<_TaskCategoryChips> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _TasksPage._categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = _TasksPage._categories[index];
          final active = _selected == index;
          return GestureDetector(
            onTap: () => setState(() => _selected = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: active ? cat.color : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: active ? cat.color : const Color(0xFFE2E8F0),
                  width: active ? 2 : 1,
                ),
                boxShadow: active
                    ? [BoxShadow(color: cat.color.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))]
                    : null,
              ),
              child: Text(
                cat.label,
                style: TextStyle(
                  color: active ? Colors.white : _Palette.muted,
                  fontSize: 13,
                  fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Premium task card (active) ────────────────────────────────────────────────
class _PremiumTaskCard extends StatelessWidget {
  const _PremiumTaskCard({
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.tagColor,
    required this.tagBg,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.statusBar,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String tag;
  final Color tagColor;
  final Color tagBg;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final Color statusBar;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: statusBar.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(color: statusBar.withValues(alpha: 0.12), blurRadius: 16, offset: const Offset(0, 6)),
          ],
        ),
        child: Row(
          children: [
            // left color bar
            Container(
              width: 5,
              height: 74,
              decoration: BoxDecoration(
                color: statusBar,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
              ),
            ),
            const SizedBox(width: 14),
            // icon
            Container(
              width: 46, height: 46,
              decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            // text
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(color: _Palette.navy, fontSize: 14.5, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(color: _Palette.muted, fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
            // tag + arrow
            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(color: tagBg, borderRadius: BorderRadius.circular(20)),
                    child: Text(tag, style: TextStyle(color: tagColor, fontSize: 10.5, fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(height: 6),
                  Icon(PhosphorIconsRegular.arrowRight, color: statusBar, size: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Coming soon task card ─────────────────────────────────────────────────────
class _ComingSoonTaskCard extends StatelessWidget {
  const _ComingSoonTaskCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8EEF7)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: iconBg.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: iconColor.withValues(alpha: 0.55), size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: _Palette.navy.withValues(alpha: 0.55),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: _Palette.muted.withValues(alpha: 0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Segera',
              style: TextStyle(color: _Palette.muted, fontSize: 10.5, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Task data models ──────────────────────────────────────────────────────────
class _TaskCategory {
  const _TaskCategory(this.label, this.color);
  final String label;
  final Color color;
}

class _TaskStat {
  const _TaskStat(this.value, this.label, this.color, this.bg);
  final String value;
  final String label;
  final Color color;
  final Color bg;
}


// ─── Profile Page ────────────────────────────────────────────────────────────
class _ProfilePage extends StatefulWidget {
  const _ProfilePage();

  @override
  State<_ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<_ProfilePage> {
  bool _notificationsEnabled = true;

  static const _menuSections = [
    _ProfileSection(
      title: 'Akun',
      items: [
        _ProfileMenuItem(
          icon: PhosphorIconsFill.userCircle,
          label: 'My Profile',
          subtitle: 'Lihat & edit informasi akun',
          color: Color(0xFF156DFF),
          bg: Color(0xFFEAF2FF),
          tag: 'profile',
        ),
        _ProfileMenuItem(
          icon: PhosphorIconsFill.qrCode,
          label: 'My QR Code',
          subtitle: 'Tampilkan QR code ID karyawan',
          color: Color(0xFF0F766E),
          bg: Color(0xFFF0FDFA),
          tag: 'qrcode',
        ),
        _ProfileMenuItem(
          icon: PhosphorIconsFill.lockKey,
          label: 'Change Password',
          subtitle: 'Ubah kata sandi akun',
          color: Color(0xFF8B5CF6),
          bg: Color(0xFFF5F3FF),
          tag: 'password',
        ),
      ],
    ),
    _ProfileSection(
      title: 'Preferensi',
      items: [
        _ProfileMenuItem(
          icon: PhosphorIconsFill.bellRinging,
          label: 'Notifications',
          subtitle: 'Kelola notifikasi aplikasi',
          color: Color(0xFFF59E0B),
          bg: Color(0xFFFEF3C7),
          tag: 'notif',
          hasToggle: true,
        ),
        _ProfileMenuItem(
          icon: PhosphorIconsFill.swatches,
          label: 'App Preferences',
          subtitle: 'Tema & bahasa aplikasi',
          color: Color(0xFF06B6D4),
          bg: Color(0xFFECFEFF),
          tag: 'prefs',
        ),
      ],
    ),
    _ProfileSection(
      title: 'Lainnya',
      items: [
        _ProfileMenuItem(
          icon: PhosphorIconsFill.shieldCheck,
          label: 'Privacy & Agreement',
          subtitle: 'Syarat, ketentuan & privasi',
          color: Color(0xFF22C55E),
          bg: Color(0xFFDCFCE7),
          tag: 'privacy',
        ),
        _ProfileMenuItem(
          icon: PhosphorIconsFill.lifebuoy,
          label: 'Help & Support',
          subtitle: 'FAQ dan hubungi kami',
          color: Color(0xFF0EA5E9),
          bg: Color(0xFFE0F2FE),
          tag: 'help',
        ),
      ],
    ),
  ];

  void _handleTap(_ProfileMenuItem item) {
    switch (item.tag) {
      case 'password':
        _showChangePasswordSheet(context);
      case 'profile':
        _showProfileSheet(context);
      case 'qrcode':
        _showQrCodeSheet(context);
      case 'help':
        _showHelpSheet(context);
      case 'privacy':
        _showPrivacySheet(context);
      case 'prefs':
        _showPreferencesSheet(context);
      default:
        break;
    }
  }

  void _showPreferencesSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _PreferencesSheet(),
    );
  }

  void _showChangePasswordSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ChangePasswordSheet(),
    );
  }

  void _showProfileSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _MyProfileSheet(),
    );
  }

  void _showQrCodeSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _QrCodeSheet(),
    );
  }

  void _showHelpSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _HelpSheet(),
    );
  }

  void _showPrivacySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _PrivacySheet(),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Keluar Aplikasi?',
          style: TextStyle(
            color: _Palette.navy,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        content: const Text(
          'Anda akan keluar dari akun ini. Pastikan semua data sudah tersimpan.',
          style: TextStyle(color: _Palette.muted, fontSize: 14, height: 1.5),
        ),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: _Palette.muted, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (_) => false);
            },
            child: const Text('Keluar', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          // ── Hero card ──
          _AppearUp(
            delayMs: 0,
            child: _buildHeroCard(),
          ),
          const SizedBox(height: 22),
          // ── Stats row ──
          _AppearUp(
            delayMs: 60,
            child: _buildStatsRow(),
          ),
          const SizedBox(height: 24),
          // ── Sections ──
          ..._menuSections.asMap().entries.map((e) {
            final delay = 120 + e.key * 80;
            return _AppearUp(
              delayMs: delay,
              child: _buildSection(e.value),
            );
          }),
          const SizedBox(height: 8),
          // ── Logout ──
          _AppearUp(
            delayMs: 400,
            child: _buildLogoutButton(context),
          ),
          const SizedBox(height: 12),
          // ── Version ──
          const Center(
            child: Text(
              'HERO v1.0.0 • Build 2026.05',
              style: TextStyle(color: _Palette.muted, fontSize: 11.5, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A6BFF), Color(0xFF0A3DB0)],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF156DFF).withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.18),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 2.5),
                ),
                child: const Icon(PhosphorIconsFill.user, color: Colors.white, size: 34),
              ),
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    color: Color(0xFF22C55E),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 11),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Lulus Bagos H',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'EMP-2024-0042',
                  style: TextStyle(color: Color(0xFFB8D0FF), fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Staff',
                        style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E).withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '● Active',
                        style: TextStyle(color: Color(0xFF4ADE80), fontSize: 11, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _showProfileSheet(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(PhosphorIconsRegular.pencilSimple, color: Colors.white, size: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(child: _buildStatChip('88%', 'ATR Bulan Ini', PhosphorIconsFill.calendarCheck, const Color(0xFF156DFF), const Color(0xFFEAF2FF))),
        const SizedBox(width: 10),
        Expanded(child: _buildStatChip('22', 'Hari Hadir', PhosphorIconsFill.checkCircle, const Color(0xFF22C55E), const Color(0xFFDCFCE7))),
        const SizedBox(width: 10),
        Expanded(child: _buildStatChip('3 Th', 'Masa Kerja', PhosphorIconsFill.briefcase, const Color(0xFF8B5CF6), const Color(0xFFF5F3FF))),
      ],
    );
  }

  Widget _buildStatChip(String value, String label, IconData icon, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 17),
          ),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w900, height: 1)),
          const SizedBox(height: 3),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(color: _Palette.muted, fontSize: 10.5, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildSection(_ProfileSection section) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            section.title.toUpperCase(),
            style: const TextStyle(
              color: _Palette.muted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 14, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            children: section.items.asMap().entries.map((e) {
              final isLast = e.key == section.items.length - 1;
              return _buildMenuItem(e.value, isLast);
            }).toList(),
          ),
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  Widget _buildMenuItem(_ProfileMenuItem item, bool isLast) {
    Widget trailing;
    if (item.tag == 'notif') {
      trailing = Switch(
        value: _notificationsEnabled,
        onChanged: (v) => setState(() => _notificationsEnabled = v),
        activeColor: _Palette.blue,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      );
    } else {
      trailing = const Icon(PhosphorIconsRegular.arrowRight, color: _Palette.muted, size: 18);
    }

    return InkWell(
      onTap: item.hasToggle ? null : () => _handleTap(item),
      borderRadius: BorderRadius.circular(22),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(color: item.bg, borderRadius: BorderRadius.circular(13)),
              child: Icon(item.icon, color: item.color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.label, style: const TextStyle(color: _Palette.navy, fontSize: 14.5, fontWeight: FontWeight.w700)),
                  Text(item.subtitle, style: const TextStyle(color: _Palette.muted, fontSize: 12, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext ctx) {
    return GestureDetector(
      onTap: () => _confirmLogout(ctx),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF1F2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFFFCDD2)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(PhosphorIconsFill.signOut, color: Color(0xFFEF4444), size: 20),
            SizedBox(width: 8),
            Text(
              'Logout',
              style: TextStyle(
                color: Color(0xFFEF4444),
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Profile menu data models ──────────────────────────────────────────────────
class _ProfileSection {
  const _ProfileSection({required this.title, required this.items});
  final String title;
  final List<_ProfileMenuItem> items;
}

class _ProfileMenuItem {
  const _ProfileMenuItem({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.bg,
    required this.tag,
    this.hasToggle = false,
  });
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final Color bg;
  final String tag;
  final bool hasToggle;
}

// ── Bottom Sheets ─────────────────────────────────────────────────────────────
class _MyProfileSheet extends StatelessWidget {
  const _MyProfileSheet();

  @override
  Widget build(BuildContext context) {
    return _BaseSheet(
      title: 'My Profile',
      child: Column(
        children: [
          Center(
            child: Stack(
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFEAF2FF),
                    border: Border.all(color: const Color(0xFF156DFF), width: 2.5),
                  ),
                  child: const Icon(PhosphorIconsFill.user, color: _Palette.blue, size: 42),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(color: _Palette.blue, shape: BoxShape.circle),
                    child: const Icon(PhosphorIconsRegular.camera, color: Colors.white, size: 14),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildInfoTile('Nama Lengkap', 'Lulus Bagos Hermawan'),
          _buildInfoTile('Employee ID', 'EMP-2024-0042'),
          _buildInfoTile('Departemen', 'Teknologi & Informasi'),
          _buildInfoTile('Jabatan', 'Staff IT'),
          _buildInfoTile('Email', 'lulus@company.com'),
          _buildInfoTile('No. HP', '+62 812 3456 7890'),
          _buildInfoTile('Bergabung', '15 Maret 2021'),
          const SizedBox(height: 16),
          _PrimaryButton(label: 'Edit Profil', onTap: () => Navigator.pop(context)),
        ],
      ),
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: _Palette.muted, fontSize: 11.5, fontWeight: FontWeight.w600, letterSpacing: 0.4)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: _Palette.navy, fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          Divider(color: Colors.black.withValues(alpha: 0.06), height: 1),
        ],
      ),
    );
  }
}

// ── QR Code Sheet ─────────────────────────────────────────────────────────────
class _QrCodeSheet extends StatefulWidget {
  const _QrCodeSheet();

  @override
  State<_QrCodeSheet> createState() => _QrCodeSheetState();
}

class _QrCodeSheetState extends State<_QrCodeSheet> {
  // Static employee data — replace with actual auth/session data when available
  static const _employeeId = 'EMP-IDX-00142';
  static const _employeeName = 'Budi Santoso';
  static const _department = 'Engineering';

  bool _copied = false;

  void _copyId() {
    Clipboard.setData(const ClipboardData(text: _employeeId));
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          // Header
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDFA),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  PhosphorIconsFill.qrCode,
                  color: Color(0xFF0F766E),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My QR Code',
                    style: TextStyle(
                      fontFamily: _headingFont,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: _Palette.navy,
                    ),
                  ),
                  const Text(
                    'Tunjukkan untuk absen & verifikasi',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF718096),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 28),
          // QR Code card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F766E).withValues(alpha: 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                // Name + dept badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _employeeName,
                      style: TextStyle(
                        fontFamily: _headingFont,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _Palette.navy,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF2FF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _department,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF156DFF),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // QR Image
                QrImageView(
                  data: _employeeId,
                  version: QrVersions.auto,
                  size: 200,
                  backgroundColor: Colors.white,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: Color(0xFF061B49),
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Color(0xFF061B49),
                  ),
                ),
                const SizedBox(height: 20),
                // Employee ID row
                GestureDetector(
                  onTap: _copyId,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: _copied
                          ? const Color(0xFFDCFCE7)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _copied
                            ? const Color(0xFF22C55E)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _copied
                              ? PhosphorIconsFill.checkCircle
                              : PhosphorIconsRegular.identificationCard,
                          size: 16,
                          color: _copied
                              ? const Color(0xFF22C55E)
                              : const Color(0xFF718096),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _employeeId,
                          style: TextStyle(
                            fontFamily: _bodyFont,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _copied
                                ? const Color(0xFF16A34A)
                                : _Palette.navy,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          _copied
                              ? PhosphorIconsRegular.check
                              : PhosphorIconsRegular.copy,
                          size: 14,
                          color: _copied
                              ? const Color(0xFF22C55E)
                              : const Color(0xFFABB5C3),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _copied ? 'ID tersalin!' : 'Tap untuk menyalin ID',
                  style: TextStyle(
                    fontSize: 11,
                    color: _copied
                        ? const Color(0xFF16A34A)
                        : const Color(0xFFABB5C3),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Info note
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Row(
              children: [
                const Icon(
                  PhosphorIconsFill.info,
                  size: 16,
                  color: Color(0xFFD97706),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'QR Code ini unik untukmu. Jangan bagikan ke orang lain.',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF92400E),
                      height: 1.4,
                    ),
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

class _ChangePasswordSheet extends StatefulWidget {
  const _ChangePasswordSheet();

  @override
  State<_ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<_ChangePasswordSheet> {
  final _formKey = GlobalKey<FormState>();
  bool _showCurrent = false;
  bool _showNew = false;
  bool _showConfirm = false;
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _BaseSheet(
      title: 'Change Password',
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _PasswordField(
              label: 'Password Saat Ini',
              controller: _currentCtrl,
              obscure: !_showCurrent,
              onToggle: () => setState(() => _showCurrent = !_showCurrent),
              validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 14),
            _PasswordField(
              label: 'Password Baru',
              controller: _newCtrl,
              obscure: !_showNew,
              onToggle: () => setState(() => _showNew = !_showNew),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Wajib diisi';
                if (v.length < 8) return 'Minimal 8 karakter';
                return null;
              },
            ),
            const SizedBox(height: 14),
            _PasswordField(
              label: 'Konfirmasi Password Baru',
              controller: _confirmCtrl,
              obscure: !_showConfirm,
              onToggle: () => setState(() => _showConfirm = !_showConfirm),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Wajib diisi';
                if (v != _newCtrl.text) return 'Password tidak sama';
                return null;
              },
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F4FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(PhosphorIconsFill.info, color: _Palette.blue, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Password harus minimal 8 karakter, mengandung huruf besar, angka, dan simbol.',
                      style: TextStyle(color: _Palette.muted, fontSize: 12, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _PrimaryButton(
              label: 'Simpan Password',
              onTap: () {
                if (_formKey.currentState!.validate()) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Password berhasil diubah', style: TextStyle(fontWeight: FontWeight.w600)),
                      backgroundColor: const Color(0xFF22C55E),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _HelpSheet extends StatelessWidget {
  const _HelpSheet();

  static const _faqs = [
    _FaqItem('Bagaimana cara absen masuk?', 'Buka menu Attendance, pastikan GPS aktif dan Anda berada di area kantor, lalu tekan tombol Check In.'),
    _FaqItem('Absen saya tidak terekam?', 'Pastikan sinyal GPS kuat dan Anda dalam jangkauan area kantor. Jika masalah berlanjut, hubungi HR.'),
    _FaqItem('Bagaimana mengajukan izin?', 'Fitur pengajuan izin sedang dalam pengembangan dan akan segera hadir.'),
    _FaqItem('Siapa yang bisa dihubungi?', 'Hubungi tim HR di hr@company.com atau melalui menu bantuan di bawah.'),
  ];

  @override
  Widget build(BuildContext context) {
    return _BaseSheet(
      title: 'Help & Support',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'FAQ',
            style: TextStyle(color: _Palette.navy, fontSize: 15, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          ..._faqs.map((faq) => _buildFaqItem(faq)),
          const SizedBox(height: 20),
          const Text(
            'Hubungi Kami',
            style: TextStyle(color: _Palette.navy, fontSize: 15, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          _buildContactCard(PhosphorIconsFill.envelope, 'Email Support', 'hr@company.com', const Color(0xFF156DFF), const Color(0xFFEAF2FF)),
          const SizedBox(height: 10),
          _buildContactCard(PhosphorIconsFill.whatsappLogo, 'WhatsApp HR', '+62 811 2345 6789', const Color(0xFF22C55E), const Color(0xFFDCFCE7)),
          const SizedBox(height: 16),
          _PrimaryButton(label: 'Tutup', onTap: () => Navigator.pop(context)),
        ],
      ),
    );
  }

  Widget _buildFaqItem(_FaqItem faq) {
    return Theme(
      data: ThemeData().copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        iconColor: _Palette.blue,
        collapsedIconColor: _Palette.muted,
        title: Text(faq.question, style: const TextStyle(color: _Palette.navy, fontSize: 13.5, fontWeight: FontWeight.w700)),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(faq.answer, style: const TextStyle(color: _Palette.muted, fontSize: 13, height: 1.6)),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(IconData icon, String label, String value, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700)),
              Text(value, style: const TextStyle(color: _Palette.navy, fontSize: 14, fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }
}

class _PrivacySheet extends StatelessWidget {
  const _PrivacySheet();

  @override
  Widget build(BuildContext context) {
    return _BaseSheet(
      title: 'Privacy & Agreement',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Developer badge ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1A6BFF), Color(0xFF0A3DB0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(PhosphorIconsFill.buildings, color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Dikembangkan oleh', style: TextStyle(color: Color(0xFFB8D0FF), fontSize: 11, fontWeight: FontWeight.w600)),
                          Text('PT INDEXIM COALINDO', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 0.3)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Divisi System Integration',
                  style: TextStyle(color: Color(0xFFB8D0FF), fontSize: 12, fontWeight: FontWeight.w500),
                ),
                const Text(
                  'HERO — Human Resources Organizer v1.0',
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildSection(
            icon: PhosphorIconsFill.copyright,
            color: const Color(0xFF156DFF),
            title: 'Hak Cipta & Kepemilikan',
            body:
              'Aplikasi HERO (Human Resources Organizer) adalah sistem yang dikembangkan secara eksklusif oleh Divisi System Integration PT INDEXIM COALINDO. Seluruh hak cipta, kode sumber, desain antarmuka, dan aset digital yang terdapat dalam aplikasi ini merupakan milik sah PT INDEXIM COALINDO.\n\n'
              'Dilarang keras menyalin, mendistribusikan, memodifikasi, atau menggunakan ulang sebagian maupun seluruh konten aplikasi ini dalam bentuk apapun tanpa izin tertulis resmi dari PT INDEXIM COALINDO.',
          ),
          const SizedBox(height: 16),
          _buildSection(
            icon: PhosphorIconsFill.prohibit,
            color: const Color(0xFFEF4444),
            title: 'Larangan Penggunaan',
            body:
              '• Dilarang mendistribusikan aplikasi ini kepada pihak manapun di luar lingkungan PT INDEXIM COALINDO.\n'
              '• Dilarang melakukan rekayasa balik (reverse engineering) terhadap aplikasi.\n'
              '• Dilarang menggunakan fitur GPS palsu (mock location) untuk memanipulasi data kehadiran.\n'
              '• Dilarang mengakses akun milik karyawan lain.\n'
              '• Pelanggaran dapat mengakibatkan tindakan disiplin sesuai peraturan perusahaan dan/atau proses hukum.',
          ),
          const SizedBox(height: 16),
          _buildSection(
            icon: PhosphorIconsFill.shieldCheck,
            color: const Color(0xFF22C55E),
            title: 'Kebijakan Privasi & Data',
            body:
              'PT INDEXIM COALINDO berkomitmen penuh melindungi data pribadi karyawan. Data lokasi GPS hanya digunakan untuk verifikasi kehadiran secara real-time dan tidak disimpan secara permanen. Data kehadiran disimpan di server internal perusahaan yang terenkripsi dan hanya dapat diakses oleh tim HR yang berwenang.\n\n'
              'Kami tidak membagikan, menjual, atau menyewakan data pribadi karyawan kepada pihak ketiga dalam kondisi apapun.',
          ),
          const SizedBox(height: 16),
          _buildSection(
            icon: PhosphorIconsFill.fileText,
            color: const Color(0xFF8B5CF6),
            title: 'Syarat & Ketentuan Penggunaan',
            body:
              'Dengan menggunakan aplikasi HERO, Anda menyatakan telah membaca, memahami, dan menyetujui seluruh syarat dan ketentuan yang berlaku. Aplikasi ini hanya boleh digunakan oleh karyawan aktif PT INDEXIM COALINDO yang telah mendapatkan akun resmi dari Departemen HR.\n\n'
              'PT INDEXIM COALINDO berhak untuk melakukan pembaruan, penangguhan, atau penghentian layanan aplikasi sewaktu-waktu demi kepentingan operasional perusahaan.',
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F7FC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(PhosphorIconsFill.calendarCheck, color: _Palette.muted, size: 16),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Berlaku sejak: 1 Januari 2026  •  Versi: 1.0.0',
                    style: TextStyle(color: _Palette.muted, fontSize: 11.5, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _PrimaryButton(label: 'Saya Memahami & Menyetujui', onTap: () => Navigator.pop(context)),
        ],
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required Color color,
    required String title,
    required String body,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 7),
              Expanded(child: Text(title, style: TextStyle(color: color, fontSize: 13.5, fontWeight: FontWeight.w800))),
            ],
          ),
          const SizedBox(height: 8),
          Text(body, style: const TextStyle(color: _Palette.muted, fontSize: 12.5, height: 1.7)),
        ],
      ),
    );
  }
}

// ── App Preferences enums ─────────────────────────────────────────────────────
enum _AppTheme { light, dark, system }
enum _AppLanguage { id, en }

// ── Preferences Sheet ─────────────────────────────────────────────────────────
class _PreferencesSheet extends StatefulWidget {
  const _PreferencesSheet();

  @override
  State<_PreferencesSheet> createState() => _PreferencesSheetState();
}

class _PreferencesSheetState extends State<_PreferencesSheet> {
  _AppTheme _theme = _AppTheme.light;
  _AppLanguage _lang = _AppLanguage.id;

  static const _themes = [
    _ThemeOption(_AppTheme.light, 'Light', 'Tampilan terang', PhosphorIconsFill.sun, Color(0xFFF59E0B), Color(0xFFFEF3C7)),
    _ThemeOption(_AppTheme.dark, 'Dark', 'Tampilan gelap', PhosphorIconsFill.moon, Color(0xFF8B5CF6), Color(0xFFF5F3FF)),
    _ThemeOption(_AppTheme.system, 'System', 'Ikuti sistem', PhosphorIconsFill.deviceMobile, Color(0xFF156DFF), Color(0xFFEAF2FF)),
  ];

  static const _languages = [
    _LangOption(_AppLanguage.id, 'Indonesia', 'Bahasa Indonesia', '🇮🇩'),
    _LangOption(_AppLanguage.en, 'English', 'English (US)', '🇬🇧'),
  ];

  @override
  Widget build(BuildContext context) {
    return _BaseSheet(
      title: 'App Preferences',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Theme Section ──
          _buildSectionHeader(
            icon: PhosphorIconsFill.paintBrush,
            color: const Color(0xFF06B6D4),
            bg: const Color(0xFFECFEFF),
            title: 'Tema Aplikasi',
            subtitle: 'Pilih tampilan yang nyaman untuk Anda',
          ),
          const SizedBox(height: 14),
          ...(_themes.map((t) => _buildThemeOption(t))),
          const SizedBox(height: 24),
          // ── Language Section ──
          _buildSectionHeader(
            icon: PhosphorIconsFill.translate,
            color: const Color(0xFF156DFF),
            bg: const Color(0xFFEAF2FF),
            title: 'Bahasa / Language',
            subtitle: 'Pilih bahasa yang digunakan / Select your language',
          ),
          const SizedBox(height: 14),
          Row(
            children: _languages.map((l) {
              final selected = _lang == l.value;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _lang = l.value),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      color: selected ? const Color(0xFFEAF2FF) : const Color(0xFFF4F7FC),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: selected ? _Palette.blue : const Color(0xFFE2E8F0),
                        width: selected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(l.flag, style: const TextStyle(fontSize: 30)),
                        const SizedBox(height: 8),
                        Text(
                          l.label,
                          style: TextStyle(
                            color: selected ? _Palette.blue : _Palette.navy,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l.sublabel,
                          style: TextStyle(
                            color: selected ? _Palette.blue.withValues(alpha: 0.7) : _Palette.muted,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (selected)
                          Container(
                            width: 20,
                            height: 20,
                            decoration: const BoxDecoration(color: _Palette.blue, shape: BoxShape.circle),
                            child: const Icon(Icons.check, color: Colors.white, size: 12),
                          )
                        else
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFFD1D5DB), width: 1.5),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 28),
          _PrimaryButton(
            label: 'Simpan Preferensi',
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _lang == _AppLanguage.id ? 'Preferensi disimpan' : 'Preferences saved',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  backgroundColor: const Color(0xFF22C55E),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required Color color,
    required Color bg,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: _Palette.navy, fontSize: 15, fontWeight: FontWeight.w800)),
            Text(subtitle, style: const TextStyle(color: _Palette.muted, fontSize: 11.5, fontWeight: FontWeight.w500)),
          ],
        ),
      ],
    );
  }

  Widget _buildThemeOption(_ThemeOption t) {
    final selected = _theme == t.value;
    return GestureDetector(
      onTap: () => setState(() => _theme = t.value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? t.bg : const Color(0xFFF4F7FC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? t.color : const Color(0xFFE2E8F0),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: t.bg, borderRadius: BorderRadius.circular(12)),
              child: Icon(t.icon, color: t.color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.label, style: TextStyle(color: selected ? t.color : _Palette.navy, fontSize: 14, fontWeight: FontWeight.w700)),
                  Text(t.sublabel, style: const TextStyle(color: _Palette.muted, fontSize: 12)),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22, height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? t.color : Colors.transparent,
                border: Border.all(color: selected ? t.color : const Color(0xFFD1D5DB), width: 2),
              ),
              child: selected
                  ? const Icon(Icons.check, color: Colors.white, size: 13)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeOption {
  const _ThemeOption(this.value, this.label, this.sublabel, this.icon, this.color, this.bg);
  final _AppTheme value;
  final String label;
  final String sublabel;
  final IconData icon;
  final Color color;
  final Color bg;
}

class _LangOption {
  const _LangOption(this.value, this.label, this.sublabel, this.flag);
  final _AppLanguage value;
  final String label;
  final String sublabel;
  final String flag;
}

// ── Shared sheet widgets ──────────────────────────────────────────────────────
class _BaseSheet extends StatelessWidget {
  const _BaseSheet({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFD1D5DB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                color: _Palette.navy,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
            const Divider(height: 24),
            Expanded(
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                children: [child],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.label,
    required this.controller,
    required this.obscure,
    required this.onToggle,
    this.validator,
  });
  final String label;
  final TextEditingController controller;
  final bool obscure;
  final VoidCallback onToggle;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      style: const TextStyle(color: _Palette.navy, fontSize: 14, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: _Palette.muted, fontSize: 13),
        filled: true,
        fillColor: const Color(0xFFF4F7FC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: _Palette.blue, width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFEF4444))),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5)),
        suffixIcon: IconButton(
          icon: Icon(obscure ? PhosphorIconsRegular.eye : PhosphorIconsRegular.eyeSlash, color: _Palette.muted, size: 18),
          onPressed: onToggle,
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: _Palette.blue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
      ),
    );
  }
}

class _FaqItem {
  const _FaqItem(this.question, this.answer);
  final String question;
  final String answer;
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Good morning,',
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: _bodyFont,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF334155),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
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
              const SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF2FF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(PhosphorIconsFill.calendar, color: Color(0xFF156DFF), size: 12),
                        SizedBox(width: 5),
                        Text(
                          'Minggu, 31 Mei 2026',
                          style: TextStyle(fontSize: 11, color: Color(0xFF156DFF), fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(PhosphorIconsFill.circle, color: Color(0xFF16A34A), size: 8),
                        SizedBox(width: 5),
                        Text(
                          'Active',
                          style: TextStyle(fontSize: 11, color: Color(0xFF16A34A), fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ],
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
      children: const [
        _HeaderIconButton(icon: PhosphorIconsRegular.bell, showDot: true),
        SizedBox(width: 10),
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
  const _HeaderIconButton({required this.icon, this.showDot = false});

  final IconData icon;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: _softCardDecoration(radius: 18),
          child: const Icon(PhosphorIconsRegular.bell, color: _Palette.navy),
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
      child: Row(
        children: [
          Expanded(
            child: _SummaryItem(
              icon: PhosphorIconsRegular.calendar,
              title: 'Attendance',
              value: '88%',
              subtitle: 'Lihat detail ATR',
              active: true,
              onTap: () => Navigator.of(context).pushNamed('/attendance-rate'),
            ),
          ),
          const Expanded(
            child: _SummaryItem(
              icon: PhosphorIconsRegular.fileText,
              title: 'Requests',
              value: '—',
              subtitle: 'Coming Soon',
              accentColor: Color(0xFF8B5CF6),
              accentBg: Color(0xFFF5F3FF),
            ),
          ),
          const Expanded(
            child: _SummaryItem(
              icon: PhosphorIconsRegular.users,
              title: 'People',
              value: '—',
              subtitle: 'Coming Soon',
              accentColor: Color(0xFF06B6D4),
              accentBg: Color(0xFFECFEFF),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatefulWidget {
  const _SummaryItem({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
    this.active = false,
    this.onTap,
    this.accentColor,
    this.accentBg,
  });

  final IconData icon;
  final String title;
  final String value;
  final String subtitle;
  final bool active;
  final VoidCallback? onTap;
  final Color? accentColor;
  final Color? accentBg;

  @override
  State<_SummaryItem> createState() => _SummaryItemState();
}

class _SummaryItemState extends State<_SummaryItem> {
  bool _pressed = false;

  Color get _color => widget.accentColor ?? (widget.active ? _Palette.blue : const Color(0xFF9AA6B7));
  Color get _bg => widget.accentBg ?? (widget.active ? const Color(0xFFEAF2FF) : const Color(0xFFF3F6FA));

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) { if (widget.onTap != null) setState(() => _pressed = true); },
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 130),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _pressed
                ? _color.withValues(alpha: 0.45)
                : _color.withValues(alpha: 0.22)),
            color: _pressed ? _bg.withValues(alpha: 0.6) : Colors.white,
            boxShadow: [
              BoxShadow(
                color: _color.withValues(alpha: _pressed ? 0.16 : 0.08),
                blurRadius: _pressed ? 14 : 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(13)),
                child: Icon(widget.icon, color: _color),
              ),
              const SizedBox(height: 10),
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: const TextStyle(color: _Palette.navy, fontSize: 13, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 7),
              Text(
                widget.value,
                style: TextStyle(color: _color, fontSize: 30, fontWeight: FontWeight.w800, height: 1),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      widget.subtitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: _Palette.muted, fontSize: 11.8, fontWeight: FontWeight.w500),
                    ),
                  ),
                  if (widget.onTap != null) ...[
                    const SizedBox(width: 2),
                    Icon(PhosphorIconsRegular.arrowRight, size: 12, color: _color),
                  ],
                ],
              ),
            ],
          ),
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
  const _QuickAccessGrid({required this.items, required this.onOpenMenu});

  final List<_MenuItemData> items;
  final ValueChanged<String> onOpenMenu;

  // pad items list to 8 slots (blank tiles for empty slots)
  List<_MenuItemData> get _padded {
    const blank = _MenuItemData(title: '', icon: PhosphorIconsRegular.plus);
    final list = List<_MenuItemData>.from(items);
    while (list.length < 8) list.add(blank);
    return list.take(8).toList();
  }

  @override
  Widget build(BuildContext context) {
    final display = _padded;
    return GridView.builder(
      itemCount: display.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      itemBuilder: (context, index) {
        final item = display[index];
        return _QuickAccessTile(
          data: item,
          onTap: () {
            if (item.active) {
              onOpenMenu(item.title);
            } else if (item.named) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${item.title} — segera hadir',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  backgroundColor: item.color,
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
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
    this.named = false,
    this.color = const Color(0xFF156DFF),
    this.bgColor = const Color(0xFFEAF2FF),
  });

  final String title;
  final IconData icon;
  final bool active;   // fully active (navigates)
  final bool named;    // named but not yet active (shows snackbar)
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
    final isBlank = !data.active && !data.named;

    return AnimatedScale(
      scale: _pressed ? 0.95 : 1,
      duration: const Duration(milliseconds: 110),
      curve: Curves.easeOut,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: (data.active || data.named) ? widget.onTap : null,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            gradient: data.active
                ? LinearGradient(
                    colors: [data.color, data.bgColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: data.active ? null : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: data.active
                  ? Colors.transparent
                  : data.named
                      ? data.color.withValues(alpha: 0.25)
                      : const Color(0xFFE8EEF7),
            ),
            boxShadow: data.active
                ? [BoxShadow(color: data.color.withValues(alpha: 0.38), blurRadius: 14, offset: const Offset(0, 6))]
                : data.named
                    ? [BoxShadow(color: data.color.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 3))]
                    : null,
          ),
          child: Stack(
            children: [
              // ── Segera badge (top-right) for named tiles ──
              if (data.named)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: data.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Baru',
                      style: TextStyle(
                        color: data.color,
                        fontSize: 7,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
              // ── Icon + label ──
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: data.active
                            ? Colors.white.withValues(alpha: 0.22)
                            : data.named
                                ? data.bgColor
                                : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        data.icon,
                        color: data.active
                            ? Colors.white
                            : data.named
                                ? data.color
                                : const Color(0xFFBBC5D4),
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      isBlank ? '' : data.title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: TextStyle(
                        color: data.active
                            ? Colors.white
                            : data.named
                                ? _Palette.navy
                                : const Color(0xFFCBD5E1),
                        fontSize: 10.5,
                        fontWeight: data.active || data.named ? FontWeight.w700 : FontWeight.w500,
                        height: 1.2,
                      ),
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

class _AppearUp extends StatefulWidget {
  const _AppearUp({required this.child, this.delayMs = 0});

  final Widget child;
  final int delayMs;

  @override
  State<_AppearUp> createState() => _AppearUpState();
}

class _AppearUpState extends State<_AppearUp> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.7, curve: Curves.easeOut));
    _slide = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    Future<void>.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slide,
      child: FadeTransition(
        opacity: _fade,
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
            badgeColor: Color(0xFFDCFCE7),
            badgeTextColor: Color(0xFF16A34A),
            iconBg: Color(0xFFDCFCE7),
            iconColor: Color(0xFF16A34A),
          ),
          Divider(height: 1, color: Color(0xFFE6ECF5)),
          _ActivityItem(
            icon: PhosphorIconsRegular.signOut,
            title: 'Checked out',
            subtitle: 'Yesterday, 6:01 PM  •  Office',
            badge: 'Early',
            badgeColor: Color(0xFFEAF2FF),
            badgeTextColor: Color(0xFF156DFF),
            iconBg: Color(0xFFEAF2FF),
            iconColor: Color(0xFF156DFF),
          ),
          Divider(height: 1, color: Color(0xFFE6ECF5)),
          _ActivityItem(
            icon: PhosphorIconsRegular.clockCountdown,
            title: 'Late Arrival',
            subtitle: '2 days ago, 9:34 AM  •  Office',
            badge: 'Terlambat',
            badgeColor: Color(0xFFFEF3C7),
            badgeTextColor: Color(0xFFD97706),
            iconBg: Color(0xFFFEF3C7),
            iconColor: Color(0xFFD97706),
          ),
        ],
      ),
    );
  }
}

class _ActivityItem extends StatefulWidget {
  const _ActivityItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.badgeColor,
    required this.badgeTextColor,
    this.iconBg = const Color(0xFFEAF2FF),
    this.iconColor = const Color(0xFF156DFF),
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String badge;
  final Color badgeColor;
  final Color badgeTextColor;
  final Color iconBg;
  final Color iconColor;

  @override
  State<_ActivityItem> createState() => _ActivityItemState();
}

class _ActivityItemState extends State<_ActivityItem> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        decoration: BoxDecoration(
          color: _pressed ? const Color(0xFFF0F6FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            AnimatedScale(
              scale: _pressed ? 0.92 : 1.0,
              duration: const Duration(milliseconds: 140),
              curve: Curves.easeOut,
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: widget.iconBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(widget.icon, color: widget.iconColor, size: 22),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      color: _Palette.navy,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    widget.subtitle,
                    style: const TextStyle(
                      color: _Palette.muted,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedScale(
              scale: _pressed ? 0.95 : 1.0,
              duration: const Duration(milliseconds: 140),
              curve: Curves.easeOut,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: widget.badgeColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  widget.badge,
                  style: TextStyle(
                    color: widget.badgeTextColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
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

class _SectionHeader extends StatefulWidget {
  const _SectionHeader({
    required this.title,
    required this.actionText,
    required this.onTap,
  });

  final String title;
  final String actionText;
  final VoidCallback onTap;

  @override
  State<_SectionHeader> createState() => _SectionHeaderState();
}

class _SectionHeaderState extends State<_SectionHeader> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          widget.title,
          style: const TextStyle(
            color: _Palette.navy,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) {
            setState(() => _pressed = false);
            widget.onTap();
          },
          onTapCancel: () => setState(() => _pressed = false),
          child: AnimatedScale(
            scale: _pressed ? 0.90 : 1.0,
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOut,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _pressed
                    ? const Color(0xFFEAF2FF)
                    : const Color(0xFFEAF2FF).withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _pressed
                      ? _Palette.blue.withValues(alpha: 0.4)
                      : _Palette.blue.withValues(alpha: 0.15),
                ),
              ),
              child: Text(
                widget.actionText,
                style: const TextStyle(
                  color: _Palette.blue,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Edit Quick Access Sheet ───────────────────────────────────────────────────
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

class _EditQuickAccessSheetState extends State<_EditQuickAccessSheet>
    with TickerProviderStateMixin {
  late List<_MenuItemData> _selected;
  late AnimationController _headerAnim;
  late AnimationController _listAnim;
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;

  @override
  void initState() {
    super.initState();
    _selected = List<_MenuItemData>.from(widget.selected);

    _headerAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 380));
    _listAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));

    _headerFade = CurvedAnimation(parent: _headerAnim, curve: Curves.easeOut);
    _headerSlide = Tween<Offset>(begin: const Offset(0, -0.15), end: Offset.zero)
        .animate(CurvedAnimation(parent: _headerAnim, curve: Curves.easeOutCubic));

    _headerAnim.forward();
    Future.delayed(const Duration(milliseconds: 80), () {
      if (mounted) _listAnim.forward();
    });
  }

  @override
  void dispose() {
    _headerAnim.dispose();
    _listAnim.dispose();
    super.dispose();
  }

  bool _isSelected(_MenuItemData item) =>
      _selected.any((s) => s.title == item.title);

  void _toggle(_MenuItemData item) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_isSelected(item)) {
        if (item.active) return; // Attendance always pinned
        _selected.removeWhere((s) => s.title == item.title);
      } else {
        if (_selected.length >= 8) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Maksimal 8 menu di Quick Access',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              backgroundColor: const Color(0xFFDC2626),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
          return;
        }
        _selected.add(item);
      }
    });
  }

  void _save() {
    HapticFeedback.mediumImpact();
    widget.onSave(List<_MenuItemData>.from(_selected));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF7FAFF),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Handle ──
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // ── Header ──
          SlideTransition(
            position: _headerSlide,
            child: FadeTransition(
              opacity: _headerFade,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1A6BFF), Color(0xFF0A4FC9)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1A6BFF).withValues(alpha: 0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Icon(PhosphorIconsFill.gridFour, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Edit Quick Access',
                          style: TextStyle(
                            fontFamily: _headingFont,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: _Palette.navy,
                          ),
                        ),
                        Text(
                          'Pilih maks. 8 menu • ${_selected.length}/8 dipilih',
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: Color(0xFF718096),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Save button
                    GestureDetector(
                      onTap: _save,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1A6BFF), Color(0xFF0A4FC9)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1A6BFF).withValues(alpha: 0.30),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Text(
                          'Simpan',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 13.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // ── Divider ──
          const Divider(height: 1, color: Color(0xFFE8EEF7)),
          // ── Menu List ──
          Flexible(
            child: AnimatedBuilder(
              animation: _listAnim,
              builder: (context, _) {
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                  itemCount: _allQuickMenus.length,
                  itemBuilder: (context, index) {
                    final delay = index * 40;
                    final progress = Curves.easeOutCubic.transform(
                      ((_listAnim.value * 500 - delay) / 300).clamp(0.0, 1.0),
                    );
                    final item = _allQuickMenus[index];
                    final selected = _isSelected(item);
                    final pinned = item.active; // can't deselect

                    return Transform.translate(
                      offset: Offset(0, 20 * (1 - progress)),
                      child: Opacity(
                        opacity: progress,
                        child: _MenuPickerRow(
                          item: item,
                          selected: selected,
                          pinned: pinned,
                          onTap: () => _toggle(item),
                        ),
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

class _MenuPickerRow extends StatefulWidget {
  const _MenuPickerRow({
    required this.item,
    required this.selected,
    required this.pinned,
    required this.onTap,
  });

  final _MenuItemData item;
  final bool selected;
  final bool pinned;
  final VoidCallback onTap;

  @override
  State<_MenuPickerRow> createState() => _MenuPickerRowState();
}

class _MenuPickerRowState extends State<_MenuPickerRow>
    with SingleTickerProviderStateMixin {
  late AnimationController _checkAnim;
  bool _prevSelected = false;

  @override
  void initState() {
    super.initState();
    _checkAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
      value: widget.selected ? 1.0 : 0.0,
    );
    _prevSelected = widget.selected;
  }

  @override
  void didUpdateWidget(_MenuPickerRow old) {
    super.didUpdateWidget(old);
    if (widget.selected != _prevSelected) {
      _prevSelected = widget.selected;
      if (widget.selected) {
        _checkAnim.forward();
      } else {
        _checkAnim.reverse();
      }
    }
  }

  @override
  void dispose() {
    _checkAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.pinned ? null : widget.onTap,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: widget.selected ? item.bgColor : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: widget.selected
                    ? item.color.withValues(alpha: 0.4)
                    : const Color(0xFFE8EEF7),
                width: widget.selected ? 1.5 : 1,
              ),
              boxShadow: widget.selected
                  ? [
                      BoxShadow(
                        color: item.color.withValues(alpha: 0.12),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Row(
              children: [
                // Icon bubble
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: widget.selected ? item.color.withValues(alpha: 0.18) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(item.icon, color: widget.selected ? item.color : const Color(0xFF94A3B8), size: 20),
                ),
                const SizedBox(width: 14),
                // Label
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: TextStyle(
                          fontFamily: _headingFont,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: widget.selected ? _Palette.navy : const Color(0xFF4A5568),
                        ),
                      ),
                      if (widget.pinned)
                        const Text(
                          'Selalu tampil',
                          style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                        ),
                    ],
                  ),
                ),
                // Check / pin indicator
                if (widget.pinned)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF2FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Tetap',
                      style: TextStyle(
                        color: Color(0xFF156DFF),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                else
                  ScaleTransition(
                    scale: CurvedAnimation(parent: _checkAnim, curve: Curves.elasticOut),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: widget.selected ? item.color : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: widget.selected ? item.color : const Color(0xFFCBD5E1),
                          width: 2,
                        ),
                      ),
                      child: widget.selected
                          ? const Icon(Icons.check_rounded, size: 15, color: Colors.white)
                          : null,
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
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(14, 0, 14, 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: Colors.white.withValues(alpha: 0.9), width: 1.1),
          boxShadow: [
            BoxShadow(
              color: _Palette.navy.withValues(alpha: 0.12),
              blurRadius: 26,
              offset: const Offset(0, 12),
            ),
            BoxShadow(
              color: _Palette.blue.withValues(alpha: 0.06),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: SizedBox(
          height: 58,
          child: Row(
            children: List.generate(tabs.length, (index) {
              final tab = tabs[index];
              return Expanded(
                child: _PremiumNavItem(
                  data: tab,
                  active: index == currentIndex,
                  onTap: () {
                    if (index != currentIndex) {
                      HapticFeedback.selectionClick();
                    }
                    onChanged(index);
                  },
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _PremiumNavItem extends StatefulWidget {
  const _PremiumNavItem({
    required this.data,
    required this.active,
    required this.onTap,
  });

  final _TabData data;
  final bool active;
  final VoidCallback onTap;

  @override
  State<_PremiumNavItem> createState() => _PremiumNavItemState();
}

class _PremiumNavItemState extends State<_PremiumNavItem> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.active;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 110),
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
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: active ? const Color(0xFFEAF2FF) : Colors.transparent,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: active
                      ? _Palette.blue.withValues(alpha: 0.18)
                      : Colors.transparent,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    active ? widget.data.active : widget.data.inactive,
                    color: active ? _Palette.blue : const Color(0xFF58677D),
                    size: active ? 24 : 22,
                  ),
                  const SizedBox(height: 3),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    style: TextStyle(
                      color: active ? _Palette.blue : const Color(0xFF58677D),
                      fontSize: 11.8,
                      fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                      letterSpacing: active ? 0.1 : 0,
                    ),
                    child: Text(widget.data.label),
                  ),
                ],
              ),
            ),
          ),
        ),
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
