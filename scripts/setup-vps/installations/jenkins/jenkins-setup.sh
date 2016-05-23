setup_name="jenkins"

injected_variables="
    ${injected_variables}
    jenkins='iu';
"

ssh_commands="${ssh_commands}; $(cat ${PWD}/installations/${setup_name}/${setup_name}-commands.sh)"