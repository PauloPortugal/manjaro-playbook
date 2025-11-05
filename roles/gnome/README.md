# GNOME Role

GNOME desktop environment customization and configuration.

## Description

The `gnome` role customizes the GNOME 3 desktop with:
- Top bar configuration (clock, battery, weather)
- Dash-to-dock customization
- Keyboard shortcuts
- Peripheral settings (touchpad, mouse)
- Screensaver configuration
- Window titlebar settings
- Favorite applications

## Requirements

- GNOME 3 desktop environment
- `dconf` command-line tool
- User session (not run as root)

## Variables

All variables are defined in `group_vars/all`:

| Variable | Type | Description |
|----------|------|-------------|
| `user_name` | string | Username for GNOME configuration |
| `gnome` | list | GNOME-related packages |

## Tasks

All tasks use `community.general.dconf` to modify GNOME settings:

1. **Top Bar** (`tasks/top-bar.yml`) - Clock, weather, battery
2. **Dash-to-Dock** (`tasks/dash-to-dock.yml`) - Dock appearance and behavior
3. **Keyboard Shortcuts** (`tasks/keyboard-shortcuts.yml`) - Custom key bindings
4. **Peripherals** (`tasks/peripherals.yml`) - Mouse and touchpad
5. **Screensaver** (`tasks/screensaver.yml`) - Lock screen settings
6. **Window Titlebars** (`tasks/window-titlebars.yml`) - Titlebar buttons
7. **Favorite Apps** (`tasks/main.yml`) - Dock applications

## Configuration Details

### Top Bar
- Show date on clock
- Disable clock seconds
- Battery percentage visible
- Weather locations (London, Porto)
- World clocks (Cape Town)

### Dash-to-Dock
- Position: Bottom
- Icon size: 48px
- Intelligent autohide
- Show favorites only
- Click action: Minimize/restore

### Keyboard Shortcuts
Custom shortcuts for quick access:
- Terminal, Files, Browser
- System monitor, Settings
- Custom commands

### Peripherals
- Tap-to-click enabled
- Natural scrolling (optional)
- Mouse acceleration

### Screensaver
- Timeout settings
- Lock screen behavior
- Idle delay

## Tags

- `gnome` - All GNOME configuration tasks

## Example Usage

```bash
ansible-playbook playbook.yml -l localhost \
  --extra-vars="user_name=myuser user_git_name='My Name' user_email=me@example.com" \
  --tags gnome \
  --ask-become-pass
```

## Post-Installation

Changes take effect immediately. If not:

```bash
# Reload GNOME Shell (X11)
Alt+F2, type 'r', press Enter

# Or logout/login
```

## Customization

All settings use `dconf`. To see current values:

```bash
# List all settings
dconf dump /org/gnome/

# Specific setting
dconf read /org/gnome/desktop/interface/clock-show-date
```

To modify:

```bash
# Set a value
dconf write /org/gnome/desktop/interface/clock-show-date "true"

# Reset to default
dconf reset /org/gnome/desktop/interface/clock-show-date
```

## Favorite Applications

Default dock applications (customizable in `group_vars/all`):
- Firefox
- Thunderbird
- Files
- Terminal
- Text Editor
- Software Center

## Troubleshooting

### Settings Not Applied

```bash
# Check dconf service
systemctl --user status dconf

# Reset and reapply
dconf reset -f /org/gnome/
ansible-playbook playbook.yml --tags gnome
```

### Keyboard Shortcuts Not Working

```bash
# List current shortcuts
gsettings list-recursively org.gnome.settings-daemon.plugins.media-keys
```

## Author

Paulo Portugal

## License

See LICENSE file in repository root.
