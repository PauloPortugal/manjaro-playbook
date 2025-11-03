# Security Role

System security configuration including firewall and antivirus protection.

## Description

The `security` role configures:
- **UFW (Uncomplicated Firewall)** - Host-based firewall
- **ClamAV** - Antivirus engine
- **Clamtk** - ClamAV GUI
- **Gufw** - UFW GUI

## Requirements

- Manjaro/Arch Linux system
- `sudo` privileges
- Internet connection

## Variables

All variables are defined in `group_vars/all`:

| Variable | Type | Description |
|----------|------|-------------|
| `security_tools` | list | Security packages to install |

Packages: `clamav`, `clamtk`, `gufw`, `ufw`, `ufw-extras`

## Tasks

1. **Install Security Tools** - Installs firewall and antivirus packages
2. **Configure ClamAV** - Sets up antivirus daemon and updates
3. **Configure UFW** - Enables and configures firewall

## Installed Packages

- **ufw** - Uncomplicated Firewall (iptables frontend)
- **ufw-extras** - Additional UFW rules
- **gufw** - GTK+ frontend for UFW
- **clamav** - Antivirus engine
- **clamtk** - ClamAV GUI scanner

## Configuration

### UFW (Firewall)

- **Default policy**: Deny incoming, allow outgoing
- **Enabled**: Yes (starts on boot)
- **GUI**: Gufw available for configuration

### ClamAV (Antivirus)

- **Service**: clamav-daemon (enabled)
- **Freshclam**: Virus definition updater (enabled)
- **Database**: Auto-updated daily
- **GUI**: Clamtk for manual scans

## Tags

- `security` - All security tasks

## Example Usage

```bash
ansible-playbook playbook.yml -l localhost \
  --extra-vars="user_name=myuser user_git_name='My Name' user_email=me@example.com" \
  --tags security \
  --ask-become-pass
```

## Post-Installation

### Check UFW Status

```bash
sudo ufw status verbose
```

### Update ClamAV Database

```bash
sudo freshclam
```

### Scan with ClamAV

```bash
# GUI
clamtk

# CLI
clamscan -r /home
```

## UFW Common Commands

```bash
# Allow specific port
sudo ufw allow 22/tcp

# Deny port
sudo ufw deny 80/tcp

# Enable/disable
sudo ufw enable
sudo ufw disable

# Reset to defaults
sudo ufw reset
```

## ClamAV Common Commands

```bash
# Update virus database
sudo freshclam

# Scan directory
clamscan -r /path/to/directory

# Scan and remove infected files
clamscan -r --remove /path/to/directory
```

## Security Best Practices

1. **Keep UFW enabled** - Protects against network attacks
2. **Update ClamAV daily** - Freshclam runs automatically
3. **Regular scans** - Schedule weekly full system scans
4. **Review firewall rules** - Audit UFW rules periodically
5. **Monitor logs** - Check `/var/log/ufw.log` and `/var/log/clamav/`

## Troubleshooting

### UFW Not Starting

```bash
# Check status
sudo systemctl status ufw

# Enable and start
sudo systemctl enable ufw
sudo systemctl start ufw
```

### ClamAV Database Update Fails

```bash
# Check freshclam service
sudo systemctl status clamav-freshclam

# Manual update
sudo freshclam

# Check logs
sudo journalctl -u clamav-freshclam
```

## Author

Paulo Portugal

## License

See LICENSE file in repository root.
