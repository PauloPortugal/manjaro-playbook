#!/bin/bash

set -x

# Only install if package does not exist
if [ -z "$(pacman -Q | grep ${1})" ]; then
  # Download Arch linux AUR package
  wget https://aur.archlinux.org/cgit/aur.git/snapshot/${1}.tar.gz -P /tmp/${1}

  # Extract package
  tar -xvzf /tmp/${1}/${1}.tar.gz -C /tmp/${1}/

  # Create install package
  cd /tmp/${1}/${1}
  makepkg -s --skippgpcheck

  # Install package
  sudo pacman -U *xz --noconfirm

  # Remove temporary folder
  rm -rf /tmp/${1}
else
  exit -1;
fi
