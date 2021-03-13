# Manjaro/Arch Linux Ansible Provision

This is an Ansible playbook meant to provision a Manjaro or Antergos Linux distribution,
based on Arch Linux. It should run locally after a clean OS install.

## Preamble

### 1. Creating Bootable Linux USB Drive from the Command Line

Find out the name of the USB drive
```
lsblk
```

Flash the ISO image to the USB drive
```
dd bs=4M if=/path/to/iso of=/dev/sdx status=progress oflag=sync
```

### 2. Refresh the copy of the master package database from the server and install `ansible`, `git` and `xclip`
```
sudo pacman -Syy
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

| Tag         | Description                                                                                                      |
|-------------|------------------------------------------------------------------------------------------------------------------|
| base        | Install Linux util libraries, python-pip, xinput, terminator, snap and zsh                                       |
| users       | Setup user accounts                                                                                              |
| printers    | Install printer drivers                                                                                          |
| browsers    | Install Chrome and chromedriver
| audio-tools | Install Audacity                                                                                  |
| dev-tools   | Install jq, xq, docker, docker-compose, go, nodejs, npm, nvm, jre8, jre10, maven, clojure, leiningen, sbt, scala, minikube, kubectl, hub and heroku  |
| cloud-tools | Install google-cloud-sdk                                                                                         |
| editors     | Install vim, atom, emacs, gimp, Intellij + JetBrains Toolbox, Microsoft Visual Studio and Xmind                  |
| media       | Install Spotify and Peek (GIF Screen recorder)                                                                   |
| multimedia  | Install gimp and darktable                                                                                       |
| gnome       | Configure the desktop environment                                                                                |
| comms       | Install communication/Instant Messaging apps: signal-desktop, slack-desktop                                      |
| aur         | Install Arch User Repository libraries                                                                           |
| security    | Install clamav, clamtk, ufw, ufw-extras and gufw                                                                 |

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

1. The following steps need to be reviewed as they will always have a `changed` status:
 * pip
 * nvm

2. Configure `thefuck`
 * add `eval $(thefuck --alias)` in your `~/.zshrc`

3. It would be nice to include more audio-tools.
