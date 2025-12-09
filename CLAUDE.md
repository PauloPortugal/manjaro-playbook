# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an Ansible playbook for configuring Manjaro/Arch Linux GNOME 3 desktop systems. It's designed to run locally after a clean OS install and follows Manjaro's community recommendations for package management (pacman for official packages, Pamac for AUR packages).

## Required Variables

The playbook requires three user-specific variables passed via `--extra-vars`:
- `user_name`: The system username
- `user_git_name`: Git user name for configuration
- `user_email`: Git email for configuration

These are NOT defined in defaults and must always be provided when running the playbook.

## Development Setup

### Initial Setup
```bash
# Run the automated setup script (installs all dependencies)
./setup-dev-environment.sh
```

This installs: ansible, ansible-lint, git, xclip, python-pip, yamllint, python-pytokens, shellcheck, pre-commit, and Ansible Galaxy collections.

### Code Quality Checks

Pre-commit hooks are automatically installed by `setup-dev-environment.sh` and run on every commit.

Manual validation:
```bash
# Run all quality checks
yamllint . && ansible-lint

# Check playbook syntax
ansible-playbook --syntax-check playbook.yml

# Check shell scripts
shellcheck tests/*.sh aur/*.sh setup-dev-environment.sh
```

## Running the Playbook

### Full Installation
```bash
ansible-playbook playbook.yml -l localhost \
  --extra-vars="user_name=USERNAME user_git_name=GIT_USERNAME user_email=EMAIL" \
  --ask-become-pass
```

### Run Specific Role with Tags
```bash
ansible-playbook playbook.yml -l localhost \
  --extra-vars="user_name=USERNAME user_git_name=GIT_USERNAME user_email=EMAIL" \
  --ask-become-pass \
  --tags browsers
```

Available tags match role names: `base`, `users`, `printers`, `browsers`, `development`, `cloud`, `editors`, `media`, `multimedia`, `audio`, `comms`, `gnome`, `security`, `virtualization`

Note: The `users` role has a `never` tag and must be explicitly called.

### Debug Mode
```bash
# Verbose output
ansible-playbook -v playbook.yml ...

# Maximum verbosity
ansible-playbook -vvvv playbook.yml ...
```

## Testing

### Run All Tests
```bash
./tests/run-all-tests.sh
```

This runs:
1. Code quality checks (yamllint, ansible-lint, syntax check, shellcheck)
2. Unit tests (if on testbuild host)
3. Integration tests (if Vagrant VM is running)

### Verification Tests
```bash
# Run verification against localhost
ansible-playbook tests/verify.yml --connection=local -i localhost,

# Run specific verification tags
ansible-playbook tests/verify.yml --connection=local -i localhost, --tags verify-base
```

Available verification tags: `verify-base`, `verify-development`, `verify-security`, `verify-browsers`, `verify-editors`, `verify-config`

### Idempotency Testing
```bash
# Test specific target
./tests/test-idempotency.sh testbuild

# Test specific role
./tests/test-idempotency.sh testbuild base

# Test with skipped tags
./tests/test-idempotency.sh localhost --skip-tags aur
```

### Role-Specific Tests
```bash
# Test individual role functionality and idempotency
ansible-playbook tests/test-roles.yml --connection=local -i localhost, --tags test-base
```

## Architecture

### Role Structure

The playbook follows standard Ansible role structure:
```
roles/
  <role-name>/
    tasks/main.yml       # Primary task entry point
    tasks/*.yml          # Subtasks imported by main.yml
    defaults/main.yml    # Default variables
    files/               # Static files to copy
    templates/           # Jinja2 templates
    handlers/            # Handlers for this role
```

### Variable Precedence

Critical pattern for user-specific paths:
- Roles use `{{ user_name }}` variable for paths like `/home/{{ user_name }}/...`
- Test playbooks set: `user_name: "{{ ansible_user_id }}"` when running standalone
- Verification playbook (tests/verify.yml) sets `user_name` to `ansible_user_id` if not already defined
- This allows roles to work both in production (with user_name passed) and testing (using ansible_user_id)

### Package Management Strategy

