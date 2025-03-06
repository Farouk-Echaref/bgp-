# bgp-

This project is focused on network simulation and configuration using BGP EVPN, VXLAN, GNS3, and Docker. 
You will be working with routing protocols like BGP (MP-BGP), OSPF, and IS-IS, and simulating a virtualized data center network.

## whats bgp: border gateway protocol

- routing protocol that connects the internet
https://www.youtube.com/watch?v=A1KXPpqlNZ4&ab_channel=EyeonTech

### part1:
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


