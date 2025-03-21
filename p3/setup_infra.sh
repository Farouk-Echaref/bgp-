# spine RR Config

# Enter vtysh mode
vtysh

# Config mode
conf t
hostname router_fech-cha-1

# Turn off IPv6 forwarding
no ipv6 forwarding

# Setup eth0
interface eth0
ip address 10.1.1.1/30
exit

# Setup eth1
interface eth1
ip address 10.1.1.5/30
exit

# Setup eth2
interface eth2
ip address 10.1.1.9/30
exit

# Setup loobpack interface
interface lo
ip address 1.1.1.1/32
exit

# Setup iBGP with AS number 1
router bgp 1

# Create an iBGP peering group named ibgp
neighbor ibgp peer-group

# Assign this peering group to AS 1 (same AS number cs we are in iBGP)
neighbor ibgp remote-as 1

# Neighbors will communicate through loobpack interface
neighbor ibgp update-source lo

# Setup iBGP dynamic neighbors listen on specified range and add them to our ibgp peering group
# per the subject: Our leafs (VTEP) will be configured to have dynamic relations
bgp listen range 1.1.1.0/29 peer-group ibgp
exit

# Configure a neighbor in peer group DYNAMIC as Route Reflector client
address-family l2vpn evpn
neighbor ibgp activate
neighbor ibgp route-reflector-client
exit-address-family
exit

# Enable routing process OSPF on all IP networks on area 0
router ospf
network 0.0.0.0/0 area 0
exit

# Leaf 2
ip link add br0 type bridge
ip link set dev br0 up
ip link add vxlan10 type vxlan id 10 dstport 4789
ip link set dev vxlan10 up
brctl addif br0 vxlan10
brctl addif br0 eth1

vtysh

conf t

hostname router_fech-cha-2
no ipv6 forwarding

interface eth0
ip address 10.1.1.2/30
ip ospf area 0

exit 

interface lo
ip address 1.1.1.2/32
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

# host 1
ip address add 20.1.1.1/24 dev eth1
