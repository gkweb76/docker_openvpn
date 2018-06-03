# Supported tags
-   [`2.4.4`, `2.4.4-r1`, `latest` (*2.4*)]



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
Grab the host real path, for instance /var/lib/docker/volumes/openvpn/_data (referred as 'ovpn_volume_path' below)

Then copy your files there, using the correct path:  
`cp ./openvpn.conf ovpn_volume_path`  
`cp ./auth.conf ovpn_volume_path`  
... and any other files you may require.  

Apply a strict chmod so that only root can modify these files:  
`chmod 644 ovpn_volume_path/openvpn.conf`  
`chmod 644 ovpn_volume_path/auth.conf`  

Finally start your container:  
-   **as a client**  
`docker container run --rm -v openvpn:/etc/openvpn --cap-add=NET_ADMIN \`  
`--device /dev/net/tun --read-only=true --tmpfs /tmp --name openvpn gkweb76/openvpn`  

-   **as a server**  
`docker container run --rm -v openvpn:/etc/openvpn --cap-add=NET_ADMIN \`  
`-p 1194:1194/udp --device /dev/net/tun --read-only=true --tmpfs /tmp \`  
`--name openvpn gkweb76/openvpn`  


# Docker compose example  
`version: "3.5"`  
  
`services:`  
&nbsp;&nbsp;  `openvpn:`  
&nbsp;&nbsp;  `image: gkweb76/openvpn:2.4.4`  
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


# Tested on

[Ubuntu](https://www.ubuntu.com/) 18.04 LTS and Docker 18.04.0 CE (Community Edition).

# License
