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
# for FRR: https://www.watchguard.com/help/docs/help-center/en-US/Content/en-US/Fireware/dynamicrouting/bgp_commands_frr.html
# enable BGP (iBGP - internal BGP) with AS number 1 (same AS across all routers in this setup)
router bgp 1
 # resource: https://networklessons.com/bgp/bgp-peer-groups-on-cisco-ios
 # https://is5com.com/HTML%20User%20Manuals/Config_Guid_1.12.05/BGP%20Config%20Guide/HTML5/CM-BGP-iBiome-1.12.05-EN/iMX_Common/Configuration_Guides/DITA_Topics/BGP/3_15_peer_groups.html
 # Define iBGP peer group for dynamic neighbors
 # Peer groups allow you to configure multiple neighbors with the same settings, reducing configuration repetition.
 # Instead of defining each neighbor separately, a peer group applies the same configuration to all iBGP neighbors.
 neighbor ibgp peer-group

 # In iBGP, all peers must be in the same AS (unlike eBGP, where peers have different AS numbers)
 neighbor ibgp remote-as 1  # Since this is iBGP, all routers have the same AS

 # why: https://forum.networklessons.com/t/the-use-of-the-update-source-command/7418
 # why2: https://learningnetwork.cisco.com/s/question/0D53i00000qgWsZCAU/update-source-loopback
 # Loopback interfaces never go down, unlike physical interfaces.
 # If a physical link fails, the router can still reach the loopback via another path (as long as OSPF is running).
 # Ensures BGP sessions remain stable even if an interface goes down.
 # Without this command, BGP would use the physical interface (e.g., eth0 or vxlan10), which could go down!
 neighbor ibgp update-source lo  # Use loopback interface for stability

 # Listen for dynamic BGP neighbors from leaf routers in the specified range
 # Automatically discovers new BGP neighbors in 1.1.1.0/29 using bgp listen range
 # Any router with an IP in 1.1.1.0/29 that tries to establish BGP will automatically become a neighbor.
 # These neighbors are automatically assigned to the ibgp peer group.
 # Why use bgp listen range?
 # Instead of manually configuring each neighbor (neighbor 1.1.1.2 remote-as 1, etc.), this automatically detects neighbors in the given subnet.
 # Useful in dynamic setups where new routers might be added.
 bgp listen range 1.1.1.0/29 peer-group ibgp
exit

# Configure EVPN (Ethernet VPN) within iBGP for VXLAN overlay
# resource: https://networklessons.com/vxlan/vxlan-mp-bgp-evpn-l2-vni
# from cisco: https://www.cisco.com/c/en/us/td/docs/switches/lan/catalyst9400/software/release/16-10/configuration_guide/lyr2/b_1610_lyr2_9400_cg/configuring_vxlan_bgp_evpn.pdf
# for frr: https://vincent.bernat.ch/en/blog/2017-vxlan-bgp-evpn
# from FRR docs: https://docs.frrouting.org/en/latest/evpn.html
# This enables EVPN as a BGP address family.
# EVPN (Ethernet VPN) is used in VXLAN networks for:
# Layer 2 extension over an IP network (bridging VLANs across data centers).
# Layer 3 forwarding (routing between VXLAN segments).
# MAC and IP mobility (handling dynamic changes in endpoint locations).
address-family l2vpn evpn
 # This activates EVPN for the ibgp peer group.
 # BGP will now exchange EVPN routes with iBGP neighbors.
 # Why activate EVPN for iBGP?

 # VXLAN needs a control plane to learn MAC addresses and routes dynamically.
 # Instead of relying on flood-and-learn (like traditional VXLAN), BGP EVPN distributes MAC/IP information efficiently
 neighbor ibgp activate  # Activate EVPN for iBGP peer group
 # resource frr: https://docs.frrouting.org/en/latest/bgp.html#route-reflector
 # In iBGP, routers normally don't forward routes learned from one iBGP peer to another (to prevent loops).
 # A route reflector allows iBGP routers to share routes, avoiding the need for a full mesh. 
 # Without this, every leaf router would have to be manually connected to every other router
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