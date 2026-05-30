import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
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
    if (title.toLowerCase() == 'attendance') {
      Navigator.of(context).pushNamed(AppRoutes.attendance);
      return;
    }
    Navigator.of(context).pushNamed(MenuScreen.routeName, arguments: title);
  }
}

class _DashboardHome extends StatelessWidget {
  const _DashboardHome({required this.onOpenMenu});

  final ValueChanged<String> onOpenMenu;

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
          const _AppearUp(
            delayMs: 190,
            child: _SectionHeader(
              title: 'Quick Access',
              actionText: 'Edit',
              onTap: _noop,
            ),
          ),
          const SizedBox(height: 12),
          _AppearUp(delayMs: 250, child: _QuickAccessGrid(onOpenMenu: onOpenMenu)),
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

class _ProfilePage extends StatelessWidget {
  const _ProfilePage();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
      children: [
        const _AppearUp(
          delayMs: 20,
          child: Text(
            'Profile',
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
            'Informasi akun dan preferensi aplikasi.',
            style: TextStyle(
              color: _Palette.muted,
              fontFamily: _bodyFont,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 18),
        const _AppearUp(
          delayMs: 130,
          child: _ProfileCard(),
        ),
      ],
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _softCardDecoration(radius: 22),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Color(0xFFEAF2FF),
            child: Icon(PhosphorIconsFill.user, color: _Palette.blue),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lulus Bagos H',
                  style: TextStyle(
                    color: _Palette.navy,
                    fontFamily: _headingFont,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Employee ID • Active',
                  style: TextStyle(
                    color: _Palette.muted,
                    fontFamily: _bodyFont,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
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
  const _QuickAccessGrid({required this.onOpenMenu});

  final ValueChanged<String> onOpenMenu;

  @override
  Widget build(BuildContext context) {
    final items = <_MenuItemData>[
      const _MenuItemData(title: 'Attendance', icon: PhosphorIconsRegular.calendar, active: true),
      const _MenuItemData(title: 'Coming Soon', icon: PhosphorIconsRegular.plus),
      const _MenuItemData(title: 'Coming Soon', icon: PhosphorIconsRegular.plus),
      const _MenuItemData(title: 'Coming Soon', icon: PhosphorIconsRegular.plus),
      const _MenuItemData(title: 'Coming Soon', icon: PhosphorIconsRegular.plus),
      const _MenuItemData(title: 'Coming Soon', icon: PhosphorIconsRegular.plus),
      const _MenuItemData(title: 'Coming Soon', icon: PhosphorIconsRegular.plus),
      const _MenuItemData(title: 'Coming Soon', icon: PhosphorIconsRegular.plus),
    ];

    return GridView.builder(
      itemCount: items.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return _QuickAccessTile(
          data: item,
          onTap: () {
            if (item.active) {
              onOpenMenu(item.title);
            }
          },
        );
      },
    );
  }
}

class _MenuItemData {
  const _MenuItemData({required this.title, required this.icon, this.active = false});

  final String title;
  final IconData icon;
  final bool active;
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
    return AnimatedScale(
      scale: _pressed ? 0.97 : 1,
      duration: const Duration(milliseconds: 110),
      curve: Curves.easeOut,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: data.active ? widget.onTap : null,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: data.active ? 1 : 0.78),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: data.active
                ? _Palette.blue.withValues(alpha: 0.4)
                : const Color(0xFFE8EEF7),
            ),
            boxShadow: data.active
                ? [
                    BoxShadow(
                      color: _Palette.blue.withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                data.icon,
                color: data.active ? _Palette.blue : const Color(0xFF9AA6B7),
                size: 24,
              ),
              const SizedBox(height: 10),
              Text(
                data.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: data.active ? _Palette.navy : const Color(0xFF8A96A8),
                  fontSize: 11.8,
                  fontWeight: data.active ? FontWeight.w700 : FontWeight.w600,
                ),
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
