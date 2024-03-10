#!/usr/bin/env bash

DEFAULT_CONF=~/.mlab/conf.txt
DEFAULT_CACHE_CONF=~/.mlab/cache/conf.txt

declare -A targets

targets[cache]=global

get_config() {
    echo $(cat "$1" | grep "$2" | cut -d'=' -f2)
}

download() {

    local URL=$URI/$1
    local DEST_FILE=$2
    
    local HTTP_CODE=$(curl -sSLo "$DEST_FILE" -w "%{http_code}" "$URL")

    if [ ${HTTP_CODE} -eq 404 ] ; then
      rm -f "$DEST_FILE"
      echo "Url not found: $URL" && exit 1
    elif [ ${HTTP_CODE} -ne 200 ] ; then
      rm -f "$DEST_FILE"
      echo "Downloaded fail: $URL" && exit 2
    fi

}

path_caching=
key_caching=global/cache.sh
cmd_cache() {

  [ ! -f "$DEFAULT_CACHE_CONF" ] && exit 1

  CACHE_PATH=$(get_config "$DEFAULT_CACHE_CONF" "PATH")
  CANONICAL_CACHING=$(eval dirname $CACHE_PATH)/$(basename $CACHE_PATH)
  path_caching="$CANONICAL_CACHING/global/cache.sh"

  if [ ! -f $path_caching ] ; then
    
    mkdir -p $(dirname "$path_caching")
    download "$key_caching" "$path_caching"
    chmod +x "$path_caching"

  fi
  
  local KEY=$1

  cmd_cached=$(path_caching get $KEY 2> /dev/null)
  if [ $? -ne 0 ] ; then
    local FILE=$(mktemp -u)
    download "$KEY" "$FILE"
    cmd_cached=$($path_caching put "$KEY" "$FILE")
    chmod +x "$cmd_cached"
  fi

  echo $cmd_cached

}

run() {

  local KEY=$1
  local PARAMS=${@:2}

  local SOURCE=$(mktemp -u)

  if [ ! -f "$DEFAULT_CACHE_CONF" ] ; then

    # log debug "No cache"
    download "$KEY" "$SOURCE"
    chmod +x "$SOURCE"

  else

    local CMD_KEY=$(cmd_cache $KEY)
    SOURCE=$CMD_KEY

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

    # Check default configuration
    [ ! -f "$DEFAULT_CONF" ] && echo "Default configuration not found on $DEFAULT_CONF" && exit 1

    URI="$(get_config "$DEFAULT_CONF" "URI")"
    [ -z "$URI" ] && echo "Default URI not found on file $DEFAULT_CONF" && exit 1

    DEFAULT_LOG_LEVEL="$(get_config "$DEFAULT_CONF" "LOG_LEVEL")"
    export LOG_LEVEL=${DEFAULT_LOG_LEVEL:-"ERROR"}


target=mlab
if [[ ! "$1" =~ ^- && ! "$1" =~ ^-- ]] ; then
  target=$1
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

TYPE=${targets[$target]}
run $TYPE/$target.sh $@