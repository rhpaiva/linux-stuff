export TERM='xterm'

KERNEL="$(uname -r)"

echo -e "\n>>> Installing Docker Engine\n"

# ensure that APT works with the https method and that CA certificates are installed.
apt-get install --assume-yes \
    apt-transport-https \
    ca-certificates \
    linux-image-extra-${kernel}

# Add the new GPG key
# add the repo to apt's sources
# install docker and a syntax for vim
test $? -eq 0 \
&& apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D \
&& echo deb https://apt.dockerproject.org/repo ubuntu-xenial main > /etc/apt/sources.list.d/docker.list \
&& apt-get update \
&& apt-get --assume-yes install docker-engine
#vim-syntax-docker

# install docker-compose and its command completion
test $? -eq 0 \
&& echo -e "\n>>> Installing Docker Compose as a container" \
&& curl -L https://github.com/docker/compose/releases/download/${docker_compose_version}/run.sh > /usr/local/bin/docker-compose \
&& chmod +x /usr/local/bin/docker-compose \
&& curl -L https://raw.githubusercontent.com/docker/compose/${docker_compose_version}/contrib/completion/bash/docker-compose > /etc/bash_completion.d/docker-compose \
&& docker-compose --version

# Adds generated user to group docker to avoid sudo
test $? -eq 0 \
&& echo -e "\n>>> Adding user '${server_user}' to group docker" \
&& usermod -a -G docker ${server_user} \
&& service docker restart
