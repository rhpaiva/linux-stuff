function config_web_server() {
    ufw allow 80/tcp
}

# === Locale generation ===
locale-gen en_US en_US.UTF-8 de_DE de_DE.UTF-8 \
&& echo -e 'LANG="en_US.UTF-8"\nLANGUAGE="en_US:en"\n' > /etc/default/locale

# === APT Stuff ===
apt-get update \
&& apt-get --assume-yes install ntp fail2ban \

# === User creation ===
echo -e "\n>>> Generating new user '${server_user}' in server..." \
&& adduser --gecos '' ${server_user} \
&& usermod --append --groups sudo ${server_user}

# === SSH Credentials ===
echo -e '\n>>> Copying your public key to server...' \
&& mkdir --parents /home/${server_user}/.ssh \
&& echo "${ssh_key}" >> /home/${server_user}/.ssh/authorized_keys

# === SSH Config ===
echo -e '\n>>> Tweaking SSH config to make it safer...' \
&& sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config \
&& sed -i 's/PubkeyAuthentication no/PubkeyAuthentication yes/g' /etc/ssh/sshd_config \
&& sed -i 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config \
&& sed -i 's/ClientAliveInterval 120/ClientAliveInterval 300/g' /etc/ssh/sshd_config \
&& sed -i 's/LoginGraceTime 120/LoginGraceTime 30/g' /etc/ssh/sshd_config \
&& sed -i 's/Port 22/Port 666/g' /etc/ssh/sshd_config \
&& systemctl reload sshd

# === Firewall Config ===
echo -e '\n>>> Configuring the firewall...' \
&& sed -i 's/IPV6=no/IPV6=yes/g' /etc/default/ufw \
&& ufw allow 666/tcp

if [[ "${is_web_server}" == true ]]; then
    config_web_server;
fi

ufw disable \
&& ufw --force enable \
&& ufw status