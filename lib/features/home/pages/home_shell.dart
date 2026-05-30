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
  late final Future<List<AppMenuItem>> _menuFuture =
      widget.menuRepository.fetchMenus(widget.role);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('HERO | ${widget.role.label}')),
      body: FutureBuilder<List<AppMenuItem>>(
        future: _menuFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          final menus = snapshot.data ?? <AppMenuItem>[];
          if (menus.isEmpty) {
            return const Center(child: Text('Belum ada menu untuk role ini.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: menus.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = menus[index];
              return Card(
                child: ListTile(
                  leading: Icon(item.icon),
                  title: Text(item.title),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).pushNamed(
                    MenuScreen.routeName,
                    arguments: item.title,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
