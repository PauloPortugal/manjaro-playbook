# Base Role

Core system configuration and utilities for Manjaro/Arch Linux.

## Description

The `base` role handles fundamental system setup including:
- System package updates and upgrades
- Essential utilities installation
- Shell configuration (Bash and Zsh)
- Terminal emulator setup (Terminator)
- NTP time synchronization
- Python package management
- Workspace directory creation

This role should be run first as other roles may depend on utilities installed here.

## Requirements

- Manjaro/Arch Linux system
- `sudo` privileges
- Internet connection for package downloads

## Variables

All variables are defined in `group_vars/all`:

### Package Lists

| Variable | Type | Description |
|----------|------|-------------|
| `utils` | list | System utilities from official repos |
| `utils_aur` | list | System utilities from AUR |
| `shell_aliases` | list | Shell aliases to configure |
| `zsh_plugins` | list | Oh-My-Zsh plugins to enable |
| `pip_packages` | list | Python packages to install |

### User Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `user_name` | Yes | Username for configuration |

## Dependencies

None. This is a foundational role.

## Tasks

### Main Tasks (tasks/main.yml)

1. **Update system packages**
   - Updates package cache
   - Upgrades all packages
   - Uses `community.general.pacman`

2. **Install utilities**
   - Installs packages from `utils` list
   - Includes: base-devel, gcc, git, htop, vim, etc.

3. **Install AUR utilities**
   - Installs packages from `utils_aur` list
   - Uses pamac for AUR package management
   - Includes: git-extras, lsdesktopf, zsh-git-prompt

4. **Configure NTP**
   - Imports `ntp.yml` tasks
   - Ensures accurate system time

5. **Configure Python/PIP**
   - Imports `pip.yml` tasks
   - Installs Python package manager

6. **Configure Bash**
   - Imports `bash.yml` tasks
   - Sets up shell aliases

7. **Configure Zsh**
   - Imports `zsh.yml` tasks
   - Installs Oh-My-Zsh
   - Configures plugins and theme

8. **Configure Terminator**
   - Imports `terminator.yml` tasks
   - Sets up terminal emulator

9. **Create workspace directory**
   - Creates `~/Workspace` folder
   - Sets proper permissions

### Subtasks

#### NTP Configuration (tasks/ntp.yml)
- Starts and enables NTP daemon
- Ensures system time synchronization

#### Python/PIP (tasks/pip.yml)
- Installs python-pip
- Configures pip environment

#### Bash Configuration (tasks/bash.yml)
- Creates shell aliases in `~/.bashrc`
- Adds custom commands

#### Zsh Configuration (tasks/zsh.yml)
- Installs Oh-My-Zsh framework
- Checks if `.zshrc` exists
- Configures plugins (git, docker, etc.)
- Sets up shell aliases
- Configures prompt theme

#### Terminator (tasks/terminator.yml)
- Installs terminator terminal emulator
- Copies custom configuration

## Files

| File | Purpose |
|------|---------|
| `files/install-oh-my-zsh.sh` | Oh-My-Zsh installation script |
| `files/terminator_config` | Terminator configuration template |

## Handlers

| Handler | Purpose |
|---------|---------|
| `Configure .zshrc` | Reloads Zsh configuration after changes |

## Tags

- `base` - All base role tasks
- `utils` - Utility installation
- `utils-aur` - AUR utility installation
- `aur` - All AUR-related tasks
- `pre` - Pre-configuration tasks (updates)

## Example Usage

### Run entire base role

```bash
ansible-playbook playbook.yml -l localhost \
  --extra-vars="user_name=myuser user_git_name='My Name' user_email=me@example.com" \
  --tags base \
  --ask-become-pass
```

### Run only utility installation

```bash
ansible-playbook playbook.yml -l localhost \
  --extra-vars="user_name=myuser user_git_name='My Name' user_email=me@example.com" \
  --tags utils \
  --ask-become-pass
```

### Skip AUR packages

```bash
ansible-playbook playbook.yml -l localhost \
  --extra-vars="user_name=myuser user_git_name='My Name' user_email=me@example.com" \
  --tags base \
  --skip-tags aur \
  --ask-become-pass
```

## Installed Packages

### Official Repositories (utils)

- base-devel - Development tools
- binutils - Binary utilities
- bluez, bluez-utils - Bluetooth support
- gcc - C compiler
- gum - Interactive CLI tool
- htop - Process viewer
- keychain - SSH key manager
- make - Build automation
- mlocate - File indexing
- ntp - Network time protocol
- pamac - AUR helper
- python-pip - Python package manager
- pwgen - Password generator
- terminator - Terminal emulator
- tree - Directory visualization
- wget - File downloader
- xclip - Clipboard utility
- xorg-xinput - Input configuration

### AUR (utils_aur)

- git-extras - Additional git commands
- lsdesktopf - Desktop file lister
- zsh-git-prompt - Git status in prompt

## Shell Configuration

### Bash Aliases

```bash
ll='ls -lrt'           # Long list, sorted by time
pull='hub pull-request --no-edit -o -p'  # Quick PR creation
rgrep='grep -r'        # Recursive grep
vi=vim                 # Vim shortcut
W='cd ~/Workspace'     # Quick workspace navigation
```

### Zsh Plugins

- archlinux - Arch Linux helpers
- colored-man-pages - Colorized man pages
- docker - Docker completions
- docker-compose - Docker Compose completions
- dotenv - Load .env files
- git-prompt - Git status in prompt
- git-extras - Git-extras completions
- spring - Spring Framework helpers

## Notes

### Oh-My-Zsh Installation

The role checks if Oh-My-Zsh is already installed to avoid reinstallation:

```yaml
- name: Check if .zshrc exists
  ansible.builtin.stat:
    path: /home/{{ user_name }}/.oh-my-zsh
  register: oh_my_zsh_exists
```

### Workspace Directory

Creates `~/Workspace` with mode `0755` for project organization.

### Shell Changes

After running this role, you may need to:
1. Log out and back in for shell changes to take effect
2. Run `chsh -s /bin/zsh` to set Zsh as default shell (if desired)

## Troubleshooting

### AUR Package Installation Fails

If AUR packages fail to install:

```bash
# Check pamac is working
pamac list

# Try manual installation
pamac build <package-name>
```

### Zsh Not Default Shell

```bash
# Set Zsh as default
chsh -s /bin/zsh

# Verify
echo $SHELL
```

### Oh-My-Zsh Theme Issues

Edit `~/.zshrc` and change theme:

```bash
ZSH_THEME="robbyrussell"  # or any other theme
```

## Author

Paulo Portugal

## License

See LICENSE file in repository root.
