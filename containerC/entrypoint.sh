#!/bin/bash

# confiure networking
ip addr flush dev eth1
ip route flush dev eth1
ip addr add 10.0.0.2/24 dev eth1

# Keep the container running
exec sleep inf
