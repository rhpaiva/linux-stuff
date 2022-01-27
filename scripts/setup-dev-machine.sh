#!/usr/bin/env bash

# =================================================================
# Steps to setup a new computer for web development based on ubuntu
# =================================================================

# vars
downloads_dir=$(echo $HOME/Downloads)

echo ">>> Download dir is: ${downloads_dir}"

# =================================================================
# Basic packages and setup
# =================================================================

function install_initial() {
    sudo apt install htop terminator git vim ca-certificates curl gnupg lsb-release gnome-tweaks net-tools whois tree jq nmap

    ssh-keygen -t rsa -b 2048
}

# =================================================================
# Docker
# =================================================================

function install_docker() {
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
   
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
   
    $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    sudo apt update
    sudo apt install docker-ce docker-ce-cli containerd.io

    # Adds user to group docker to avoid sudo
    echo ">>> Adding current user to group docker"
    sudo groupadd docker &>2 /dev/null
    sudo usermod -a -G docker $USER
    newgrp docker
    sudo service docker restart
}

# =================================================================
# init stuff
# =================================================================
        
# runs a command if it exists
if [ ! -z "$1" ]; then
        echo "Running installation for $1"
        install_$1
        exit $?
else
    echo "No specific installation provided!"
fi
