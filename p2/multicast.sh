#!/bin/bash

DOCKER_CONTAINER_HOST1="host_amiski-1"
DOCKER_CONTAINER_HOST2="host_amiski-2"
DOCKER_CONTAINER_ROUTER2="router_amiski-1"
DOCKER_CONTAINER_ROUTER1="router_amiski-2"

# Rename running containers to match their internal hostname
containers=$(docker ps -q)
for container in $containers; do
    hostname=$(docker exec -it $container hostname | tr -d '\r')
    docker rename $container "$hostname" 2>/dev/null
done


# Configuration for router_amiski-1
docker exec -it $DOCKER_CONTAINER_ROUTER1 ip addr add 10.1.1.1/24 dev eth0
docker exec -it $DOCKER_CONTAINER_ROUTER1 ip link add vxlan10 type vxlan id 10 dev eth0  group 239.1.1.1 dstport 4789
docker exec -it $DOCKER_CONTAINER_ROUTER1 brctl addbr br0
docker exec -it $DOCKER_CONTAINER_ROUTER1 brctl addif br0 vxlan10
docker exec -it $DOCKER_CONTAINER_ROUTER1 brctl stp br0 off
docker exec -it $DOCKER_CONTAINER_ROUTER1 ip link set up dev br0
docker exec -it $DOCKER_CONTAINER_ROUTER1 ip link set up dev vxlan10
docker exec -it $DOCKER_CONTAINER_ROUTER1 brctl addif br0 eth1


# Configuration for router_amiski-2
docker exec -it $DOCKER_CONTAINER_ROUTER2 ip addr add 10.1.1.2/24 dev eth0
docker exec -it $DOCKER_CONTAINER_ROUTER2 ip link add vxlan10 type vxlan id 10 dev eth0 group 239.1.1.1 dstport 4789
docker exec -it $DOCKER_CONTAINER_ROUTER2 brctl addbr br0
docker exec -it $DOCKER_CONTAINER_ROUTER2 brctl addif br0 vxlan10
docker exec -it $DOCKER_CONTAINER_ROUTER2 brctl stp br0 off
docker exec -it $DOCKER_CONTAINER_ROUTER2 ip link set up dev br0
docker exec -it $DOCKER_CONTAINER_ROUTER2 ip link set up dev vxlan10
docker exec -it $DOCKER_CONTAINER_ROUTER2 brctl addif br0 eth1


# Configuration for Host_amiski-1
docker exec -it $DOCKER_CONTAINER_HOST1  ip addr add 30.1.1.1/24 dev eth1


# Configuration for Host_amiski-2
docker exec -it $DOCKER_CONTAINER_HOST2  ip addr add 30.1.1.2/24 dev eth1
