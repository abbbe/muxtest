#!/bin/bash

# Ping from containera to containerc
docker exec containera ping -c 4 10.0.0.2

# Ping from containerc to containera
docker exec containerc ping -c 4 10.0.0.1