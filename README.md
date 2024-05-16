# muxtest

This repository implements a testbed for flow tracker and multiplexor.
It deploys cointainers A, B, and C.
We run flows between A and C.
Container B is used for manipulating the flows.

```
docker compose up -d --build
./tests/100_ping.sh
./tests/200_a_curl_http_c.sh
docker compose down
```