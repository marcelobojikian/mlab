#!/usr/bin/env bash

canonical() {
  echo $(eval dirname "$1")/$(basename "$1")
}

CACHE_DIR_CONF=$(canonical ~/.mlab/cache)
CACHE_FILE_CONF=$CACHE_DIR_CONF/conf.txt

CACHE_PATH=$CACHE_DIR_CONF
CACHE_URL=none

[[ -z "$1" || "$1" =~ ^- || "$1" =~ ^-- ]] && echo "No command or option." && echo "Try 'mlab cache -h' for more information." && exit 1

target=$1
shift

[ "$target" != "enable" ] && [ ! -d "$CACHE_DIR_CONF" ] && echo "Enable cache first." && echo "Try 'mlab cache -h' for more information." && exit 1

while getopts ':-:' OPTION ; do
    case "$OPTION" in
    - ) [ $OPTIND -ge 1 ] && optind=$(expr $OPTIND - 1 ) || optind=$OPTIND
         eval OPTION="\$$optind"
         OPTARG=$(echo $OPTION | cut -d'=' -f2)
         OPTION=$(echo $OPTION | cut -d'=' -f1)
         case $OPTION in
            --path) CACHE_PATH="$OPTARG" ;;
            --url) CACHE_URL="$OPTARG" ;;
            * ) echo -e "Invalid option: $OPTARG \r\nTry 'mlab cache -h' for more information." && exit 1 ;;
         esac
       OPTIND=1
       shift
      ;;
    ? ) echo -e "Invalid option: $OPTARG \r\nTry 'mlab cache -h' for more information." && exit 1 ;;
    esac
done

get_config() {
  local path=$(cat "$CACHE_FILE_CONF" | grep "$1" | cut -d'=' -f2)
  echo $(canonical "$path")
}

set_config() {
    cat <<EOF > $1
PATH=$CACHE_PATH
URL=$CACHE_URL
EOF
}

request_one_param() {
  [ -z "$1" ] && echo "One o more paramaters failed." && echo "Try 'mlab cache -h' for more information." && exit 1
}

required_two_param() {
  [ -z "$1" ] || [ -z "$2" ] && echo "One o more paramaters failed." && echo "Try 'mlab cache -h' for more information." && exit 1
}

case $target in
  "enable")

    [ "$CACHE_URL" == "none" ] && echo "No url option." && echo "Try 'mlab cache -h' for more information." && exit 1
    
    mkdir -p "$CACHE_DIR_CONF"
    set_config "$CACHE_FILE_CONF"
    mkdir -p "$CACHE_PATH"
  ;;
  "delete")
    if [ -f "$CACHE_FILE_CONF" ]; then
        PATH_DIR=$(get_config PATH)
        [ "$PATH_DIR" != "$CACHE_DIR_CONF" ] && rm -r $PATH_DIR        
        rm -r $CACHE_DIR_CONF
    fi
  ;;
  "get")
    request_one_param $@
    PATH_DIR=$(get_config PATH)
    KEY="$PATH_DIR/$1"
    [ ! -f "$KEY" ] && echo "Cache not found: $KEY" && exit 1
    echo $KEY
  ;;
  "put")
    required_two_param $@
    PATH_DIR=$(get_config PATH)
    KEY="$PATH_DIR/$1"
    FILE="$2"
    [ ! -f "$FILE" ] && echo "File not found: $KEY" && exit 1
    mkdir -p $(dirname "$KEY")
    mv "$FILE" "$KEY"
    echo $KEY
  ;;
  *)
    echo "Invalid command: $target" && echo "Try 'mlab cache -h' for more information." && exit 1
  ;;
esac