#!/usr/bin/env bash

URI=https://raw.githubusercontent.com/marcelobojikian/mlab/main/Proxmox/mlab

source <(curl -s $URI/env/global.func.sh)

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