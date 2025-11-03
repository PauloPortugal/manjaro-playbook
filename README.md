# Manjaro/Arch Linux Ansible Provision

[![CI](https://github.com/PauloPortugal/manjaro-playbook/workflows/CI/badge.svg)](https://github.com/PauloPortugal/manjaro-playbook/actions)

This is an [Ansible playbook](https://docs.ansible.com/ansible/latest/user_guide/index.html) meant to configure a Manjaro OS (Arch Linux distribution) GNOME 3 desktop.
It should run locally after a clean OS install.

This playbook follows the Manjaro [community recommendation when installing the additional software packages](https://wiki.manjaro.org/index.php/Arch_User_Repository) from the [Arch User Repository](https://aur.archlinux.org/packages):
 * Using Arch Linux Package Manager **pacman** to install [Arch Linux official packages](https://archlinux.org/packages/)
 * Using the command line **Pamac** for a more automated way of installing [AUR packages](https://aur.archlinux.org/packages)
 * Using a bespoke script [install-aur.sh](https://github.com/PauloPortugal/manjaro-playbook/blob/master/aur/install-aur.sh) to provide a "manual installation" for [AUR packages](https://aur.archlinux.org/packages)


## :placard: Table of contents
- [Manjaro/Arch Linux Ansible Provision](#manjaroarch-linux-ansible-provision)
  - [:placard: Table of contents](#placard-table-of-contents)
  - [Provision and configure a Vagrant VM](#provision-and-configure-a-vagrant-vm)
    - [Provision and configure a Manjaro Vagrant VM](#provision-and-configure-a-manjaro-vagrant-vm)
  - [Run and configure the localhost machine](#run-and-configure-the-localhost-machine)
    - [Code Quality Checks](#code-quality-checks)
    - [Install everything](#install-everything)
    - [Install everything with debug turned on](#install-everything-with-debug-turned-on)
    - [Install only the 'dev-tools' role with minimal logging](#install-only-the-dev-tools-role-with-minimal-logging)
  - [:toolbox: Playbook Roles](#toolbox-playbook-roles)
  - [:rocket: Instructions to install a new Manjaro image](#rocket-instructions-to-install-a-new-manjaro-image)
    - [1. Creating Bootable Linux USB Drive from the Command Line](#1-creating-bootable-linux-usb-drive-from-the-command-line)
    - [2. Refresh pacaman mirrors, the copy of the master package database from the server and install `ansible`, `git` and `xclip`](#2-refresh-pacaman-mirrors-the-copy-of-the-master-package-database-from-the-server-and-install-ansible-git-and-xclip)
    - [3. Set Git SSH credentials](#3-set-git-ssh-credentials)
    - [4. Git clone the current project](#4-git-clone-the-current-project)
  - [:cloud: Google Cloud Configuration](#cloud-google-cloud-configuration)
  - [:construction: TODO](#construction-todo)

----

## Provision and configure a Vagrant VM
Before applying the changes against your desktop/laptop, being able to test against a [Docker](https://www.docker.com/) container or a [Vagrant](https://www.vagrantup.com/) VM machine allows to test the playbook safer, quicker and often.

Since this is a Manjaro/Arch Desktop setup, having a Virtual Box to be able to login and inspect the UI is somewhat useful, although this is still an experimentation as the preferred approach was to opt for a Docker container.

The Vagrant VM box is based on a [Manjaro Gnome X64 21.0](https://app.vagrantup.com/pmonteiro/boxes/manjaro-21-X64-gnome/versions/1.0.0) box. This should not be an issue if you want the [latest Manjaro release](https://manjaro.org/downloads/official/gnome/), as the playbook will upgrade the VM to the lastest Manjaro release version.


### Provision and configure a Manjaro Vagrant VM

Install and configure Vagrant & [Oracle VirtualBox](https://www.virtualbox.org/) locally
```
# if from a different Linux distribution or on a Mac make sure to install Vagrant and Oracle
# if you are using a Manjaro/Arch, install and configure Vagrant & Oracle VirtualBox locally
ansible-playbook playbook.yml -l localhost --extra-vars="user_name=USERNAME user_git_name=GIT_USERNAME" --ask-become-pass --tags virtualization

#Provision the Vagrant box
vagrant up --provision

# Run Ansible playbook against the Vagrant VM
ansible-playbook playbook.yml -l testbuild --extra-vars="user_name=USERNAME user_git_name=GIT_USERNAME user_email=EMAIL" --ask-become-pass
```

## Run and configure the localhost machine

### Code Quality Checks

Before running the playbook, validate your code:

```bash
# Check YAML syntax and style
yamllint .

# Check Ansible best practices
ansible-lint

# Verify playbook syntax
ansible-playbook --syntax-check playbook.yml
```

**Note**: If you ran `./setup-dev-environment.sh`, pre-commit hooks are already installed and will run these checks automatically on every commit!

### Install everything
```
ansible-lint
ansible-playbook playbook.yml -l localhost --extra-vars="user_name=USERNAME user_git_name=GIT_USERNAME user_email=EMAIL" --ask-become-pass
```

### Install everything with debug turned on
```
ansible-lint
ansible-playbook -vvvv playbook.yml -l localhost --extra-vars="user_name=USERNAME user_git_name=GIT_USERNAME user_email=EMAIL" --ask-become-pass
```

### Install only the 'dev-tools' role with minimal logging
```
ansible-lint
ansible-playbook -v playbook.yml -l localhost --extra-vars="user_name=USERNAME user_git_name=GIT_USERNAME user_email=EMAIL" --ask-become-pass --tags dev-tools
```


## :toolbox: Playbook Roles

Roles supported:

| Roles          | Description                                                                                                      |
|----------------|------------------------------------------------------------------------------------------------------------------|
| base           | Install Linux util libraries, python-pip, xinput, terminator, snap and zsh                                       |
| users          | Setup user accounts                                                                                              |
| printers       | Install printer drivers                                                                                          |
| browsers       | Install tor, google-chrome and chromedriver                                                                      |
| audio-tools    | Install audacity                                                                                                 |
| dev-tools      | Install tesseract, jq, xq, docker, docker-compose, go, nodejs, npm, nvm, jre8, jre10, maven, clojure, leiningen, sbt, scala, minikube, kubectl, kubectx, kubefwd, hub and heroku  |
| cloud-tools    | Install google-cloud-sdk                                                                                         |
| editors        | Install vim, emacs, gimp, Intellij + JetBrains Toolbox, Goland, Visual Studio Code and Xmind                  |
| media          | Install Spotify and Peek (GIF Screen recorder)                                                                   |
| multimedia     | Install gimp, darktable and kdenlive                                                                                       |
| gnome          | Configure the desktop environment                                                                                |
| comms          | Install communication/Instant Messaging apps: signal-desktop, slack-desktop                                      |
| aur            | Install Arch User Repository libraries                                                                           |
| security       | Install clamav, clamtk, ufw, ufw-extras and gufw                                                                 |
| virtualization | Install vagrant, virtualbox and virtualbox-host-modules                                                     |

Example on how to install only browsers:
```
ansible-playbook playbook.yml --extra-vars="user_name=USERNAME user_git_name=GIT_USERNAME user_email=EMAIL" --ask-become-pass --tags browsers
```


## :rocket: Instructions to install a new Manjaro image

### 1. Creating Bootable Linux USB Drive from the Command Line

Find out the name of the USB drive
```
lsblk
```

Flash the ISO image to the USB drive
```
dd bs=4M if=/path/to/iso of=/dev/sdx status=progress oflag=sync
```

Change boot order and install Manjaro.


### 2. Install development dependencies

After installing Manjaro, run the automated setup script:

```bash
sudo pacman-mirrors -f && sudo pacman -Syyu
sudo pacman -S git --noconfirm
git clone git@github.com:PauloPortugal/manjaro-playbook.git
cd manjaro-playbook
./setup-dev-environment.sh
```

This will install all required dependencies: ansible, ansible-lint, yamllint, python-pytokens, and Ansible collections.

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

### 5. Run the playbook

Now you're ready to run the playbook:

```bash
# Validate code quality first
yamllint . && ansible-lint

# Run the playbook
ansible-playbook playbook.yml -l localhost \
  --extra-vars="user_name=USERNAME user_git_name=GIT_USERNAME user_email=EMAIL" \
  --ask-become-pass
```


## :cloud: Google Cloud Configuration

On the command line run
```
gcloud init
gcloud auth login
```

For more information about Gcloud command lines read https://cloud.google.com/sdk/gcloud


## :construction: TODO

1. It would be nice to include more audio-tools.
