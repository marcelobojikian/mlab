#!/usr/bin/env bash

key_remote() {

    local KEY_NAME=$1
    local MACHINE=$2
    local KEY_PSWD=$3

    mkdir -p private/ssh

    # Create key on ssh folder com password '$PASSWORD_SSH'
    ssh-keygen -f "private/ssh/$KEY_NAME" -N "$KEY_PSWD"
    ssh-copy-id -i "private/ssh/$KEY_NAME.pub" $MACHINE

}

_usage_key_remote() {
cat <<EOF

Usage:  mlab key-remote [KEY_FILENAME] [SSH_SERVER] [KEY_PASSWORN optional] 

Create ssh-key and send to remote server

Example: 
        
        mlab key-remote minha-chave delta@192.168.1.1 

        mlab key-remote minha-chave delta@192.168.1.1 senha_secreta

For more details, see man mlab.

EOF
}

_usage() {
cat <<EOF

Usage:  mlab [OPTIONS] COMMAND

Common Commands:
  key-remote           Create ssh-key and send to remote server

Global Options:
  -h                   Show this message
  -v                   Print version information and quit

Run 'mlab COMMAND -h' for more information on a command.
For more details, see man mlab.
EOF
}

OPTSTRING=":hv"

case $1 in
  key-remote)
    case $2 in
        '-h')
            _usage_key_remote 
        ;;
        *)
            [ -z "$2" ] && echo "Invalid option: KEY_FILENAME." && echo "Try 'mlab key-remote -h' for more information." && exit 1
            [ -z "$3" ] && echo "Invalid option: SSH_SERVER." && echo "Try 'mlab key-remote -h' for more information." && exit 1
            key_remote "$2" "$3" "$4" 
        ;;
    esac
    ;;

  *)

    while getopts ${OPTSTRING} opt; do
    case ${opt} in
        h)
            _usage
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

