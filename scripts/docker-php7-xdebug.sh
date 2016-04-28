#!/usr/bin/env bash

docker run -i --rm -v ${PWD}:${PWD} -v /tmp/:/tmp/ -w ${PWD} --net=host --sig-proxy=true --pid=host rhpaiva/php-xdebug:7-fpm php $@
