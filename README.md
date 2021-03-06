# Supported tags
-   [`2.4.4`, `2.4.4-r1`, `latest` (*[2.4.4-r1/Dockerfile](https://github.com/gkweb76/openvpn/blob/master/2.4.4-r1/Dockerfile)*)]



# What is OpenVPN
[OpenVPN](https://openvpn.net) is an open source VPN from OpenVPN Technologies, that can be used as a VPN server or as a VPN client.
![](https://openvpn.net/templates/telethra/img/ovpntech_logo-s.png)



# Why using this image ?
This image is a vanilla OpenVPN software without any additional packages installed. Indeed, often other packages are pre-installed such as Easy-RSA which is not always suitable, for instance if you want to use OpenVPN on a router as a client. Also, you may want to use OpenVPN as a server and install yourself any other packages you may require.

This image is based on [Alpine Linux](https://alpinelinux.org/) and therefore is built with [LibreSSL](https://www.libressl.org/), which is a more secure fork of OpenSSL made by the [OpenBSD](https://www.openbsd.org/) team. Also Alpine Linux is generally immune to vulnerabilities targetting components not installed in this Operating System, such as: bash (e.g. Shellshock vulnerability), OpenSSL (e.g. Heartbleed vulnerability), glibc (e.g Ghost vulnerability). Also, Alpine Linux has a much smaller image size compared to other OS thanks to less packages installed by default and not relying on glibc, providing faster image download, and reduced attack surface, hence better security.

![](https://wiki.alpinelinux.org/w/resources/assets/alogo.png)



# Maintained by
Guillaume Kaddouch  
Blog: [https://networkfilter.blogspot.com/](https://networkfilter.blogspot.com/)  
Twitter: [@gkweb76](https://twitter.com/gkweb76)  
Github: [gkweb76](https://github.com/gkweb76/)  



# How to use this image from command line
First create your _openvpn_ volume:  
`docker volume create openvpn`  
`docker volume inspect openvpn | grep Mount`  
Grab the host real path, for instance /var/lib/docker/volumes/openvpn/_data (referred as '$OVPN_VOLUME_PATH' below)

Then copy your files there, using the correct path:  
`cp ./openvpn.conf $OVPN_VOLUME_PATH`  
`cp ./auth.conf $OVPN_VOLUME_PATH`  
... and any other files you may require.  

Apply a strict chmod so that only root can modify these files:  
`chmod 644 $OVPN_VOLUME_PATH/openvpn.conf`  
`chmod 644 $OVPN_VOLUME_PATH/auth.conf`  

Finally start your container:  
-   **as a client**  
sysctl command line option only required on a router  
`docker container run --rm -v openvpn:/etc/openvpn --cap-add=NET_ADMIN \`  
`--device /dev/net/tun --read-only=true --tmpfs /tmp --name openvpn \`  
`--sysctl net.ipv4.ip_forward=1 gkweb76/openvpn`  

-   **as a server**  
`docker container run --rm -v openvpn:/etc/openvpn --cap-add=NET_ADMIN \`  
`-p 1194:1194/udp --device /dev/net/tun --read-only=true --tmpfs /tmp \`  
`--name openvpn gkweb76/openvpn`  


# Docker compose example  
`version: "3.5"`  
  
`services:`  
&nbsp;&nbsp;  `openvpn:`  
&nbsp;&nbsp;  `image: gkweb76/openvpn:latest`  
&nbsp;&nbsp;  `container_name: openvpn`  
&nbsp;&nbsp;  `read_only: yes`  
&nbsp;&nbsp;  `networks:`  
&nbsp;&nbsp;&nbsp;&nbsp;  `- openvpn`  
&nbsp;&nbsp;  `cap_add: # add capabilities`  
&nbsp;&nbsp;&nbsp;&nbsp;  `- NET_ADMIN`  
&nbsp;&nbsp;  `devices: # create /dev/net/tun inside container`  
&nbsp;&nbsp;&nbsp;&nbsp;  `- /dev/net/tun`  
&nbsp;&nbsp;    `sysctls: # update container /etc/sysctl.conf`  
&nbsp;&nbsp;&nbsp;&nbsp;      `net.ipv4.ip_forward: 1`  
&nbsp;&nbsp;    `volumes:`  
&nbsp;&nbsp;&nbsp;&nbsp;      `- openvpn:/etc/openvpn # put your conf files here`  
&nbsp;&nbsp;&nbsp;&nbsp;      `- /etc/localtime:/etc/localtime:ro # keep container clock in sync with host`  
&nbsp;&nbsp;    `tmpfs:`  
&nbsp;&nbsp;&nbsp;&nbsp;      `- /tmp`  
&nbsp;&nbsp;    `restart: "unless-stopped"`  
  
`# Networks declaration`  
`networks:`  
&nbsp;&nbsp;  `openvpn:`  
  
`# Volumes declaration`  
`volumes:`  
&nbsp;&nbsp;  `openvpn:`  
    
If you need help with your compose file, check the official [documentation](https://docs.docker.com/compose/compose-file/).  

# On a home VPN gateway (router)
When the router is a client from an external VPN server, and is forwarding traffic from the LAN to the VPN tunnel, you may want to add in your `openvpn.conf` file the following lines:  
`script-security 2` 
`up /etc/openvpn/init.sh`  

Then inside `init.sh` you can write the following to NAT outbound traffic, and to send back the traffic to the LAN. Replace `$LAN_NET` by your LAN network and `$OVPN_GW` by your openvpn container network gateway (e.g 172.19.0.1):  
`#!bin/ash`  
`iptables -t nat -D POSTROUTING -o tun0 -j MASQUERADE` 
`ip route del $LAN_NET via $OVPN_GW dev eth0` 
`iptables -t nat -A POSTROUTING -o tun0 -j MASQUERADE` 
`ip route add $LAN_NET via $OVPN_GW dev eth0` 


# Tested on

[Ubuntu](https://www.ubuntu.com/) 18.04 LTS and Docker 18.04.0 CE (Community Edition), with ProtonVPN
![](https://protonvpn.com/assets/img/media/protonvpn-logo-grey.png)

# License

MIT License
