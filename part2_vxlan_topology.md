# BGP Part 2 VXLAN Topology

## Overview
This topology represents a VXLAN, which is used to extend a Layer 2 (L2) network over a Layer 3 (L3) network.

## **Network Components**

- **Hosts:** `host_fech-cha-1` and `host_fech-cha-2` act as endpoints that need to communicate as if they are in the same L2 network (same VLAN), even though they are separated by routers.
- **Routers:** `router_fech-cha-1` and `router_fech-cha-2` serve as VXLAN Tunnel Endpoints (VTEPs). They encapsulate Ethernet frames from hosts into VXLAN packets and forward them over the network.
- **Switch:** `switch_fech-cha-1` connects both routers. In a real-world scenario, this switch could represent a Layer 3 core network or an underlay transport network that carries VXLAN traffic between VTEPs (e.g., the internet, a data center fabric, a routed backbone, or a Layer 3 switch).

## **How VXLAN Works in This Topology**

### **Encapsulation Process:**
1. When `host_fech-cha-1` sends traffic to `host_fech-cha-2`, `router_fech-cha-1` encapsulates the Ethernet frame into a VXLAN packet.
2. This VXLAN packet is then forwarded through `switch_fech-cha-1` to `router_fech-cha-2`.

### **Decapsulation Process:**
1. `router_fech-cha-2` receives the VXLAN packet, extracts the original Ethernet frame, and forwards it to `host_fech-cha-2`.

### **VXLAN ID (VNI) for Segmentation:**
- Each VXLAN network is identified by a VXLAN Network Identifier (VNI), acting like a VLAN ID.
- This allows multiple virtual networks to coexist over the same infrastructure without interfering.

## **Why is the Switch Between the Routers?**
- The switch represents the underlay network, which is responsible for transporting VXLAN packets between VTEPs (`router_fech-cha-1` and `router_fech-cha-2`).
- In a real network, this could be an IP fabric with multiple routers and switches instead of a single switch.

## **How Layer 2 (L2) Extension Over Layer 3 (L3) Works**
- Normally, VLANs are restricted to a single L2 domain (a single switch or interconnected switches).
- VXLAN allows VLANs to be extended over a Layer 3 (IP-based) network, making it possible for hosts in different locations to communicate as if they were in the same VLAN.

## **Underlay and Overlay Networks**
VXLAN separates the network into two parts:

### **Underlay Network (Physical or IP-based network)**
- This is the real network that carries VXLAN packets.
- In this topology, the underlay is the network between `router_fech-cha-1` and `router_fech-cha-2`, connected through `switch_fech-cha-1`.
- The underlay can be a traditional IP network with routing (OSPF, BGP, etc.).

### **Overlay Network (VXLAN Virtual Network)**
- This is the virtualized Layer 2 network that sits on top of the underlay.
- It allows `host_fech-cha-1` and `host_fech-cha-2` to communicate as if they were in the same VLAN, even though the underlay network is routing VXLAN packets at Layer 3.
- The VXLAN header includes a VXLAN Network Identifier (VNI), which acts like a VLAN ID but supports up to 16 million virtual networks.

## **Why is VXLAN Used Here?**
### **In Traditional Networking:**
- VLANs are limited to 4,096 IDs and cannot span multiple IP networks.

### **VXLAN Overcomes These Limitations By:**
- Extending Layer 2 over Layer 3, allowing VLANs to work across different locations.
- Providing up to 16 million VNIs, compared to only 4,096 VLANs.
- Enabling a single virtual L2 network across routers, allowing `host_fech-cha-1` and `host_fech-cha-2` to communicate transparently.

## **Why Not Just Route Traffic Instead of Using VXLAN?**
Some applications require L2 connectivity. Routing traffic at L3 would break them.

