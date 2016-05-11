#!/usr/bin/env bash

docker run -i --rm -v ${PWD}:${PWD} -v /tmp/:/tmp/ -w ${PWD} --net=host --sig-proxy=true --pid=host node:6 npm $@
