import 'package:flutter/material.dart';
import 'package:hero/core/models/app_menu_item.dart';
import 'package:hero/features/auth/pages/login_page.dart';
import 'package:hero/features/menu/pages/menu_screen.dart';

/// Central route registry.
/// Add new named routes here as features are added.
abstract final class AppRoutes {
  static const String login = '/';
  static const String menu = MenuScreen.routeName;

  static Route<void> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case menu:
        final selectedMenu = settings.arguments as AppMenuItem?;
        return MaterialPageRoute<void>(
          builder: (_) => MenuScreen(
            title: selectedMenu?.title ?? 'Menu',
            route: selectedMenu?.route,
          ),
          settings: settings,
        );
      default:
        return MaterialPageRoute<void>(
          builder: (_) => const LoginPage(),
          settings: settings,
        );
    }
  }
}
