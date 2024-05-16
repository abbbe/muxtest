#!/bin/bash -xe

# container A fetches something from container C over HTTP and HTTPS

source common/config.sh

# fetch something over plain HTTP
$RUNA curl http://$HOSTC/

# fetch something over HTTPS
$RUNA curl -k https://$HOSTC/
