#!bin/ash
# Replace $LAN_NET by your LAN network
# Replace $OVPN_GW by your openvpn container network gateway (e.g 172.19.0.1)

# This file allows your OpenVPN container to NAT outbound traffic and to send traffic back to your LAN

iptables -t nat -D POSTROUTING -o tun0 -j MASQUERADE
ip route del $LAN_NET via $OVPN_GW dev eth0
iptables -t nat -A POSTROUTING -o tun0 -j MASQUERADE
ip route add $LAN_NET via $OVPN_GW dev eth0
