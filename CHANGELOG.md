# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- **Phase 1: Code Quality & Linting** (2025-11-03)
  - `.yamllint` configuration with 120-char line limit
  - `.ansible-lint` configuration for Ansible best practices
  - `.pre-commit-config.yaml` with 10 automated checks
  - `requirements.txt` for Python dependencies
  - `requirements.yml` for Ansible collections
  - `setup-dev-environment.sh` automated setup script
  - Pre-commit hooks (yamllint, ansible-lint, shellcheck, etc.)
  - Comprehensive documentation in `.claude/docs/`:
    - `ANSIBLE_GUIDELINES.md` - Best practices guide
    - `AUDIT_REPORT.md` - Quality audit
    - `IMPROVEMENT_PLAN.md` - 8-week roadmap

- **Phase 2: CI/CD Pipeline** (2025-11-03)
  - `.github/workflows/ci.yml` - GitHub Actions workflow
  - Automated quality checks on push and PR
  - Multi-job pipeline (Lint, Security, Summary)
  - Dependency caching for faster builds
  - ShellCheck security scanning

- **Phase 3: Documentation Enhancement** (2025-11-03)
  - Role-specific README files:
    - `roles/base/README.md`
    - `roles/development/README.md`
    - `roles/security/README.md`
    - `roles/gnome/README.md`
  - `CONTRIBUTING.md` - Contribution guidelines
  - `CHANGELOG.md` - This file
  - CI status badge in README

### Changed
- Fixed 19 YAML line-length violations
- Fixed shell script exit codes (255 instead of -1)
- Added safety check to `aur/install-aur.sh` (cd with error handling)
- Updated README with automated setup instructions
- Organized documentation into `.claude/docs/` directory
- README cleanup (removed AI-specific docs from user view)

### Fixed
- ansible-lint dependency issue (python-pytokens)
- Shell script compatibility (POSIX-compliant exit codes)
- Trailing whitespace in multiple files
- End-of-file issues in configuration files

### Security
- Added ShellCheck validation for all shell scripts
- Configured UFW firewall in security role
- Enabled ClamAV antivirus scanning

## [2.16.0] - 2024-XX-XX

### Changed
- Update dependencies

### Fixed
- Forbidden implicit octal value (ansible-lint)
- Commands idempotency issues
- Various ansible-lint errors and warnings

## [2.15.0] - 2023-XX-XX

### Added
- Neovim editor support

## Earlier Versions

See git history for changes prior to v2.15.0.

---

## Version Numbering

This project uses Semantic Versioning:
- **MAJOR** version: Incompatible changes (requires manual intervention)
- **MINOR** version: New features (backward compatible)
- **PATCH** version: Bug fixes (backward compatible)

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on contributing to this project.
