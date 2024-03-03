#!/usr/bin/env bash

URI=https://raw.githubusercontent.com/marcelobojikian/mlab/main/Proxmox/mlab

URI_CMD=$URI/cmd
URI_USAGE=$URI/usage

_usage() {
    
    local KEY="${1:-mlab}"
    local LANG=$(locale | grep LANGUAGE | cut -d= -f2 | cut -d_ -f1)

    local OUTPUT_FILE=$(mktemp)
    local HTTP_CODE=$(curl --silent --output $OUTPUT_FILE --write-out "%{http_code}" $URI_USAGE/$LANG/$KEY)
    
    if [ ${HTTP_CODE} -eq 404 ] ; then 
        echo "usage not exist '$LANG/$KEY'" && exit 1
    else
        cat "$OUTPUT_FILE"
    fi
    
}

_cmd() {
    
    local COMMAND=$URI_CMD/$1/$2
    shift 2

    local OUTPUT_FILE=$(mktemp)
    local HTTP_CODE=$(curl --silent --output $OUTPUT_FILE --write-out "%{http_code}" $COMMAND.sh)

    if [ ${HTTP_CODE} -eq 404 ] ; then 
        echo "command not exist '$TYPE/$CMD'" && exit 1
    else
        sudo chmod +x "$OUTPUT_FILE"
        $OUTPUT_FILE $@
    fi

}

OPTSTRING=":hv"

case $1 in
    key-remote | first-step)
        case $2 in
            '-h')
                _usage $1 
            ;;
            *)
                echo _cmd vm $@
                _cmd vm $@
            ;;
        esac
    ;;

    *)
        while getopts ${OPTSTRING} opt; do
        case ${opt} in
            h)
                _usage mlab
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

