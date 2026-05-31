import 'package:flutter/material.dart';
import 'package:hero/features/auth/pages/login_page.dart';
import 'package:hero/features/attendance/pages/attendance_page.dart';
import 'package:hero/features/attendance/pages/attendance_rate_page.dart';
import 'package:hero/features/menu/pages/menu_screen.dart';

/// Central route registry.
/// Add new named routes here as features are added.
abstract final class AppRoutes {
  static const String login = '/';
  static const String menu = MenuScreen.routeName;
  static const String attendance = AttendancePage.routeName;
  static const String attendanceRate = AttendanceRatePage.routeName;

  static Route<void> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case attendance:
        return MaterialPageRoute<void>(
          builder: (_) => const AttendancePage(),
          settings: settings,
        );
      case attendanceRate:
        return MaterialPageRoute<void>(
          builder: (_) => const AttendanceRatePage(),
          settings: settings,
        );
      case menu:
        final title = settings.arguments as String? ?? 'Menu';
        return MaterialPageRoute<void>(
          builder: (_) => MenuScreen(title: title),
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
