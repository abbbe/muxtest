#!/bin/bash -xe

source common/config.sh

docker compose up -d --build
./tests/100_ping.sh
sleep 1

./tests/200_a_curl_c.sh

docker logs containerb

docker compose down

