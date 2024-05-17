#!/bin/bash -xe

# here we simulate flows between two client and two server containers, using two ciphers
# we simulate the flow in three steps, capturing the traffic in separate pcap files
# then we run the flowtracker tool to analyze the traffic
# FIXME should validate the result of the analysis somehow

source common/config.sh

step() {
    NAME=$1; shift

    $RUNB tshark -i br0 -w /tmp/$NAME.pcap &
    sleep 1

    while [ $# -gt 0 ] ; do
        CMD="$1"; shift

        echo "Running '$CMD'"
        $CMD
        sleep 1

    done

    $RUNB killall tshark
    sleep 1
}

# cleanup
$RUNB killall tshark || true
$RUNB sh -c "rm -rf /tmp/*.pcap" || true
# FIXME: merged pcap does not get recreated
$RUNB sh -c "rm /*.pcapng" || true
sleep 1

# --- capture ---

CURL1="curl -k --ciphers ECDHE-RSA-AES256-GCM-SHA384"
CURL2="curl -k --ciphers DHE-PSK-AES128-CBC-SHA256"

# STEP 100: A -> C
step 100-a-curl1-c \
    "$RUNA $CURL1 -k https://$DOMAINC/container.txt"

# STEP 110: A -> C, A -> D
step 110-a-curl1-cd \
    "$RUNA $CURL1 -k https://$DOMAINC/container.txt" \
    "$RUNA $CURL1 -k https://$DOMAIND/container.txt"

# STEP 120: A -> C, E -> C (another JA3)
step 120-ae-curl2-c \
    "$RUNA $CURL2 -k https://$DOMAINC/container.txt" \
    "$RUNE $CURL2 -k https://$DOMAINC/container.txt"

# --- analyze ---

$RUNB sh -c "/venv/bin/ftracker /tmp/*.pcap"

echo "OK"
