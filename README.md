# Manjaro/Arch Linux Ansible Provision

This is an Ansible playbook meant to provision a Manjaro Linux distribution,
based on Arch Linux. It should run locally after a clean Manjaro install.

## Preamble
```
sudo pacman -Syy
sudo pacman -S ansible git --noconfirm
```

## Run
```
ansible-playbook -vvv playbook.yml --extra-vars="user_name=USERNAME user_email=EMAIL" --ask-become-pass
```

## Notes

### Arch User Repository (AUR)
All tasks that install AUR packages are tagged with `aur`.
