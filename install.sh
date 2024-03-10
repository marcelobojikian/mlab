#!/usr/bin/env bash

canonical() {
  echo $(eval dirname "$1")/$(basename "$1")
}

PROJECT_ROOT=https://github.com/marcelobojikian/mlab/raw/main

COMMAND_NAME=mlab
COMMAND_CONF=$(canonical "~/.$COMMAND_NAME")

echo Instalando Home Lab library

echo Set default configuration on path $COMMAND_CONF/conf.txt
mkdir -p "$COMMAND_CONF"
cat <<EOF > $COMMAND_CONF/conf.txt
URI=$PROJECT_ROOT/src
LOG_LEVEL=ERROR
EOF

echo Download command $COMMAND_NAME from $PROJECT_ROOT

TO=/usr/local/sbin/$COMMAND_NAME
sudo curl -sSLo "$TO" --progress-bar "$PROJECT_ROOT/src/proxmox/cmd.sh" && sudo chmod +x "$TO"

echo Enable cache on path $COMMAND_CONF/cache
$COMMAND_NAME cache enable --url="$PROJECT_ROOT/src" --path="$COMMAND_CONF/cache"

echo Instalacao completa