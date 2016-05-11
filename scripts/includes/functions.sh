#!/usr/bin/env bash

function check_last_command() {
    if [[ "$?" > 0 ]]; then
        echo -e "\n>>> Last command failed. Aborting..."
        exit 1
    fi
}