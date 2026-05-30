# Features

## Status Legend

| Symbol | Meaning |
|---|---|
| ✅ | Done (in this release) |
| 🔄 | In progress |
| 📋 | Planned |
| 💡 | Idea / under consideration |

---

## v1.0 — Foundation (Current)

### Auth Module
| Feature | Status | Notes |
|---|---|---|
| Animated login page | ✅ | Glassmorphism card, ambient gradient, glow orbs |
| Role selection on login | ✅ | Staff, Supervisor, Manager, HERO Admin |
| Input validation | ✅ | Client-side; backend validation on v1.1 |
| Password obscure toggle | 📋 | Eye icon to show/hide |
| Biometric login | 📋 | Fingerprint / Face ID via `local_auth` |

### Home & Navigation
| Feature | Status | Notes |
|---|---|---|
| Role-based dynamic menu | ✅ | Menu loaded from repository per role |
| Lazy menu loading | ✅ | FutureBuilder — loads only on HomeShell mount |
| Bottom navigation | 📋 | Dashboard, Tasks, Notifications, Profile |
| Dark / Light theme toggle | 📋 | Persisted via `shared_preferences` |

---

## v1.1 — Core HR Modules

### Attendance
| Feature | Status | Notes |
|---|---|---|
| Clock-in / Clock-out | 📋 | GPS-verified |
| Attendance history | 📋 | Calendar view |
| Late / absent alerts | 📋 | Push notifications |

### Leave Request
| Feature | Status | Notes |
|---|---|---|
| Submit leave request | 📋 | Form with date picker |
| Leave balance display | 📋 | Remaining days by type |
| Status tracking | 📋 | Pending / Approved / Rejected |

### Announcements
| Feature | Status | Notes |
|---|---|---|
| Announcement list | 📋 | From DB, paginated |
| Read receipts | 📋 | Track who has read |
| Push notification | 📋 | Firebase Cloud Messaging |

---

## v1.2 — Approval Engine

### Tiered Approval
| Feature | Status | Notes |
|---|---|---|
| Dynamic approval chain | 📋 | Configured in DB, not hardcoded |
| In-app approval action | 📋 | Approve / Reject with comment |
| Escalation / fallback role | 📋 | Auto-escalate on timeout |
| Approval history log | 📋 | Full audit trail |

### Supervisor Features
| Feature | Status | Notes |
|---|---|---|
| Approve overtime | 📋 | List + bulk action |
| Team attendance summary | 📋 | Table + chart |

### Manager Features
| Feature | Status | Notes |
|---|---|---|
| Budget review dashboard | 📋 | Charts + export PDF |
| Department headcount | 📋 | |

---

## v2.0 — Admin & Integration

### HERO Admin
| Feature | Status | Notes |
|---|---|---|
| User management | 📋 | CRUD employees, assign roles |
| Policy master | 📋 | Leave types, overtime rules |
| Menu configurator | 📋 | Enable/disable menus per role in UI |
| Audit log viewer | 📋 | All approval actions |

### Integration
| Feature | Status | Notes |
|---|---|---|
| REST API backend | 📋 | Replace MockRepository implementations |
| JWT authentication | 📋 | Secure token storage via `flutter_secure_storage` |
| Offline mode | 💡 | SQLite cache for attendance/leaves |
| Export to PDF/Excel | 📋 | Reports |

---

## Design Principles

1. **DB-driven menus** — No rebuild needed to add/remove modules
2. **Lazy loading** — Modules fetched and rendered on demand
3. **Role isolation** — UI and data always filtered by authenticated role
4. **No hardcoded approvers** — Approval chains live in the database
5. **Graceful degradation** — Offline fallback for critical features (v2.0)
