#!/bin/bash

# Flush routes and addresses on eth1 and eth2
ip addr flush dev eth1
ip route flush dev eth1
ip addr flush dev eth2
ip route flush dev eth2

# Create a bridge and add eth1 and eth2 to it
ip link add name br0 type bridge
ip link set eth1 master br0 up 
ip link set eth2 master br0 up
ip link set br0 up

# Keep the container running
exec sleep inf