### **Key Reasons for VXLAN:**
1. **Some Applications Require L2 Connectivity:**
   - Certain legacy applications, clustering solutions, and network storage systems require Layer 2 communication to function properly.
   - If hosts were split into different subnets with routing between them, these applications may break.
   - VXLAN allows L2 connectivity across different networks.

2. **Multi-Tenancy in Data Centers:**
   - Large data centers host multiple customers (tenants) needing their own isolated networks.
   - VXLAN allows each tenant to have their own virtual network over a shared infrastructure.

3. **Scalability Beyond VLAN Limits:**
   - VLANs are limited to 4,096 IDs.
   - VXLAN supports 16 million VNIs, making it much more scalable.

4. **Extending Networks Across Different Physical Locations:**
   - VLANs cannot be easily extended between different buildings, data centers, or cities.
   - VXLAN allows machines in different locations to share the same virtual L2 network over an L3 infrastructure.

## **Why is VXLAN Useful in Cloud Environments and Data Centers?**
### **Without VXLAN:**
- Separate physical VLANs would be required for each tenant.
- VLANs are hard to extend between different data centers.

### **With VXLAN:**
- Each tenant gets a virtual network identified by a VNI.
- The same VXLAN network can span multiple data centers.
- The physical network only needs to route IP packets, simplifying deployment.

### **Example:**
- A web hosting provider has customers with VMs in multiple data centers.
- VXLAN ensures that the customer’s VMs remain in the same subnet, even across locations.

## **VXLAN Tunnel Endpoints (VTEPs)**
### **Definition:**
A VXLAN Tunnel Endpoint (VTEP) is a device that:
- Encapsulates normal Ethernet frames inside VXLAN (UDP/IP packets).
- Decapsulates VXLAN packets back into normal Ethernet frames.
- Forwards traffic as if it were in a normal Layer 2 network.

### **In This Topology:**
- `router_fech-cha-1` and `router_fech-cha-2` act as VTEPs.
- They take Ethernet frames from their connected hosts and encapsulate them inside VXLAN packets.
- The packets traverse the L3 network through `switch_fech-cha-1` before reaching the other VTEP.

## **VXLAN in Multi-Data Center Environments**
### **Challenges of VLANs:**
- VLAN tags only work within a single L2 network.
- Extending VLANs over long distances requires special L2 transport (MPLS, SD-WAN, etc.).
- If a company has multiple data centers, they usually require separate networks and routing.

### **How VXLAN Helps:**
- Extends L2 over L3, allowing data centers to share a common VLAN.
- Does not require special L2 transport, just an IP network.
- Uses VXLAN Tunnels over a routed network between data centers.

### **Result:**
Even if `host_dc1` (Data Center 1) and `host_dc2` (Data Center 2) are physically separated, they communicate as if they were on the same VLAN.

## **Why VXLAN is Important for Multi-Data Center Deployments**
- Extends L2 domains without complex transport solutions.
- Supports up to 16 million VNIs, solving VLAN scaling issues.
- Used by cloud providers (AWS, Azure, Google Cloud) for multi-tenant networking.
- Enables seamless application deployment across geographic locations.

### **Explanation of the Static VXLAN Configuration in Your Topology**

This configuration sets up **VXLAN** between `router_fech-cha-1` and `router_fech-cha-2`, enabling **Layer 2 (L2) connectivity** between `host_fech-cha-1` and `host_fech-cha-2` over a **Layer 3 (L3) network**.

---

### **1️⃣ Explanation for `router_fech-cha-1`**
1. **Create a bridge interface (`br0`)**  
   ```bash
   ip link add br0 type bridge
   ip link set dev br0 up
   ```
   - `br0` is a Linux bridge that will connect the local host interface (`eth1`) and the VXLAN interface (`vxlan10`).
   - This ensures that frames received from either side (host or VXLAN tunnel) are forwarded correctly.

2. **Assign an IP address to `eth0` (the underlay interface)**  
   ```bash
   ip addr add 10.1.1.1/24 dev eth0
   ```
   - This IP (`10.1.1.1`) is part of the **underlay network** and used to send VXLAN packets.

