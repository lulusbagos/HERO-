# Architecture

## Overview

HERO menggunakan arsitektur **Feature-First** berlapis yang memisahkan concern secara tegas, memudahkan penambahan fitur dan penggantian implementasi tanpa merusak kode yang sudah berjalan.

```
Presentation  ─── features/<feature>/pages/     (UI + state)
                   features/<feature>/widgets/   (reusable UI components)
Application   ─── features/<feature>/repositories/ (data contracts + mock)
Domain        ─── core/models/                  (data classes)
                   core/enums/                   (enumerations)
                   core/repositories/            (abstract contracts)
Infrastructure─── core/services/                (business logic, future: API clients)
Config        ─── app/                           (MaterialApp, theme, routing)
```

---

## Layer Descriptions

### `app/`

| File | Responsibility |
|---|---|
| `hero_app.dart` | Root `MaterialApp` — wire theme and routing together |
| `app_theme.dart` | Single source of truth for colours, typography, shape tokens |
| `app_routes.dart` | Named-route registry; add all new routes here |

**Rule:** No business logic, no I/O — configuration only.

---

### `core/`

| Folder | Contents |
|---|---|
| `enums/` | App-wide enumerations (`AppRole`) |
| `models/` | Plain Dart data classes (`AppMenuItem`) |
| `repositories/` | Abstract repository interfaces — define contracts, not implementations |
| `services/` | Stateless business-logic services (`AuthService`) |

**Rule:** `core/` has zero Flutter UI dependencies. It is pure Dart.

---

### `features/<feature>/`

Each feature is self-contained:

```
features/
└── <feature>/
    ├── pages/        ← StatefulWidget screens
    ├── widgets/      ← Reusable sub-widgets for this feature
    ├── repositories/ ← Feature-specific repository implementations
    ├── bloc/         ← (future) BLoC/Cubit state management
    └── models/       ← (future) feature-local data models
```

#### Current Features

| Feature | Purpose |
|---|---|
| `auth` | Login page with role selection and professional animations |
| `home` | Post-login shell that fetches and renders the role-based menu |
| `menu` | Individual module screen placeholder + mock menu repository |

---

## Dependency Rule

Arrows show what may import what:

```
features  →  core
app       →  features, core
main      →  app
```

`core/` never imports from `features/` or `app/`.  
`features/` modules do not import from each other (communicate via routes or shared core contracts).

---

## Data Flow — Login → Home

```
LoginPage
  │  user taps Sign In
  ▼
AuthService.signIn()        ← validates credentials (future: calls REST API)
  │  success
  ▼
Navigator.pushReplacement → HomeShell(role, menuRepository)
  │
  ▼
MenuRepository.fetchMenus(role)   ← async, FutureBuilder in HomeShell
  │  returns List<AppMenuItem>
  ▼
ListView renders menu cards      ← only loaded when HomeShell is visible (lazy)
```

---

## Menu-Driven Architecture

Menus bukan dikodekan langsung di UI. Mereka berasal dari repository:

```
abstract class MenuRepository {
  Future<List<AppMenuItem>> fetchMenus(AppRole role);
}
```

**Swap** `MockMenuRepository` dengan `ApiMenuRepository` ketika backend siap:

```dart
// lib/features/menu/repositories/api_menu_repository.dart
class ApiMenuRepository implements MenuRepository {
  @override
  Future<List<AppMenuItem>> fetchMenus(AppRole role) async {
    final response = await http.get(Uri.parse('/api/menus?role=${role.name}'));
    // parse and return
  }
}
```

Tidak ada perubahan di UI.

---

## Tiered Approval Concept

Approval bertingkat dikonfigurasi di database, bukan di kode:

```
DB Table: approval_chains
┌─────────────────┬───────────┬──────────┬────────────────┐
│ process_type    │ step      │ role     │ fallback_role  │
├─────────────────┼───────────┼──────────┼────────────────┤
│ leave           │ 1         │ supervisor│ manager       │
│ leave           │ 2         │ manager  │ heroAdmin      │
│ overtime        │ 1         │ supervisor│ manager       │
└─────────────────┴───────────┴──────────┴────────────────┘
```

Setiap proses yang membutuhkan approval memanggil `ApprovalService.getChain(processType)` dan membangun alur approval secara dinamis.

---

## State Management

Tahap awal menggunakan `setState` dan `FutureBuilder`. Rencana migrasi:

| Phase | State tool |
|---|---|
| v1.x | `setState` + `FutureBuilder` (current) |
| v2.x | `flutter_bloc` per feature |
| v3.x | BLoC + `freezed` data classes |

---

## Adding a New Feature

1. Buat folder `lib/features/<nama_fitur>/`
2. Tambahkan `pages/`, `widgets/`, `repositories/` sesuai kebutuhan
3. Daftarkan route baru di `lib/app/app_routes.dart`
4. Tambahkan `AppMenuItem` di `MockMenuRepository` (lalu di DB)
5. Tidak perlu menyentuh `main.dart`, `hero_app.dart`, atau `app_theme.dart`
