#!/usr/bin/env bash

# TODO:
# Docker (engine and compose)
# https://easyengine.io/tutorials/nginx/fail2ban/

# === includes ===
source includes/functions.sh

cat << BANNER

=== New Droplet Setup for Digital Ocean ===
Author: Rodrigo Paiva - rhpaiva@gmail.com

BANNER

read -p "Username to add (default '${USER}'): " server_user

if [[ -z ${server_user} ]]; then
    server_user="${USER}"
fi

read -p "Server IP: " server_ip

if [[ -z ${server_ip} ]]; then
    echo -e "\n>>> No Server IP provided. Aborting...\n"
    exit 1
fi

# === Gather server info ===
read -p "Is this server a public web server (Nginx, for example)? [y/n]: " is_web_server
if [[ "${is_web_server}" == "y" ]]  ||  [[ "${is_web_server}" == "Y" ]]; then
    is_web_server=true
else
    is_web_server=false
fi

echo -e "\n>>> Initiating configuration for server '${server_ip}'\n"

ssh_key=$(cat "${HOME}/.ssh/id_rsa.pub")
commands_file="$(cat vps-commands/commands.sh)"

# set of env variables to be passed into the ssh execution
injected_variables="
    is_web_server=${is_web_server};
    server_user='${server_user}';
    ssh_key='${ssh_key}';
"

ssh root@${server_ip} "${injected_variables} true && ${commands_file}"

check_last_command;

echo -e "\n>>> Server '${server_ip}' configured for user '${server_user}' successfully!"
echo -e ">>> 'ssh -p 666 ${server_ip}' to go into your server."