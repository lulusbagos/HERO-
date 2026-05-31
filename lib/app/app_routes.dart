import 'package:flutter/material.dart';
import 'package:hero/features/auth/pages/login_page.dart';
import 'package:hero/features/attendance/pages/attendance_page.dart';
import 'package:hero/features/attendance/pages/attendance_revision_page.dart';
import 'package:hero/features/menu/pages/menu_screen.dart';
import 'package:hero/features/menu/pages/organization_structure_page.dart';
import 'package:hero/features/leave/pages/leave_page.dart';
import 'package:hero/features/roster/pages/roster_page.dart';
import 'package:hero/features/meal_attendance/pages/meal_attendance_page.dart';
import 'package:hero/features/her_registration/pages/her_registration_page.dart';
import 'package:hero/features/schedule_revision/pages/schedule_revision_page.dart';
import 'package:hero/features/payslip/pages/payslip_page.dart';

/// Central route registry.
/// Add new named routes here as features are added.
abstract final class AppRoutes {
  static const String login = '/';
  static const String menu = MenuScreen.routeName;

  // ── Attendance ─────────────────────────────────────────────────────────────
  static const String attendance = AttendancePage.routeName;
  static const String attendanceRevision = AttendanceRevisionPage.routeName;

  // ── Organisation ──────────────────────────────────────────────────────────
  static const String organizationStructure =
      OrganizationStructurePage.routeName;

  // ── HR Features ───────────────────────────────────────────────────────────
  static const String leave = LeavePage.routeName;
  static const String roster = RosterPage.routeName;
  static const String mealAttendance = MealAttendancePage.routeName;
  static const String herRegistration = HerRegistrationPage.routeName;
  static const String scheduleRevision = ScheduleRevisionPage.routeName;
  static const String payslip = PayslipPage.routeName;

  static Route<void> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case attendance:
        return MaterialPageRoute<void>(
          builder: (_) => const AttendancePage(),
          settings: settings,
        );
      case attendanceRevision:
        return MaterialPageRoute<void>(
          builder: (_) => const AttendanceRevisionPage(),
          settings: settings,
        );
      case organizationStructure:
        return MaterialPageRoute<void>(
          builder: (_) => const OrganizationStructurePage(),
          settings: settings,
        );
      case leave:
        return MaterialPageRoute<void>(
          builder: (_) => const LeavePage(),
          settings: settings,
        );
      case roster:
        return MaterialPageRoute<void>(
          builder: (_) => const RosterPage(),
          settings: settings,
        );
      case mealAttendance:
        return MaterialPageRoute<void>(
          builder: (_) => const MealAttendancePage(),
          settings: settings,
        );
      case herRegistration:
        return MaterialPageRoute<void>(
          builder: (_) => const HerRegistrationPage(),
          settings: settings,
        );
      case scheduleRevision:
        return MaterialPageRoute<void>(
          builder: (_) => const ScheduleRevisionPage(),
          settings: settings,
        );
      case payslip:
        return MaterialPageRoute<void>(
          builder: (_) => const PayslipPage(),
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
