# Improvement Plan: Manjaro Playbook

**Version**: 1.0
**Date**: 2025-11-01
**Status**: Proposed
**Approach**: Incremental, small improvements that build upon each other

---

## Philosophy

This improvement plan follows a **"small steps, compound progress"** approach:

1. **Start Small**: Begin with quick wins that provide immediate value
2. **Build Incrementally**: Each step builds on the previous one
3. **Test Continuously**: Validate changes before moving forward
4. **Document Progress**: Track learnings and improvements
5. **Iterate**: Refine based on feedback and results

---

## Phase 1: Foundation - Code Quality & Linting (Week 1)

**Goal**: Establish automated code quality checks
**Effort**: Low
**Impact**: High
**Risk**: Very Low

### Step 1.1: Configure yamllint (Day 1)
**Duration**: 30 minutes

**Actions**:
1. Create `.yamllint` configuration file
2. Fix existing line-length violations (19 files)
3. Run yamllint to verify compliance
4. Document yamllint usage in README

**Acceptance Criteria**:
- ✅ `.yamllint` file exists with project standards
- ✅ All yamllint errors resolved
- ✅ `yamllint .` returns 0 errors

**Benefits**:
- Consistent YAML formatting
- Easier code reviews
- Catches syntax errors early

---

### Step 1.2: Fix ansible-lint (Day 1)
**Duration**: 1 hour

**Actions**:
1. Fix missing `pytokens` dependency
2. Run ansible-lint on playbook
3. Address any critical findings
4. Create `.ansible-lint` configuration file

**Commands**:
```bash
# Fix dependency
pip install pytokens

# Run ansible-lint
ansible-lint

# Create config if needed
ansible-lint --generate-ignore
```

**Acceptance Criteria**:
- ✅ `ansible-lint` runs without errors
- ✅ `.ansible-lint` config file created
- ✅ No critical violations remain

**Benefits**:
- Catches Ansible best practice violations
- Identifies potential bugs early
- Improves code quality

---

### Step 1.3: Create Pre-commit Hook (Day 2)
**Duration**: 1 hour

**Actions**:
1. Install pre-commit framework
2. Create `.pre-commit-config.yaml`
3. Configure hooks for yamllint and ansible-lint
4. Test hooks with sample commit

**Configuration**:
```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.5.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-added-large-files

  - repo: https://github.com/adrienverge/yamllint
    rev: v1.33.0
    hooks:
      - id: yamllint

  - repo: https://github.com/ansible/ansible-lint
    rev: v6.22.1
    hooks:
      - id: ansible-lint
        files: \.(yaml|yml)$
```

**Acceptance Criteria**:
- ✅ Pre-commit hooks installed
- ✅ Hooks run automatically on commit
- ✅ Documentation updated with setup instructions

**Benefits**:
- Automated quality checks
- Prevents committing broken code
- No manual linting needed

---

### Phase 1 Deliverables

- `.yamllint` configuration
- `.ansible-lint` configuration
- `.pre-commit-config.yaml`
- All YAML lint errors fixed (19 files)
- Updated README with linting instructions

**Success Metrics**:
- 0 yamllint errors
- 0 ansible-lint critical errors
- Pre-commit hooks functional

---

## Phase 2: Basic CI/CD Pipeline (Week 2)

**Goal**: Automate testing on every push/PR
**Effort**: Low-Medium
**Impact**: High
**Risk**: Low

### Step 2.1: Create GitHub Actions Workflow (Day 3-4)
**Duration**: 3 hours

**Actions**:
1. Create `.github/workflows/` directory
2. Create `ci.yml` workflow file
3. Configure jobs for syntax check, linting
4. Test workflow with a PR

**Workflow Configuration**:
```yaml
# .github/workflows/ci.yml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.11'

      - name: Install dependencies
        run: |
          pip install ansible ansible-lint yamllint pytokens

      - name: Run yamllint
        run: yamllint .

      - name: Run ansible-lint
        run: ansible-lint

      - name: Syntax check
        run: ansible-playbook --syntax-check playbook.yml
```

**Acceptance Criteria**:
- ✅ GitHub Actions workflow file exists
- ✅ Workflow runs on push and PR
- ✅ All checks pass (lint, syntax)
- ✅ Status badge added to README

**Benefits**:
- Automatic validation on every change
- Prevents merging broken code
- Visible quality status in README

---

### Step 2.2: Add Dependencies File (Day 4)
**Duration**: 30 minutes

**Actions**:
1. Create `requirements.yml` for Ansible collections
2. Create `requirements.txt` for Python packages
3. Update CI workflow to install dependencies
4. Document dependency management

