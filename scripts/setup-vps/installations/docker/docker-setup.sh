docker_compose_version='1.7.1'

read -p "Docker Compose Version (default '${docker_compose_version}'): " compose_version
test ! -z "${compose_version}" && docker_compose_version="${compose_version}"

injected_variables="
    ${injected_variables}
    docker_compose_version='${docker_compose_version}';
"

ssh_commands="${ssh_commands}; $(cat ${PWD}/installations/docker/docker-commands.sh)"