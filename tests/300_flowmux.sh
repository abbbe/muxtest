#!/bin/bash -xe

# here we use two containers and two curl commands using differnet ciphers
# both fetch the same container.txt file from the domainC
# we expect the multiplexor to correctly follow redirection rules
# specifically, requests from container A with matching JA3 should be redirected to D
# as a result, curl would fetch container.txt from containerD instead of C

source common/config.sh

URL="https://$DOMAINC/container.txt"
CURL="curl -k --ciphers ECDHE-RSA-AES256-GCM-SHA384 $URL"
CURL_JA3_MATCH="curl -k --ciphers DHE-PSK-AES128-CBC-SHA256 $URL"

N=1
SLEEP=.1

test_redir() {
    # params:
    # N - number of iterations
    # RUNx / RESx - command to run / expected output
    local N=$1; shift
    local RUN1="$1" ; shift
    local RES1="$1" ; shift
    local RUN2="$1" ; shift
    local RES2="$1" ; shift

    for _ in `seq $N` ; do
        OUT1=`$RUN1`
        [ "$OUT1" == "$RES1" ]
        sleep $SLEEP

        OUT2=`$RUN2`
        [ "$OUT2" == "$RES2" ]
        sleep $SLEEP
    done
}

test__self() {
    ## just a selftest, to make sure backend servers return expected responses
    ## normally these flows bypass the redirection
    local RUN1="$RUNA curl -k https://$DOMAINC/container.txt"
    local RUN2="$RUNE curl -k https://$DOMAIND/container.txt"

    test_redir 2 "$RUN1" "containerC" "$RUN2" "containerD"
}

test__partmatch_l4__mismatch_ja3() {
    ## no requests get redirected if JA3 does not match 
    local RUN1="$RUNA $CURL" # L4 match, JA3 mismatch
    local RUN2="$RUNE $CURL" # L4 mismatch, JA3 mismatch

    test_redir $N "$RUN1" "containerC" "$RUN2" "containerC"
}

test__mismatch_l4__partmatch_ja3() {
    ## no requests get redirected if L4 does not match 
    local RUN1="$RUNE $CURL" # L4 mismatch, JA3 match
    local RUN2="$RUNE $CURL_JA3_MATCH" # L4 mismatch, JA3 mismatch

    test_redir $N "$RUN1" "containerC" "$RUN2" "containerC"
}

test__match_l4__partmatch_ja3() {
    ## only request with matching both L4 and JA3 get redirected
    local RUN1="$RUNA $CURL" # L4 match, JA3 mismatch
    local RUN2="$RUNA $CURL_JA3_MATCH" # L4 match, JA3 match

    test_redir $N "$RUN1" "containerC" "$RUN2" "containerD"
}

test__partmatch_l4__match_ja3() {
    ## only request with matching both L4 and JA3 get redirected
    local RUN1="$RUNA $CURL_JA3_MATCH" # L4 match, JA3 match
    local RUN2="$RUNE $CURL_JA3_MATCH" # L4 mismatch, JA3 match

    test_redir $N "$RUN1" "containerD" "$RUN2" "containerC"
}

cleanup() {
    $RUNB iptables -t nat -F PREROUTING
    $RUNB sh -c "killall mitmdump && sleep 1 || true"
}

# redirect TCP/80 and TCP/443 to localhost TCP/8080
cleanup
$RUNB iptables -t nat -A PREROUTING -s $HOSTA -d $HOSTC -p tcp --dport 80 -j REDIRECT --to-port 8080
$RUNB iptables -t nat -A PREROUTING -s $HOSTA -d $HOSTC -p tcp --dport 443 -j REDIRECT --to-port 8080
$RUNB ./venv/bin/mitmdump --ssl-insecure &
sleep 1

# FIXME: the flowmux plugin, something ike
# mitmdump -s ./mitmproxy/contrib/flowmux/flowmux.py \
#  --set redirect_flow '{"ip.src": "$HOSTA", "ip.dst": "$HOSTC", "tcp.dport": "443", "ja3": "070ed1ebe4979528bf846db0c1382e79"}' \
#  --set redirect_to $HOSTD:8443

test__self
test__partmatch_l4__mismatch_ja3
test__mismatch_l4__partmatch_ja3

# FIXME: tests below should pass when multiplexor is implemented
# test__match_l4__partmatch_ja3
# test__partmatch_l4__match_ja3

cleanup

echo "OK"
