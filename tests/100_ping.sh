#!/bin/bash -xe

# a simple connectivity test between containers A/E and C/D

source common/config.sh

# ping from containera to containerc
for RUN in "$RUNA" "$RUNE"; do
    for HOST in $HOSTC $HOSTD; do
        $RUN ping -i .2 -c 3 $HOST
    done
done

echo "OK"
