import 'package:flutter/material.dart';
import 'package:hero/core/enums/app_role.dart';
import 'package:hero/core/models/app_menu_item.dart';
import 'package:hero/core/repositories/menu_repository.dart';
import 'package:hero/features/menu/pages/menu_screen.dart';

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
  static const _quickActionCandidates = <AppMenuItem>[
    AppMenuItem(
      title: 'Profile',
      route: '/profile',
      icon: Icons.badge_outlined,
    ),
    AppMenuItem(
      title: 'Work Schedule Revision',
      route: '/work-schedule-revision',
      icon: Icons.schedule_send_outlined,
    ),
    AppMenuItem(
      title: 'HER Registration',
      route: '/her-registration',
      icon: Icons.app_registration_outlined,
    ),
    AppMenuItem(
      title: "Today's Birthdays",
      route: '/birthdays',
      icon: Icons.cake_outlined,
    ),
    AppMenuItem(
      title: 'Notifications',
      route: '/notifications',
      icon: Icons.notifications_active_outlined,
    ),
  ];

  late final Future<List<AppMenuItem>> _menuFuture =
      widget.menuRepository.fetchMenus(widget.role);
  final Set<String> _quickActionRoutes = <String>{};
  bool _isEditingQuickActions = false;

  void _initQuickActions(List<AppMenuItem> menus) {
    if (_quickActionRoutes.isNotEmpty) return;
    _quickActionRoutes.addAll(
      menus.take(3).map((item) => item.route),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('HERO | ${widget.role.label}'),
        actions: [
          TextButton.icon(
            onPressed: () {
              setState(() => _isEditingQuickActions = !_isEditingQuickActions);
            },
            icon: Icon(
              _isEditingQuickActions ? Icons.done_rounded : Icons.edit_rounded,
            ),
            label: Text(_isEditingQuickActions ? 'Done' : 'Edit'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: FutureBuilder<List<AppMenuItem>>(
        future: _menuFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          final menus = snapshot.data ?? <AppMenuItem>[];
          _initQuickActions(menus);
          if (menus.isEmpty) {
            return const Center(child: Text('Belum ada menu untuk role ini.'));
          }

          final quickActions = menus
              .where((item) => _quickActionRoutes.contains(item.route))
              .toList();

          final menuRoutes = menus.map((item) => item.route).toSet();
          final availableCandidates = _quickActionCandidates
              .where(
                (candidate) => menuRoutes.contains(candidate.route),
              )
              .toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quick Actions',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: quickActions
                            .map(
                              (item) => ActionChip(
                                avatar: Icon(item.icon, size: 18),
                                label: Text(item.title),
                                onPressed: () => Navigator.of(context).pushNamed(
                                  MenuScreen.routeName,
                                  arguments: item,
                                ),
                              ),
                            )
                            .toList(),
                      ),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: !_isEditingQuickActions
                            ? const SizedBox.shrink()
                            : Padding(
                                key: const ValueKey('quick-action-editor'),
                                padding: const EdgeInsets.only(top: 16),
                                child: Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: availableCandidates.map((item) {
                                    final selected = _quickActionRoutes
                                        .contains(item.route);
                                    return FilterChip(
                                      selected: selected,
                                      avatar: Icon(item.icon, size: 18),
                                      label: Text(item.title),
                                      onSelected: (_) {
                                        setState(() {
                                          if (selected) {
                                            _quickActionRoutes.remove(item.route);
                                          } else {
                                            _quickActionRoutes.add(item.route);
                                          }
                                        });
                                      },
                                    );
                                  }).toList(),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ...menus.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Card(
                    child: ListTile(
                      leading: Icon(item.icon),
                      title: Text(item.title),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.of(context).pushNamed(
                        MenuScreen.routeName,
                        arguments: item,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
