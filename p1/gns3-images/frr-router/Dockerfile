# Use the official FRRouting image, which already includes BGP, OSPF, and IS-IS support.
FROM frrouting/frr:latest

# Ensures that BGP, OSPF, IS-IS, and Zebra are enabled in the FRRouting configuration.
RUN echo 'service integrated-vtysh-config' > /etc/frr/vtysh.conf && \
    sed -i \
    -e 's/bgpd=no/bgpd=yes/g' \      # Enable BGP daemon
    -e 's/ospfd=no/ospfd=yes/g' \    # Enable OSPF daemon
    -e 's/isisd=no/isisd=yes/g' \    # Enable IS-IS daemon
    -e 's/zebra=no/zebra=yes/g' \    # Enable Zebra (routing manager)
    /etc/frr/daemons

# Install additional useful networking tools
RUN apt update && apt install -y \
    iproute2 \        # For managing network interfaces
    iputils-ping \    # For basic connectivity testing
    busybox \         # Lightweight Unix utilities
    nano \            # Text editor for quick edits
    vim \             # Text editor for general edits
    net-tools         # Includes ifconfig, netstat, etc.

# Ensure proper permissions for FRR
RUN chmod 777 /etc/*
RUN chmod 777 /etc/frr/
RUN chown frr:frr /etc/frr/*

# Expose necessary FRR ports 
# 179 for BGP, 2601 for zebra CLI, 2604 for OSPF CLI, 2608 ISIS CLI
EXPOSE 179 2601 2604 2608

# Start FRRouting and keep the container running
CMD /usr/lib/frr/frrinit.sh start && tail -f /dev/null
