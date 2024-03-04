#!/usr/bin/env bash

echo Instalando Home Lab lib

URI=https://raw.githubusercontent.com/marcelobojikian/mlab/main/Proxmox/mlab
TO=/usr/local/sbin/mlab

sudo wget "$URI/cmd.sh" -O "$TO" && sudo chmod +x "$TO"

echo Instalacao completa