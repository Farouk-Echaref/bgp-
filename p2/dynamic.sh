# execute the commands in the bash

# Configuration
# --------------------------------------------
# 🔹 Configure Router 1 (router_fech-cha-1)
# --------------------------------------------

# Create a Linux bridge
ip link add br0 type bridge

# Bring up the bridge interface
ip link set dev br0 up

# Assign an IP to eth0 (Underlay Network)
ip addr add 10.1.1.1/24 dev eth0

# Create VXLAN interface with multicast group (L2 extension over L3)
ip link add name vxlan10 type vxlan id 10 dev eth0 group 239.1.1.1 dstport 4789

# Assign an IP to VXLAN interface (Overlay Network)
ip addr add 20.1.1.1/24 dev vxlan10

# Add eth1 and vxlan10 to the bridge
brctl addif br0 eth1
brctl addif br0 vxlan10

# Bring up VXLAN interface
ip link set dev vxlan10 up

# --------------------------------------------
# 🔹 Configure Router 2 (router_fech-cha-2)
# --------------------------------------------

# Create a Linux bridge
ip link add br0 type bridge

# Bring up the bridge interface
ip link set dev br0 up

# Assign an IP to eth0 (Underlay Network)
ip addr add 10.1.1.2/24 dev eth0

# Create VXLAN interface with multicast group (same group as Router 1)
ip link add name vxlan10 type vxlan id 10 dev eth0 group 239.1.1.1 dstport 4789

# Assign an IP to VXLAN interface (Overlay Network)
ip addr add 20.1.1.2/24 dev vxlan10

# Bring up VXLAN interface
ip link set dev vxlan10 up

# Add eth1 and vxlan10 to the bridge
brctl addif br0 eth1
brctl addif br0 vxlan10

# --------------------------------------------
# 🔹 Configure Host 1 (host_fech-cha-1)
# --------------------------------------------

# Assign an IP to eth1 (Connects to VXLAN network)
ip addr add 30.1.1.1/24 dev eth1

# --------------------------------------------
# 🔹 Configure Host 2 (host_fech-cha-2)
# --------------------------------------------

# Assign an IP to eth1 (Connects to VXLAN network)
ip addr add 30.1.1.2/24 dev eth1

