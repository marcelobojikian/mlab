#!/usr/bin/env bash

URI=https://raw.githubusercontent.com/marcelobojikian/mlab/main/Proxmox/mlab

source <(curl -s $URI/env/global.func.sh)

[ -z "$1" ] && echo "Invalid option: KEY_FILENAME." && echo "Try 'mlab key-remote -h' for more information." && exit 1
[ -z "$2" ] && echo "Invalid option: SSH_SERVER." && echo "Try 'mlab key-remote -h' for more information." && exit 1

KEY_NAME=$1
MACHINE=$2
KEY_PSWD=$3

mkdir -p private/ssh

# Create key on ssh folder com password '$PASSWORD_SSH'
ssh-keygen -f "private/ssh/$KEY_NAME" -N "$KEY_PSWD"
ssh-copy-id -i "private/ssh/$KEY_NAME.pub" $MACHINE