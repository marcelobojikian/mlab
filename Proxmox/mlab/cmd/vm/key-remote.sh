#!/usr/bin/env bash

[ -z "$1" ] && echo "Invalid option: KEY_FILENAME." && echo "Try 'mlab key-remote -h' for more information." && exit 1
[ -z "$2" ] && echo "Invalid option: SSH_SERVER." && echo "Try 'mlab key-remote -h' for more information." && exit 1

local KEY_NAME=$1
local MACHINE=$2
local KEY_PSWD=$3

echo mkdir -p private/ssh

# Create key on ssh folder com password '$PASSWORD_SSH'
echo ssh-keygen -f "private/ssh/$KEY_NAME" -N "$KEY_PSWD"
echo ssh-copy-id -i "private/ssh/$KEY_NAME.pub" $MACHINE