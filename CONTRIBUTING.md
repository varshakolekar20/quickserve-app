# Contributing to QuickServe

Thank you for your interest in contributing to QuickServe! This document explains how to contribute effectively.

---

## Getting Started

### 1. Fork the Repository

Click the **Fork** button on the [GitHub repository](https://github.com/varshakolekar20/quickserve-app) page.

### 2. Clone Your Fork

```bash
git clone https://github.com/YOUR_USERNAME/quickserve-app.git
cd quickserve-app
```

### 3. Set Up the Project

```bash
flutter pub get
flutter doctor
```

### 4. Create a Feature Branch

Use a descriptive branch name:

```bash
git checkout -b feat/push-notifications
git checkout -b fix/agent-dashboard-loading
git checkout -b docs/update-database-schema
```

---

## Making Changes

### Code Style

- Run `dart format .` before committing
- Run `flutter analyze` and fix all warnings
- Follow existing naming conventions (camelCase for variables, PascalCase for classes)
- Add comments for non-obvious logic
- Keep methods focused and short

### Commit Messages

Use the conventional commits format:

```
feat: add push notification support
fix: resolve null check on agent profile fetch
docs: update installation guide for Windows
test: add validation tests for phone number
refactor: extract status badge into shared widget
```

### Testing

- Add tests for any new business logic
- Run `flutter test` before submitting
- Authorization and validation logic must have test coverage

---

## Submitting a Pull Request

1. Push your branch to your fork:
   ```bash
   git push origin feat/your-feature
   ```

2. Open a Pull Request on GitHub against the `main` branch

3. Fill in the PR description:
   - What does this PR do?
   - What problem does it solve?
   - How was it tested?
   - Any breaking changes?

4. Wait for review

---

## What to Contribute

Good areas for contribution:

- 🐛 **Bug fixes** — check the Issues tab
- 📱 **New screens** — profile photo upload, notification center
- 🧪 **Tests** — increase test coverage
- 📝 **Documentation** — improve setup guides, add comments
- ♿ **Accessibility** — semantic labels, screen reader support
- 🌐 **Localization** — support additional languages

---

## Code of Conduct

Be respectful. Constructive feedback is welcome. Personal attacks are not.

---

## Questions?

Open a GitHub Issue or contact [@varshakolekar20](https://github.com/varshakolekar20).
