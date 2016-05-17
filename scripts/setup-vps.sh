#!/usr/bin/env bash

DOCKER_COMPOSE_VERSION='1.7.1'

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

if [[ -z "${server_ip}" ]]; then
    echo -e "\n>>> No Server IP provided. Aborting...\n"
    exit 1
fi

ssh_key=$(cat "${HOME}/.ssh/id_rsa.pub")
ssh_commands="$(cat setup-vps-commands/basic-setup.sh)"

# Gather server info
confirm "Is this server a public web server (Nginx, for example)? [y/n]: "
is_web_server=${last_answer}

confirm "Install Docker Engine and Docker Compose? [y/n]: "
install_docker=${last_answer}

if [[ "$install_docker" == true ]]; then
    ssh_commands="${ssh_commands}; $(cat setup-vps-commands/docker-setup.sh)"

    read -p "Docker Compose Version (default '${DOCKER_COMPOSE_VERSION}'): " compose_version
    test ! -z "${compose_version}" && DOCKER_COMPOSE_VERSION="${compose_version}"
fi

# set of env variables to be passed into the ssh execution
injected_variables="
    is_web_server=${is_web_server};
    server_ip='${server_ip}';
    server_user='${server_user}';
    ssh_key='${ssh_key}';
    docker_compose_version='${DOCKER_COMPOSE_VERSION}';
"

#echo -e "${injected_variables} true && ${ssh_commands}"; exit 1;
echo -e "\n>>> Executing commands in server '${server_ip}'...\n"
ssh root@${server_ip} "${injected_variables} true && ${ssh_commands}"

check_last_command;

echo -e "\n>>> Server '${server_ip}' configured for user '${server_user}' successfully!"
echo -e ">>> 'ssh -p 666 ${server_ip}' to go into your server.\n"