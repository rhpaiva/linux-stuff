#!/usr/bin/env bash

# TODO:
# Firewall, fail2ban
# https://easyengine.io/tutorials/nginx/fail2ban/

# === includes ===
source includes/functions.sh

# === variables ===
ssh_key=$(cat "${HOME}/.ssh/id_rsa.pub")

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
    echo -e ">>> No Server IP provided. Aborting...\n"
    exit 1
fi

echo -e "\n>>> Initiating configuration for server '${server_ip}'\n"

ssh root@${server_ip} \
    "
    locale-gen en_US en_US.UTF-8 de_DE de_DE.UTF-8 \
    && echo -e 'LANG=\"en_US.UTF-8\"\nLANGUAGE=\"en_US:en\"\n' > /etc/default/locale \
    && echo '' \
    && echo '>>> Generating new user '${server_user}' in server...' \
    && adduser --disabled-password --gecos '' ${server_user} \
    && usermod --append --groups sudo ${server_user} \
    && echo '' \
    && echo '>>> Copying your public key to server...' \
    && mkdir --parents /home/${server_user}/.ssh \
    && echo '${ssh_key}' >> /home/${server_user}/.ssh/authorized_keys \
    && echo '' \
    && echo '>>> Tweaking SSH config to make it safer...' \
    && sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config \
    && sed -i 's/PubkeyAuthentication no/PubkeyAuthentication yes/g' /etc/ssh/sshd_config \
    && sed -i 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config \
    && sed -i 's/ClientAliveInterval 120/ClientAliveInterval 300/g' /etc/ssh/sshd_config \
    && sed -i 's/LoginGraceTime 120/LoginGraceTime 30/g' /etc/ssh/sshd_config \
    && sed -i 's/Port 22/Port 666/g' /etc/ssh/sshd_config \
    && systemctl reload sshd
    "

check_last_command;

echo -e "\n>>> Server '${server_ip}' configured for user '${server_user}' successfully!"
echo -e ">>> 'ssh -p 666 ${server_ip}' to go into your server."