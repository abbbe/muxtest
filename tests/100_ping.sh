#!/bin/bash

# A simple connectivity test between containers A and B.

source /config.sh

# Ping from containera to containerc
docker exec containera ping -c 3 $HOSTC

# Ping from containerc to containera
docker exec containerc ping -c 4 $HOSTA
