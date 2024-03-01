#!/usr/bin/env bash

data_format=$(date "+%d-%m-%Y")

first_step() {

    echo [INFO] Updanting system

    sudo apt update && sudo apt upgrade -y


    echo [INFO] Install QEmu Agent
    # Comando que habilita a interacao da interface do Proxmox 
    sudo apt install qemu-guest-agent -y


    echo [INFO] Add Docker\'s official GPG key  
    # Add Docker's official GPG key:
    sudo apt-get install ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    echo [INFO] Add docker repository to Apt sources
    # Add the repository to Apt sources:
    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    sudo apt-get update

    echo [INFO] Install docker
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

    echo [INFO] Post installer docker
    sudo groupadd docker
    sudo usermod -aG docker $USER
    sudo systemctl enable docker.service
    sudo systemctl enable containerd.service

    echo [INFO] Create docker compose file with VScode
    cat <<EOF >~/docker-compose.yaml
---
version: "3.8"

volumes:
    ansible:

services:

    vscode:
        image: lscr.io/linuxserver/code-server:latest
        ports:
        - 8443:8443
        volumes:
        - ansible:/home/ansible:rw
        environment:
        - PUID=0
        - PGID=0
        - PASSWORD=password
        - TZ=Europe/Dublin
        - DEFAULT_WORKSPACE=/home

EOF

    echo [INFO] Run VSCode
    docker compose up -d

    echo [INFO] Install ansible
    docker compose exec vscode apt update
    docker compose exec vscode apt install software-properties-common -y
    docker compose exec vscode add-apt-repository --yes --update ppa:ansible/ansible
    docker compose exec vscode apt install ansible -y

    echo [INFO] First step complete
    echo [INFO] VScode: http://$(hostname -I | awk '{ print $1 }'):8443
    echo [INFO] run: sudo reboot
    echo [INFO] After reboot the qemu-guest-agent start working

}

key_remote() {

    local KEY_NAME=$1
    local MACHINE=$2
    local KEY_PSWD=$3

    mkdir -p private/ssh

    # Create key on ssh folder com password '$PASSWORD_SSH'
    ssh-keygen -f "private/ssh/$KEY_NAME" -N "$KEY_PSWD"
    ssh-copy-id -i "private/ssh/$KEY_NAME.pub" $MACHINE

}

_usage_key_remote() {
cat <<EOF

Usage:  mlab key-remote [KEY_FILENAME] [SSH_SERVER] [KEY_PASSWORN optional] 

Create ssh-key and send to remote server

Example: 
        
        mlab key-remote minha-chave delta@192.168.1.1 

        mlab key-remote minha-chave delta@192.168.1.1 senha_secreta

For more details, see man mlab.

EOF
}

_usage() {
cat <<EOF

Usage:  mlab [OPTIONS] COMMAND

Common Commands:
  key-remote           Create ssh-key and send to remote server
  first-step           Install VSCode using docker and aneble ansible to use

Global Options:
  -h                   Show this message
  -v                   Print version information and quit

Run 'mlab COMMAND -h' for more information on a command.
For more details, see man mlab.
EOF
}

OPTSTRING=":hv"

case $1 in
  key-remote)
    case $2 in
        '-h')
            _usage_key_remote 
        ;;
        *)
            [ -z "$2" ] && echo "Invalid option: KEY_FILENAME." && echo "Try 'mlab key-remote -h' for more information." && exit 1
            [ -z "$3" ] && echo "Invalid option: SSH_SERVER." && echo "Try 'mlab key-remote -h' for more information." && exit 1
            key_remote "$2" "$3" "$4" 
        ;;
    esac
    ;;
    
  first-step)
    first_step
    ;;  

  *)

    while getopts ${OPTSTRING} opt; do
    case ${opt} in
        h)
            _usage
        ;;
        v)
            echo "Version: 1.0"
        ;;
        ?)
            echo "Invalid option: -${OPTARG}."
            echo "Try 'mlab -h' for more information."        
            exit 1
        ;;
    esac
    done

    ;;
esac

