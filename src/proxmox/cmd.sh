#!/usr/bin/env bash
# https://opensource.com/article/20/6/bash-trap
# https://github.com/lehmannro/assert.sh/blob/master/assert.sh

export LOG_LEVEL=ERROR

FILE_CONF=~/.mlab/conf.txt
CACHE_FILE=~/.mlab/cache/conf.txt

if [[ ! -e "$FILE_CONF" ]]; then
    mkdir -p $(dirname "$FILE_CONF")
    cat <<EOF > $FILE_CONF
URI=https://raw.githubusercontent.com/marcelobojikian/mlab/main/Proxmox/mlab
EOF
fi

get_config() {
    echo $(cat "$1" | grep "$2" | cut -d'=' -f2)
}

URI="$(get_config "$FILE_CONF" "URI")"

download() {

    local URL=$URI/$1
    local DEST_FILE=$2
    
    local HTTP_CODE=$(curl --silent --write-out "%{http_code}" --output "$DEST_FILE" "$URL")

    if [ ${HTTP_CODE} -eq 404 ] ; then
      rm -f "$DEST_FILE"
      echo "Url not found: $URL" && exit 1
    elif [ ${HTTP_CODE} -ne 200 ] ; then
      rm -f "$DEST_FILE"
      echo "Downloaded fail: $URL" && exit 2
    fi

}

configure_cache() {
  
  local CACHE_KEY=$1

  # log debug "load cache configuration"
  local CMD_CACHE="$(get_config "$CACHE_FILE" "PATH")/$CACHE_KEY"

  if [ ! -f "$CMD_CACHE" ] ; then
    # log debug "Download command cache"
    mkdir -p $(dirname "$CMD_CACHE")
    download "$CACHE_KEY" "$CMD_CACHE"
    chmod +x "$CMD_CACHE"
  fi

}

run() {

  local KEY=$1
  local PARAMS=$2

  local SOURCE=$(mktemp -u)

  if [ -z "$CACHE_FILE" ] ; then

    # log debug "No cache"
    download "$KEY" "$SOURCE"
    chmod +x "$SOURCE"

  else

    CACHE_KEY=global/cache.sh
    configure_cache "$CACHE_KEY"

    CMD_CACHE="$(get_config "$CACHE_FILE" "PATH")/$CACHE_KEY"

    result=$($CMD_CACHE get $KEY)
    if [ $? -ne 0 ] ; then
      # log debug "Not cached yet"
      download "$KEY" "$SOURCE"
      # log debug "Cache key \"$KEY\" on \"$SOURCE\" "
      $CMD_CACHE put "$KEY" "$SOURCE"
      chmod +x "$SOURCE"
    fi

    SOURCE=$result

  fi

  # log debug "Running cmd $SOURCE $PARAMS"
  $SOURCE $PARAMS
  
}

_usage() {
  echo "Usage: mlab [OPTIONS] COMMAND"
  # local LANG=$(locale | grep LANGUAGE | cut -d= -f2 | cut -d_ -f1)
  # run "usage/$LANG/${1:-mlab}"
}

_version() {
    echo "Version: 1.0"
}

target=mlab
PARAMETERS=("${@:1}")
if [[ ! "$1" =~ ^- && ! "$1" =~ ^-- ]] ; then
  target=$1
  PARAMETERS=("${@:2}")
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

echo run $target $PARAMETERS