#!/bin/bash

source /config.sh

# configure networking
ip addr flush dev eth1
ip route flush dev eth1
ip addr add $HOSTC/$NETMASKLEN dev eth1

# start the web server
cd /tmp
python3 -m http.server 80 &

# keep the container running
exec sleep inf
