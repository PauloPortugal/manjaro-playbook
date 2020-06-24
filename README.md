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

| Tag       | Description                                                                                                      |
|-----------|------------------------------------------------------------------------------------------------------------------|
| base      | Install Linux util libraries, python-pip, xinput, terminator, snap and zsh                                       |
| users     | Setup user accounts                                                                                              |
| printers  | Install printer drivers                                                                                          |
| browsers  | Install Chrome and chromedriver                                                                                  |
| dev-tools | Install jq, xq, docker, docker-compose, go, nodejs, npm, nvm, jre8, jre10, maven, clojure, leiningen, sbt, scala, kubernetes, bluemix-cli, hub and heroku  |
| editors   | Install vim, atom, emacs, gimp, Intellij and Microsoft Visual Studio                                             |
| media     | Install Spotify and Peek (GIF Screen recorder)                                                                   |
| gnome     | Configure the desktop environment                                                                                |
| comms     | Install communication/Instant Messaging apps: signal-desktop, slack-desktop                                      |
| aur       | Install Arch User Repository libraries                                                                           |
| security  | Install clamav, clamtk, ufw, ufw-extras and gufw                                                                 |

Example on how to install only browsers:
```
ansible-playbook playbook.yml --extra-vars="user_name=USERNAME user_email=EMAIL" --ask-become-pass --tags browsers
```

## TODO

Bluemix setup:
 * enable zsh completion, add the following line in "~/.zshrc":
   . /usr/local/ibmcloud/autocomplete/zsh_autocomplete
 * IBM Cloud CLI automatically collects data for usage analysis and user experience improvement. To disable the collecting, run "ibmcloud config --usage-stats-collect false"
 * IBM Cloud CLI has a plug-in framework to extend its capability. To install the recommended plug-ins and dependencies, run the install script from http://ibm.biz/install-idt. For additional plug-in details, see https://console.bluemix.net/docs/cli/reference/bluemix_cli/extend_cli.html.
 * Install the container-registry ibmcloud plugin install container-registry -r Bluemix
   Use 'ibmcloud plugin show container-registry' to show its details.
 * Install the kubernetes CLI tool (ibmcloud ks) : ibmcloud plugin install container-service
