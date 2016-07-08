test $? -gt 0 && exit 1

export TERM='xterm'

echo -e "\n${bgcolor_ok}>>> Initiating basic configuration for server '${server_ip}'${color_reset}\n"

# === Locale generation ===
locale-gen en_US en_US.UTF-8 de_DE de_DE.UTF-8 \
&& echo -e 'LANG="en_US.UTF-8"\nLANGUAGE="en_US:en"\n' > /etc/default/locale

# adjust timezone
test $? -eq 0 \
&& mv /etc/localtime /etc/localtime.old \
&& ln -s /usr/share/zoneinfo/${timezone} /etc/localtime \
&& echo -e "\n${bgcolor_ok}>>> Changed timezone to '${timezone}'${color_reset}"

# preconfigure iptables-persistent to not show the dialog
test $? -eq 0 \
&& echo iptables-persistent iptables-persistent/autosave_v4 boolean true | debconf-set-selections \
&& echo iptables-persistent iptables-persistent/autosave_v6 boolean true | debconf-set-selections

# === APT Stuff ===
test $? -eq 0 \
&& apt-get update \
&& apt-get --assume-yes install \
    htop \
    curl \
    iptables-persistent
#    ntp

# === User creation ===
test $? -eq 0 \
&& echo -e "\n${bgcolor_ok}>>> Generating new user '${server_user}' in server...${color_reset}\n" \
&& adduser --gecos '' ${server_user} \
&& usermod --append --groups sudo ${server_user}

# === SSH Credentials ===
test $? -eq 0 \
&& echo -e "\n${bgcolor_ok}>>> Copying your public key to server...${color_reset}" \
&& mkdir --parents /home/${server_user}/.ssh \
&& echo "${ssh_key}" >> /home/${server_user}/.ssh/authorized_keys

# === SSH Config ===
test $? -eq 0 \
&& echo -e "\n${bgcolor_ok}>>> Tweaking SSH config to make it safer...${color_reset}" \
&& sed -i \
    -e 's/#PasswordAuthentication yes/PasswordAuthentication no/g' \
    -e 's/PubkeyAuthentication no/PubkeyAuthentication yes/g' \
    -e 's/PermitRootLogin yes/PermitRootLogin no/g' \
    -e 's/ClientAliveInterval 120/ClientAliveInterval 300/g' \
    -e 's/LoginGraceTime 120/LoginGraceTime 30/g' \
    -e "s/Port 22/Port ${ssh_port}/g" \
    /etc/ssh/sshd_config \
&& systemctl reload sshd

# === Firewall Config ===
# - reset rules
# - accepts the current SSH connection.
# - allow new SSH connections onto port ${ssh_port}
# - accept into loopback
# - drops everything else by default (careful when flushing iptables because DROP is maintained)
test $? -eq 0 \
&& echo -e "\n${bgcolor_ok}>>> Configuring iptables rules...${color_reset}\n" \
&& iptables --policy INPUT ACCEPT \
&& iptables --policy OUTPUT ACCEPT \
&& iptables --flush \
&& iptables --append INPUT --match conntrack --ctstate ESTABLISHED,RELATED --jump ACCEPT \
&& iptables --append INPUT --protocol tcp --destination-port "${ssh_port}" -j ACCEPT \
&& iptables --insert INPUT 1 --in-interface lo --jump ACCEPT \
&& iptables --policy INPUT DROP \
&& iptables --list-rules \
&& netfilter-persistent save