The playbook uses multiple package managers:
1. **pacman**: For official Arch Linux packages (via `community.general.pacman` module)
2. **Pamac**: For automated AUR package installation (via `shell` commands)
3. **Custom AUR script**: `aur/install-aur.sh` for manual AUR installations

### Workspace Directory

The base role creates `~/Workspace` directory. This is a standard convention:
- Created by: `roles/base/tasks/main.yml`
- Path: `/home/{{ user_name }}/Workspace`
- Shell alias: `W='cd ~/Workspace'` (defined in base role defaults)

## CI/CD

### CI Workflow

GitHub Actions workflow (`.github/workflows/ci.yml`) runs:

1. **Lint Job**: yamllint, ansible-lint, syntax checks, trailing whitespace check
2. **Security Job**: ShellCheck on shell scripts
3. **Test Job**: Syntax verification and verification tests (with test environment setup)

The workflow matrix includes:
- "Syntax Verification": `ansible-playbook --syntax-check playbook.yml`
- "Verification Tests": `ansible-playbook tests/verify.yml --connection=local -i localhost,`

Note: CI creates `~/Workspace` before verification tests to match role expectations.

### Release Workflow

GitHub Actions workflow (`.github/workflows/release.yml`) automatically creates releases:

1. **Triggers**: Pushes to `main` branch (can also be triggered manually)
2. **Process**:
   - Analyzes commits since last tag using conventional commit format
   - Determines version bump type (major/minor/patch)
   - Creates new git tag
   - Generates changelog from commits
   - Creates GitHub release with changelog

3. **Version Bump Rules**:
   - `feat!:` or `fix!:` (with `!`) → Major version (e.g., 1.0.0 → 2.0.0)
   - `feat:` or `feature:` → Minor version (e.g., 1.0.0 → 1.1.0)
   - `fix:` or `patch:` → Patch version (e.g., 1.0.0 → 1.0.1)
   - Other commit types → No release

4. **Skip CI**: Add `[skip ci]` or `[ci skip]` to commit message to skip automatic release

### Manual Version Bumps

Use the version bump script for manual releases:

```bash
# Dry run (see what would happen)
./scripts/bump-version.sh --dry-run

# Create version bump and tag
./scripts/bump-version.sh

# Verbose output showing commit analysis
./scripts/bump-version.sh -v

# Skip pushing to remote
./scripts/bump-version.sh --skip-push
```

## Vagrant Testing

Test against Vagrant VM:
```bash
# Provision Vagrant box
vagrant up --provision

# Run playbook against VM
ansible-playbook playbook.yml -l testbuild \
  --extra-vars="user_name=vagrant user_git_name=Test user_email=test@test.com" \
  --ask-become-pass
```

The inventory file defines `testbuild` as the Vagrant VM target.

## Important Conventions

1. **Idempotency**: All tasks must be idempotent. Test with `./tests/test-idempotency.sh`
2. **Tags**: Every role has a corresponding tag for selective execution
3. **User Variables**: Never hardcode usernames; always use `{{ user_name }}`
4. **Become**: Use `become: true` for tasks requiring root, with `become_user` for specific users
5. **AUR Handling**: AUR packages require special handling due to security (can't run as root)
6. **Commit Messages**: Follow conventional commit format for automatic versioning (see Versioning section)

## Versioning

This project uses [Semantic Versioning](https://semver.org/) with automated version bumps based on commit messages.

### Commit Message Format

Follow [Conventional Commits](https://www.conventionalcommits.org/):

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

See [CHANGELOG.md](CHANGELOG.md) for detailed versioning documentation.

## File Locations

- **Main playbook**: `playbook.yml`
- **Inventory**: `inventory/` (defined in `ansible.cfg`)
- **Configuration**: `ansible.cfg` (sets pipelining, inventory location)
- **Requirements**: `requirements.yml` (Ansible Galaxy collections)
- **Tests**: `tests/` directory
- **AUR scripts**: `aur/` directory
- **Handlers**: `handlers/` directory (imported by main playbook)
- **Scripts**: `scripts/` directory (utility scripts including version bumping)
- **Workflows**: `.github/workflows/` directory (CI/CD pipelines)
