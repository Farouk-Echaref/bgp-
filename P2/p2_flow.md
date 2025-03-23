## P2 topology design:

+-----------------+          +-----------------+
| host_fech-cha-1 |          | host_fech-cha-2 |
| 30.1.1.1/24     |          | 30.1.1.2/24     |
| eth1            |          | eth1            |
+--------+--------+          +--------+--------+
         |                            |
         |                            |
+--------+--------+          +--------+--------+
| router_fech-cha-1 |        | router_fech-cha-2 |
| 10.1.1.1/24 (eth0) |        | 10.1.1.2/24 (eth0) |
| br0 (Bridge)      |        | br0 (Bridge)      |
| vxlan10 (20.1.1.1)|        | vxlan10 (20.1.1.2)|
+--------+--------+          +--------+--------+
         | (VXLAN Tunnel)            | (VXLAN Tunnel)
         |============================|
          (VXLAN ID 10 over eth0)

## p2 topology flow:

+ Underlay (Physical Network - L3)

10.1.1.1/24 (Router 1, eth0)

10.1.1.2/24 (Router 2, eth0)

This network carries VXLAN traffic (UDP-encapsulated Ethernet frames).

+ VXLAN Overlay (Virtual Network - L2)

VXLAN interfaces have IP addresses (20.1.1.x) so that routers can encapsulate/decapsulate packets.

These do NOT act as default gateways for hosts.

The bridge (br0) connects VXLAN to the host-facing interface (eth1).

+ Bridges in Linux
A Linux bridge is like a software switch that connects different interfaces at Layer 2 (Ethernet level).

How It Works Here
br0 connects eth1 (the host interface) and vxlan10 (the VXLAN interface).

Traffic from host_fech-cha-1 (eth1) enters br0.

The bridge forwards the packet to vxlan10, which encapsulates it in VXLAN UDP.

The encapsulated packet is sent over eth0 (the underlay) to router_fech-cha-2.

router_fech-cha-2 decapsulates the packet and forwards it via br0 to eth1 (host_fech-cha-2).

(1) host_fech-cha-1 sends IP packet to 30.1.1.2
   ┌──────────────┐
   │ 30.1.1.1     │
   │ host_fech-1  │
   └──────┬───────┘
          │
          ▼
   ┌──────────────┐
   │ eth1         │  Packet enters Router 1
   └──────┬───────┘
          │
          ▼
   ┌──────────────┐
   │ br0 (Bridge) │  Bridges packet from eth1 → vxlan10
   └──────┬───────┘
          │
          ▼
   ┌──────────────┐
   │ vxlan10      │  Encapsulates in VXLAN UDP
   └──────┬───────┘
          │
          ▼
   ┌──────────────┐
   │ eth0 (10.1.1.1) │  Sends VXLAN packet over network
   └──────┬───────┘
          │  UDP VXLAN Encapsulation
          ▼
     🛰  VXLAN Tunnel
          ▼
   ┌──────────────┐
   │ eth0 (10.1.1.2) │  Receives VXLAN packet
   └──────┬───────┘
          │
          ▼
   ┌──────────────┐
   │ vxlan10      │  Decapsulates VXLAN
   └──────┬───────┘
          │
          ▼
   ┌──────────────┐
   │ br0 (Bridge) │  Bridges packet from vxlan10 → eth1
   └──────┬───────┘
          │
          ▼
   ┌──────────────┐
   │ 30.1.1.2     │
   │ host_fech-2  │
   └──────────────┘


