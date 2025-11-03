# Contributing to Manjaro Playbook

Thank you for considering contributing to this project! This document provides guidelines for contributing.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Making Changes](#making-changes)
- [Coding Standards](#coding-standards)
- [Testing](#testing)
- [Submitting Changes](#submitting-changes)
- [Reporting Issues](#reporting-issues)

## Code of Conduct

- Be respectful and inclusive
- Welcome newcomers and help them learn
- Focus on constructive feedback
- Assume good intentions

## Getting Started

### Prerequisites

- Manjaro/Arch Linux system (or Vagrant VM for testing)
- Git installed
- Basic Ansible knowledge

### Fork and Clone

1. Fork the repository on GitHub
2. Clone your fork locally:

```bash
git clone git@github.com:YOUR_USERNAME/manjaro-playbook.git
cd manjaro-playbook
```

3. Add upstream remote:

```bash
git remote add upstream git@github.com:PauloPortugal/manjaro-playbook.git
```

## Development Setup

### Automated Setup (Recommended)

```bash
./setup-dev-environment.sh
```

This installs:
- ansible, ansible-lint, yamllint, python-pytokens, pre-commit
- Ansible Galaxy collections
- Pre-commit hooks

### Manual Setup

```bash
sudo pacman -S ansible ansible-lint yamllint python-pytokens pre-commit
ansible-galaxy collection install -r requirements.yml
pre-commit install
```

### Verify Setup

```bash
yamllint . && ansible-lint && echo "✅ Setup complete!"
```

## Making Changes

### 1. Create a Branch

```bash
git checkout -b feature/your-feature-name
# or
git checkout -b fix/issue-description
```

Branch naming conventions:
- `feature/` - New features
- `fix/` - Bug fixes
- `docs/` - Documentation changes
- `refactor/` - Code refactoring
- `test/` - Test additions/changes

### 2. Make Your Changes

Edit files as needed. The project structure:

```
manjaro-playbook/
├── playbook.yml          # Main playbook
├── group_vars/all        # Variables
├── roles/                # Ansible roles
│   ├── base/
│   ├── development/
│   └── ...
└── .github/workflows/    # CI/CD
```

### 3. Test Locally

```bash
# Pre-commit hooks run automatically
git add .
git commit -m "Your message"

# Or run manually
pre-commit run --all-files

# Test on Vagrant VM (recommended)
vagrant up --provision
ansible-playbook playbook.yml -l testbuild \
  --extra-vars="user_name=vagrant user_git_name='Test' user_email=test@test.com" \
  --ask-become-pass
```

## Coding Standards

### Ansible Best Practices

Follow guidelines in [`.claude/docs/ANSIBLE_GUIDELINES.md`](.claude/docs/ANSIBLE_GUIDELINES.md):

1. **Use FQCN (Fully Qualified Collection Names)**
   ```yaml
   # Good
   - name: Install package
     community.general.pacman:
       name: example

   # Avoid
   - name: Install package
     pacman:
       name: example
   ```

2. **Name All Tasks**
   ```yaml
   # Good
   - name: Install development tools
     community.general.pacman:
       name: "{{ developer_stack }}"

   # Avoid
   - community.general.pacman:
       name: "{{ developer_stack }}"
   ```

3. **Use become Appropriately**
   ```yaml
   - name: Install system package
     community.general.pacman:
       name: example
     become: true  # Only when needed
   ```

4. **Set File Permissions Explicitly**
   ```yaml
   - name: Create directory
     ansible.builtin.file:
       path: /etc/myapp
       state: directory
       mode: "0755"  # Always specify
   ```

### YAML Style

- **Indentation**: 2 spaces (no tabs)
- **Line length**: Max 120 characters
- **Quotes**: Use double quotes for strings with variables
- **Booleans**: Use `true`/`false` (not `yes`/`no`)

### Variable Naming

Currently, variable naming rules are relaxed. Future phases will enforce:
- Role prefix (e.g., `base_command_result`)
- Loop variable prefix (e.g., `loop_var: base_item`)

## Testing

### Pre-commit Checks

Pre-commit hooks run automatically on commit:
- Trailing whitespace removal
- End-of-file fixes
- YAML syntax check
- yamllint
- ansible-lint
- ShellCheck (for shell scripts)

### Manual Testing

```bash
# Syntax validation
ansible-playbook --syntax-check playbook.yml

# Check mode (dry run)
ansible-playbook playbook.yml -l testbuild --check \
  --extra-vars="user_name=test user_git_name='Test' user_email=test@test.com"

# Full run on Vagrant VM
vagrant up --provision
ansible-playbook playbook.yml -l testbuild \
  --extra-vars="user_name=vagrant user_git_name='Test' user_email=test@test.com" \
  --ask-become-pass
```

### Idempotency

Run the playbook twice; the second run should report no changes:

```bash
# First run
ansible-playbook playbook.yml -l testbuild --extra-vars="..." --ask-become-pass

# Second run - should be idempotent
ansible-playbook playbook.yml -l testbuild --extra-vars="..." --ask-become-pass
```

## Submitting Changes

### 1. Commit Guidelines

Follow conventional commits:

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation
- `style`: Formatting (no code change)
- `refactor`: Code restructuring
- `test`: Adding tests
- `chore`: Maintenance

**Examples:**

```bash
git commit -m "feat(development): add Python 3.12 support"

git commit -m "fix(security): update ClamAV configuration

- Fix freshclam update schedule
- Enable daemon on boot
- Update virus database path

Fixes #123"

git commit -m "docs(base): add troubleshooting section to README"
```

### 2. Push Changes

```bash
git push origin feature/your-feature-name
```

### 3. Create Pull Request

1. Go to your fork on GitHub
2. Click "New Pull Request"
3. Select your branch
4. Fill in the PR template:
   - **Title**: Clear, descriptive (follows commit convention)
   - **Description**: What changed and why
   - **Testing**: How you tested the changes
   - **Checklist**: Complete all items

### 4. PR Requirements

Before submitting:
- ✅ Pre-commit hooks pass
- ✅ CI checks pass (automatic)
- ✅ Tested on Vagrant VM
- ✅ Documentation updated (if applicable)
- ✅ CHANGELOG.md updated (for notable changes)

### 5. Review Process

- Maintainers will review your PR
- Address feedback by pushing new commits
- Once approved, maintainers will merge

## Reporting Issues

### Before Reporting

1. Search existing issues
2. Check documentation
3. Try on a clean Vagrant VM

### Issue Template

```markdown
**Description**
Clear description of the issue

**Steps to Reproduce**
1. Step one
2. Step two
3. ...

**Expected Behavior**
What should happen

**Actual Behavior**
What actually happens

**Environment**
- OS: Manjaro 23.0.0
- Ansible: 2.19.2
- Playbook version: commit hash or tag

**Logs**
```
Paste relevant logs here
```
```

### Issue Labels

- `bug` - Something isn't working
- `enhancement` - New feature request
- `documentation` - Documentation improvement
- `good first issue` - Good for newcomers
- `help wanted` - Extra attention needed

## Project Structure

```
.
├── playbook.yml              # Main playbook
├── inventory                 # Hosts (localhost, Vagrant VM)
├── group_vars/all            # Global variables
├── roles/                    # Ansible roles
│   ├── base/
│   │   ├── tasks/
│   │   │   └── main.yml
│   │   ├── files/
│   │   └── README.md
│   └── ...
├── handlers/                 # Event handlers
├── aur/                      # AUR installation scripts
├── .github/workflows/        # CI/CD
├── .claude/docs/             # AI assistant context
├── requirements.txt          # Python dependencies
├── requirements.yml          # Ansible collections
└── setup-dev-environment.sh  # Automated setup
```

## Development Workflow

```
1. Fork & Clone → 2. Create Branch → 3. Make Changes
        ↓                                     ↓
4. Test Locally ← 5. Commit (pre-commit runs)
        ↓
6. Push to Fork → 7. Create PR → 8. Review → 9. Merge
```

## Getting Help

- **Documentation**: Check [README.md](README.md) and [`.claude/docs/`](.claude/docs/)
- **Issues**: Search or create an issue on GitHub
- **Discussions**: Use GitHub Discussions for questions

## Recognition

Contributors are recognized in:
- Git commit history
- GitHub contributors page
- Release notes (for significant contributions)

## License

By contributing, you agree that your contributions will be licensed under the same license as the project (see [LICENSE](LICENSE)).

---

Thank you for contributing! 🎉
