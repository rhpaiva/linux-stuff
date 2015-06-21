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
alias caiu='ping 8.8.8.8'
 
# list the directories grouping the directories at the top of the list
alias lld='ll --group-directories-first'
 
# find process by name
alias pfind="ps aux | grep $1"

# find things in history
alias hfind="history | grep $1"
 
# create symbolic link from $1 to $2
alias sln="ln -s $1 $2"
 
# make user aliases available with sudo
alias sudo='sudo '
 
# run selenium using java
alias runselenium="java -jar /usr/bin/selenium"
 
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
	cat "$HOME/.ssh/${keyname}_rsa.pub" #2>/dev/null;
}

# === docker === #

alias docker="sudo docker "

# list all containers created
alias docpsa="docker ps -a "

# remove all created containers
alias docrma="docker rm $(docker ps -a -q)"

# stop all created containers
alias docstopa="docker stop $(docker ps -a -q)"
