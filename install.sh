#!/usr/bin/env bash

canonical() {
  echo $(eval dirname "$1")/$(basename "$1")
}

PROJECT_ROOT=https://github.com/marcelobojikian/mlab/raw/main

COMMAND_NAME=mlab
COMMAND_PATH_CONF=$(canonical "~/.$COMMAND_NAME")

echo Instalando Home Lab library

echo Config Path: "$COMMAND_PATH_CONF"
mkdir -p "$COMMAND_PATH_CONF"

echo Set default configuration on path $COMMAND_PATH_CONF/conf.txt
cat <<EOF > $COMMAND_PATH_CONF/conf.txt
URI=$PROJECT_ROOT/src
FUNCTIONS=$COMMAND_PATH_CONF/global/functions.sh
LOG_LEVEL=ERROR
EOF

echo Download command $COMMAND_NAME from $PROJECT_ROOT

TO=/usr/local/sbin/$COMMAND_NAME
sudo curl -sSLo "$TO" --progress-bar "$PROJECT_ROOT/src/proxmox/cmd.sh" && sudo chmod +x "$TO"

echo Enable cache on path $COMMAND_PATH_CONF/cache
$COMMAND_NAME cache enable --url="$PROJECT_ROOT/src" --path="$COMMAND_PATH_CONF/cache"

echo Instalacao completa