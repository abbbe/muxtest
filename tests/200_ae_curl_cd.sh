#!/bin/bash -xe

# containers A and E fetch something from containers C and D over HTTP and HTTPS

source common/config.sh

for RUN in "$RUNA" "$RUNE"; do
    for DOMAIN in $DOMAINC $DOMAIND; do
        # A fetches something over plain HTTP
        $RUN curl http://$DOMAIN/container.txt

        # A fetches something over HTTPS
        $RUN curl -k https://$DOMAIN/container.txt
    done
done

echo "OK"
