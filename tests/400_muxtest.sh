#!/bin/bash -xe

# a simple connectivity test between containers A and B.
source common/config.sh

# 1. start flow tracker on
$RUNB flowtracker on

# 2. fetch something over TLS couple times
$RUNA curl https://$DOMAINC
$RUNA curl https://$DOMAINC

# 3. cut flow tracking
$RUNB flowtracker cut "test1"