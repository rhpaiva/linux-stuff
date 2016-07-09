# https://www.digitalocean.com/community/tutorials/how-to-set-up-an-openvpn-server-on-ubuntu-16-04

user_home="/home/${server_user}"
ca_dir="${user_home}/openvpn-ca"

openvpn_rules="
# START OPENVPN RULES
# NAT table rules
*nat
:POSTROUTING ACCEPT [0:0]
# Allow traffic from OpenVPN client to eth0
-A POSTROUTING -s 10.8.0.0/8 -o eth0 -j MASQUERADE
COMMIT
# END OPENVPN RULES
"

echo -e "\n>>> Installing VPN server\n"

# install openvpn
# easy-rsa will help to set up an internal CA (certificate authority) for use with our VPN
apt-get install --assume-yes \
    openvpn \
    easy-rsa

# CA setup with certificate values for creation
test $? -eq 0 \
&& echo -e "\n>>> Setting up CA (certificate authority) and its variables\n" \
&& make-cadir "${ca_dir}" \
&& cd "${ca_dir}" \
&& sed --in-place \
    -e "s/export KEY_COUNTRY=\"US\"/export KEY_COUNTRY=\"DE\"/g" \
    -e "s/export KEY_PROVINCE=\"CA\"/export KEY_PROVINCE=\"BE\"/g" \
    -e "s/export KEY_CITY=\"SanFrancisco\"/export KEY_CITY=\"Berlin\"/g" \
    -e "s/export KEY_ORG=\"Fort-Funston\"/export KEY_ORG=\"KundenMeter\"/g" \
    -e "s/export KEY_EMAIL=\"me@myhost.mydomain\"/export KEY_EMAIL=\"rhpaiva@gmail.com\"/g" \
    -e "s/export KEY_OU=\"MyOrganizationalUnit\"/export KEY_OU=\"IT\"/g" \
    -e "s/export KEY_NAME=\"EasyRSA\"/export KEY_OU=\"server\"/g" \
    "${ca_dir}/vars" \
&& source "${ca_dir}/vars" \
&& ./clean-all

# This will initiate the process of creating the root certificate authority key and certificate
test $? -eq 0 \
&& echo -e "\n>>> Building root CA\n" \
&& ./build-ca

# Create the Server Certificate, Key, and Encryption Files
test $? -eq 0 \
&& echo -e "\n>>> Generating the OpenVPN server certificate and key pair\n" \
&& ./build-key-server server \
&& ./build-dh \
&& openvpn --genkey --secret keys/ta.key

# Generate a Client Certificate and Key Pair
test $? -eq 0 \
&& echo -e "\n>>> Generating the OpenVPN server certificate and key pair\n" \
&& source "${ca_dir}/vars" \
&& ./build-key "client_${server_user}"

# Configure the OpenVPN Service
test $? -eq 0 \
&& echo -e "\n>>> Configuring the OpenVPN Service\n" \
&& cp ${ca_dir}/keys/{ca.crt,ca.key,server.crt,server.key,ta.key,dh2048.pem} /etc/openvpn \
&& gunzip -c /usr/share/doc/openvpn/examples/sample-config-files/server.conf.gz > /etc/openvpn/server.conf \
&& sed --in-place \
    -e "s/;push \"redirect-gateway def1 bypass-dhcp\"/push \"redirect-gateway def1 bypass-dhcp\"/g" \
    -e "s/;push \"dhcp-option DNS 208.67.222.222/push \"dhcp-option DNS 208.67.222.222/g" \
    -e "s/;push \"dhcp-option DNS 208.67.220.220\"/push \"dhcp-option DNS 208.67.220.220/g" \
    -e "s/;tls-auth ta.key 0*/tls-auth ta.key 0/g" \
    -e "s/;user nobody/user nobody/g" \
    -e "s/;group nogroup/group nogroup/g" \
    /etc/openvpn/server.conf \
&& echo -e "\nkey-direction 0" >> /etc/openvpn/server.conf

# Adjust the Server Networking Configuration
test $? -eq 0 \
&& echo -e "\n>>> Allowing IP Forwarding\n" \
&& sed --in-place "s/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g" /etc/sysctl.conf \
&& sysctl --load

test $? -eq 0 \
&& echo -e "\n>>> Adjusting UFW Rules to Masquerade Client Connections\n" \
&& echo "${openvpn_rules}" | cat - /etc/ufw/before.rules > tmpfile \
    && mv tmpfile /etc/ufw/before.rules \
&& sed --in-place "s/DEFAULT_FORWARD_POLICY=\"DROP\"/DEFAULT_FORWARD_POLICY=\"ACCEPT\"/g" /etc/default/ufw \
&& ufw allow 1194/udp \
&& ufw disable \
&& ufw enable

# Start and Enable the OpenVPN Service
test $? -eq 0 \
&& echo -e "\n>>> Stating OpenVPN Service\n" \
&& systemctl start openvpn@server \
&& systemctl status openvpn@server \
&& ip addr show tun0 \
&& systemctl enable openvpn@server

# Client Configuration Infrastructure
test $? -eq 0 \
&& echo -e "\n>>> Adjusting UFW Rules to Masquerade Client Connections\n" \
&& mkdir -p "${user_home}/vpn-client-configs/files" \
&& chmod 700 "${user_home}/vpn-client-configs/files" \
&& cp /usr/share/doc/openvpn/examples/sample-config-files/client.conf "${user_home}/vpn-client-configs/base.conf"

