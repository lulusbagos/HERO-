import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero/core/enums/app_role.dart';
import 'package:hero/core/models/app_menu_item.dart';
import 'package:hero/core/repositories/menu_repository.dart';
import 'package:hero/app/hero_app.dart';
import 'package:hero/features/home/pages/home_shell.dart';
import 'package:hero/features/menu/pages/menu_screen.dart';

void main() {
  testWidgets('HERO login renders key elements', (WidgetTester tester) async {
    await tester.pumpWidget(const HeroApp());

    expect(find.text('HERO'), findsOneWidget);
    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
  });

  testWidgets('notification center shows unread styling target',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MenuScreen(
          title: 'Notifications',
          route: '/notifications',
        ),
      ),
    );

    expect(find.text('Notification Center'), findsOneWidget);
    expect(find.byKey(const ValueKey('unread-notification')), findsOneWidget);
  });

  testWidgets('edit quick actions reveals movable dummy menus',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: HomeShell(
          role: AppRole.staff,
          menuRepository: _FakeMenuRepository(),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('quick-action-editor')), findsOneWidget);
    expect(find.text('HER Registration'), findsWidgets);
    expect(find.text("Today's Birthdays"), findsWidgets);
  });
}

class _FakeMenuRepository implements MenuRepository {
  @override
  Future<List<AppMenuItem>> fetchMenus(AppRole role) async {
    return const [
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
  }
}
