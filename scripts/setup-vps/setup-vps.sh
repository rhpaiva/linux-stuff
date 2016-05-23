#!/usr/bin/env bash

# === vars ===
# Vars to be passed to the ssh commands. Also visible inside additional scripts.
injected_variables=""
# Additional setup files to be run in the server
setup_files="$@"

# color codes
color_fg=38
color_bg=48
color_fail=196
color_ok=22

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
    echo -e "\n>>> No Server IP provided. Aborting...\n"
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
            echo -e "\nFile ${file_path} not found"
            exit 1
        fi

        additional="${additional}\n\t- ${setup_file}"

        source "${file_path}"
    done

    echo -e "\n>>> Running additional installation for: ${additional}"
fi

# set of env variables to be passed into the ssh execution
injected_variables="
    alias echo_ok='echo -e \"\e[${color_fg};5;${color_red}m$@\"'
    alias echo_fail='echo -e \"\e[${color_fg};5;${color_blue}m$@\"'
    ${injected_variables}
    server_ip='${server_ip}'
    server_user='${server_user}'
    ssh_key='${ssh_key}'
    ssh_port='${ssh_port}'
"

#echo -e "${injected_variables} true && ${ssh_commands}"; exit 1;
echo -e "\n>>> Executing commands in server '${server_ip}'...\n"
ssh "root@${server_ip}" "${injected_variables} true && ${ssh_commands}"

check_last_command;

# we don't have root access anymore
echo -e "\n>>> Rebooting server '${server_ip}'...\n"
ssh -p "${ssh_port}" "${server_ip}" "reboot now"

echo -e "\n>>> Server '${server_ip}' configured for user '${server_user}' successfully!"
echo -e ">>> 'ssh -p ${ssh_port} ${server_ip}' to go into your server.\n"