3. **Create a VXLAN interface (`vxlan10`)**  
   ```bash
   ip link add name vxlan10 type vxlan id 10 dev eth0 remote 10.1.1.2 local 10.1.1.1 dstport 4789
   ```
   - `vxlan10`: The VXLAN tunnel interface.
   - `id 10`: The VXLAN Network Identifier (VNI), which acts like a VLAN ID.
   - `dev eth0`: Uses `eth0` as the transport interface.
   - `remote 10.1.1.2`: The **destination VTEP** (`router_fech-cha-2`).
   - `local 10.1.1.1`: The **source VTEP** (`router_fech-cha-1`).
   - `dstport 4789`: The standard VXLAN port.

4. **Assign an IP address to `vxlan10` (the overlay network)**  
   ```bash
   ip addr add 20.1.1.1/24 dev vxlan10
   ```
   - This IP (`20.1.1.1`) is part of the **overlay network** where hosts will communicate.

5. **Attach `eth1` (host-facing interface) and `vxlan10` to the bridge (`br0`)**  
   ```bash
   brctl addif br0 eth1
   brctl addif br0 vxlan10
   ```
   - `eth1`: Connects to `host_fech-cha-1`.
   - `vxlan10`: Connects to the VXLAN tunnel.
   - Traffic between `host_fech-cha-1` and `vxlan10` is **bridged**, simulating an extended Layer 2 network.

6. **Enable the VXLAN interface**  
   ```bash
   ip link set dev vxlan10 up
   ```
   - Ensures the VXLAN tunnel interface is active.

7. **Display Interface Information (Optional)**  
   ```bash
   ip addr show eth0  # Show IP address of eth0
   ip -d link show vxlan10  # Show VXLAN details
   ```

---

### **2️⃣ Explanation for `router_fech-cha-2`**
Configuration is **similar** to `router_fech-cha-1`, but with **mirrored IPs**:

- Assigns `10.1.1.2/24` to `eth0` (underlay network).
- Creates `vxlan10` with:
  - `remote 10.1.1.1` (pointing to `router_fech-cha-1`).
  - `local 10.1.1.2`.
- Assigns `20.1.1.2/24` to `vxlan10`.
- Bridges `vxlan10` and `eth1`.

---

### **3️⃣ Explanation for Hosts**
Each host is **assigned an IP within the overlay network**:

- `host_fech-cha-1`: `30.1.1.1/24` on `eth1`
- `host_fech-cha-2`: `30.1.1.2/24` on `eth1`
- These are **L2 endpoints** that communicate over VXLAN.




---

## **🔍 Key Takeaways**
1. **`router_fech-cha-1` and `router_fech-cha-2` are VTEPs**  
   - They encapsulate/de-encapsulate VXLAN packets to extend Layer 2 over Layer 3.

2. **VXLAN uses `eth0` for transport (underlay) and `eth1` for host connectivity**  
   - `eth0` = IP-based transport network.
   - `eth1` = Connects to the hosts (bridged with VXLAN).

3. **Traffic flows as if hosts are in the same L2 domain**  
   - `host_fech-cha-1` and `host_fech-cha-2` can communicate without being aware of VXLAN.
   - The routers **bridge** the VXLAN tunnel to `eth1`, making it transparent.

---

### **🚀 Next Steps**
- **Verify Connectivity**  
  - Run `ping 30.1.1.2` from `host_fech-cha-1` to confirm VXLAN works.
- **Check VXLAN Tunnel Status**  
  ```bash
  ip -d link show vxlan10
  ```
- **Enable VXLAN Learning (Optional)**  
  - If using multicast, enable **dynamic VXLAN learning** instead of static remote IP.

---

This explanation + script should fully clarify how VXLAN works in your topology! 🚀 Let me know if you need more details. 😊