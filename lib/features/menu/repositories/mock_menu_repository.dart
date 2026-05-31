import 'package:flutter/material.dart';
import 'package:hero/core/enums/app_role.dart';
import 'package:hero/core/models/app_menu_item.dart';
import 'package:hero/core/repositories/menu_repository.dart';

/// Mock implementation of [MenuRepository].
/// Replace with a real API/database call when the backend is ready.
class MockMenuRepository implements MenuRepository {
  @override
  Future<List<AppMenuItem>> fetchMenus(AppRole role) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));

    const commonMenus = <AppMenuItem>[
      AppMenuItem(
        title: 'Attendance',
        route: '/attendance',
        icon: Icons.fact_check_outlined,
      ),
      AppMenuItem(
        title: 'Leave Request',
        route: '/leave',
        icon: Icons.beach_access_outlined,
      ),
      AppMenuItem(
        title: 'Announcement',
        route: '/announcement',
        icon: Icons.campaign_outlined,
      ),
    ];

    switch (role) {
      case AppRole.staff:
        return commonMenus;

      case AppRole.supervisor:
        return <AppMenuItem>[
          ...commonMenus,
          const AppMenuItem(
            title: 'Approve Overtime',
            route: '/approve-overtime',
            icon: Icons.playlist_add_check_circle_outlined,
          ),
        ];

      case AppRole.manager:
        return <AppMenuItem>[
          ...commonMenus,
          const AppMenuItem(
            title: 'Budget Review',
            route: '/budget',
            icon: Icons.analytics_outlined,
          ),
          const AppMenuItem(
            title: 'Tiered Approval',
            route: '/tiered-approval',
            icon: Icons.layers_outlined,
          ),
        ];

      case AppRole.heroAdmin:
        return <AppMenuItem>[
          ...commonMenus,
          const AppMenuItem(
            title: 'User Management',
            route: '/users',
            icon: Icons.admin_panel_settings_outlined,
          ),
          const AppMenuItem(
            title: 'Policy Master',
            route: '/policy',
            icon: Icons.rule_folder_outlined,
          ),
          const AppMenuItem(
            title: 'Tiered Approval',
            route: '/tiered-approval',
            icon: Icons.layers_outlined,
          ),
        ];
    }
  }
}
