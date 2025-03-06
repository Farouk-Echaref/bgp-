# Use the official FRRouting image, which already includes BGP, OSPF, and IS-IS support.
FROM frrouting/frr:latest

# --------------------------------------------
# 🔹 Configure FRRouting (FRR) Services
# --------------------------------------------
# - Enables the "integrated vtysh" mode, allowing all FRR daemons to be controlled from one CLI.
# - Modifies the FRR configuration file to enable essential routing protocols:
#   BGP  (Border Gateway Protocol)
#   OSPF (Open Shortest Path First)
#   IS-IS (Intermediate System to Intermediate System)
#   Zebra (FRR's core routing manager)
RUN echo 'service integrated-vtysh-config' > /etc/frr/vtysh.conf && \
    sed -i \
    -e 's/bgpd=no/bgpd=yes/g' \
    -e 's/ospfd=no/ospfd=yes/g' \
    -e 's/isisd=no/isisd=yes/g' \
    -e 's/zebra=no/zebra=yes/g' \
    /etc/frr/daemons

# --------------------------------------------
# 🔹 Install Additional Useful Networking Tools
# --------------------------------------------
# The following packages are installed for better network debugging and management:
# - `iproute2`       → Used to view and modify routing tables
# - `iputils-ping`   → Provides the `ping` command for testing connectivity
# - `busybox`        → Lightweight UNIX utilities for troubleshooting
# - `nano` & `vim`   → Text editors for modifying config files
# - `net-tools`      → Includes commands like `ifconfig`, `netstat`
RUN apk update && apk add --no-cache \
    iproute2 \
    iputils \
    busybox \
    nano \
    vim \
    net-tools

# --------------------------------------------
# 🔹 Ensure Proper Permissions for FRR Configuration Files
# --------------------------------------------
# - Modifies file permissions to prevent access issues in FRR.
RUN chmod 777 /etc/frr/
RUN chown frr:frr /etc/frr/*

# --------------------------------------------
# 🔹 Expose Required Ports for Routing Protocols
# --------------------------------------------
# These ports are used by different FRR services:
# - `179`   → BGP communication between routers
# - `2601`  → Zebra CLI management
# - `2604`  → OSPF communication
# - `2608`  → IS-IS communication
EXPOSE 179 2601 2604 2608
