#!/bin/bash -xe

# a simple connectivity test between containers A and B.

source common/config.sh

# fetch something over plain http
docker exec containera curl -s $HOSTC:80