#!/bin/bash


docker build -f ./dockerfiles/Dockerfile.busybox -t busybox .
docker build -f ./dockerfiles/Dockerfile.frr -t frr .