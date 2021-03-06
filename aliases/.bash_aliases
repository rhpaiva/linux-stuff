## ================= ##
## Personal aliases  ##
## ================= ##
 
hosts="/etc/hosts"
 
# shortcuts for bash edition
alias bashreload='source ~/.bashrc'
alias bashedit='vim ~/.bashrc'
alias aliases="vim ~/.bash_aliases"
 
# raise the history size
export HISTFILESIZE=20000
export HISTSIZE=10000
 
PROMPT_COMMAND='history -a'
 
# do we have internet?
alias isdown='ping 8.8.8.8'

# move unity bar to the specified position
alias mvbar="gsettings set com.canonical.Unity.Launcher launcher-position $1"
 
# list the directories grouping the directories at the top of the list
alias lld='ll -h --group-directories-first'
 
# find process by name
alias pfind="ps aux | grep $1"

# find things in history
alias hfind="history | grep $1"
 
# create symbolic link from $1 to $2
alias sln="ln -s $1 $2"
 
# make user aliases available with sudo
alias sudo='sudo '

# make diff always use colordiff instead
alias diff="colordiff "
 
# go back N levels
alias ..="cd .."
alias ..2="cd ../.."
alias ..3="cd ../../.."
alias ..4="cd ../../../.."
 
# This is GOLD for finding out what is taking so much space on your drives!
alias diskspace="du -S | sort -n -r | more"
 
# Show me the size (sorted) of only the folders in this directory
alias folders="find . -maxdepth 1 -type d -print | xargs du -sk | sort -rn"

# Delete with confirmation all the files in a directory $1
alias delfiles="find . -type f -maxdepth 1 -exec rm -iv {} \;"

# Color for manpages in less makes manpages a little easier to read
export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'
 
# === SVN aliases === #
 
# show log with last $1 entries and show changed files
alias svnlog="svn log -vl $1"
alias svnlog_diff="svn log -vl $1 --diff"
 
# === NGINX aliases === #
 
# list sites-available
alias sitels="lld /etc/nginx/sites-available"
 
# edit nginx sites-available/<sitename>
function sitemod () {
	if [ -z "$1" ]; then
        	echo "Please specify the name of the site - usage: sitemod <sitename>"
	        return 1
	fi

	local siteName="/etc/nginx/sites-available/${1}.conf"
 
	if [ ! -f $siteName ]; 
	then
		printf "%s does not exist. The ones available are:\n\n" $siteName
 
		for site in $(ls /etc/nginx/sites-available); do
			printf "\t- %s\n" $site;
		done
 
		echo ''
		return 1
	fi
 
	sudo vim $siteName 
}

# === keys handling === #

# Generate new rsa key. Usage: newkey <email> <keyname>
function newkey () {
	local email="$1"
	local keyname="$2"

	if [ -z "$email" -o -z "$keyname" ]; then
       		echo "Please provide your email and name of the key - usage: newkey <email> <keyname>"
        	return 1
	fi
								 
 	ssh-keygen -t rsa -b 4096 -C "$email" -f "$HOME/.ssh/${keyname}_rsa"
	ssh-add "$HOME/.ssh/${keyname}_rsa.pub"
}

# show available rsa keys. Usage: mykey [<keyname> ("id" is default")]
function mykey () {
	local keyname="$1"

	if [ -z "$keyname" ]; then
		keyname="id"
	fi

	echo "Public key from file $HOME/.ssh/${keyname}_rsa.pub" && echo ""
	cat "$HOME/.ssh/${keyname}_rsa.pub" #2>/dev/null
}

# === docker === #

# list all containers created
alias docps="docker ps --all "

# only ids of containers
alias docids="docker ps --all --quiet"

# go into a container
function docgo() {
    docker exec --interactive --tty "$1" /bin/bash
}

# remove all created containers
alias docrma="docids | xargs docker rm"

# stop all created containers
alias docstopa="docids | xargs docker stop"

# because docker-compose is too much to type
alias docompose="docker-compose $@"

# stop and remove all containers
alias docnuke="docstopa && docrma"

# updates all docker images
alias docpull='for img in $(docker images --format "{{.Repository}}:{{.Tag}}"); do docker pull $img; done'

# run php7 in a container
alias php7="docker run -i --rm -v $(pwd):$(pwd) -v /tmp/:/tmp/ -w $(pwd) -e 'TERM=xterm' --net=host --sig-proxy=true --pid=host rhpaiva/php:7-fpm php $@"
alias php7-xdebug="docker run -i --rm -v $(pwd):$(pwd) -v /tmp/:/tmp/ -w $(pwd) -e 'TERM=xterm' --net=host --sig-proxy=true --pid=host rhpaiva/php:7-xdebug php $@"

# === composer running in a docker container === #
function composer() {
	local current_dir=$(pwd)
	docker run -ti --rm -v ${current_dir}:${current_dir} -v /tmp/:/tmp/ -w ${current_dir} -e 'TERM=xterm' rhpaiva/php:7-tools composer $@
}

# === aliases for Digital Ocean doctl ===

function dodropmk() {
	local name="$1"
    local size="512mb"
	local region="FRA1"
	local image="ubuntu-16-04-x64"
	local sshkey="$(ssh-add -l -E md5 | grep rhpaiva | cut -d ' ' -f 2 | cut -b 5-)"

    echo "Creating: doctl compute droplet create "${name}" --image "${image}" --size "${size}" --region "${region}" --ssh-keys "${sshkey}" --wait --enable-private-networking"

    doctl compute droplet create "${name}" --image "${image}" --size "${size}" --region "${region}" --ssh-keys "${sshkey}" --wait --enable-private-networking
}

function dodroprm() {
	doctl compute droplet delete "$1"
}

function dodropls() {
	doctl compute droplet list
}
