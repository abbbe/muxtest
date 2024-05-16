#!/bin/bash -xe

# a simple connectivity test between containers A and B

source common/config.sh

# ping from containera to containerc
$RUNA ping -i .2 -c 4 $DOMAINC
