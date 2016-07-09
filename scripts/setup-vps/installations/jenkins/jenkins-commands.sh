docker_exec='docker run -ti --rm -e TERM="xterm" -v ${PWD}:${PWD} -v /tmp/:/tmp/ -w ${PWD} --net=host --sig-proxy=true --pid=host'

# pull docker images
echo -e "\n${bgcolor_ok}>>> Pulling necessary docker images${color_reset}\n" \
&& docker pull jenkins:latest \
&& docker pull rhpaiva/php:7-fpm \
&& docker pull rhpaiva/php:7-tools \
&& docker pull node:6

# create shortcuts for utilities
test $? -eq 0 \
&& echo -e "\n${bgcolor_ok}>>> Creating shortcut for PHP${color_reset}\n" \
&& echo -e '#!/usr/bin/env bash\n'"${docker_exec} "'rhpaiva/php:7-fpm php $@' > /usr/local/bin/php \
&& chmod +x /usr/local/bin/php

test $? -eq 0 \
&& echo -e "\n${bgcolor_ok}>>> Creating shortcut for NodeJS and NPM${color_reset}\n" \
&& echo -e '#!/usr/bin/env bash\n'"${docker_exec} "'node:6 node $@' > /usr/local/bin/node \
&& echo -e '#!/usr/bin/env bash\n'"${docker_exec} "'node:6 npm $@' >  /usr/local/bin/npm \
&& chmod +x /usr/local/bin/node \
&& chmod +x  /usr/local/bin/npm