# Spine RR Configuration (Route Reflector)

# Enter vtysh mode to configure the router
# shell for FRR daemons => https://www.youtube.com/watch?v=_sQ0kXW5E0I&ab_channel=wezlwezl
vtysh

# Enter configuration mode
conf t

# Set hostname for identification
hostname router_fech-cha-1

# Disable IPv6 forwarding (not required for this setup)
no ipv6 forwarding

# Configure physical interfaces with IP addresses (point-to-point links for OSPF and iBGP communication)
interface eth0
 ip address 10.1.1.1/30  # Link to leaf router_fech-cha-2
exit

interface eth1
 ip address 10.1.1.5/30  # Link to leaf router_fech-cha-3
exit

interface eth2
 ip address 10.1.1.9/30  # Link to leaf router_fech-cha-4
exit

# Configure loopback interface (used for iBGP peering and stability in routing)
interface lo
 ip address 1.1.1.1/32  # Unique identifier for this router
exit

# Configure iBGP (internal BGP) with AS number 1 (same AS across all routers in this setup)
router bgp 1

 # Define iBGP peer group for dynamic neighbors
 neighbor ibgp peer-group
 neighbor ibgp remote-as 1  # Since this is iBGP, all routers have the same AS
 neighbor ibgp update-source lo  # Use loopback interface for stability

 # Listen for dynamic BGP neighbors from leaf routers in the specified range
 bgp listen range 1.1.1.0/29 peer-group ibgp
exit

# Configure EVPN (Ethernet VPN) within iBGP for VXLAN overlay
address-family l2vpn evpn
 neighbor ibgp activate  # Activate EVPN for iBGP peer group
 neighbor ibgp route-reflector-client  # Act as route reflector for leafs
exit-address-family
exit

# Configure OSPF (Open Shortest Path First) for underlay network routing
router ospf
 network 0.0.0.0/0 area 0  # Advertise all connected interfaces in OSPF area 0
exit


# Leaf Configuration (router_fech-cha-2 as an example, others are similar)

ip link add br0 type bridge
ip link set dev br0 up
ip link add vxlan10 type vxlan id 10 dstport 4789
ip link set dev vxlan10 up
brctl addif br0 vxlan10
brctl addif br0 eth1
vtysh

conf t

hostname router_fech-cha-2
no ipv6 forwarding  # Disable IPv6 forwarding

# Configure physical interface eth0 with IP and OSPF
interface eth0
 ip address 10.1.1.2/30  # Connected to router_fech-cha-1
 ip ospf area 0  # Enable OSPF on this interface
exit

# Configure loopback interface for iBGP peering
interface lo
 ip address 1.1.1.2/32  # Unique identifier for this router
 ip ospf area 0  # Advertise in OSPF
exit

# Configure iBGP peering with the route reflector (spine)
router bgp 1
 neighbor 1.1.1.1 remote-as 1  # Connect to RR in AS 1
 neighbor 1.1.1.1 update-source lo  # Use loopback for stability
exit

# Enable EVPN for VXLAN overlays
address-family l2vpn evpn
 neighbor 1.1.1.1 activate  # Activate EVPN with RR
 advertise-all-vni  # Advertise all VXLAN Network Identifiers (VNIs)
exit-address-family
exit

# Configure OSPF for underlay routing
router ospf
exit


# Host Configuration (hostrouter_fech-cha-1)

# Assign IP address to host interface (connected to leaf router)
ip address add 20.1.1.1/24 dev eth1
