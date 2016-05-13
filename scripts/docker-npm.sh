#!/usr/bin/env bash

docker run -ti --rm -e 'TERM=xterm' -v ${PWD}:${PWD} -v /tmp/:/tmp/ -w ${PWD} --net=host --sig-proxy=true --pid=host node:6 npm $@
