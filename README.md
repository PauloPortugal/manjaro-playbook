# Manjaro/Arch Linux Ansible Provision

This is an [Ansible playbook](https://docs.ansible.com/ansible/latest/user_guide/index.html) meant to configure a Manjaro OS (Arch Linux distribution) GNOME 3 desktop.
It should run locally after a clean OS install.

This playbook follows the Manjaro [community recommendation when installing the additional software packages](https://wiki.manjaro.org/index.php/Arch_User_Repository) from the [Arch User Repository](https://aur.archlinux.org/packages):
 * Using Arch Linux Package Manager **pacman** to install [Arch Linux official packages](https://archlinux.org/packages/)
 * Using the command line **Pamac** for a more automated way of installing [AUR packages](https://aur.archlinux.org/packages)
 * Using the [install-aur.sh](https://github.com/PauloPortugal/manjaro-playbook/blob/master/aur/install-aur.sh) to provide a "manual installation"

## Prior Instructions

### 1. Creating Bootable Linux USB Drive from the Command Line

Find out the name of the USB drive
```
lsblk
```

Flash the ISO image to the USB drive
```
dd bs=4M if=/path/to/iso of=/dev/sdx status=progress oflag=sync
```

### 2. Refresh pacaman mirrors, the copy of the master package database from the server and install `ansible`, `git` and `xclip`
```
sudo pacman-mirrors -f && sudo pacman -Syyu
sudo pacman -S ansible git xclip --noconfirm
```

### 3. Set Git SSH credentials

Generate a new SSH Key
```
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
```

Start the ssh-agent in the background
```
eval "$(ssh-agent -s)"
```

Add SSH Key to the ssh-agent
```
ssh-add ~/.ssh/id_rsa
```

Copy the SSH public key to the clipboard
```
xclip -sel clip < ~/.ssh/id_rsa.pub
```

### 4. Git clone the current project
```
git clone git@github.com:PauloPortugal/manjaro-playbook.git
cd manjaro-playbook
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

### Install only the 'dev-tools' role
```
ansible-playbook -v playbook.yml --extra-vars="user_name=USERNAME user_email=EMAIL" --ask-become-pass --tags dev-tools
```


## Playbook Tags

Tags supported:

| Tag            | Description                                                                                                      |
|----------------|------------------------------------------------------------------------------------------------------------------|
| base           | Install Linux util libraries, python-pip, xinput, terminator, snap and zsh                                       |
| users          | Setup user accounts                                                                                              |
| printers       | Install printer drivers                                                                                          |
| browsers       | Install tor, google-chrome and chromedriver                                                                      |
| audio-tools    | Install audacity                                                                                                 |
| dev-tools      | Install jq, xq, docker, docker-compose, go, nodejs, npm, nvm, jre8, jre10, maven, clojure, leiningen, sbt, scala, minikube, kubectl, hub and heroku  |
| cloud-tools    | Install google-cloud-sdk                                                                                         |
| editors        | Install vim, atom, emacs, gimp, Intellij + JetBrains Toolbox, Microsoft Visual Studio and Xmind                  |
| media          | Install Spotify and Peek (GIF Screen recorder)                                                                   |
| multimedia     | Install gimp and darktable                                                                                       |
| gnome          | Configure the desktop environment                                                                                |
| comms          | Install communication/Instant Messaging apps: signal-desktop, slack-desktop                                      |
| aur            | Install Arch User Repository libraries                                                                           |
| security       | Install clamav, clamtk, ufw, ufw-extras and gufw                                                                 |
| virtualization | Install vagrant, virtualbox and virtualbox-host-modules-arch                                                     |

Example on how to install only browsers:
```
ansible-playbook playbook.yml --extra-vars="user_name=USERNAME user_email=EMAIL" --ask-become-pass --tags browsers
```

## Google Cloud Configuration

On the command line run
```
gcloud init
```

For more information about Gcloud command lines read https://cloud.google.com/sdk/gcloud


## TODO

1. It would be nice to include more audio-tools.

2. Test the playbook
