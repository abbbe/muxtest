#!/bin/bash -xe

# container A makes two HTTPS requests to container C with different JA3 fingerprints

source common/config.sh

$RUNA curl --ciphers ECDHE-RSA-AES256-GCM-SHA384 -k https://$DOMAINC

$RUNA curl --ciphers TLS_AES_256_GCM_SHA384 -k https://$DOMAINC
