#!/bin/bash -e

j2 /tmp/rucio.cfg.j2 > /opt/rucio/etc/rucio.cfg

/docker-entrypoint.sh

