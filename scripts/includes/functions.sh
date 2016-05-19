#!/usr/bin/env bash

function check_last_command() {
    if [[ "$?" > 0 ]]; then
        echo -e "\n>>> Last command failed. Aborting..."
        exit 1
    fi

    exit 0
}

function confirm() {
    local question="$1"

    read -p "${question}" last_answer

    if [[ "${last_answer}" == "y" ]]  ||  [[ "${last_answer}" == "Y" ]]; then
        last_answer=true
    else
        last_answer=false
    fi
}