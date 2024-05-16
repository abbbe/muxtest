#!/bin/bash -xe

# A simple connectivity test between containers A and B.

source common/config.sh

# Ping from containera to containerc
docker exec containera ping -i .2 -c 4 $HOSTC

# Ping from containerc to containera
docker exec containerc ping -i .2 -c 4 $HOSTA