**Files to Create**:

`requirements.yml`:
```yaml
collections:
  - name: community.general
    version: ">=8.0.0"
  - name: ansible.posix
    version: ">=1.5.0"
```

`requirements.txt`:
```
ansible>=2.9
ansible-lint>=6.0.0
yamllint>=1.30.0
pytokens>=1.8.0
```

**Acceptance Criteria**:
- ✅ `requirements.yml` created
- ✅ `requirements.txt` created
- ✅ CI workflow installs dependencies
- ✅ README documents dependency installation

**Benefits**:
- Explicit dependency management
- Reproducible environments
- Easier onboarding for contributors

---

### Phase 2 Deliverables

- `.github/workflows/ci.yml`
- `requirements.yml`
- `requirements.txt`
- CI status badge in README
- Documentation updates

**Success Metrics**:
- CI pipeline runs successfully
- All checks pass on main branch
- PR builds validate automatically

---

## Phase 3: Documentation Enhancement (Week 3)

**Goal**: Improve project documentation and discoverability
**Effort**: Medium
**Impact**: Medium
**Risk**: Very Low

### Step 3.1: Role Documentation (Day 5-7)
**Duration**: 4 hours (spread over 3 days)

**Actions**:
1. Create template for role README
2. Document 2-3 roles per day
3. Include purpose, variables, dependencies, examples

**Template**:
```markdown
# Role: {role_name}

## Description
Brief description of what this role does.

## Requirements
- Dependencies
- Required variables

## Variables
| Variable | Default | Description |
|----------|---------|-------------|
| var_name | value   | What it does |

## Example Playbook
\`\`\`yaml
- hosts: localhost
  roles:
    - {role_name}
\`\`\`

## Tags
- tag1
- tag2

## Notes
Special considerations or warnings
```

**Roles to Document** (Priority Order):
1. base - Most frequently used
2. development - Complex with many packages
3. security - Important for safety
4. gnome - Many configuration options
5. Others as time permits

**Acceptance Criteria**:
- ✅ README.md in at least 5 critical roles
- ✅ Consistent documentation format
- ✅ All variables documented
- ✅ Usage examples included

**Benefits**:
- Easier to understand role purpose
- Clearer variable usage
- Better onboarding for new users

---

### Step 3.2: Create CONTRIBUTING.md (Day 8)
**Duration**: 1 hour

**Actions**:
1. Document contribution process
2. Explain how to test changes
3. Code style guidelines
4. PR requirements

**Acceptance Criteria**:
- ✅ CONTRIBUTING.md created
- ✅ Covers: setup, testing, PR process
- ✅ References ANSIBLE_GUIDELINES.md
- ✅ Linked from README

**Benefits**:
- Clear contributor expectations
- Consistent contribution quality
- Lower barrier to contribution

---

### Step 3.3: Create CHANGELOG.md (Day 8)
**Duration**: 30 minutes

**Actions**:
1. Create CHANGELOG.md
2. Document recent changes from git history
3. Establish versioning strategy
4. Add to future commit process

**Format** (Keep a Changelog):
```markdown
# Changelog

## [Unreleased]

## [1.0.0] - 2025-11-01
### Added
- Initial release
- 14 roles for system configuration
...
```

**Acceptance Criteria**:
- ✅ CHANGELOG.md created
- ✅ Recent history documented
- ✅ Format follows keepachangelog.com
- ✅ Linked from README

**Benefits**:
- Track project evolution
- Clear version history
- Easier to understand changes

---

### Phase 3 Deliverables

- Role README files (minimum 5 roles)
- CONTRIBUTING.md
- CHANGELOG.md
- Updated main README with links

**Success Metrics**:
- 5+ roles documented
- Contributing guide complete
- Changelog maintained

---

## Phase 4: Testing Infrastructure (Week 4-5)

**Goal**: Enable automated role testing
**Effort**: High
**Impact**: High
**Risk**: Medium

### Step 4.1: Set Up Molecule for One Role (Day 9-11)
**Duration**: 6 hours

**Actions**:
1. Install Molecule and dependencies
2. Choose a simple role (e.g., base)
3. Initialize Molecule in the role
4. Create test scenarios
5. Run tests and iterate

**Commands**:
```bash
# Install Molecule
pip install molecule molecule-plugins[docker]

# Initialize in a role
cd roles/base
molecule init scenario

# Run tests
molecule test
```

**Test Scenarios**:
1. Default scenario - basic installation
2. Idempotency test - run twice, no changes
3. Verify test - check expected outcomes

**Acceptance Criteria**:
- ✅ Molecule configured for one role
- ✅ Tests pass locally
- ✅ CI runs Molecule tests
- ✅ Documentation explains how to test

