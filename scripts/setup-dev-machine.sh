#!/usr/bin/env bash

# =================================================================
# Steps to setup a new computer for web development based on ubuntu
# =================================================================

# vars
downloads_dir=$(echo $HOME/Downloads)
chrome_file='google-chrome-stable_current_amd64.deb'
skype_file='skype-ubuntu-precise_4.3.0.37-1_i386.deb'
phpstorm_file='PhpStorm-8.0.3.tar.gz'
phpstorm_dir='/opt/jetbrains'

echo ">>> Download dir is: ${downloads_dir}"

# for UBUNTU: make bash colored
if [ -f "$HOME/.bashrc" ]; then
	sed -i 's/#force_color_prompt=yes/force_color_prompt=yes/g' "$HOME/.bashrc"
	source "$HOME/.bashrc"
fi

# =================================================================
# Basic packages and setup
# =================================================================

function function_init() {
	# cause aptitude rules!
	sudo apt-get install aptitude 
	sudo aptitude -y update

	# console package manager
	sudo aptitude -y install gdebi
	
	# postgresql
	#sudo aptitude -y install postgresql postgresql-contrib pgadmin3
	
	# mysql
	#sudo aptitude install mysql-server-5.6

	# other tools
	sudo aptitude -y install git \ 
				curl \ 
				htop \ 
				colordiff \ 
				terminator \ 
				vim \ 
				whois \ 
				tree \ 
				jq \
				mytop

	# nginx
	#sudo aptitude -y install nginx

	# PHP 5 and extensions
	#sudo aptitude -y install php5-fpm \ 
	#			php5-gd \ 
	#			php5-curl \ 
	#			php5-json \ 
	#			php5-mcrypt \ 
	#			php5-memcached \ 
	#			php5-mysql \ 
	#			php5-xdebug \ 
	#			php5-intl \ 
	#			php5-pgsql

	exit $?

}

# =================================================================
# vpn
# =================================================================
function install_vpn () {
	sudo aptitude -y install openvpn bridge-utils \
				 network-manager-openvpn \
				 network-manager-openvpn-gnome \
				 network-manager-vpnc

	sudo restart network-manager
}

# =================================================================
# Useful apps
# =================================================================

# download and install chrome
function install_chrome () {
	if [ ! -f "${downloads_dir}/${chrome_file}" ]; then
		wget --directory-prefix="${downloads_dir}" \ 
			"https://dl.google.com/linux/direct/${chrome_file}"
	fi

	sudo gdebi "${downloads_dir}/${chrome_file}"
}

# download and install skype
function install_skype () {
    if [ ! -f "${downloads_dir}/${skype_file}" ]; then
		wget --directory-prefix="${downloads_dir}" \ 
			"http://download.skype.com/linux/${skype_file}"
	fi

	sudo gdebi "${downloads_dir}/${skype_file}"
	
	# for skypes proper cursor and display skype on the system tray
	sudo aptitude -y install libxcursor1:i386 sni-qt:i386
}

# =================================================================
# PHPStorm
# =================================================================

function install_phpstorm() {
    # for phpstorm (we also need java)
	sudo aptitude -y install default-jre default-jdk

        if [ ! -f "${downloads_dir}/${phpstorm_file}" ]; then
		wget --directory-prefix="${downloads_dir}" \ 
			"http://download-cf.jetbrains.com/webide/${phpstorm_file}"
	fi

	[ ! -d "${phpstorm_dir}" ] && sudo mkdir "${phpstorm_dir}"

	sudo cp "${downloads_dir}/${phpstorm_file}" "${phpstorm_dir}"
	cd "${phpstorm_dir}"
	sudo tar -xf "${phpstorm_file}"
	sudo rm "${phpstorm_file}"
	
	# finalizes the installation
	sudo "./$(ls)/bin/phpstorm.sh" &
	cd -
}

# =================================================================
# MariaDB 10
# =================================================================

function install_mariadb() {
	# add the repository to sources list
	sudo apt-get install software-properties-common
	sudo apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xcbcb082a1bb943db
	sudo add-apt-repository 'deb http://ftp.hosteurope.de/mirror/mariadb.org/repo/10.0/ubuntu trusty main'
	
	# install the girl
	sudo apt-get update
	sudo apt-get install mariadb-server-10.0
}

# =================================================================
# Docker
# =================================================================

function install_docker() {
	# add the key from docker's repo to apt-key to verify packages
	sudo sh -c "wget -qO- https://get.docker.io/gpg | apt-key add -"

	# add the repo to apt's sources
	sudo sh -c "echo deb http://get.docker.io/ubuntu docker main > /etc/apt/sources.list.d/docker.list"

	# install docker and a syntax for vim
	sudo aptitude -y install lxc-docker vim-syntax-docker

	# install docker-compose
	sudo sh -c 'curl -L https://github.com/docker/compose/releases/download/1.2.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose'
	sudo chmod +x /usr/local/bin/docker-compose

	# install command completion for compose
	sudo sh -c 'curl -L https://raw.githubusercontent.com/docker/compose/1.2.0/contrib/completion/bash/docker-compose > /etc/bash_completion.d/docker-compose'
}

# =================================================================
# Docker images
# =================================================================
function install_dockerimgs () {
	sudo docker pull ubuntu:trusty
	sudo docker pull nginx:latest
	sudo docker pull php:5.6-fpm
	sudo docker pull mariadb:10
	sudo docker pull memcached:latest
	sudo docker pull mongo:latest
	sudo docker pull node:latest
	sudo docker pull jenkins:latest
}

# =================================================================
# Services (ideally go into docker containers)
# =================================================================

# for quick tests
#sudo aptitude install php5-cli

# memcache
#sudo aptitude install memcached

# PHP 5 with php-fpm
#sudo aptitude install php5-fpm
# PHP 5 extensions
#sudo aptitude install php5-gd php5-curl php5-json php5-mcrypt php5-memcached php5-mysql php5-xdebug php5-intl php5-pgsql

# mysql and a query monitor
#sudo aptitude install mysql-server mytop

# ruby and sass
#sudo aptitude install ruby
#sudo gem install sass


# =================================================================
# PHP Env & Config
# =================================================================

# composer related stuff
function install_composer () {
	curl -sS https://getcomposer.org/installer | php
	sudo mv composer.phar /usr/local/bin
	sudo ln -s /usr/local/bin/composer.phar /usr/local/bin/composer
	composer install
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
