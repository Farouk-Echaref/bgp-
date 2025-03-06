# **BGP, EVPN, and VXLAN Learning Roadmap**

## **Project Overview**
This project requires setting up a network simulation using **GNS3 and Docker** to explore **BGP, EVPN, and VXLAN**. It consists of three major parts:
1. **GNS3 Configuration with Docker**
2. **Discovering VXLAN**
3. **Discovering BGP with EVPN**

The project must be executed in a **virtual machine**, and all configurations should be well documented.

---

## **Required Skills & Learning Path**
### **Step 1: Understanding the Basics (Before Starting the Project)**
#### **Networking Fundamentals**
- **OSI Model & TCP/IP**: Understanding how networking layers interact.
- **IP Addressing & Subnetting**: CIDR, subnet masks, and IP allocation.
- **Routing Basics**: Static vs. dynamic routing, default routes.

#### **Linux & Docker**
- **Linux CLI**: File navigation, `vim`, `nano`, `iproute2`, `net-tools`.
- **Docker Basics**: Images, containers, networking (`bridge`, `host`, `macvlan`).

#### **GNS3 Setup**
- Installing GNS3 in a **VM**.
- Configuring GNS3 to use **Docker** containers.
- Understanding **GNS3 network modes**.

---

### **Step 2: GNS3 Configuration with Docker (Project Part 1)**
#### **Learning Requirements**
- How to **build and run custom Docker images**.
- How to **connect Docker containers** inside **GNS3**.
- Understanding **Quagga/FRRouting (FRR)**:
  - **BGP (Border Gateway Protocol)**
  - **OSPF (Open Shortest Path First)**
  - **IS-IS (Intermediate System to Intermediate System)**

#### **Practical Steps**
1. Install **GNS3** & **Docker**.
2. Build a **BusyBox-based Docker image** for testing.
3. Build a **router image** with **FRRouting (FRR)** supporting BGP, OSPF, and IS-IS.
4. Run these images in **GNS3**.
5. Ensure basic **connectivity** between instances.
6. Document the configurations in a `P1/` directory.

---

### **Step 3: Discovering VXLAN (Project Part 2)**
#### **Learning Requirements**
- What is **VXLAN (RFC 7348)** and how it extends Layer 2 over Layer 3?
- Understanding **VXLAN encapsulation** (VNI, VTEPs, multicast/static VXLANs).
- Configuring **Linux bridges and VXLAN interfaces**.
- Using **tcpdump** to analyze VXLAN packets.

#### **Practical Steps**
1. Configure a **VXLAN (ID 10) bridge**.
2. Use **static VXLAN setup** between two nodes.
3. Extend the setup using **multicast VXLAN**.
4. Verify **MAC address learning & packet encapsulation**.
5. Document everything in `P2/`.

---

### **Step 4: Discovering BGP with EVPN (Project Part 3)**
#### **Learning Requirements**
- What is **EVPN (RFC 7432)** and how it integrates with BGP?
- **BGP EVPN Route Types**:
  - Type 2: MAC/IP routes
  - Type 3: Inclusive Multicast routes
- **Route Reflectors (RR)** in BGP.
- **Using OSPF as an underlay**.

#### **Practical Steps**
1. Configure a **BGP EVPN overlay**.
2. Use **Route Reflectors (RR) to distribute EVPN routes**.
3. Verify **MAC learning via BGP**.
4. Test **connectivity between endpoints**.
5. Document everything in `P3/`.

---

## **Final Deliverables**
- **GNS3 Project Files** (`P1/`, `P2/`, `P3/` in a Git repo).
- **Well-commented configurations**.
- **Network verification results** (ping, tcpdump, `show` commands).

By following this structured approach, you will **gradually build expertise** in GNS3, Docker, BGP, EVPN, and VXLAN without getting overwhelmed.

