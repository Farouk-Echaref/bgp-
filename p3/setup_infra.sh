# Spine RR Configuration (Route Reflector)

# cisco commands resources:
# https://www.cisco.com/c/en/us/td/docs/routers/access/800M/software/800MSCG/routconf.html
# https://www.netwrix.com/cisco-commands-cheat-sheet.html

# cisco config support in frr
# https://docs.frrouting.org/projects/dev-guide/en/latest/cli.html

# Enter vtysh mode to configure the router
# shell for FRR daemons => provides a combined frontend to all FRR daemons in a single combined session
vtysh

# Enter the config terminal mode in the privileged mode to enter the global configuration mode, and the user can modify the global configuration of the switch/router
# resource: https://www.cisco.com/c/en/us/td/docs/wireless/mwam/user/guide/mwam1/CLI.pdf
# resource: https://www.linkedin.com/pulse/cisco-switch-basic-configuration-cian-hu/
conf t

# Set hostname for identification
# resource: https://www.cisco.com/E-Learning/bulk/public/tac/cim/cib/using_cisco_ios_software/cmdrefs/hostname.htm
hostname router_fech-cha-1

# Disable IPv6 forwarding (not required for this setup)
# best practice for security and performance reasons
# some services (e.g., systemd, kernel) might still generate IPv6 packets, and that adds load cs they will still be routed
# If an attacker sends IPv6 packets (like rogue Router Advertisements), your router could accidentally forward them, creating a security risk.
no ipv6 forwarding

# Configure physical interfaces with IP addresses (point-to-point links for OSPF and iBGP communication)
# from cisco : https://www.cisco.com/E-Learning/bulk/public/tac/cim/cib/using_cisco_ios_software/cmdrefs/interface.htm
interface eth0
 ip address 10.1.1.1/30  # Link to leaf router_fech-cha-2
 # unlike in cisco config, FRR on Linux does not require no shutdown for interfaces to be operational
 # in linux (FRR) Interfaces are up unless explicitly disabled via ip link set ethX down.
 # FRR relies on the Linux kernel for interface state
 #no shutdown
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

# Since all routers are part of the same AS (Autonomous System) 1, iBGP is used for exchanging routing information
# from cisco: https://www.cisco.com/c/en/us/td/docs/ios/iproute_bgp/command/reference/irg_book/irg_bgp1.html
# enable BGP (iBGP - internal BGP) with AS number 1 (same AS across all routers in this setup)
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


# Leaf Configuration (router_fech-cha-2)

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


# Leaf Configuration (router_fech-cha-3)

ip link add br0 type bridge
ip link set dev br0 up
ip link add vxlan10 type vxlan id 10 dstport 4789
ip link set dev vxlan10 up
brctl addif br0 vxlan10
brctl addif br0 eth0

vtysh
conf t
hostname router_fech-cha-3
no ipv6 forwarding

interface eth1
ip address 10.1.1.6/30
ip ospf area 0
exit

interface lo
ip address 1.1.1.3/32
ip ospf area 0
exit

router bgp 1
neighbor 1.1.1.1 remote-as 1
neighbor 1.1.1.1 update-source lo
exit

address-family l2vpn evpn
neighbor 1.1.1.1 activate
advertise-all-vni
exit-address-family
exit

router ospf
exit

# Leaf Configuration (router_fech-cha-4)

ip link add br0 type bridge
ip link set dev br0 up
ip link add vxlan10 type vxlan id 10 dstport 4789
ip link set dev vxlan10 up
brctl addif br0 vxlan10
brctl addif br0 eth0

vtysh
conf t
hostname router_fech-cha-4
no ipv6 forwarding

interface eth2
ip address 10.1.1.10/30
ip ospf area 0
exit

interface lo
ip address 1.1.1.4/32
ip ospf area 0
exit


router bgp 1
neighbor 1.1.1.1 remote-as 1
neighbor 1.1.1.1 update-source lo
exit

address-family l2vpn evpn
neighbor 1.1.1.1 activate
advertise-all-vni
exit-address-family
exit

router ospf
exit



# Assign IP address to hosts interfaces (connected to leaf router)

# Host Configuration (host_fech-cha-1)
ip addr add 20.1.1.1/24 dev eth1
# Host Configuration (host_fech-cha-2)
ip addr add 20.1.1.2/24 dev eth0
# Host Configuration (host_fech-cha-3)
ip addr add 20.1.1.3/24 dev eth0