
_logger() {

  local lvl_configured=$(echo "${1:-"ERROR"}" | awk '{print toupper($0)}')
  local -A levels=( ['DEBUG']="7" ['INFO']="6" ['WARN']="4" ['ERROR']="3" ['FATAL']="2")
  
  local type=$(echo "${2}" | awk '{print toupper($0)}')
  [[ ! ${!levels[@]} =~ $type ]] && echo "Invalid log" && exit 1

  shift 2

  local lvl_visible="${levels[${lvl_configured}]}"

  local lvl_used="${levels[${type}]:-3}"
  local message="[${type}] ${@}";

  if [ $lvl_visible -ge $lvl_used ] ;then
    echo -e $message
  fi

}

data_format=$(date "+%d-%m-%Y")

# More details execute 'mlab dev colors'
_colors() {
    RD=$(echo "\033[01;31m")
    GN=$(echo "\033[1;92m")
    BL=$(echo "\033[36m")
    RESET=$(echo "\033[0m")
}
