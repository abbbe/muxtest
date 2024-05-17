#!/bin/bash -xe

source common/config.sh

docker compose up -d --build
./tests/100_ping.sh
sleep 1

./tests/200_ae_curl_cd.sh
./tests/300_flowmux.sh

docker logs containerb

docker compose down

