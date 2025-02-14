# PockEat

## Build Status
Staging: [![Staging Workflow](https://github.com/Pemuda-Pembuka-Langkah/pockeat-mobile/actions/workflows/staging.yml/badge.svg)](https://github.com/Pemuda-Pembuka-Langkah/pockeat-mobile/actions/workflows/staging.yml)

Production: [![Production Workflow](https://github.com/Pemuda-Pembuka-Langkah/pockeat-mobile/actions/workflows/production.yml/badge.svg)](https://github.com/Pemuda-Pembuka-Langkah/pockeat-mobile/actions/workflows/production.yml)

## Code Coverage
Master Branch: [![codecov](https://codecov.io/gh/Pemuda-Pembuka-Langkah/pockeat-mobile/branch/master/graph/badge.svg)](https://codecov.io/gh/Pemuda-Pembuka-Langkah/pockeat-mobile)

Staging Branch: [![codecov](https://codecov.io/gh/Pemuda-Pembuka-Langkah/pockeat-mobile/branch/staging/graph/badge.svg)](https://codecov.io/gh/Pemuda-Pembuka-Langkah/pockeat-mobile)

## Table of Contents
- [CI/CD Documentation](#ci-cd-documentation)
  - [Environment Strategy](#environment-strategy)
  - [Branch Strategy](#branch-strategy)
  - [Workflows](#workflows)
    - [Development Workflow](#development-workflow)
    - [Staging Workflow](#staging-workflow)
    - [Production Workflow](#production-workflow)
    - [Release Workflow](#release-workflow)
  - [Conventional Commits](#conventional-commits)

## CI/CD Documentation

### Environment Strategy
Project ini menggunakan 3 environment yang terpisah:

- **Development Environment**
 - Menggunakan Firebase Emulator untuk development lokal
 - Setup Firebase Emulator:
   ```bash
   # Install Firebase CLI
   npm install -g firebase-tools

   # Login ke Firebase
   firebase login

   # Di root project
   firebase init emulators

   # Start emulator
   firebase emulators:start
   ```
 - Emulator UI tersedia di `localhost:4000`
 - Semua data tersimpan lokal
 - Default ketika run `flutter run`
 - Perfect untuk rapid development tanpa mempengaruhi data production
 - Team members hanya perlu:
   1. Install Firebase CLI
   2. Run `firebase login` dan `firebase emulators:start`
   3. Run `flutter run` di terminal terpisah
  - pastikan login pakai akun pockeatdev@gmail.com

- **Staging Environment**
 - Firebase Project: `pockeat-staging-f099c`
 - Digunakan untuk testing dan QA
 - Run dengan `flutter run --dart-define=FLAVOR=staging`
 - Tempat testing integrasi dengan Firebase sebelum ke production

- **Production Environment**
 - Firebase Project: `pockeat-production`
 - Environment untuk end users
 - Strict security rules
 - Run dengan `flutter run --dart-define=FLAVOR=production`
 - Build production APK menggunakan flavor ini

### Branch Strategy
- `PBI-*`: Feature branches for development
- `staging`: Integration branch for testing
- `master`: Production branch
- `v*` tags: Release versions

### Workflows

### Development Workflow
File: `.github/workflows/development.yml`

Triggers on push to `PBI-*` branches:
- Run tests
- Static analysis (flutter analyze)

### Staging Workflow
File: `.github/workflows/staging.yml`

Triggers on push and pull requests to `staging` branch:
- Run tests
- Static analysis
- Code coverage upload to Codecov
- Build & upload debug APK

### Production Workflow
File: `.github/workflows/production.yml`

Triggers on push and pull requests to `master` branch:
- Run tests
- Static analysis
- Code coverage upload to Codecov
- Build, Sign & upload release APK

### Release Workflow
File: `.github/workflows/release.yml`

Triggers on push of `v*` tags:
- Run tests
- Build release APK
- Generate changelog from conventional commits
- Create GitHub Release with:
  - Signed Release APK
  - Auto-generated changelog

### Conventional Commits

All commits must follow the conventional commits format for proper changelog generation:

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

Types:
- `feat(scope)`: New features
- `fix(scope)`: Bug fixes
- `docs(scope)`: Documentation changes
- `style(scope)`: Code style changes (formatting, etc)
- `refactor(scope)`: Code refactoring
- `test(scope)`: Adding or updating tests
- `chore(scope)`: Maintenance tasks

Examples:
```
feat(auth): add Google Sign-In
fix(api): handle server timeout
docs(readme): update installation steps
```

Breaking changes should include `BREAKING CHANGE:` in the commit body or footer.
