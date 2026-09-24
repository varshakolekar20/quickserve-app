# Security Policy

## Reporting a Vulnerability

If you discover a security vulnerability in QuickServe, please report it responsibly.

**Do NOT create a public GitHub issue for security vulnerabilities.**

Instead, contact the developer directly via GitHub:
[@varshakolekar20](https://github.com/varshakolekar20)

Please include:
- A description of the vulnerability
- Steps to reproduce
- Potential impact
- Suggested fix (if known)

You can expect a response within 72 hours.

---

## Secret Management

### What is kept secret
- Supabase project URL
- Supabase anon key
- Any future API keys or service credentials

### How secrets are managed in this project

| Practice | Implementation |
|----------|---------------|
| No secrets in source code | Credentials passed via `--dart-define` at build time |
| `.env` file gitignored | `.gitignore` excludes `.env` and `*.env` |
| `.env.example` provided | Template with placeholder values only |
| No service-role key in client | Only the anon public key is used (RLS enforces access) |
| Mock mode available | App runs without any credentials in demo mode |

### Supabase Security Model

This project uses Supabase with **Row Level Security (RLS)** enabled on all tables.

The **anon key** used in the mobile app is safe to include in client-side code because:
- It only allows actions permitted by RLS policies
- All data access is scoped to `auth.uid()` (the authenticated user)
- No user can read, write, or delete another user's data at the database level

The **service-role key** (which bypasses RLS) is:
- Never used in the mobile application
- Only used in server-side administrative scripts (not in this repository)

---

## Authentication Security

- Passwords are hashed by Supabase Auth (bcrypt) — never stored in plain text
- JWT tokens expire and are refreshed automatically by the Supabase client SDK
- Password reset uses a secure, time-limited email link
- Role is stored in the database `profiles` table and verified server-side

---

## Input Validation

All user inputs are validated:
- Email format validation
- Phone number format validation
- Minimum password length enforcement
- Text field length limits
- Server-side constraints via PostgreSQL `CHECK` constraints

---

## Disclosure Policy

This is a student/educational project. While security best practices have been followed, it is not intended for production use without additional security review, penetration testing, and hardening.
