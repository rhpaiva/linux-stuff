function check_last_command() {
    if [[ "$?" > 0 ]]; then
        echo -e "\n${fgcolor_fail}>>> Last command failed. Aborting...${color_reset}"
        exit 1
    fi
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

function append_commands() {
    ssh_commands="${ssh_commands}; $(cat ${PWD}/installations/$1/$1-commands.sh)"
}