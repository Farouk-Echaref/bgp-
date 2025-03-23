#!/bin/sh

docker build -t alpine-busybox-fechcha -f ../gns3-images/alpine-busybox/_fech-cha-1_host ../gns3-images/alpine-busybox/

docker build -t frr-router-fechcha -f ../gns3-images/frr-router/_fech-cha-2 ../gns3-images/frr-router/

