# QuickServe — Mobile Service Request Platform

> A full-stack Flutter mobile application for managing home/field service requests with role-based access for **Customers** and **Agents (Technicians)**.

---

## 📱 Overview

**QuickServe** lets customers submit service requests (plumbing, electrical, cleaning, etc.) and tracks them through a complete lifecycle. Assigned agents receive jobs, accept them, start work, and mark them complete — all within one unified app.

| Role | Capabilities |
|------|-------------|
| **Customer** | Create requests, track status, cancel requests, manage profile |
| **Agent** | View assigned jobs, Accept → Start → Complete lifecycle, add field notes |

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────┐
│                Flutter Mobile App                    │
│  ┌──────────┐  ┌──────────┐  ┌────────────────────┐ │
│  │  Auth    │  │ Customer │  │  Agent Dashboard   │ │
│  │  Screen  │  │  Home    │  │  (Job Queue)       │ │
│  └────┬─────┘  └────┬─────┘  └─────────┬──────────┘ │
│       │             │                   │             │
│  ┌────▼─────────────▼───────────────────▼──────────┐ │
│  │         Riverpod State Management               │ │
│  │         GoRouter Navigation                     │ │
│  └────────────────────┬────────────────────────────┘ │
└───────────────────────┼─────────────────────────────┘
                        │ HTTPS / Supabase Client
┌───────────────────────▼─────────────────────────────┐
│                  Supabase Backend                    │
│  ┌──────────────┐  ┌──────────────┐  ┌───────────┐  │
│  │  Auth (JWT)  │  │  PostgreSQL  │  │  RLS      │  │
│  │              │  │  Database    │  │  Policies │  │
│  └──────────────┘  └──────────────┘  └───────────┘  │
└─────────────────────────────────────────────────────┘
```

### Technology Stack

| Layer | Technology |
|-------|-----------|
| Mobile UI | Flutter 3.47 (Dart) |
| State Management | Riverpod 2.5 |
| Navigation | GoRouter 14 |
| Backend / Auth | Supabase (PostgreSQL + Auth) |
| Security | Supabase Row Level Security (RLS) |
| Fonts / Icons | Google Fonts, Material Icons |

---

## 🗄️ Database Schema

### Tables

#### `profiles`
| Column | Type | Description |
|--------|------|-------------|
| `id` | UUID (PK, FK → auth.users) | User identity |
| `email` | TEXT | User email |
| `full_name` | TEXT | Display name |
| `phone` | TEXT | Contact number |
| `role` | TEXT | `'customer'` or `'agent'` |
| `created_at` | TIMESTAMPTZ | Registration time |

#### `services`
| Column | Type | Description |
|--------|------|-------------|
| `id` | UUID (PK) | Service ID |
| `name` | TEXT | Service name (e.g. Plumbing) |
| `description` | TEXT | Service description |
| `base_price` | NUMERIC | Starting price |
| `is_active` | BOOLEAN | Availability flag |

#### `service_requests`
| Column | Type | Description |
|--------|------|-------------|
| `id` | UUID (PK) | Request ID |
| `request_id` | TEXT | Human-readable ID (REQ-YYYY-XXXXXX) |
| `customer_id` | UUID (FK → profiles) | Requesting customer |
| `agent_id` | UUID (FK → profiles, nullable) | Assigned agent |
| `service_id` | UUID (FK → services) | Service type |
| `description` | TEXT | Problem description |
| `preferred_date` | DATE | Requested date |
| `preferred_time` | TEXT | Time slot preference |
| `address` | TEXT | Service location |
| `status` | TEXT | Current status (see lifecycle) |
| `priority` | TEXT | LOW / MEDIUM / HIGH / URGENT |
| `agent_notes` | TEXT | Field notes by agent |
| `created_at` | TIMESTAMPTZ | Creation time |
| `updated_at` | TIMESTAMPTZ | Last update time |

#### `audit_logs`
| Column | Type | Description |
|--------|------|-------------|
| `id` | UUID (PK) | Log entry ID |
| `user_id` | UUID | Actor |
| `event_type` | TEXT | Event name (see below) |
| `resource_type` | TEXT | e.g. `service_request` |
| `resource_id` | UUID | Affected record ID |
| `metadata` | JSONB | Extra context |
| `created_at` | TIMESTAMPTZ | Event time |

### Request Status Lifecycle

```
CREATED → ASSIGNED → ACCEPTED → IN_PROGRESS → COMPLETED
                                     ↓
                                 CANCELLED (only from CREATED or ASSIGNED)
