# bgp-AS

![alt text](bgp-simplified.svg)

This project is focused on network simulation and configuration using BGP EVPN, VXLAN, GNS3, and Docker. 
You will be working with routing protocols like BGP (MP-BGP), OSPF, and IS-IS, and simulating a virtualized data center network.

## whats bgp: border gateway protocol (path vector routing protocol)
 
- An autonomous system is a group of networks and gateways for which one administrative authority has responsibility. Gateways are interior neighbors if they reside on the same autonomous system and exterior neighbors if they reside on different autonomous systems.

An AS routing policy is a list of the IP address space that the AS controls, plus a list of the other ASes to which it connects. This information is necessary for routing packets to the correct networks. ASes announce this information to the Internet using the Border Gateway Protocol (BGP).

resource: https://www.cloudflare.com/en-gb/learning/network-layer/what-is-an-autonomous-system/

- we know that Static routing describes a process by which routing is configured with fixed values that do not change at runtime unless manually edited. Static routes are used with and without dynamic Routing protocols and usually share the same routing table as those protocols.

- bgp is a dynamic routing protocol, used by ISP.

- from RFC:
 The primary function of a BGP speaking system is to exchange network
   reachability information with other BGP systems.  This network
   reachability information includes information on the list of
   Autonomous Systems (ASes) that reachability information traverses.
   This information is sufficient for constructing a graph of AS
   connectivity for this reachability from which routing loops may be
   pruned, and, at the AS level, some policy decisions may be enforced.

- from CLOUDFLARE:
ASes announce their routing policy to other ASes and routers via the Border Gateway Protocol (BGP). BGP is the protocol for routing data packets between ASes. Without this routing information, operating the Internet on a large scale would quickly become impractical: data packets would get lost or take too long to reach their destinations.

Each AS uses BGP to announce which IP addresses they are responsible for and which other ASes they connect to. BGP routers take all this information from ASes around the world and put it into databases called routing tables to determine the fastest paths from AS to AS. When packets arrive, BGP routers refer to their routing tables to determine which AS the packet should go to next.

With so many ASes in the world, BGP routers are constantly updating their routing tables. As networks go offline, new networks come online, and ASes expand or contract their IP address space, all of this information has to be announced via BGP so that BGP routers can adjust their routing tables.

- routing protocol that connects the internet
https://www.youtube.com/watch?v=A1KXPpqlNZ4&ab_channel=EyeonTech

## part1:
- frr routing demo:
https://www.youtube.com/watch?v=D4nk5VSUelg&ab_channel=AhmadNadeem
- setup gns3 in linux mint3:
https://docs.gns3.com/docs/getting-started/installation/linux/
after install check :
```bash
gns3 &
```
gui will open .
server type: local
server path: /usr/bin/gns3server
hostbinding: localhost
port: 3080 tcp

- make busybox docker image
- make frr routing image.

- after constructing those images using dockerfiles, we are going to build them so we can use them later using gns3, check the shell script in the confs folder in part 1.

- after constructing the two docker images:
![alt text](frr_routes_busy_alpine_docker_images.png)

- now we gonna construct our router based on the frr routing image and host based on the alpine image, in gns3, so gns3 will be configured with docker env.
ill put the descriptive video



https://github.com/user-attachments/assets/7f70fdba-7bc8-47a9-9401-93ec3f0ed3ed



