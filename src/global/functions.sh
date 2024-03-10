
command_key(){

  targets=()
  targets[cache]=global
  targets[first-installer]=proxmox

  echo "${targets[$1]}/$1.sh"
}

log() {
  
  local severity=$(echo "${1}" | awk '{print toupper($0)}')
  shift

  local -A levels=( ['DEBUG']="7" ['INFO']="6" ['WARN']="4" ['ERROR']="3" ['FATAL']="2")
  [[ ! ${!levels[@]} =~ $severity ]] && echo "Invalid log" && exit 1

  local LEVEL=$(echo "${LOG_LEVEL:-"ERROR"}" | awk '{print toupper($0)}')
  local LOG="${levels[${LEVEL}]}"

  local lvl_msg="${levels[${severity}]:-3}"
  local msg="[${severity}] ${@}";

  [ $LOG -ge $lvl_msg ] && echo -e $msg

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

DEFAULT_CACHE_CONF=~/.mlab/cache/conf.txt
path_caching=
key_caching=global/cache.sh
cmd_cache() {

  [ ! -f "$DEFAULT_CACHE_CONF" ] && exit 1

  CACHE_PATH=$(get_config "$DEFAULT_CACHE_CONF" "PATH")
  CANONICAL_CACHING=$(eval dirname $CACHE_PATH)/$(basename $CACHE_PATH)
  path_caching="$CANONICAL_CACHING/global/cache.sh"

  if [ ! -f $path_caching ] ; then

    local KEY_CACHE="$(command_key cache)"
    
    mkdir -p $(dirname "$path_caching")
    download "$key_caching" "$path_caching"
    chmod +x "$path_caching"

  fi
  
  local KEY=$1

  cmd_cached=$($path_caching get $KEY 2> /dev/null)
  if [ $? -ne 0 ] ; then
    local FILE=$(mktemp -u)
    download "$KEY" "$FILE"
    cmd_cached=$($path_caching put "$KEY" "$FILE")
    chmod +x "$cmd_cached"
  fi

  echo $cmd_cached

}