**Benefits**:
- Automated role testing
- Catch regressions early
- Confidence in changes
- Template for other roles

---

### Step 4.2: Idempotency Testing Script (Day 12)
**Duration**: 2 hours

**Actions**:
1. Create test script for idempotency
2. Run playbook twice
3. Verify no changes on second run
4. Add to CI pipeline

**Script**:
```bash
#!/bin/bash
# test-idempotency.sh

set -e

echo "Running playbook first time..."
ansible-playbook playbook.yml -l testbuild --check

echo "Running playbook second time..."
RESULT=$(ansible-playbook playbook.yml -l testbuild --check | grep -c 'changed=0' || true)

if [ "$RESULT" -gt 0 ]; then
  echo "✅ Playbook is idempotent"
  exit 0
else
  echo "❌ Playbook is not idempotent"
  exit 1
fi
```

**Acceptance Criteria**:
- ✅ Test script created
- ✅ Runs in CI pipeline
- ✅ Catches non-idempotent tasks
- ✅ Documentation updated

**Benefits**:
- Ensures playbook can be re-run safely
- Catches state management issues
- Improves reliability

---

### Phase 4 Deliverables

- Molecule testing for base role
- Idempotency test script
- CI integration for tests
- Testing documentation

**Success Metrics**:
- Molecule tests pass
- Idempotency verified
- CI runs all tests automatically

---

## Phase 5: Code Modernization (Week 6)

**Goal**: Update to modern Ansible practices
**Effort**: Medium
**Impact**: Medium
**Risk**: Low (with testing)

### Step 5.1: Replace with_items with loop (Day 13-14)
**Duration**: 3 hours

**Actions**:
1. Find all uses of `with_items`
2. Replace with modern `loop` syntax
3. Test each change
4. Update documentation

**Migration Pattern**:
```yaml
# OLD
- name: Install packages
  pacman:
    name: "{{ item }}"
  with_items: "{{ packages }}"

# NEW
- name: Install packages
  community.general.pacman:
    name: "{{ item }}"
  loop: "{{ packages }}"
```

**Files to Update**:
- Search: `grep -r "with_items" roles/`
- Update each occurrence
- Test after each role update

**Acceptance Criteria**:
- ✅ No `with_items` in codebase
- ✅ All loops use modern syntax
- ✅ Tests pass after changes
- ✅ Functionality unchanged

**Benefits**:
- Uses current Ansible syntax
- Removes deprecation warnings
- Future-proofs code

---

### Step 5.2: Add Role Defaults (Day 15-16)
**Duration**: 4 hours

**Actions**:
1. Create `defaults/main.yml` for each role
2. Move appropriate variables from group_vars
3. Document default values
4. Test with defaults

**Example**:
```yaml
# roles/base/defaults/main.yml
---
workspace_dir: "{{ ansible_env.HOME }}/Workspace"
workspace_mode: "0755"

default_shell: /bin/zsh
configure_ntp: true
```

**Acceptance Criteria**:
- ✅ `defaults/main.yml` in all roles
- ✅ Sensible defaults defined
- ✅ Variables documented
- ✅ Playbook works with defaults

**Benefits**:
- Roles more reusable
- Clear default values
- Easier to override
- Better role organization

---

### Step 5.3: Add Role Metadata (Day 17)
**Duration**: 2 hours

**Actions**:
1. Create `meta/main.yml` for each role
2. Document dependencies
3. Add role information
4. Specify supported platforms

**Example**:
```yaml
# roles/development/meta/main.yml
---
galaxy_info:
  author: Paulo Portugal
  description: Development tools for Manjaro
  license: MIT
  min_ansible_version: "2.9"
  platforms:
    - name: Archlinux
      versions:
        - all

dependencies:
  - role: base
```

**Acceptance Criteria**:
- ✅ `meta/main.yml` in all roles
- ✅ Dependencies documented
- ✅ Platform info specified
- ✅ Ansible Galaxy compatible

**Benefits**:
- Clear role dependencies
- Ansible Galaxy ready
- Better role reusability
- Documentation of requirements

---

### Phase 5 Deliverables

- Modern loop syntax throughout
- Role defaults in all roles
- Role metadata files
- Updated documentation

**Success Metrics**:
- 0 deprecation warnings
- All roles have defaults and meta
- Tests pass

---

## Phase 6: Advanced Testing (Week 7-8)

**Goal**: Comprehensive test coverage
**Effort**: High
**Impact**: High
**Risk**: Low

### Step 6.1: Molecule for All Critical Roles (Day 18-22)
**Duration**: 10 hours (2 hours/day)