```

### Audit Event Types
- `LOGIN_SUCCESS` — User authenticated
- `REQUEST_CREATED` — New service request submitted
- `REQUEST_ASSIGNED` — Agent assigned to request
- `REQUEST_UPDATED` — Status changed
- `AUTHORIZATION_FAILED` — Unauthorized access attempt
- `DATABASE_ERROR` — Backend error captured

---

## 🔐 Security — Row Level Security (RLS)

All database access is enforced at the **database layer** (not just UI).

| Policy | Table | Rule |
|--------|-------|------|
| Customers see own requests | `service_requests` | `customer_id = auth.uid()` |
| Agents see assigned requests | `service_requests` | `agent_id = auth.uid()` |
| Customers create own requests | `service_requests` | `customer_id = auth.uid()` |
| Customers cancel own (if CREATED/ASSIGNED) | `service_requests` | Status check + ownership |
| Agents update assigned requests | `service_requests` | `agent_id = auth.uid()` |
| Users see own profile | `profiles` | `id = auth.uid()` |

---

## 🚀 Setup & Run Instructions

### Prerequisites
- Flutter 3.47+ installed
- Dart SDK ≥ 3.0.0
- A Supabase project (free tier works)

### 1. Clone the repository
```bash
git clone https://github.com/YOUR_USERNAME/quickserve-app.git
cd quickserve-app/mobile
```

### 2. Configure Supabase
Create a `.env` file or update `lib/core/config/supabase_config.dart`:
```dart
const supabaseUrl = 'YOUR_SUPABASE_URL';
const supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
```

### 3. Install dependencies
```bash
flutter pub get
```

### 4. Run the app
```bash
# Android (phone connected via USB or emulator)
flutter run

# Build release APK
flutter build apk --release
# APK will be at: build/app/outputs/flutter-apk/app-release.apk

# Run on Chrome (web)
flutter run -d chrome
```

### 5. Run tests
```bash
flutter test
```

---

## 🧪 Test Credentials

> **Note:** Create these accounts in your Supabase project Auth → Users, then set roles in the `profiles` table.

| Role | Email | Password |
|------|-------|----------|
| Customer | `customer@test.com` | `Test@1234` |
| Agent | `agent@test.com` | `Test@1234` |

**Setting a user role (in Supabase SQL editor):**
```sql
UPDATE profiles SET role = 'agent' WHERE email = 'agent@test.com';
```

---

## 🧪 Tests Included

| Test File | What It Tests |
|-----------|--------------|
| `test/rls_isolation_test.dart` | **Authorization**: Customer cannot cancel in-progress requests; invalid state transitions rejected |
| `test/state_machine_test.dart` | Status lifecycle transitions (valid & invalid) |
| `test/customer_auth_test.dart` | Authentication flow, login/logout |
| `test/models_test.dart` | Data model serialization/deserialization |
| `test/validation_test.dart` | Input validation rules |
| `test/request_validation_test.dart` | Request creation validation |
| `test/widget_test.dart` | App smoke test (renders without crashing) |

---

## 📁 Project Structure

```
lib/
├── main.dart                     # App entry point (Riverpod + GoRouter)
├── core/
│   ├── config/                   # Supabase config
│   ├── router/app_router.dart    # Route definitions (role-based)
│   ├── theme/app_theme.dart      # Material theme
│   └── utils/status_helper.dart  # State machine logic
├── features/
│   ├── auth/screens/             # Login, Splash
│   ├── home/screens/             # Customer home (tab navigation)
│   ├── services/screens/         # Browse services
│   ├── requests/                 # Create/view requests, providers
│   ├── profile/screens/          # Profile management
│   └── agent/screens/            # Agent dashboard, job details
├── models/                       # ServiceRequest, Profile data models
├── services/                     # Supabase API service classes
└── widgets/                      # Shared UI components
```

---

## 📋 Submission Checklist

- [x] GitHub repository with clean structure + `.gitignore`
- [x] Working Flutter mobile app (Customer + Agent roles)
- [x] Supabase backend + PostgreSQL database
- [x] Authentication (email/password via Supabase Auth)
- [x] Role-Based Access Control (Customer vs Agent)
- [x] RLS policies enforced at database layer
- [x] Audit logging (LOGIN_SUCCESS, REQUEST_CREATED, etc.)
- [x] Error handling (network, auth, validation)
- [x] Architecture + database/security documentation (this README)
- [x] Unit tests including authorization boundary test
- [x] Release APK built successfully (53.5 MB)

---

## 🌐 Web Admin Portal

The web version runs via `flutter run -d chrome` or deploy `build/web/` to any static host (Firebase Hosting, Netlify, etc.).

---

*Built with Flutter + Supabase · QuickServe v1.0.0*
