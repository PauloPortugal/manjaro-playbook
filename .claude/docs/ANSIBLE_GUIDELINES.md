# Ansible Guidelines for Manjaro Playbook

## Table of Contents
- [Overview](#overview)
- [Project Structure](#project-structure)
- [Best Practices](#best-practices)
- [Role Development](#role-development)
- [Variable Management](#variable-management)
- [Testing Strategy](#testing-strategy)
- [Code Quality](#code-quality)

---

## Overview

This Ansible playbook automates the configuration of a Manjaro OS (Arch Linux distribution) GNOME 3 desktop environment. It follows a role-based architecture with centralized variable management.

### Design Principles

1. **Modularity**: Each role handles a specific domain (browsers, development, security, etc.)
2. **Idempotency**: All tasks should be safely re-runnable without side effects
3. **Tagging**: Use tags for selective execution of playbook sections
4. **Centralized Configuration**: All package lists in `group_vars/all`
5. **Local-First**: Designed primarily for localhost execution with Vagrant testing support

---

## Project Structure

```
manjaro-playbook/
├── ansible.cfg              # Ansible configuration
├── inventory                # Host inventory (localhost, testbuild VM)
├── playbook.yml            # Main playbook entry point
├── group_vars/
│   └── all                 # Global variables (package lists, configs)
├── handlers/               # Event handlers (os, freshclam, zshrc)
├── roles/                  # 14 modular roles
│   ├── base/
│   ├── users/
│   ├── development/
│   ├── browsers/
│   ├── editors/
│   ├── security/
│   └── ...
└── aur/                    # Custom AUR installation scripts
```

---

## Best Practices

### 1. Module Usage

**Always use Fully Qualified Collection Names (FQCN)**

```yaml
# GOOD
- name: Install packages
  community.general.pacman:
    name: "{{ packages }}"
    state: present

# AVOID
- name: Install packages
  pacman:
    name: "{{ packages }}"
    state: present
```

### 2. Task Naming

**Use descriptive, action-oriented names**

```yaml
# GOOD
- name: Install development tools from official repos
  community.general.pacman:
    name: "{{ developer_stack }}"
    state: present

# AVOID
- name: Dev tools
  community.general.pacman:
    name: "{{ developer_stack }}"
    state: present
```

### 3. Privilege Escalation

**Apply `become` at the task level, not globally**

```yaml
# GOOD
- name: Install system packages
  community.general.pacman:
    name: "{{ utils }}"
    state: present
  become: true

# Use become_user when impersonating specific users
- name: Create user workspace
  ansible.builtin.file:
    path: /home/{{ user_name }}/Workspace
    state: directory
    mode: "0755"
  become_user: "{{ user_name }}"
  become: true
```

### 4. File Permissions

**Always specify file/directory permissions explicitly**

```yaml
- name: Create configuration directory
  ansible.builtin.file:
    path: /etc/myapp
    state: directory
    mode: "0755"
    owner: root
    group: root
```

### 5. Shell Commands

**Avoid shell/command modules when native Ansible modules exist**

```yaml
# GOOD
- name: Copy configuration file
  ansible.builtin.copy:
    src: config.yml
    dest: /etc/app/config.yml
    mode: "0644"

# AVOID
- name: Copy configuration
  ansible.builtin.shell: cp config.yml /etc/app/config.yml
```

**When shell is necessary, use proper error handling**

```yaml
- name: Install AUR package with pamac
  ansible.builtin.shell: |
    set -o pipefail
    pamac build -d --no-confirm {{ item }} | grep "is up to date"
    if [ $? != 0 ]; then
      pamac build --no-confirm {{ item }}
    fi
  args:
    executable: /bin/bash
  register: command_result
  failed_when: command_result.rc != 0
  changed_when: "'successfully' in command_result.stdout"
```

### 6. Looping

**Use modern loop syntax**

```yaml
# GOOD
- name: Install packages
  community.general.pacman:
    name: "{{ item }}"
    state: present
  loop: "{{ package_list }}"

# ACCEPTABLE (but deprecated)
- name: Install packages
  community.general.pacman:
    name: "{{ item }}"
    state: present
  with_items: "{{ package_list }}"
```

### 7. Conditional Execution

```yaml
# Check if file exists before acting
- name: Check if config exists
  ansible.builtin.stat:
    path: /etc/app/config.yml
  register: config_file

- name: Create default config
  ansible.builtin.copy:
    src: default_config.yml
    dest: /etc/app/config.yml
    mode: "0644"
  when: not config_file.stat.exists
```

---

## Role Development

### Standard Role Structure

```
role_name/
├── tasks/
│   ├── main.yml        # Entry point
│   └── subtask.yml     # Modular sub-tasks
├── files/              # Static files to deploy
├── templates/          # Jinja2 templates
├── defaults/           # Default variables (lowest precedence)
│   └── main.yml
├── vars/               # Role-specific variables (higher precedence)
│   └── main.yml
├── handlers/           # Event handlers
│   └── main.yml
├── meta/               # Role metadata and dependencies
│   └── main.yml
└── README.md           # Role documentation
```

### Task Organization

**Break complex roles into subtasks**

```yaml
# roles/base/tasks/main.yml
---
- name: Update system packages
  community.general.pacman:
    update_cache: true
    upgrade: true
  become: true

- name: Configure NTP
  ansible.builtin.import_tasks: ntp.yml

- name: Configure PIP
  ansible.builtin.import_tasks: pip.yml

- name: Configure Bash
  ansible.builtin.import_tasks: bash.yml
```

### Using Handlers

**Handlers run once at the end of a play, regardless of how many tasks notify them**

```yaml
# tasks/main.yml
- name: Update ClamAV configuration
  ansible.builtin.template:
    src: freshclam.conf.j2
    dest: /etc/clamav/freshclam.conf
    mode: "0644"
  become: true
  notify: Update virus database

# handlers/main.yml
- name: Update virus database
  ansible.builtin.command: freshclam
  become: true
```

---

## Variable Management

### Variable Precedence (lowest to highest)

1. Role defaults (`role/defaults/main.yml`)
2. Inventory variables
3. Group variables (`group_vars/`)
4. Host variables (`host_vars/`)
5. Play variables
6. Role variables (`role/vars/main.yml`)
7. Extra variables (`--extra-vars`)

### Centralized Package Management

**Current approach: All packages in `group_vars/all`**

```yaml
# group_vars/all
developer_stack:
  - ansible
  - docker
  - go
  - jq
  - kubectl

developer_stack_aur:
  - aws-cli-v2-bin
  - heroku-cli
  - postman-bin
```

**Benefits:**
- Single source of truth
- Easy to review all packages at once
- Simplifies package list maintenance

**Considerations:**
- Could become large (currently 167 lines)
- Consider splitting into role-specific var files if it grows beyond 300 lines

### Required Extra Variables

The playbook requires these variables at runtime:

```yaml
user_name: "pmonteiro"         # System username
user_git_name: "Paulo Monteiro" # Git committer name
user_email: "email@example.com" # Git email address
```

---

## Testing Strategy

### 1. Syntax Validation

```bash
# Check playbook syntax
ansible-playbook --syntax-check playbook.yml

# Lint YAML files
yamllint .

# Lint Ansible best practices
ansible-lint
```

### 2. Dry Run (Check Mode)

```bash
# Preview changes without applying them
ansible-playbook playbook.yml -l localhost \
  --check \
  --diff \
  --extra-vars="user_name=test user_git_name='Test User' user_email=test@example.com"
```

### 3. Vagrant Testing

```bash
# Test against VM before applying to localhost
vagrant up --provision
ansible-playbook playbook.yml -l testbuild \
  --extra-vars="user_name=vagrant user_git_name='Test' user_email=test@test.com" \
  --ask-become-pass
```

### 4. Tag-Based Testing

```bash
# Test individual roles
ansible-playbook playbook.yml -l testbuild \
  --tags base \
  --extra-vars="user_name=test user_git_name='Test' user_email=test@test.com" \
  --ask-become-pass
```

### 5. Idempotency Testing

Run the playbook twice and verify no changes on the second run:

```bash
# First run - should make changes
ansible-playbook playbook.yml -l testbuild --extra-vars="..." --ask-become-pass

# Second run - should report "ok" with no changes
ansible-playbook playbook.yml -l testbuild --extra-vars="..." --ask-become-pass
```

---

## Code Quality

### YAML Style

1. **Indentation**: 2 spaces (never tabs)
2. **Line Length**: Max 80 characters (configurable with yamllint)
3. **Quotes**: Use double quotes for strings containing variables
4. **Booleans**: Use `true`/`false` (not `yes`/`no`)
5. **Lists**: Use hyphen notation for lists

```yaml
# GOOD
- name: Install packages
  community.general.pacman:
    name: "{{ packages }}"
    state: present
    update_cache: true
  become: true
  tags:
    - packages
    - base

# AVOID
- name: Install packages
  community.general.pacman: name={{ packages }} state=present update_cache=yes
  become: yes
```

### Error Handling

```yaml
# Block with rescue for error handling
- name: Install AUR packages
  block:
    - name: Attempt AUR installation
      ansible.builtin.script: aur/install-aur.sh {{ item }}
      loop: "{{ aur_packages }}"
  rescue:
    - name: Log installation failure
      ansible.builtin.debug:
        msg: "Failed to install AUR packages"
  always:
    - name: Clean up temporary files
      ansible.builtin.file:
        path: /tmp/aur-build
        state: absent
```

### Documentation

1. **Task Names**: Every task must have a descriptive name
2. **Comments**: Explain complex logic, not obvious actions
3. **README**: Each role should have usage documentation
4. **Change Control**: Document breaking changes in commit messages

### Security

1. **Secrets**: Never commit secrets to git
   - Use Ansible Vault for sensitive data
   - Use environment variables or `--extra-vars`

2. **Permissions**: Follow principle of least privilege
   - Minimize use of `become: true`
   - Set explicit file permissions

3. **Package Sources**:
   - Prefer official repos over AUR
   - Review AUR PKGBUILDs before installation

---

## Common Patterns

### Pattern: Installing from Multiple Sources

```yaml
# Official repos
- name: Install official packages
  community.general.pacman:
    name: "{{ official_packages }}"
    state: present
  become: true

# AUR packages
- name: Install AUR packages
  ansible.builtin.script: aur/install-aur.sh {{ item }}
  loop: "{{ aur_packages }}"
  register: result
  changed_when: result.rc == 0
  failed_when: result.rc != 0 and result.rc != 255

# Python packages
- name: Install Python packages
  ansible.builtin.pip:
    name: "{{ pip_packages }}"
    state: present
```

### Pattern: User-Specific Configuration

```yaml
- name: Copy user configuration
  ansible.builtin.copy:
    src: "user_config.yml"
    dest: "/home/{{ user_name }}/.config/app/config.yml"
    owner: "{{ user_name }}"
    group: "{{ user_name }}"
    mode: "0644"
  become: true
```

### Pattern: Conditional Tasks

```yaml
- name: Install desktop environment packages
  community.general.pacman:
    name: "{{ gnome_packages }}"
    state: present
  become: true
  when: ansible_env.XDG_CURRENT_DESKTOP == "GNOME"
```

---

## Tags Strategy

Current tagging approach:

```yaml
roles:
  - {role: base, tags: [base]}
  - {role: development, tags: [development]}
  - {role: browsers, tags: [browsers]}
```

**Usage:**

```bash
# Install everything
ansible-playbook playbook.yml -l localhost --extra-vars="..." --ask-become-pass

# Install only development tools
ansible-playbook playbook.yml -l localhost --extra-vars="..." --ask-become-pass --tags development

# Install multiple specific roles
ansible-playbook playbook.yml -l localhost --extra-vars="..." --ask-become-pass --tags "base,browsers,editors"

# Skip certain roles
ansible-playbook playbook.yml -l localhost --extra-vars="..." --ask-become-pass --skip-tags "users,virtualization"
```

---

## Troubleshooting

### Common Issues

**Issue: Package already installed**
```bash
# AUR script returns 255 when package exists
failed_when: result.rc != 0 and result.rc != 255
```

**Issue: Permission denied**
```bash
# Ensure become: true is set
# Check file ownership and permissions
```

**Issue: Module not found**
```bash
# Install required collections
ansible-galaxy collection install community.general
```

**Issue: Idempotency failures**
```bash
# Run with -vvv for detailed output
ansible-playbook -vvv playbook.yml ...
```

---

## References

- [Ansible Best Practices](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html)
- [Manjaro Package Management](https://wiki.manjaro.org/index.php/Pacman_Overview)
- [Arch User Repository](https://wiki.archlinux.org/title/Arch_User_Repository)
- [Ansible Lint Rules](https://ansible-lint.readthedocs.io/rules/)
