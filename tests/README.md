# Testing Guide

This directory contains testing tools and documentation for the manjaro-playbook project.

## Table of Contents

- [Overview](#overview)
- [Quick Start](#quick-start)
- [Test Scripts](#test-scripts)
- [Testing Strategies](#testing-strategies)
- [CI/CD Testing](#cicd-testing)
- [Troubleshooting](#troubleshooting)

## Overview

The testing infrastructure provides multiple layers of validation:

1. **Pre-commit Hooks** (Local) - Catch issues before commit
2. **CI Pipeline** (Remote) - Validate on GitHub
3. **Idempotency Tests** - Ensure playbook safety
4. **Integration Tests** - Verify components work together
5. **Vagrant Testing** - Test on clean VM

## Quick Start

### Prerequisites

```bash
# Ensure development environment is set up
./setup-dev-environment.sh

# For Vagrant testing
vagrant plugin install vagrant-vbguest  # Optional but recommended
```

### Run All Tests Locally

```bash
# Quick test suite (linting + syntax + verification)
./tests/run-all-tests.sh

# Or run individual test suites:

# 1. Linting and syntax
yamllint . && ansible-lint && ansible-playbook --syntax-check playbook.yml

# 2. Verification tests
ansible-playbook tests/verify.yml -l localhost

# 3. Role-specific tests
ansible-playbook tests/test-roles.yml -l localhost

# 4. Idempotency test (requires Vagrant)
./tests/test-idempotency.sh testbuild

# 5. Full Vagrant test cycle
./tests/vagrant-test.sh all
```

## Test Scripts

### 1. test-idempotency.sh

Tests that the playbook is idempotent (can run multiple times without changes).

**Usage:**
```bash
./tests/test-idempotency.sh [target] [tags]
```

**Examples:**
```bash
# Test full playbook on Vagrant VM
./tests/test-idempotency.sh testbuild

# Test only base role
./tests/test-idempotency.sh testbuild base

# Test on localhost (careful!)
./tests/test-idempotency.sh localhost --skip-tags aur
```

**What it does:**
1. Runs playbook first time (expects changes)
2. Runs playbook second time (expects NO changes)
3. Compares results
4. ✅ Passes if second run has 0 changes
5. ❌ Fails if second run makes changes

**Output:**
```
========================================
Idempotency Test
========================================
Target: testbuild
Tags: all

=== First Run (expect changes) ===
✓ First run completed
First run stats:
  Changed: 42
  Failed: 0

=== Second Run (expect no changes) ===
✓ Second run completed
Second run stats:
  Changed: 0
  Failed: 0

========================================
✅ IDEMPOTENCY TEST PASSED
========================================
```

### 2. vagrant-test.sh

Automates full testing workflow with Vagrant VM.

**Usage:**
```bash
./tests/vagrant-test.sh [command] [tags]
```

**Commands:**
- `setup` - Start VM
- `run` - Run playbook
- `test` - Test idempotency
- `verify` - Run verification checks
- `clean` - Destroy VM
- `all` - Full cycle (setup + run + test + verify + optional clean)

**Examples:**
```bash
# Full test cycle
./tests/vagrant-test.sh all

# Just setup and run
./tests/vagrant-test.sh setup
./tests/vagrant-test.sh run

# Test specific role
./tests/vagrant-test.sh all base

# Clean up
./tests/vagrant-test.sh clean
```

**Full Cycle Output:**
```
=== Full test cycle ===
=== Setting up Vagrant VM ===
✓ VM is ready

=== Running playbook ===
✓ Playbook completed

=== Testing idempotency ===
✓ Idempotency test passed

=== Verifying installation ===
✓ Verification passed

========================================
✅ ALL TESTS PASSED
========================================

Destroy VM? (y/N)
```

### 3. verify.yml

Ansible playbook that verifies installation of key components.

**Usage:**
```bash
ansible-playbook tests/verify.yml -l testbuild
```

**What it checks:**
- **Base**: git, htop, Workspace directory
- **Development**: Docker, Go, kubectl
- **Security**: UFW, ClamAV

**Example output:**
```yaml
TASK [Display base verification results]
ok: [testbuild] =>
  msg:
    - '✓ Git version: git version 2.43.0'
    - '✓ htop installed'
    - '✓ Workspace directory exists'
```

## Testing Strategies

### 1. Pre-Commit Testing (Automatic)

Runs automatically on every commit:

```bash
# Happens automatically when you commit
git commit -m "Your changes"

# Or run manually
pre-commit run --all-files
```

**Checks:**
- Trailing whitespace
- End-of-file fixes
- YAML syntax
- yamllint
- ansible-lint
- ShellCheck

### 2. Syntax Validation

```bash
# YAML syntax
yamllint .

# Ansible best practices
ansible-lint

# Playbook syntax
ansible-playbook --syntax-check playbook.yml
```

### 3. Dry Run (Check Mode)

Preview changes without applying:

```bash
ansible-playbook playbook.yml -l testbuild \
  --check \
  --diff \
  --extra-vars="user_name=vagrant user_git_name='Test' user_email=test@test.com"
```

### 4. Vagrant Testing

Safe testing on disposable VM:

```bash
# Full automated test
./tests/vagrant-test.sh all

# Manual testing
vagrant up
ansible-playbook playbook.yml -l testbuild \
  --extra-vars="user_name=vagrant user_git_name='Test' user_email=test@test.com" \
  --ask-become-pass

# Clean up
vagrant destroy -f
```

### 5. Idempotency Testing

Critical for Ansible playbooks:

```bash
./tests/test-idempotency.sh testbuild

# Or manually
ansible-playbook playbook.yml -l testbuild --extra-vars="..." --ask-become-pass
# Second run should report: ok=X changed=0 unreachable=0 failed=0
ansible-playbook playbook.yml -l testbuild --extra-vars="..." --ask-become-pass
```

### 6. Role-Specific Testing

Test individual roles:

```bash
# Test only base role
ansible-playbook playbook.yml -l testbuild \
  --tags base \
  --extra-vars="..." \
  --ask-become-pass

# Verify idempotency
./tests/test-idempotency.sh testbuild base
```

### 7. Integration Testing

Test multiple roles together:

```bash
# Test base + development
ansible-playbook playbook.yml -l testbuild \
  --tags "base,development" \
  --extra-vars="..." \
  --ask-become-pass

# Verify installation
ansible-playbook tests/verify.yml -l testbuild
```

## CI/CD Testing

GitHub Actions runs automatically on push and PR:

```yaml
# Runs on every push to main/master/develop
# Runs on every pull request
```

**CI checks:**
1. yamllint
2. ansible-lint
3. Syntax validation
4. ShellCheck
5. Trailing whitespace check

**View results:**
- GitHub → Actions tab
- PR conversation (for PRs)
- Commit status (green checkmark or red X)

## Testing Workflow

### Before Committing

```bash
# 1. Validate syntax
yamllint . && ansible-lint

# 2. Pre-commit hooks run automatically
git add .
git commit -m "Your changes"
```

### Before Pushing

```bash
# 1. Test on Vagrant VM
./tests/vagrant-test.sh all

# 2. Push to GitHub
git push origin your-branch

# 3. CI runs automatically
```

### Before Merging PR

1. ✅ CI checks pass
2. ✅ Code review approved
3. ✅ Tested on Vagrant VM
4. ✅ Documentation updated
5. ✅ CHANGELOG.md updated

## Test Matrix

| Test Type | When | Tool | Time | Required |
|-----------|------|------|------|----------|
| Syntax | Pre-commit | yamllint | <1s | Yes |
| Linting | Pre-commit | ansible-lint | ~5s | Yes |
| Syntax check | Pre-commit | ansible-playbook | ~2s | Yes |
| ShellCheck | Pre-commit | shellcheck | ~1s | Yes |
| CI Pipeline | Push/PR | GitHub Actions | ~2-3min | Yes |
| Idempotency | Before PR | test-idempotency.sh | ~10min | Recommended |
| Integration | Before release | vagrant-test.sh | ~15min | Recommended |

## Troubleshooting

### Test Script Not Found

```bash
# Ensure scripts are executable
chmod +x tests/*.sh

# Run from project root
cd /path/to/manjaro-playbook
./tests/test-idempotency.sh testbuild
```

### Vagrant VM Issues

```bash
# VM not starting
vagrant destroy -f
vagrant up

# SSH issues
vagrant reload

# Provision issues
vagrant provision

# Start fresh
vagrant destroy -f && vagrant up --provision
```

### Idempotency Test Fails

**Common causes:**
1. Non-idempotent shell commands
2. Timestamp-based changes
3. Random values in config
4. Network-dependent tasks

**Debug:**
```bash
# Run with verbose output
ansible-playbook -vvv playbook.yml -l testbuild --extra-vars="..."

# Check diff
diff /tmp/ansible-run1.log /tmp/ansible-run2.log
```

### CI Fails but Local Passes

**Check:**
1. Python version difference (CI uses 3.11)
2. Ansible version difference
3. Missing dependencies in `requirements.txt`
4. Platform differences (CI uses Ubuntu, not Arch)

## Best Practices

1. **Always test in Vagrant before localhost** - Mistakes are disposable
2. **Run idempotency tests** - Ensures playbook safety
3. **Test incrementally** - Test each role as you develop
4. **Use tags** - Speed up testing of specific components
5. **Keep logs** - Save output for debugging
6. **Clean up** - Destroy Vagrant VMs when done
7. **Trust CI** - If CI passes, it's good to merge

## Future Testing

### Potential Additions

- **Molecule** - Advanced role testing framework
- **Testinfra** - Python-based infrastructure testing
- **InSpec** - Compliance and security testing
- **Kitchen** - Multi-platform testing
- **Serverspec** - RSpec-based testing

### Why Not Molecule Now?

- **Complexity**: Requires Docker setup, complex configuration
- **Time**: 8+ hours to implement properly
- **Value**: Current tests provide 80% of value with 20% of effort
- **Future**: Can be added when needed

## Getting Help

- **Documentation**: This README
- **Issues**: Create GitHub issue with test logs
- **CI logs**: Check GitHub Actions tab for detailed output

## Contributing Tests

When adding new roles or features:

1. ✅ Ensure role is idempotent
2. ✅ Test with `./tests/test-idempotency.sh`
3. ✅ Add verification checks to `tests/verify.yml` (optional)
4. ✅ Update this README if adding new tests
5. ✅ Document test requirements in role README

---

## Quick Reference

```bash
# Lint
yamllint . && ansible-lint

# Vagrant full test
./tests/vagrant-test.sh all

# Idempotency test
./tests/test-idempotency.sh testbuild

# Verify installation
ansible-playbook tests/verify.yml -l testbuild

# CI (automatic)
git push origin main
```

Happy testing! 🧪
