#!/usr/bin/env bash

# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----

# color echo http://www.faqs.org/docs/abs/HTML/colorizing.html

default="\033[0m"
black="\033[30m"
black_inverse="\033[7;30m"
red="\033[31m"
red_bold="\033[1;31m"
red_inverse="\033[7;31m"
green="\033[32m"
green_bold="\033[1;32m"
green_inverse="\033[7;32m"
yellow="\033[33m"
yellow_bold="\033[1;33m"
yellow_inverse="\033[7;33m"
blue="\033[34m"
blue_bold="\033[1;34m"
blue_inverse="\033[7;34m"
magenta="\033[35m"
magenta_bold="\033[1;35m"
magenta_inverse="\033[7;35m"
cyan="\033[36m"
cyan_bold="\033[1;36m"
cyan_inverse="\033[7;36m"
white="\033[37m"
white_bold="\033[1;37m"
white_inverse="\033[7;37m"

# Color-echo, Argument $1 = message, Argument $2 = color, Argument $3 = no-newline?
function cecho () {
    local default_msg="No message passed."

    # Defaults to default message.
    message=${1:-$default_msg}

    # Defaults to black, if not specified.
    color=${2:-$default}

    if [[ ${3+x} ]]
    then
        echo -en "$color$message"
    else
        echo -e "$color$message"
    fi

    # Reset text attributes to normal + without clearing screen.
    tput sgr0

    return
}

# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----

# https://github.com/tlatsas/bash-spinner

function _spinner() {
    # $1 start/stop
    #
    # on start: $2 display message
    # on stop : $2 process exit status
    #           $3 spinner function pid (supplied from stop_spinner)

    local on_success="DONE"
    local on_fail="FAIL"
    local white="\e[1;37m"
    local green="\e[1;32m"
    local red="\e[1;31m"
    local nc="\e[0m"

    case $1 in
        start)
            # calculate the column where spinner and status msg will be displayed
            let column=$(tput cols)-${#2}-8
            # display message and position the cursor in $column column
            echo -ne ${2}
            printf "%${column}s"
            #echo -ne "\t"

            # start spinner
            i=1
            sp='\|/-'
            delay=${SPINNER_DELAY:-0.15}

            while :
            do
                printf "\b${sp:i++%${#sp}:1}"
                sleep $delay
            done
            ;;
        stop)
            if [[ -z ${3} ]]; then
                echo "spinner is not running.."
                exit 1
            fi

            kill $3 > /dev/null 2>&1

            # inform the user uppon success or failure
            echo -en "\b["
            if [[ $2 -eq 0 ]]; then
                echo -en "${green}${on_success}${nc}"
            else
                echo -en "${red}${on_fail}${nc}"
            fi
            echo -e "]"
            ;;
        *)
            echo "invalid argument, try {start/stop}"
            exit 1
            ;;
    esac
}

function start_spinner {
    # $1 : msg to display
    # $2 : cecho color
    _spinner "start" "${1}" $2 &
    # set global spinner pid
    _sp_pid=$!
    disown
}

function stop_spinner {
    # $1 : command exit status
    _spinner "stop" $1 $_sp_pid
    unset _sp_pid
}

# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
