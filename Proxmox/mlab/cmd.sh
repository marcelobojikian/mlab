#!/usr/bin/env bash

URI=https://raw.githubusercontent.com/marcelobojikian/mlab/main/Proxmox/mlab

CACHE=~/.mlab/cache

LANG=$(locale | grep LANGUAGE | cut -d= -f2 | cut -d_ -f1)

_cache() {
    
    local KEY="$1"
    for ((i=2; i<=$#; i++)); do
        KEY+="/${!i}"
    done
    
    if [ ! -f "$CACHE/$KEY" ]; then
        local TMPFILE=$(mktemp)
        local HTTP_CODE=$(curl --silent --write-out "%{http_code}" --output "$TMPFILE" "$URI/$KEY")

        if [ ${HTTP_CODE} -eq 200 ] ; then 
            mkdir -p $(dirname "$CACHE/$KEY")
            mv "$TMPFILE" "$CACHE/$KEY"
            chmod +x "$CACHE/$KEY"
        elif [ ${HTTP_CODE} -eq 404 ] ; then
            echo File not found: "$URI/$KEY"
            echo Create on folder \"mlab\" file : $KEY && exit 1
        else
            echo $(cat $TMPFILE)
        fi

    fi

}

_help() {

    _cache usage $LANG $@
    
    local KEY="usage/$LANG/${1:-mlab}"
    local USAGE_FILE="$CACHE/$KEY"

    if [ -f "$USAGE_FILE" ]; then
        $USAGE_FILE
    fi
    
}

_cmd() {

    _cache cmd $1 $2
    
    local KEY=cmd/$1/$2
    local CMD_FILE="$CACHE/$KEY"
    shift 2

    if [ -f "$CMD_FILE" ]; then
        $CMD_FILE $@
    fi

}

OPTSTRING=":hv"

case $1 in
    key-remote | first-step)
        case $2 in
            '-h')
                _help $1 
            ;;
            *)
                FILE=$1.sh
                shift 1
                _cmd vm $FILE $@
            ;;
        esac
    ;;

    *)
        while getopts ${OPTSTRING} opt; do
        case ${opt} in
            h)
                _help mlab
            ;;
            v)
                echo "Version: 1.0"
            ;;
            ?)
                echo "Invalid option: -${OPTARG}."
                echo "Try 'mlab -h' for more information."        
                exit 1
            ;;
        esac
        done
    ;;
esac

