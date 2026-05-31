enum AppRole { staff, supervisor, manager, heroAdmin }

extension AppRoleLabel on AppRole {
  String get label {
    switch (this) {
      case AppRole.staff:
        return 'Staff';
      case AppRole.supervisor:
        return 'Supervisor';
      case AppRole.manager:
        return 'Manager';
      case AppRole.heroAdmin:
        return 'HERO Admin';
    }
  }
}
