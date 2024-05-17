# muxtest

This repository implements a testbed for flow tracker and multiplexor.
It deploys several interconnected docker cointainers:
* A and E sit on network AB, also connected to B.
* C and D sit on network BC, also connected to B.
* B bridges the two networks.
* Connections flow from A or E to C or D.
* Container B is manipulates the flow and either sends them to C or D.

## flow tracker

Main features of the tracker:
* parse series of PCAP files captured along with certain test activitis,
* groups similar flows by source IP, destionation IP and port, JA* finterprints,
* display a summary of flows per PCAP file, do not display flows seen already.

In this testbed we use it to capture JA3 fingerprints for multiplexor testing
```
$ ftr -j test.pcapng.gz | tee test.json
[{"ip.src": "10.0.0.1", "ip.dst": "10.0.0.3", "tcp.dport": "443", "ja3": "12345"}]

$ JA3=`jq -r '.[0].ja3' < tests/300_muxtest.json`
```

## flow multiplexing

The purpose of the multiplexor is to receive a TLS connection and route it to a handler tool.
Main features:
* receive a redirected connection, capture TLS client hello, calculate JA3 fingerprint,
* decide if the connection needs to be relayed upstream or passed to a handler tool,
* find an appropriate instance of a handler tool if does not exist yet,
* transparently relay the connection to the handler tool or the original destination.

The following syntax can be used to redirect specific clients:
```
mitmdump -s ./mitmproxy/contrib/flowmux/flowmux.py \
  --set redirect_flow '{"ip.src": "10.0.0.1", "ip.dst": "10.0.0.3", "tcp.dport": "443", "ja3": "070ed1ebe4979528bf846db0c1382e79"}' \
  --set redirect_to 10.0.0.4:8443
```

## testing

There is a main test script which brings up a testbed and invoke other test scripts.
Currently implemented:
* 100_ping: A/E pings C/D, just to test L3 connectivity
* 200_curl: A/E fetches a URL from C/D (ignoring the content)
* 300_flowmux: A/E fetch 

```
abb@box:~/muxtest$ ./test.sh
```

## credits

Early versions were based on ... (TODO try find back that python script)
