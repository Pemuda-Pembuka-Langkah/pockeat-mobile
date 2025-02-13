# PockEat

[![Development](https://github.com/Pemuda-Pembuka-Langkah/pockeat-mobile/actions/workflows/development.yml/badge.svg)](https://github.com/Pemuda-Pembuka-Langkah/pockeat-mobile/actions/workflows/development.yml)
[![Staging](https://github.com/Pemuda-Pembuka-Langkah/pockeat-mobile/actions/workflows/staging.yml/badge.svg)](https://github.com/Pemuda-Pembuka-Langkah/pockeat-mobile/actions/workflows/staging.yml)
[![Production](https://github.com/Pemuda-Pembuka-Langkah/pockeat-mobile/actions/workflows/production.yml/badge.svg)](https://github.com/Pemuda-Pembuka-Langkah/pockeat-mobile/actions/workflows/production.yml)
[![codecov](https://codecov.io/gh/Pemuda-Pembuka-Langkah/pockeat-mobile/branch/master/graph/badge.svg)](https://codecov.io/gh/Pemuda-Pembuka-Langkah/pockeat-mobile)

## Table of Contents
- [CI/CD Documentation](#ci-cd-documentation)
  - [Branch Strategy](#branch-strategy)
  - [Workflows](#workflows)
    - [Development Workflow](#development-workflow)
    - [Staging Workflow](#staging-workflow)
    - [Production Workflow](#production-workflow)
    - [Release Workflow](#release-workflow)
  - [Conventional Commits](#conventional-commits)

## CI/CD Documentation

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
