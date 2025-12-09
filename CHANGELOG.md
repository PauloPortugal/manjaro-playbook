# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Automated semantic versioning based on conventional commits
- GitHub Actions workflow for automatic releases
- Changelog generation from commit messages
- Version bump script (`scripts/bump-version.sh`)

- **Phase 6: Advanced Testing** (2025-11-12)
  - Enhanced `tests/verify.yml` with comprehensive checks
  - Added verification for browsers, editors, and configuration files
  - Created `tests/test-roles.yml` for role-specific testing
  - Created `tests/run-all-tests.sh` comprehensive test runner
  - Integrated actual playbook tests into CI pipeline
  - Added test matrix with multiple scenarios in GitHub Actions
  - Three-tier CI pipeline: Lint → Security → Tests

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

## How Automated Versioning Works

This project uses [Semantic Versioning](https://semver.org/) with automated version bumps based on commit messages.

### Version Bump Rules

- **MAJOR** version: Breaking changes (commits with `!` like `feat!:` or `fix!:`)
- **MINOR** version: New features (commits starting with `feat:` or `feature:`)
- **PATCH** version: Bug fixes (commits starting with `fix:` or `patch:`)

### Commit Message Format

We follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

**Types:**
- `feat:` or `feature:` - New feature (triggers MINOR version bump)
- `fix:` or `patch:` - Bug fix (triggers PATCH version bump)
- `docs:` - Documentation changes (no version bump)
- `chore:` - Maintenance tasks (no version bump)
- `refactor:` - Code refactoring (no version bump)
- `test:` - Adding or updating tests (no version bump)
- `ci:` - CI/CD changes (no version bump)

**Breaking Changes:**
Add `!` after the type to indicate a breaking change (e.g., `feat!:` or `fix!:`).

**Examples:**
```bash
# Minor version bump (1.0.0 -> 1.1.0)
git commit -m "feat: add semantic versioning automation"

# Patch version bump (1.0.0 -> 1.0.1)
git commit -m "fix: correct ansible-lint errors in base role"

# Major version bump (1.0.0 -> 2.0.0)
git commit -m "feat!: redesign role structure requiring Python 3.11+"
```

### Manual Version Bumps

You can also manually bump versions using the script:

```bash
# Dry run to see what would happen
./scripts/bump-version.sh --dry-run

# Create version bump and tag
./scripts/bump-version.sh

# Skip pushing to remote
./scripts/bump-version.sh --skip-push
```

### Automatic Releases

When you push to the `main` branch, GitHub Actions automatically:
1. Analyzes commits since the last tag
2. Determines the version bump type
3. Creates a new git tag
4. Generates a changelog from commits
5. Creates a GitHub release with the changelog

To skip automatic releases, include `[skip ci]` or `[ci skip]` in your commit message.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on contributing to this project.
