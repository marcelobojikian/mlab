#!/usr/bin/env bash

DEFAULT_CONF=~/.mlab/conf.txt
DEFAULT_CACHE_CONF=~/.mlab/cache/conf.txt

[ ! -f "$DEFAULT_CONF" ] && echo "Default configuration not found on $DEFAULT_CONF" && exit 1

export LOG_LEVEL=
URI=

get_config() {
  local var=$(cat "$1" | grep "$2")
  [[ $var = *"="* ]] && echo $(echo $var | cut -d'=' -f2)
}

_setup() {

  URI="$(get_config "$DEFAULT_CONF" "URI")"
  [ -z "$URI" ] && echo "Default URI not found on file $DEFAULT_CONF" && exit 1

  DEFAULT_LOG_LEVEL="$(get_config "$DEFAULT_CONF" "LOG_LEVEL")"
  LOG_LEVEL=${DEFAULT_LOG_LEVEL:-"ERROR"}

}

_functions() {

  local FUNCTIONS_KEY="global/functions.sh"
  local FUNCTIONS_FILE="$(get_config "$DEFAULT_CONF" "FUNCTIONS")"

  if [ -z $FUNCTIONS_FILE ] ; then
    source <(curl -sSL "$URI/$FUNCTIONS_KEY")
  else
    if [ ! -f $FUNCTIONS_FILE ] ; then
      curl -sSLo "$FUNCTIONS_FILE" "$URI/$FUNCTIONS_KEY"
    fi
    mkdir -p $(dirname "$FUNCTIONS_FILE")
    source "$FUNCTIONS_FILE"
  fi

}

run() {

  local KEY=$1
  local PARAMS=${@:2}

  local SOURCE=$(mktemp -u)
  if [ -f "$DEFAULT_CACHE_CONF" ] ; then
    SOURCE=$(cmd_cache $KEY)
  else
    download "$KEY" "$SOURCE"
    chmod +x "$SOURCE"
  fi

  $SOURCE $PARAMS
  
}

_usage() {
  local LANG=$(locale | grep LANGUAGE | cut -d= -f2 | cut -d_ -f1)
  run "usage/$LANG/${1:-mlab}" $@
}

_version() {
    echo "Version: 1.0"
}

_setup
_functions

target=mlab
target_key="usage/en/mlab"
if [[ ! "$1" =~ ^- && ! "$1" =~ ^-- ]] ; then
  target=$1
  target_key=$(command_key $target)
  shift
fi

[ $# = 0 ] && _usage $target && exit 0

while getopts ':vh-l:' OPTION ; do
    case "$OPTION" in
    h ) _usage $target && exit 0 ;;
    v ) _version && exit 0 ;;
    l ) LOG_LEVEL="$OPTARG" ;;
    - ) [ $OPTIND -ge 1 ] && optind=$(expr $OPTIND - 1 ) || optind=$OPTIND
         eval OPTION="\$$optind"
         OPTARG=$(echo $OPTION | cut -d'=' -f2)
         OPTION=$(echo $OPTION | cut -d'=' -f1)
         case $OPTION in
            --help) _usage $target && exit 0 ;;
            --version) _version && exit 0 ;;
            --log-level) LOG_LEVEL="$OPTARG" ;;
            * ) echo -e "Invalid option: $OPTARG \r\nTry 'mlab -h' for more information." && exit 1 ;;
         esac
       OPTIND=1
       shift
      ;;
    ? ) echo -e "Invalid option: $OPTARG \r\nTry 'mlab -h' for more information." && exit 1 ;;
    esac
done

run $target_key $@