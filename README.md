<div align="center">

# ⚡ QuickServe
### Service Request Management System

*Submit · Track · Manage · Resolve*

[![Flutter](https://img.shields.io/badge/Flutter-3.47-02569B?style=flat-square&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0-0175C2?style=flat-square&logo=dart&logoColor=white)](https://dart.dev)
[![Supabase](https://img.shields.io/badge/Supabase-PostgreSQL-3ECF8E?style=flat-square&logo=supabase&logoColor=white)](https://supabase.com)
[![Riverpod](https://img.shields.io/badge/Riverpod-2.5-blue?style=flat-square)](https://riverpod.dev)
[![License](https://img.shields.io/badge/License-MIT-yellow?style=flat-square)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20Web-green?style=flat-square)](https://flutter.dev/multi-platform)

</div>

---

## 📋 Table of Contents

- [Problem Statement](#-problem-statement)
- [Solution](#-solution)
- [Features](#-features)
- [Architecture](#-architecture)
- [Technology Stack](#-technology-stack)
- [Database Design](#-database-design)
- [Security](#-security)
- [Project Structure](#-project-structure)
- [Getting Started](#-getting-started)
- [Environment Setup](#-environment-setup)
- [Running the App](#-running-the-app)
- [Testing](#-testing)
- [Project Metrics](#-project-metrics)
- [Roadmap](#-roadmap)
- [My Contribution](#-my-contribution)
- [Why This Project Matters](#-why-this-project-matters)
- [Developer](#-developer)

---

## 🔴 Problem Statement

Managing home and facility service requests is traditionally fragmented:

| Problem | Impact |
|---------|--------|
| Requests made via phone calls or WhatsApp messages | No formal tracking or accountability |
| No centralized system for logging service history | Difficulty resolving disputes or reviewing past work |
| Customers have no visibility into request status | Frustration from lack of communication |
| Technicians (agents) receive verbal job assignments | Confusion, missed jobs, no structured workflow |
| Admins manually coordinate between customers and field staff | Operational inefficiency and delays |

**QuickServe** is built to digitize and streamline this entire process.

---

## 💡 Solution

QuickServe provides a unified mobile platform where customers submit structured service requests, agents manage their job queue, and the entire lifecycle is tracked in real time.

```
Customer opens app
        ↓
Registers / Logs in securely
        ↓
Browses service catalog (AC, Plumbing, Electrical, Cleaning…)
        ↓
Creates a service request with description, date, priority
        ↓
Request stored in PostgreSQL (status: CREATED)
        ↓
Agent assigned → status: ASSIGNED
        ↓
Agent accepts → IN_PROGRESS → COMPLETED
        ↓
Customer tracks every status change in real time
        ↓
Full audit history preserved
```

---

## ✨ Features

### 👤 Customer Features
- **Secure Authentication** — Email/password sign-up & login via Supabase Auth
- **Service Catalog** — Browse available service categories with descriptions
- **Create Service Request** — Select service, describe issue, set preferred date/time, address, priority
- **Real-time Tracking** — Live status updates via Supabase Realtime subscriptions
- **Request History** — Full timeline of every status change per request
- **Cancellation Control** — Cancel requests only when in CREATED or ASSIGNED state
- **Profile Management** — View and edit personal details
- **Password Reset** — Email-based forgot password flow

### 🛠️ Agent (Technician) Features
- **Dedicated Dashboard** — Separate UI for agents upon login
- **Job Queue** — View all assigned service requests
- **Status Workflow** — Accept → Start Work → Complete (enforced sequential transitions)
- **Field Notes** — Add work notes when updating job status
- **Request Details** — See customer info, service type, address, description

### 🔐 Platform Features
- **Role-Based Access Control (RBAC)** — Customer and Agent roles with separate routing
- **Row Level Security (RLS)** — Database-layer enforcement: customers see only their data
- **State Machine** — Validated status transitions prevent invalid updates
- **Mock/Demo Mode** — App runs with local mock data when no Supabase credentials are provided
- **Cross-Platform** — Runs on Android (APK) and Web (Chrome)

---

## 🏗️ Architecture

QuickServe follows a **layered feature-first architecture**:

```
┌─────────────────────────────────────────────────────────────────┐
│                    Presentation Layer                            │
│   ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐ │
│   │  Customer    │  │    Agent     │  │   Auth Screens       │ │
│   │  Screens     │  │  Dashboard   │  │  Login/Register      │ │
│   └──────┬───────┘  └──────┬───────┘  └──────────┬───────────┘ │
│          │                 │                       │             │
│   ┌──────▼─────────────────▼───────────────────────▼──────────┐ │
│   │              State Management (Riverpod)                   │ │
│   │         GoRouter — Role-based navigation                   │ │
│   └──────────────────────────┬────────────────────────────────┘ │
└─────────────────────────────┼───────────────────────────────────┘
                               │ Service Layer
┌─────────────────────────────┼───────────────────────────────────┐
│                             ▼                                    │
│          SupabaseCustomerService (Singleton)                     │
│          ┌──────────────────────────────────────┐               │
│          │  Auth  │ Profiles │ Requests │ Agent  │               │
│          └──────────────────────────────────────┘               │
└─────────────────────────────┼───────────────────────────────────┘
                               │ HTTPS / Supabase Client SDK
┌─────────────────────────────▼───────────────────────────────────┐
│                     Supabase Backend                             │
│  ┌────────────────┐  ┌──────────────────┐  ┌─────────────────┐  │
│  │  Auth (JWT)    │  │ PostgreSQL DB    │  │ Realtime        │  │
│  │  Role metadata │  │ RLS Policies     │  │ Subscriptions   │  │
│  └────────────────┘  └──────────────────┘  └─────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

### Design Patterns Used
- **Singleton** — `SupabaseCustomerService.instance` manages one shared client
- **Repository-style Service** — All database operations isolated in the service layer
- **State Machine** — `StatusHelper.isValidTransition()` enforces request lifecycle
- **Provider Pattern** — Riverpod providers manage auth and request state
- **Feature-First Folder Structure** — Each feature owns its screens, providers, and logic

---

## 🧩 Technology Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| Mobile UI | Flutter 3.47 | Cross-platform app framework |
| Language | Dart 3.0 | Type-safe, null-safe programming |
| State Management | Riverpod 2.5 | Reactive state with dependency injection |
| Navigation | GoRouter 14 | Declarative, URL-based routing |
| Backend / Auth | Supabase | PostgreSQL + Auth + Realtime |
| Database | PostgreSQL | Relational data with RLS |
| Fonts | Google Fonts | Professional typography |
| Version Control | Git / GitHub | Source control and collaboration |
| Build | Flutter CLI | Android APK + Web build |

---

## 🗄️ Database Design

### Entity-Relationship Overview

```
profiles (1) ──────────────── (many) service_requests
     │                              │          │
     │ (agent)                      │          │
     └──── (many) service_requests  │          │
                                    │          │
services (1) ──────────────── (many)┘          │
                                               │
request_status_history (many) ────────── (1) ──┘
audit_logs (many) ────────────────────── (1) profiles
```

### Table: `profiles`

| Column | Type | Constraints | Description |
|--------|------|------------|-------------|
| `id` | UUID | PK, FK → auth.users | Supabase Auth user ID |
| `full_name` | TEXT | NOT NULL | Display name |
| `email` | TEXT | UNIQUE, NOT NULL | User email |
| `phone` | TEXT | | Contact number |
| `role` | TEXT | CHECK (customer/agent/admin) | Access role |
| `is_active` | BOOLEAN | DEFAULT true | Account status |
| `avatar_url` | TEXT | | Profile photo URL |
| `created_at` | TIMESTAMPTZ | DEFAULT now() | Registration time |
| `updated_at` | TIMESTAMPTZ | | Last updated |

### Table: `services`

| Column | Type | Description |
|--------|------|-------------|
| `id` | UUID PK | Service identifier |
| `name` | TEXT | e.g., "AC Servicing", "Plumbing" |
| `description` | TEXT | Service details |
| `icon` | TEXT | Material icon name |
| `base_price` | NUMERIC | Starting price |
| `is_active` | BOOLEAN | Visibility flag |

### Table: `service_requests`

| Column | Type | Description |
|--------|------|-------------|
| `id` | UUID PK | Request identifier |
| `request_id` | TEXT | Human-readable ID (REQ-YYYY-XXXXXX) |
| `customer_id` | UUID FK → profiles | Requesting customer |
| `agent_id` | UUID FK → profiles | Assigned technician (nullable) |
| `service_id` | UUID FK → services | Service type |
| `description` | TEXT | Problem description |
| `preferred_date` | DATE | Requested service date |
| `preferred_time` | TEXT | Morning / Afternoon / Evening |
| `address` | TEXT | Service location |
| `priority` | TEXT | LOW / MEDIUM / HIGH |
| `status` | TEXT | See lifecycle below |
| `notes` | TEXT | Agent field notes |
| `created_at` | TIMESTAMPTZ | Submission time |
| `updated_at` | TIMESTAMPTZ | Last update |

### Table: `request_status_history`

| Column | Type | Description |
|--------|------|-------------|
| `id` | UUID PK | Entry identifier |
| `request_id` | UUID FK → service_requests | Related request |
| `previous_status` | TEXT | Status before change |
| `new_status` | TEXT | Status after change |
| `changed_by` | UUID FK → profiles | Actor who made the change |
| `note` | TEXT | Optional comment |
| `created_at` | TIMESTAMPTZ | When the change occurred |

### Table: `audit_logs`

| Column | Type | Description |
|--------|------|-------------|
| `id` | UUID PK | Log entry |
| `user_id` | UUID | Actor |
| `event_type` | TEXT | LOGIN_SUCCESS, REQUEST_CREATED, etc. |
| `resource_type` | TEXT | e.g., `service_request` |
| `resource_id` | UUID | Affected record |
| `metadata` | JSONB | Extra context |
| `created_at` | TIMESTAMPTZ | Event time |

### Request Status Lifecycle

```
  ┌─────────────────────────────────────────────────────┐
  │                  Status State Machine                │
  │                                                     │
  │  CREATED ──► ASSIGNED ──► ACCEPTED ──► IN_PROGRESS ──► COMPLETED │
  │      │           │                                            │
  │      └───────────┴──────────────────────────────► CANCELLED  │
  │                                                     │
  │  Rules:                                             │
  │  • Only CREATED or ASSIGNED can be cancelled        │
  │  • Transitions must follow the defined sequence     │
  │  • Completed/Cancelled are terminal states          │
  └─────────────────────────────────────────────────────┘
```

### Logged Audit Events

| Event | Trigger |
|-------|---------|
| `LOGIN_SUCCESS` | Successful user authentication |
| `REQUEST_CREATED` | New service request submitted |
| `REQUEST_ASSIGNED` | Agent assigned to a request |
| `REQUEST_UPDATED` | Status changed on a request |
| `AUTHORIZATION_FAILED` | Unauthorized access attempt blocked |
| `DATABASE_ERROR` | Backend error captured |

---

## 🔐 Security

### Row Level Security (RLS)

All data access is enforced at the **PostgreSQL database level**, not just in the UI. Even if a malicious client bypassed the app, the database would reject unauthorized queries.

| Policy | Table | Rule |
|--------|-------|------|
| Customers see own requests | `service_requests` | `customer_id = auth.uid()` |
| Agents see assigned requests | `service_requests` | `agent_id = auth.uid()` |
| Users see own profile only | `profiles` | `id = auth.uid()` |
| Customers can create requests | `service_requests` | `customer_id = auth.uid()` |
| Agents can update assigned jobs | `service_requests` | `agent_id = auth.uid()` |

### Authentication
- JWT tokens issued by Supabase Auth
- Role stored in both `auth.users.raw_user_meta_data` and `profiles.role`
- Role checked server-side; client routing is secondary
- Password reset via secure email link

### Environment Variables
```bash
# Copy .env.example and fill in your credentials
cp .env.example .env
```

> ⚠️ **Never commit `.env` files or API keys to version control.**
> Real credentials are injected at build time via `--dart-define`.

---

## 📂 Project Structure

```
mobile/
├── lib/
│   ├── main.dart                          # App entry point (Riverpod + GoRouter)
│   │
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_colors.dart            # Color palette (status, priority colors)
│   │   │   ├── app_strings.dart           # All user-facing string constants
│   │   │   └── app_theme.dart             # Material theme constants
│   │   ├── router/
│   │   │   └── app_router.dart            # GoRouter with 14 routes (role-based)
│   │   ├── services/
│   │   │   └── supabase_service.dart      # Low-level Supabase initialization
│   │   ├── theme/
│   │   │   ├── app_colors.dart            # Theme color definitions
│   │   │   └── app_theme.dart             # ThemeData (light theme)
│   │   └── utils/
│   │       ├── date_formatter.dart        # Date parse/format utilities
│   │       ├── status_helper.dart         # State machine + status colors/icons
│   │       └── validators.dart            # Form input validation rules
│   │
│   ├── features/
│   │   ├── auth/
│   │   │   ├── providers/
│   │   │   │   └── auth_provider.dart     # Riverpod auth state provider
│   │   │   └── screens/
│   │   │       ├── splash_screen.dart     # Session check + role-based redirect
│   │   │       ├── login_screen.dart      # Email/password login + role routing
│   │   │       ├── register_screen.dart   # New customer registration
│   │   │       └── forgot_password_screen.dart
│   │   │
│   │   ├── home/
│   │   │   └── screens/
│   │   │       └── customer_home_screen.dart  # Bottom nav shell (4 tabs)
│   │   │
│   │   ├── services/
│   │   │   ├── providers/
│   │   │   │   └── services_provider.dart # Services catalog state
│   │   │   └── screens/
│   │   │       ├── services_screen.dart   # Browse service categories
│   │   │       └── service_details_screen.dart
│   │   │
│   │   ├── requests/
│   │   │   ├── providers/
│   │   │   │   └── requests_provider.dart # Request CRUD + agent state
│   │   │   └── screens/
│   │   │       ├── create_request_screen.dart  # Request creation form
│   │   │       ├── my_requests_screen.dart     # Request list with status badges
│   │   │       ├── request_details_screen.dart # Full timeline view
│   │   │       └── request_success_screen.dart # Confirmation screen
│   │   │
│   │   ├── profile/
│   │   │   └── screens/
│   │   │       ├── profile_screen.dart    # User profile view
│   │   │       └── edit_profile_screen.dart
│   │   │
│   │   └── agent/
│   │       └── screens/
│   │           ├── agent_dashboard_screen.dart       # Agent job queue
│   │           └── agent_request_details_screen.dart # Accept/Start/Complete
│   │
│   ├── models/
│   │   ├── service_item.dart       # Service catalog model
│   │   ├── service_request.dart    # Full request model with relations
│   │   ├── status_history.dart     # Status change history entry
│   │   └── user_profile.dart       # User/profile model (customer/agent/admin)
│   │
│   ├── services/
│   │   └── supabase_customer_service.dart  # Singleton service layer (400 LOC)
│   │                                       # Auth, profiles, requests, agent ops
│   └── widgets/
│       ├── custom_button.dart       # Reusable primary/secondary buttons
│       ├── custom_text_field.dart   # Styled input field
│       ├── empty_state_widget.dart  # No-data placeholder
│       ├── stat_card.dart           # Statistics card widget
│       ├── status_badge.dart        # Color-coded status pill
│       └── timeline_widget.dart     # Request history timeline
│
├── test/
│   ├── rls_isolation_test.dart       # Authorization boundary tests ⭐
│   ├── state_machine_test.dart       # Status transition validation
│   ├── customer_auth_test.dart       # Authentication flow tests
│   ├── models_test.dart              # Model serialization tests
│   ├── validation_test.dart          # Form input validation tests
│   ├── request_validation_test.dart  # Request creation rules
│   └── widget_test.dart              # App smoke test
│
├── android/                          # Android build configuration
├── web/                              # Web (PWA) build output
├── .env.example                      # Environment variable template
├── pubspec.yaml                      # Dependencies
└── README.md                         # This file
```

---

## 🚀 Getting Started

### Prerequisites

| Requirement | Version | Check |
|-------------|---------|-------|
| Flutter SDK | ≥ 3.0.0 | `flutter --version` |
| Dart | ≥ 3.0.0 | `dart --version` |
| Android SDK | API 36 | `flutter doctor` |
| Java (JDK) | 17+ | `java -version` |

### 1. Clone the Repository

```bash
git clone https://github.com/varshakolekar20/quickserve-app.git
cd quickserve-app
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Verify Setup

```bash
flutter doctor
```

All required checks (`Flutter`, `Android toolchain`, `Chrome`) should show ✅.

---

## 🔑 Environment Setup

QuickServe connects to a **Supabase** backend. You need a Supabase project to use live features.

### Step 1 — Create a Supabase Project
1. Go to [supabase.com](https://supabase.com) → New Project
2. Copy your **Project URL** and **anon public key** from Project Settings → API

### Step 2 — Configure Environment

```bash
cp .env.example .env
```

Edit `.env`:
```env
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-anon-public-key-here
```

### Step 3 — Pass Credentials at Build Time

```bash
flutter run --dart-define=SUPABASE_URL=https://... --dart-define=SUPABASE_ANON_KEY=eyJ...
```

> **Note:** If no credentials are provided, the app runs in **demo/mock mode** automatically — all UI is functional with local sample data.

### Step 4 — Set Up the Database

Run these SQL statements in your Supabase SQL Editor:

```sql
-- Profiles table (extends auth.users)
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL,
  phone TEXT,
  role TEXT DEFAULT 'customer' CHECK (role IN ('customer', 'agent', 'admin')),
  is_active BOOLEAN DEFAULT true,
  avatar_url TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ
);

-- Services catalog
CREATE TABLE services (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT,
  icon TEXT,
  base_price NUMERIC(10,2),
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Service requests
CREATE TABLE service_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  request_id TEXT UNIQUE NOT NULL,
  customer_id UUID REFERENCES profiles(id) NOT NULL,
  agent_id UUID REFERENCES profiles(id),
  service_id UUID REFERENCES services(id) NOT NULL,
  description TEXT,
  preferred_date DATE,
  preferred_time TEXT,
  address TEXT,
  priority TEXT DEFAULT 'MEDIUM' CHECK (priority IN ('LOW', 'MEDIUM', 'HIGH')),
  status TEXT DEFAULT 'CREATED' CHECK (status IN ('CREATED','ASSIGNED','ACCEPTED','IN_PROGRESS','COMPLETED','CANCELLED')),
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ
);

-- Enable Row Level Security
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE service_requests ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Users see own profile" ON profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Customers see own requests" ON service_requests FOR SELECT USING (auth.uid() = customer_id);
CREATE POLICY "Agents see assigned requests" ON service_requests FOR SELECT USING (auth.uid() = agent_id);
CREATE POLICY "Customers create own requests" ON service_requests FOR INSERT WITH CHECK (auth.uid() = customer_id);
CREATE POLICY "Agents update assigned" ON service_requests FOR UPDATE USING (auth.uid() = agent_id);
```

---

## ▶️ Running the App

### Android (Physical Device or Emulator)
```bash
# Connect phone via USB with USB Debugging on
flutter devices
flutter run
```

### Android Release APK
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Web (Chrome)
```bash
flutter run -d chrome
```

### Build Web
```bash
flutter build web
# Output: build/web/  (deploy to any static host)
```

---

## 🧪 Testing

Run all tests:

```bash
flutter test
```

Run with coverage:

```bash
flutter test --coverage
```

### Test Files

| File | What It Tests |
|------|--------------|
| `rls_isolation_test.dart` | ⭐ Authorization: cancellation rules, invalid state transitions rejected |
| `state_machine_test.dart` | Valid and invalid status transition sequences |
| `customer_auth_test.dart` | Authentication flow, input validation |
| `models_test.dart` | `fromJson`/`toJson` serialization for all models |
| `validation_test.dart` | Email, phone, name field validators |
| `request_validation_test.dart` | Request form business rules |
| `widget_test.dart` | App renders without crashing (smoke test) |

### Test Credentials

> Create these accounts in your Supabase project and set their roles in the `profiles` table.

| Role | Email | Password |
|------|-------|----------|
| Customer | `customer@test.com` | `Test@1234` |
| Agent | `agent@test.com` | `Test@1234` |

**Set agent role (Supabase SQL Editor):**
```sql
UPDATE profiles SET role = 'agent' WHERE email = 'agent@test.com';
```

---

## 📊 Project Metrics

| Metric | Value |
|--------|-------|
| Screens | 14 (auth, customer, agent, profile) |
| API Routes (GoRouter) | 14 named routes |
| Database Tables | 4 (profiles, services, service_requests, audit_logs) |
| Service Layer | 1 singleton, ~400 LOC |
| Test Files | 7 unit/widget tests |
| Models | 4 (UserProfile, ServiceRequest, ServiceItem, StatusHistory) |
| Shared Widgets | 6 reusable components |
| Supported Platforms | Android, Web |

---

## 🗺️ Roadmap

```
✅ Completed
[x] Email/password authentication (Supabase Auth)
[x] Customer request creation and management
[x] Agent job queue and status workflow
[x] Role-based routing (customer vs. agent)
[x] Real-time status subscriptions
[x] Row Level Security enforcement
[x] Status state machine with validation
[x] Request cancellation with business rules
[x] Profile management
[x] Mock/demo mode for offline development
[x] Android APK release build
[x] Web (PWA) build

⬜ Planned
[ ] Push notifications (FCM integration)
[ ] Admin web dashboard (separate Flutter Web app)
[ ] Advanced search and filtering
[ ] Pagination for large request lists
[ ] Image attachments on service requests
[ ] Google Sign-In / Social auth
[ ] Automated agent assignment algorithm
[ ] Analytics dashboard
[ ] CI/CD deployment pipeline
[ ] Production deployment
```

---

## 🧠 My Contribution

Everything in this repository was designed and implemented personally:

| Area | What I Built |
|------|-------------|
| **Application Architecture** | Designed the feature-first folder structure, layered service architecture, and Riverpod state management setup |
| **Authentication System** | Implemented full auth flow — register, login, forgot password, session restore, role-based redirect on splash |
| **Service Request Workflow** | Built the complete CRUD pipeline — create, read, cancel — with form validation and success confirmation |
| **Agent Workflow** | Designed and implemented the agent dashboard, job queue, and the Accept→Start→Complete state machine |
| **State Machine** | Wrote `StatusHelper` with validated transitions, display names, colors, and icons for every status |
| **Supabase Integration** | Built the `SupabaseCustomerService` singleton — 400+ LOC covering auth, profiles, services, requests, real-time |
| **RLS Security** | Designed all Row Level Security policies ensuring database-level isolation per user |
| **Data Models** | Defined all 4 models with `fromJson`, `toJson`, `copyWith` and null-safety |
| **UI Components** | Built 6 reusable widgets: button, text field, status badge, timeline, stat card, empty state |
| **Real-time Updates** | Implemented Supabase Realtime subscription for live request status changes |
| **Testing** | Wrote 7 test files including authorization boundary tests for RLS correctness |
| **Build Configuration** | Configured Android build (fixed AGP namespace issue, SDK setup), web build |
| **Mock Mode** | Implemented local demo fallback so the app works without backend credentials |

---

## 💼 Why This Project Matters

For recruiters and technical evaluators, this project demonstrates:

| Skill | Evidence |
|-------|---------|
| ✅ Mobile Development | Full Flutter app with 14 screens, navigation, state management |
| ✅ Backend Integration | Supabase REST + Realtime + Auth, all in a clean service layer |
| ✅ Database Design | 4-table relational schema with FK constraints and audit trail |
| ✅ Security Awareness | RLS policies, no secrets in code, environment variable management |
| ✅ Authentication | JWT-based auth with role metadata, session persistence |
| ✅ Role-Based Access | Two distinct user roles with separate routing and database permissions |
| ✅ State Management | Riverpod providers with proper dependency injection |
| ✅ Declarative Navigation | GoRouter with type-safe route parameters |
| ✅ State Machine Design | Formally validated status transitions with test coverage |
| ✅ Software Architecture | Layered, feature-first architecture with clear separation of concerns |
| ✅ Testing | Unit, model, authorization, and widget tests |
| ✅ Git / GitHub | Proper commit history, `.gitignore`, structured repository |
| ✅ Cross-Platform Build | Android APK (53.5 MB) + Web build both successful |
| ✅ Error Handling | Try/catch at service layer, mock fallback, graceful UI degradation |

---

## 👩‍💻 Developer

**Varsha Kolekar**

Computer Technology Student passionate about building real-world software solutions.

**Interests:** Flutter · Full-Stack Development · Java · Data Structures & Algorithms · Software Engineering

[![GitHub](https://img.shields.io/badge/GitHub-varshakolekar20-181717?style=flat-square&logo=github)](https://github.com/varshakolekar20)

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).

---

<div align="center">

*Built with ❤️ using Flutter + Supabase*

**QuickServe — Making service management simple, transparent, and efficient.**

</div>
