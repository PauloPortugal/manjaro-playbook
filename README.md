# Manjaro/Arch Linux Ansible Provision

This is an Ansible playbook meant to provision a Manjaro or Antergos Linux distribution,
based on Arch Linux. It should run locally after a clean OS install.

## Preamble

1. Refresh the copy of the master package database from the server and install `Ansible` and `Git`
```
sudo pacman -Syy
sudo pacman -S ansible git --noconfirm
```

2. Git clone the current project
```
git clone git@github.com:PauloPortugal/manjaro-playbook.git
```

## Run

### Install everything
```
ansible-playbook playbook.yml --extra-vars="user_name=USERNAME user_email=EMAIL" --ask-become-pass
```

### Install everything with debug turned on
```
ansible-playbook -vvv playbook.yml --extra-vars="user_name=USERNAME user_email=EMAIL" --ask-become-pass
```

## Playbook Tags

Tags supported:

| Tag       | Description                                                             |
|-----------|-------------------------------------------------------------------------|
| base      | Install Linux util libraries, python-pip, xinput, terminator and zsh    |
| browsers  | Install Chrome                                                          |
| dev-tools | Install Docker, nodejs, npm, jre8, jre10, maven, clojure and leiningen  |
| editors   | Install vim, atom, emacs and gimp                                       |
| media     | Install Spotify                                                         |
| gnome     | Configure the desktop environment                                       |
| aur       | Install Arch User Repository libraries                                  |

Example on how to install only browsers:
```
ansible-playbook playbook.yml --extra-vars="user_name=USERNAME user_email=EMAIL" --ask-become-pass --tags browsers
```