**Actions**:
1. Add Molecule to 5 most critical roles:
   - base
   - development
   - security
   - gnome
   - browsers
2. Create test scenarios for each
3. Integrate with CI

**Priority**: High-impact, frequently-changed roles first

**Acceptance Criteria**:
- ✅ 5 roles have Molecule tests
- ✅ All tests pass
- ✅ CI runs Molecule tests
- ✅ Coverage >= 80% of critical paths

**Benefits**:
- High test coverage
- Confidence in changes
- Catch bugs early
- Safe refactoring

---

### Step 6.2: Integration Testing (Day 23-24)
**Duration**: 4 hours

**Actions**:
1. Create end-to-end test scenario
2. Test full playbook on Vagrant VM
3. Verify system state after run
4. Automate verification

**Test Script**:
```yaml
# tests/verify.yml
- name: Verify system configuration
  hosts: testbuild
  tasks:
    - name: Verify Docker is installed
      command: docker --version
      changed_when: false

    - name: Verify Go is installed
      command: go version
      changed_when: false

    - name: Verify workspace exists
      stat:
        path: /home/vagrant/Workspace
      register: workspace
      failed_when: not workspace.stat.exists
```

**Acceptance Criteria**:
- ✅ Integration tests created
- ✅ Verify key installations
- ✅ Tests run in CI
- ✅ Document test process

**Benefits**:
- Verify end-to-end functionality
- Catch integration issues
- Real-world testing
- System validation

---

### Phase 6 Deliverables

- Molecule tests for 5 critical roles
- Integration test suite
- CI pipeline runs all tests
- Test documentation

**Success Metrics**:
- >80% test coverage for critical roles
- Integration tests pass
- CI catches failures

---

## Continuous Improvement

### Ongoing Activities

1. **Weekly**: Review and fix ansible-lint warnings
2. **Monthly**: Update dependencies
3. **Quarterly**: Review and update documentation
4. **Per Feature**: Add tests for new roles

### Maintenance Tasks

- Keep dependencies updated
- Review and merge Dependabot PRs
- Monitor CI pipeline health
- Address security advisories

---

## Testing Strategy

### How to Test This Playbook

The project currently uses **Vagrant** for testing. Here's a comprehensive testing approach:

### Local Testing Workflow

#### 1. Syntax and Lint Checks (30 seconds)
```bash
# Check YAML syntax
yamllint .

# Check Ansible best practices
ansible-lint

# Verify playbook syntax
ansible-playbook --syntax-check playbook.yml
```

#### 2. Dry Run / Check Mode (2 minutes)
```bash
# See what would change without applying
ansible-playbook playbook.yml -l localhost \
  --check \
  --diff \
  --extra-vars="user_name=test user_git_name='Test' user_email=test@test.com"
```

#### 3. Vagrant VM Testing (15 minutes)
```bash
# Start VM
vagrant up

# Run playbook against VM
ansible-playbook playbook.yml -l testbuild \
  --extra-vars="user_name=vagrant user_git_name='Test' user_email=test@test.com" \
  --ask-become-pass

# Verify changes in VM
vagrant ssh
# ... manual verification ...

# Destroy VM when done
vagrant destroy -f
```

#### 4. Tag-Based Testing (5 minutes)
```bash
# Test specific role only
ansible-playbook playbook.yml -l testbuild \
  --tags base \
  --extra-vars="user_name=vagrant user_git_name='Test' user_email=test@test.com" \
  --ask-become-pass
```

#### 5. Idempotency Testing (10 minutes)
```bash
# Run playbook first time
ansible-playbook playbook.yml -l testbuild \
  --extra-vars="user_name=vagrant user_git_name='Test' user_email=test@test.com" \
  --ask-become-pass

# Run second time - should show no changes
ansible-playbook playbook.yml -l testbuild \
  --extra-vars="user_name=vagrant user_git_name='Test' user_email=test@test.com" \
  --ask-become-pass | tee idempotency.log

# Check for 'changed=0' in output
grep "changed=0" idempotency.log
```

#### 6. Role-Specific Testing (variable time)
```bash
# Test individual role changes
ansible-playbook playbook.yml -l testbuild \
  --tags development \
  --extra-vars="user_name=vagrant user_git_name='Test' user_email=test@test.com" \
  --ask-become-pass
```

### CI/CD Testing (Automated)

Once GitHub Actions is set up (Phase 2):

```yaml
# Automatically runs on every push/PR:
1. yamllint check
2. ansible-lint check
3. Syntax validation
4. (Future) Molecule tests
5. (Future) Integration tests
```

