#!/bin/bash

source /config.sh

# configure networking
ip addr flush dev eth1
ip route flush dev eth1
ip addr add $HOSTE/$NETMASKLEN dev eth1

# keep the container running
exec sleep inf
