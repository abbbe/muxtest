#!/bin/bash

source /config.sh

# configure networking
ip addr flush dev eth1
ip route flush dev eth1
ip addr add $HOSTD/$NETMASKLEN dev eth1

#--- FIXME refactor this into a common script
# generate CA
CADIR=/etc/ssl/ca
mkdir -p $CADIR
openssl genrsa -out $CADIR/ca.key 2048
openssl req -x509 -new -nodes -key $CADIR/ca.key -sha256 -days 3650 -out $CADIR/ca.crt \
    -subj "/C=US/ST=CA/L=San Francisco/O=Test/OU=Test/CN=Test CA"

# issue a server certificate for D
openssl genrsa -out $CADIR/server.key 2048
openssl req -new -key $CADIR/server.key -out $CADIR/server.csr \
    -subj "/C=US/ST=CA/L=San Francisco/O=Test/OU=Test/CN=$DOMAIND"

# have it signed by the CA
openssl x509 -req -in $CADIR/server.csr -CA $CADIR/ca.crt -CAkey $CADIR/ca.key -CAcreateserial \
    -out $CADIR/server.crt -days 3650

# start the web server
cd /var/www/html
python3 -m http.server 80 &

# run socat to expose the webserver over TLS
socat openssl-listen:443,reuseaddr,fork,cert=$CADIR/server.crt,key=$CADIR/server.key,cafile=$CADIR/ca.crt,verify=0 \
    tcp:localhost:80 &
#--- FIXME refactor this into a common script

# launch the qsslcaudit thing
qsslcaudit -l 0.0.0.0

# keep the container running
exec sleep inf
