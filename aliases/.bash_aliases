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

# === MICROK8S ===
alias mk8="microk8s $@"
alias mk8ctl="microk8s kubectl $@"

# === K8S stuff === #
export K8CURNS=""

alias kctl="kubectl $@"

alias k8gns="kubectl get namespace $@"
alias k8gpods="kubectl get pods $K8CURNS $@"
alias k8logs="kubectl logs $K8CURNS $@"

alias k8ctx="kubectl config current-context $@"
alias k8usectx="kubectl config use-context $@"
alias k8setctx="kubectl config set-context $@"

alias k8clus="kubectl config get-clusters $@"
alias k8setclus="kubectl config set-cluster $@"

function k8exec() {
    local pod="$1"
    local cmd="$2"

    kubectl exec -ti ${pod} -- ${cmd}
}

function k8ns() {
    if [ -z "$1" ]; then
        local curns="${K8CURNS}"

        if [ -z "${curns}" ]; then
            local curns="not set"
        fi

        echo "Current namespace: ${curns}"
        echo -e "Namespaces available:\n"

        k8gns
    else
        export K8CURNS="-n $1"

        echo "Current namespace set to: $1"
    fi;
}

# === Add the git branch to terminal ===
force_color_prompt=yes
color_prompt=yes

parse_git_branch() {
 git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

if [ "$color_prompt" = yes ]; then
 PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[01;31m\] $(parse_git_branch)\[\033[00m\]\$ '
else
 PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w $(parse_git_branch)\$ '
fi

#unset color_prompt force_color_prompt
