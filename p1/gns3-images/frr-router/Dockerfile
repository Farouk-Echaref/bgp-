# --------------------------------------------
# 🔹 Use the Official FRRouting (FRR) Image
# --------------------------------------------
# This base image is preconfigured with FRRouting (FRR), an open-source routing
# software that supports multiple protocols, including BGP, OSPF, IS-IS, and more.
FROM frrouting/frr:latest

# --------------------------------------------
# 🔹 Configure FRRouting (FRR) Services
# --------------------------------------------
# - Enables "integrated vtysh" mode, allowing all FRR daemons to be controlled from a single CLI.
# - Updates the FRR daemons configuration to enable:
#   - BGP  (Border Gateway Protocol)
#   - OSPF (Open Shortest Path First)
#   - IS-IS (Intermediate System to Intermediate System)
#   - Zebra (FRR's core routing manager)
RUN echo 'service integrated-vtysh-config' > /etc/frr/vtysh.conf && \
    sed -i \
    -e 's/bgpd=no/bgpd=yes/g' \
    -e 's/ospfd=no/ospfd=yes/g' \
    -e 's/isisd=no/isisd=yes/g' \
    -e 's/zebra=no/zebra=yes/g' \
    /etc/frr/daemons

# --------------------------------------------
# 🔹 Install Full Networking Tools (No BusyBox)
# --------------------------------------------
# The following networking tools are installed for advanced debugging and troubleshooting:
# - iproute2         → Provides commands for network interface and routing table management
# - iputils          → Includes tools like ping and tracepath
# - nano & vim       → Text editors for modifying configuration files
# - net-tools        → Provides utilities like netstat and ifconfig
# - netcat-openbsd   → A full-featured version of netcat (instead of the limited BusyBox nc)
RUN apk update && apk add --no-cache \
    iproute2 \
    iputils \
    nano \
    vim \
    net-tools \
    netcat-openbsd

# --------------------------------------------
# 🔹 Ensure Proper Permissions for FRR Configuration Files
# --------------------------------------------
# - Modifies file permissions to prevent access issues when configuring FRR.
RUN chmod 777 /etc/frr/ && chown frr:frr /etc/frr/*

# --------------------------------------------
# 🔹 Expose Required Ports for Routing Protocols
# --------------------------------------------
# - 179   → BGP communication between routers
# - 2601  → Zebra CLI management
# - 2604  → OSPF communication
# - 2608  → IS-IS communication
EXPOSE 179 2601 2604 2608
