#!/bin/sh

# check the number of parameters is correct
if [ "$#" -ne 2 ]; then
    echo "Incorrect number of parameters"
    echo "Usage: ./ansible.sh [user_name] [email]"
    exit 1;
fi

# install required ansible galaxy roles
ansible-galaxy install -r requirements.yml

# install/update software stack
ansible-playbook playbook.yml --extra-vars="user_name=$1 user_email=$2" --ask-become-pass
