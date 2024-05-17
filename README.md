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
Below is an example of HTTP and HTTP requests flowing from A to C via B.
The requests are intercepted by mitmproxy on B.

```
abb@box:~/muxtest$ ./test.sh
...
+ ./tests/200_a_curl_c.sh
...
+ docker exec containera curl http://10.0.0.3/
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   187  100   187    0     0  18331      0 --:--:-- --:--:-- --:--:-- 18700
<!DOCTYPE HTML>
<html lang="en">
<head>
<meta charset="utf-8">
<title>Directory listing for /</title>
</head>
<body>
<h1>Directory listing for /</h1>
<hr>
<ul>
</ul>
<hr>
</body>
</html>

+ docker exec containera curl -k https://10.0.0.3/
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   187  100   187    0     0  14107      0 --:--:-- --:--:-- --:--:-- 14384
<!DOCTYPE HTML>
<html lang="en">
<head>
<meta charset="utf-8">
<title>Directory listing for /</title>
</head>
<body>
<h1>Directory listing for /</h1>
<hr>
<ul>
</ul>
<hr>
</body>
</html>
...

+ ./tests/300_flowmux.sh
...
+ docker logs containerd
+ grep 'most likely all connections were established by the same client'
most likely all connections were established by the same client

+ docker logs containerb
[22:32:52.587] HTTP(S) proxy listening at *:8080.
[22:32:53.514][10.0.0.1:55078] client connect
[22:32:53.520][10.0.0.1:55078] server connect 10.0.0.3:80
10.0.0.1:55078: GET http://10.0.0.3/ HTTP/1.1
    << HTTP/1.0 200 OK 187b
[22:32:53.524][10.0.0.1:55078] server disconnect 10.0.0.3:80
[22:32:53.525][10.0.0.1:55078] client disconnect
[22:32:53.611][10.0.0.1:37466] client connect
[22:32:53.628][10.0.0.1:37466] server connect 10.0.0.3:443
[22:32:53.658][10.0.0.1:37466] server disconnect 10.0.0.3:443
10.0.0.1:37466: GET https://10.0.0.3/ HTTP/2.0
    << HTTP/1.0 200 OK 187b
```

## credits

Early versions were based on ... (TODO try find back that python script)
