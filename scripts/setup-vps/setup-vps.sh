#!/usr/bin/env bash

# === vars ===
# Vars to be passed to the ssh commands. Also visible inside additional scripts.
injected_variables=""
# Additional setup files to be run in the server
setup_files="$@"

# color codes
color_fg=38
color_bg=48
color_reset="\e[0m"
fgcolor_fail="\e[${color_fg};5;88m"
fgcolor_ok="\e[${color_fg};5;18m"
bgcolor_fail="\e[${color_bg};5;88m"
bgcolor_ok="\e[${color_bg};5;18m"

# === includes ===
source ../includes/functions.sh

cat << BANNER

=== New Droplet Setup for Digital Ocean ===
Author: Rodrigo Paiva - rhpaiva@gmail.com

BANNER

# gather user information
read -p "Username to add (default '${USER}'): " server_user

if [[ -z ${server_user} ]]; then
    server_user="${USER}"
fi

read -p "Server IP: " server_ip

if [[ -z "${server_ip}" ]]; then
    echo -e "\n${bgcolor_fail}>>> No Server IP provided. Aborting...${color_reset}\n"
    exit 1
fi

read -p "SSH Port (default '666'): " ssh_port

if [[ -z "${ssh_port}" ]]; then
    ssh_port="666"
fi

ssh_key=$(cat "${HOME}/.ssh/id_rsa.pub")
ssh_commands="$(cat installations/base/base-commands.sh)"

# include other setups
if [[ ! -z "${setup_files}" ]]; then
    additional=""

    for setup_file in ${setup_files}; do
        file_path="${PWD}/installations/${setup_file}/${setup_file}-setup.sh"

        if [[ ! -f "${file_path}" ]]; then
            echo -e "\n${bgcolor_fail}File ${file_path} not found${color_reset}"
            exit 1
        fi

        additional="${additional}\n\t- ${setup_file}"

        source "${file_path}"
    done

    echo -e "\n${bgcolor_ok}>>> Running additional installation for: ${color_reset}${additional}"
fi

# set of env variables to be passed into the ssh execution
injected_variables="
    color_reset='${color_reset}'
    bgcolor_fail='${bgcolor_fail}'
    fgcolor_fail='${fgcolor_fail}'
    bgcolor_ok='${bgcolor_ok}'
    fgcolor_ok='${fgcolor_ok}'
    ${injected_variables}
    server_ip='${server_ip}'
    server_user='${server_user}'
    ssh_key='${ssh_key}'
    ssh_port='${ssh_port}'
    timezone='Europe/Berlin'
"

#echo -e "${injected_variables} true && ${ssh_commands}"; exit 1;
echo -e "\n${bgcolor_ok}>>> Executing commands in server '${server_ip}'...${color_reset}\n";
ssh "root@${server_ip}" "${injected_variables} true && ${ssh_commands}"

check_last_command;

echo -e "\n${bgcolor_ok}>>> Server '${server_ip}' configured for user '${server_user}' successfully!"
echo -e ">>> 'ssh -p ${ssh_port} ${server_ip}' to go into your server.${color_reset}\n"