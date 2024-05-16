#!/bin/bash

source /config.sh

# flush routes and addresses on eth1 and eth2
ip addr flush dev eth1
ip route flush dev eth1
ip addr flush dev eth2
ip route flush dev eth2

# create a bridge and add eth1 and eth2 to it
ip link add name br0 type bridge
ip link set eth1 master br0 up 
ip link set eth2 master br0 up
ip link set br0 up

# we must have an address for normal flow of the upstream packets
ip addr add $HOSTB/$NETMASKLEN dev br0

# redirect the flows
iptables -t nat -A PREROUTING -s $HOSTA -d $HOSTC -p tcp --dport 80 -j REDIRECT --to-port 8080
iptables -t nat -A PREROUTING -s $HOSTA -d $HOSTC -p tcp --dport 443 -j REDIRECT --to-port 8080

# start mitmdump
./venv/bin/mitmdump --ssl-insecure &

# keep the container running
exec sleep inf
