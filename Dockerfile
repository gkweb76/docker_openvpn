# Base image is Alpine Linux
# docker build -t gkweb76/openvpn:2.4.4 -t gkweb76/openvpn:latest -t gkweb76/openvpn:2.4.4-r1 .
FROM alpine:3.7
LABEL maintainer="Guillaume Kaddouch"
LABEL twitter="@gkweb76"

# Install openvpn
RUN apk add --update --no-cache openvpn=2.4.4-r1 && \
    rm -rf /var/cache/apk/* /tmp/* /var/tmp/*

# Healtcheck
HEALTHCHECK --interval=10s --timeout=3s --start-period=5s --retries=3 CMD ifconfig tun0 || exit 1

# Port available
EXPOSE 1194/udp

# Start OpenVPN daemon based on /etc/openvpn/openvpn.conf
VOLUME ["/etc/openvpn"]

# Environnement variables
ENV OPENVPN_VERSION 2.4.4-r1

# Start openvpn daemon
CMD ["/usr/sbin/openvpn", "--config", "/etc/openvpn/openvpn.conf"]
