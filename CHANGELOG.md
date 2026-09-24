# Changelog

All notable changes to QuickServe are documented in this file.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [1.0.0] — 2026-09-24

### Added
- **Customer Authentication** — Email/password sign-up, login, logout, and password reset via Supabase Auth
- **Role-Based Routing** — Automatic redirect to customer home or agent dashboard based on `profiles.role`
- **Service Catalog** — Browse active service categories (AC, Plumbing, Electrical, Cleaning)
- **Service Request Creation** — Form with service selection, description, date/time, address, priority
- **My Requests Screen** — List of all customer requests with live status badges
- **Request Details Screen** — Full status timeline with history of every change
- **Request Cancellation** — Business-rule-enforced cancellation (CREATED/ASSIGNED only)
- **Profile Management** — View and edit full name and phone number
- **Agent Dashboard** — Dedicated job queue screen for technician role
- **Agent Job Detail** — Accept → Start Work → Complete sequential workflow
- **Field Notes** — Agents can add notes when updating job status
- **Real-time Subscriptions** — Live status updates via Supabase Realtime channels
- **Row Level Security** — Database-layer data isolation per user role
- **State Machine** — `StatusHelper` enforces valid status transitions
- **Mock/Demo Mode** — App runs with local data when no Supabase credentials provided
- **Android Release Build** — Signed APK (53.5 MB) built successfully
- **Web Build** — Flutter Web (PWA) build for Chrome
- **7 Unit/Widget Tests** — Including authorization boundary tests

### Architecture
- Feature-first folder structure (`auth`, `home`, `services`, `requests`, `profile`, `agent`)
- Riverpod 2.5 state management
- GoRouter 14 declarative navigation with 14 routes
- Singleton service layer (`SupabaseCustomerService`)
- 4 typed data models with `fromJson`/`toJson`/`copyWith`
- 6 reusable shared widgets

---

## [Planned — v1.1.0]

- Push notifications via FCM
- Admin web dashboard
- Request image attachments
- Pagination for large data sets
- Google Sign-In

## [Planned — v2.0.0]

- Production deployment
- Advanced analytics
- Automated agent assignment
- CI/CD pipeline
