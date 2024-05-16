#!/bin/bash -xe

# a simple connectivity test between containers A and B.

source common/config.sh

# ping from containera to containerc
docker exec containera ping -i .2 -c 4 $HOSTC

# ping from containerc to containera
docker exec containerc ping -i .2 -c 4 $HOSTA
