# --------------------------------------------
# 🔹 Use a Lightweight Alpine Base Image
# --------------------------------------------
# - Alpine Linux is a small and security-focused distribution, ideal for network testing.
FROM alpine:latest  

# --------------------------------------------
# 🔹 Install Full Networking Tools (No BusyBox)
# --------------------------------------------
# The following tools are installed for better network troubleshooting:
# - vim               → Text editor for modifying files
# - tcpdump           → Packet capture utility
# - iproute2          → Advanced network interface management
# - iputils           → Includes ping, tracepath, etc.
# - net-tools         → Provides netstat, ifconfig, etc.
# - netcat-openbsd    → A full-featured version of netcat (instead of BusyBox nc)
RUN apk update && apk upgrade && apk add --no-cache \
    vim \
    tcpdump \
    iproute2 \
    iputils \
    net-tools \
    netcat-openbsd
