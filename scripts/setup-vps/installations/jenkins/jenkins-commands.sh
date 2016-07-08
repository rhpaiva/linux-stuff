docker_exec='sudo docker run -ti --rm -e TERM="xterm" -v ${PWD}:${PWD} -v /tmp/:/tmp/ -w ${PWD} --net=host --sig-proxy=true --pid=host'

echo -e "\n${bgcolor_ok}>>> Downloading docker files${color_reset}\n" \
&& git clone https://github.com/rhpaiva/dockerfiles.git

# build docker images
test $? -eq 0 \
&& echo -e "\n${bgcolor_ok}>>> Building Jenkins docker image${color_reset}\n" \
&& sudo docker build --tag rhpaiva/jenkins dockerfiles/jenkins \
&& echo -e "\n${bgcolor_ok}>>> Building PHP7 FPM docker image${color_reset}\n" \
&& sudo docker build --tag rhpaiva/php:7-fpm dockerfiles/php7 \
&& echo -e "\n${bgcolor_ok}>>> Building PHP7 Xdebug docker image${color_reset}\n" \
&& sudo docker build --tag rhpaiva/php:7-xdebug dockerfiles/php7/xdebug \
&& echo -e "\n${bgcolor_ok}>>> Building PHP7 Tools docker image${color_reset}\n" \
&& sudo docker build --tag rhpaiva/php:7-tools dockerfiles/jenkins \
&& echo -e "\n${bgcolor_ok}>>> Pulling other docker images${color_reset}\n" \
&& sudo docker pull node:6 \
&& rm -rf dockerfiles/

# create shortcuts for utilities
test $? -eq 0 \
&& echo -e "\n${bgcolor_ok}>>> Creating shortcut for PHP${color_reset}\n" \
&& mkdir scripts \
&& echo '#!/usr/bin/env bash\nsudo docker run -i --rm -v ${PWD}:${PWD} -v /tmp/:/tmp/ -w ${PWD} --net=host --sig-proxy=true --pid=host rhpaiva/php:7-xdebug php $@' > scripts/docker-php7-xdebug.sh \
&& chmod ug+x scripts/docker-php7-xdebug.sh \
&& sudo ln -s "${PWD}/scripts/docker-php7-xdebug.sh" /usr/local/bin/php

test $? -eq 0 \
&& echo -e "\n${bgcolor_ok}>>> Creating shortcut for NodeJS and NPM${color_reset}\n" \
&& echo -e '#!/usr/bin/env bash\n'"${docker_exec} "'node:6 node $@' > scripts/docker-node.sh \
&& chmod ug+x scripts/docker-node.sh \
&& sudo ln -s "${PWD}/scripts/docker-node.sh" /usr/local/bin/node \
&& echo -e '#!/usr/bin/env bash\n'"${docker_exec} "'node:6 npm $@' > scripts/docker-npm.sh \
&& chmod ug+x scripts/docker-npm.sh \
&& sudo ln -s "${PWD}/scripts/docker-npm.sh" /usr/local/bin/npm

