
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

data_format=$(date "+%d-%m-%Y")

# More details execute 'mlab dev colors'
_colors() {
    RD=$(echo "\033[01;31m")
    GN=$(echo "\033[1;92m")
    BL=$(echo "\033[36m")
    RESET=$(echo "\033[0m")
}
