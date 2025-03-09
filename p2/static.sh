#!/bin/bash

# Configuration for router_fech-cha-1
ip link add br0 type bridge  # Create a bridge interface
ip link set dev br0 up        # Bring up the bridge

ip addr add 10.1.1.1/24 dev eth0  # Assign IP to eth0 (underlay network)

# Create VXLAN interface
ip link add name vxlan10 type vxlan id 10 dev eth0 remote 10.1.1.2 local 10.1.1.1 dstport 4789
ip addr add 20.1.1.1/24 dev vxlan10  # Assign IP to VXLAN interface
ip link set dev vxlan10 up            # Activate VXLAN interface

# Attach interfaces to bridge
brctl addif br0 eth1
brctl addif br0 vxlan10

# Configuration for router_fech-cha-2
ip link add br0 type bridge
ip link set dev br0 up

ip addr add 10.1.1.2/24 dev eth0  # Assign IP to eth0 (underlay network)

# Create VXLAN interface
ip link add name vxlan10 type vxlan id 10 dev eth0 remote 10.1.1.1 local 10.1.1.2 dstport 4789
ip addr add 20.1.1.2/24 dev vxlan10
ip link set dev vxlan10 up

# Attach interfaces to bridge
brctl addif br0 eth1
brctl addif br0 vxlan10

# Configuration for host_fech-cha-1
ip addr add 30.1.1.1/24 dev eth1  # Assign IP to host-facing interface

# Configuration for host_fech-cha-2
ip addr add 30.1.1.2/24 dev eth1  # Assign IP to host-facing interface