#!/usr/bin/env bash

URI=https://raw.githubusercontent.com/marcelobojikian/mlab/main/Proxmox/mlab

CACHED=false
CACHE_DIR=~/.mlab/cache
DEBUG=false
LOG_LEVEL="INFO"

cmd_vm=("key-remote" "first-step")
cmd_dev=("hi-world")
ALL_CMD=(${cmd_vm[@]} ${cmd_dev[@]})
FIRST_CMD="$1"

LANG=$(locale | grep LANGUAGE | cut -d= -f2 | cut -d_ -f1)

has_argument() {
   [[ ("$1" == *=* && -n ${1#*=}) || ( ! -z "$2" && "$2" != -*) ]];
}

extract_argument() {
  echo "${2:-${1#*=}}"
}

_global_options() {
  while [ $# -gt 0 ]; do
    case $1 in
      --cached)
        CACHED=true
        ;;
      --cache-dir)
        if ! has_argument $@; then
          echo "Path not specified." >&2
          echo "Try 'mlab -h' for more information."
          exit 1
        fi
        CACHE_DIR=$(extract_argument $@)
        shift
        ;;
      -l | --log-level)
        if ! has_argument $@; then
          echo "Log level not specified." >&2
          echo "Try 'mlab -h' for more information."
          exit 1
        fi
        LOG_LEVEL=$(extract_argument $@)
        echo "-l | --log-level"
        ;;
      -D | --debug)
        DEBUG=true
        echo "-D | --debug"
        ;;
    esac
    shift
  done
}

_mlab_options() {

  if [ $# -eq 0 ] ; then
    _help mlab && exit 1
  fi

  local go_next=false

  while [ $# -gt 0 ]; do
    case $1 in
      -h | --help)
        if [[ ${ALL_CMD[@]} =~ $FIRST_CMD ]] ;then
          _help $FIRST_CMD && exit 0
        fi
        _help mlab && exit 0
        ;;
      -v | --version)
        echo "Version: 1.0"
        exit 0
        ;;
      rm-cache)
        rm -R $CACHE_DIR
        echo "Cache removed"
        exit 0
        ;;
    esac
    if [[ "$go_next" = false && ${ALL_CMD[@]} =~ $1 ]] ;then
      go_next=true
    fi
    shift
  done
  
  if [ "$go_next" = false ] ;then
    echo "Invalid option: $FIRST_CMD"
    echo "Try 'mlab -h' for more information."        
    exit 1
  fi

}

_download() {

    local URL=$1
    local DEST_FILE=$2
    
    local HTTP_CODE=$(curl --silent --write-out "%{http_code}" --output "$DEST_FILE" "$URL")

    if [ ${HTTP_CODE} -eq 200 ] ; then
      return 0
    elif [ ${HTTP_CODE} -eq 404 ] ; then
      return 1
    else
      return 2
    fi

}

_cache() {

  local FROM="$1"
  local TO="$2"

  mkdir -p $(dirname "$TO")
  mv "$FROM" "$TO"

}

_run() {

  local KEY=$1
  local PARAMS=$2
  local URL="$URI/$KEY"
  local CODE=0

  # Download
  local SOURCE="$CACHE_DIR/$KEY"    
  if [ "$CACHED" = false ]; then
    echo "[DEBUG] - no cache"
    SOURCE=$(mktemp)
    _download "$URL" "$SOURCE"
    CODE=$?
  else
    echo "[DEBUG] - cached"
    if [ ! -f "$SOURCE" ]; then
      echo "[DEBUG] - $KEY not cached yet"
      SOURCE=$(mktemp)
      _download "$URL" "$SOURCE"
      CODE=$?
    fi
  fi

  # Check download  
  if [ ${CODE} -eq 0 ] ; then
    if [ "$CACHED" = false ]; then
      echo "[DEBUG] - $KEY downloaded"
      chmod +x "$SOURCE"
    else
      if [ ! -f "$CACHE_DIR/$KEY" ]; then
        echo "[DEBUG] - Caching $KEY on "$CACHE_DIR/$KEY""
        _cache "$SOURCE" "$CACHE_DIR/$KEY"
        chmod +x "$CACHE_DIR/$KEY"
        SOURCE="$CACHE_DIR/$KEY"
      fi
    fi
    $SOURCE $PARAMS
  elif [ ${CODE} -eq 1 ] ; then
    echo "[DEBUG] - File not found: $URL"
    echo "[ERROR] - Create on folder \"mlab\" file : $KEY" && exit 1
  else
    echo "[DEBUG] - $KEY downloaded fail, error"
    echo "[ERROR] - File error: $(cat $SOURCE)" && exit 1
  fi

}

_help() {
    local KEY="usage/$LANG/${1:-mlab}"
    _run $KEY
}

_dev() {
    local KEY="dev/${1:-"hello-world"}.sh"
    echo _run $KEY
}

CMD=""
PARAMETER=""
_command() {

  local value="\<${1}\>"

  if [[ ! ${ALL_CMD[@]} =~ $FIRST_CMD ]] ;then
    CMD="mlab"
    echo "value not found"
  else
    shift

    [[ ${cmd_vm[@]} =~ $value ]] && CMD="cmd/vm"
    [[ ${cmd_dev[@]} =~ $value ]] && CMD="cmd/dev"
    
    echo "value $CMD found"
    CMD="$CMD/$FIRST_CMD.sh"

  fi
  PARAMETER="$@"

}

_global_options $@
_mlab_options $@

_command $@

_run "$CMD" "$PARAMETER"

#_cmd vm $FILE $@
if [ "$CACHED" = true ]; then
 echo "Cache mode enabled."
 echo "Cache dir specified: $CACHE"
fi

