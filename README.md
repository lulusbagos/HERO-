# HERO — Human Enterprise Resource Operations

> Mobile application for PT INDEXIM COALINDO  
> Built with **Flutter** · Designed for multi-role HR & GA workflows

---

## About

**HERO** is a premium mobile platform that streamlines all Human Resource and General Administration processes for PT INDEXIM COALINDO. It supports tiered approval chains, role-based access, and a dynamic menu system driven entirely by a backend database — enabling administrators to add or remove features without a new app release.

---

## Quick Start

```bash
# clone
git clone https://github.com/lulusbagos/HERO-.git
cd HERO-

# install dependencies
flutter pub get

# run on a connected device or emulator
flutter run
```

---

## Project Structure

```
lib/
├── main.dart
├── app/
│   ├── hero_app.dart                 # MaterialApp, theme, routing
│   ├── app_theme.dart                # Centralised colour/typography tokens
│   └── app_routes.dart               # Named-route registry (all 9 menus wired)
├── core/
│   ├── constants/app_constants.dart  # App-wide magic values
│   ├── enums/app_role.dart
│   ├── models/app_menu_item.dart
│   ├── repositories/menu_repository.dart
│   ├── services/auth_service.dart
│   ├── utils/format_utils.dart       # Date/time formatting helpers
│   └── widgets/feature_placeholder.dart  # Premium "Coming Soon" page
└── features/
    ├── auth/pages/login_page.dart
    ├── home/pages/home_shell.dart    # Dashboard, Tasks, Profile tabs
    ├── attendance/
    │   ├── pages/attendance_page.dart           # GPS map check-in
    │   └── pages/attendance_revision_page.dart  # Revisi absen + approval
    ├── menu/
    │   ├── pages/menu_screen.dart
    │   └── pages/organization_structure_page.dart  # Org tree chart
    ├── leave/pages/leave_page.dart
    ├── roster/pages/roster_page.dart
    ├── meal_attendance/pages/meal_attendance_page.dart
    ├── her_registration/pages/her_registration_page.dart
    ├── schedule_revision/pages/schedule_revision_page.dart
    └── payslip/pages/payslip_page.dart

# Each feature folder also has: models/, widgets/, repositories/ stubs
```

---

## Roles

| Role | Access |
|---|---|
| **Staff** | Attendance, leave, announcements |
| **Supervisor** | Staff menus + approve overtime |
| **Manager** | Supervisor menus + budget review + tiered approval |
| **HERO Admin** | Full access + user management + policy master |

---

## Key Concepts

- **Role-based access** — menus are fetched per role at runtime from the database
- **Tiered approval** — approval chains configured in DB, never hardcoded
- **Lazy loading** — feature modules loaded on demand via `FutureBuilder` + repository pattern
- **DB-driven menus** — swap `MockMenuRepository` with an API implementation, zero UI changes needed

---

## Assets

Place company assets in `assets/images/` then declare in `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/images/
```

---

## Documentation

| Doc | Description |
|---|---|
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | Folder structure, layer rules, data flow |
| [docs/FEATURES.md](docs/FEATURES.md) | Feature status per version |
| [docs/CONTRIBUTING.md](docs/CONTRIBUTING.md) | Branch strategy, commit convention, PR checklist |
| [docs/ROADMAP.md](docs/ROADMAP.md) | Planned milestones v1.0 → v3.0 |

---

*© PT INDEXIM COALINDO · All rights reserved*

---

## Latest Session Handover

**Branch**: `copilot/premium-home-ui-20260530`  
**Last commit**: `83075f1` — HERO is now the **primary editing project**

### Completed Features
| Feature | Status | File |
|---|---|---|
| Login Page | ✅ Done | `auth/pages/login_page.dart` |
| Home Dashboard | ✅ Done | `home/pages/home_shell.dart` |
| Notification Center (HTML) | ✅ Done | inside `home_shell.dart` |
| Quick Access (editable) | ✅ Done | inside `home_shell.dart` |
| Attendance + GPS Map | ✅ Done | `attendance/pages/attendance_page.dart` |
| Revisi Absen (form + approval) | ✅ Done | `attendance/pages/attendance_revision_page.dart` |
| Struktur Organisasi | ✅ Done | `menu/pages/organization_structure_page.dart` |
| Profile (premium full) | ✅ Done | inside `home_shell.dart` |
| Leave, Roster, Absen Makan, Her Reg, Revisi Jadwal, Payslip | 🚧 Stub | `features/<name>/pages/` |

### Deploy Command (Samsung SM G975F)
```powershell
Set-Location "D:\4. PROJECT\13. Mobile\HERO"
$env:GRADLE_USER_HOME = "D:\.gradle-hero"
flutter run -d RR8M601DR3Z
```

### Key Notes
- **This folder (HERO) is the primary editing project** — edit here directly
- `pubspec.yaml` in HERO includes `flutter_map` + `latlong2` for the GPS attendance page — do NOT remove them
- Color palette: navy `0xFF061B49`, blue `0xFF156DFF`, muted `0xFF718096`; font: `Poppins`
- All 9 Quick Access menus are routed in `AppRoutes` + `_openMenu()`