### Manual Verification Checklist

After running the playbook, verify:

**Base Role**:
- [ ] Zsh is default shell
- [ ] Terminator is installed and configured
- [ ] Workspace directory exists
- [ ] NTP is configured

**Development Role**:
- [ ] Docker is installed: `docker --version`
- [ ] Go is installed: `go version`
- [ ] kubectl works: `kubectl version --client`
- [ ] Node.js via nvm: `nvm --version`

**Security Role**:
- [ ] UFW is enabled: `sudo ufw status`
- [ ] ClamAV is running: `sudo systemctl status clamav-daemon`

**GNOME Role**:
- [ ] Favorite apps configured
- [ ] Keyboard shortcuts work
- [ ] Dash-to-dock configured

### Testing Best Practices

1. **Always test in VM first** - Never run untested changes on your main system
2. **Use check mode** - Preview changes before applying
3. **Test incrementally** - Test one role at a time when making changes
4. **Verify idempotency** - Always run twice to ensure no unwanted changes
5. **Check logs** - Review `/var/log/` for any errors
6. **Document issues** - Note any failures or unexpected behavior

### Future Testing Enhancements

1. **Molecule** - Automated role testing
2. **InSpec** - System state verification
3. **Kitchen** - Multi-platform testing
4. **GitHub Actions** - Automated CI/CD
5. **Terraform** - Cloud-based test environments

---

## Rollback Strategy

If any phase causes issues:

1. **Git**: Revert to previous working commit
2. **Vagrant**: `vagrant destroy && vagrant up` for clean state
3. **Testing**: Run full test suite after revert
4. **Documentation**: Document the issue and solution

---

## Success Criteria

### Phase 1 (Week 1)
- [x] Code passes yamllint
- [x] Code passes ansible-lint
- [x] Pre-commit hooks working

### Phase 2 (Week 2)
- [ ] CI pipeline operational
- [ ] All checks pass on main
- [ ] Dependencies documented

### Phase 3 (Week 3)
- [ ] 5+ roles documented
- [ ] CONTRIBUTING.md exists
- [ ] CHANGELOG maintained

### Phase 4 (Week 4-5)
- [ ] Molecule tests for base role
- [ ] Idempotency verified
- [ ] Tests in CI

### Phase 5 (Week 6)
- [ ] Modern Ansible syntax
- [ ] Role defaults added
- [ ] Role metadata complete

### Phase 6 (Week 7-8)
- [ ] 5 critical roles tested
- [ ] Integration tests pass
- [ ] >80% coverage

---

## Risk Mitigation

| Risk | Impact | Mitigation |
|------|--------|------------|
| Breaking changes | High | Test in VM first, git revert available |
| Time overrun | Medium | Focus on Phase 1-2 first, defer Phase 6 |
| Learning curve | Low | Good documentation, incremental approach |
| Tool installation issues | Low | Document dependencies, use venv |

---

## Resources Required

### Tools
- ansible-lint
- yamllint
- pre-commit
- molecule (Phase 4+)
- docker (for Molecule)

### Time Investment
- **Phase 1**: ~3 hours
- **Phase 2**: ~4 hours
- **Phase 3**: ~6 hours
- **Phase 4**: ~8 hours
- **Phase 5**: ~9 hours
- **Phase 6**: ~14 hours

**Total**: ~44 hours over 8 weeks (~5-6 hours/week)

### Learning Resources
- [Ansible Best Practices](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html)
- [Molecule Documentation](https://molecule.readthedocs.io/)
- [Ansible Lint](https://ansible-lint.readthedocs.io/)

---

## Conclusion

This plan provides a **structured, incremental approach** to improving the manjaro-playbook:

1. **Start Small**: Linting and quality checks (Phase 1)
2. **Build Foundation**: CI/CD pipeline (Phase 2)
3. **Enhance Usability**: Documentation (Phase 3)
4. **Add Safety**: Testing infrastructure (Phase 4)
5. **Modernize**: Update to current practices (Phase 5)
6. **Mature**: Comprehensive testing (Phase 6)

Each phase delivers value independently, so you can stop at any point and still have improvements.

**Recommended Minimum**: Complete Phases 1-2 (2 weeks, ~7 hours)
**Recommended Target**: Complete Phases 1-4 (5 weeks, ~21 hours)
**Stretch Goal**: Complete all phases (8 weeks, ~44 hours)

---

## Next Steps

1. Review this plan
2. Prioritize phases based on your needs
3. Start with Phase 1, Step 1.1 (yamllint configuration)
4. Track progress in CHANGELOG.md
5. Iterate and improve

Good luck! 🚀
