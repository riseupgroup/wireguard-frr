FROM alpine:3.21

WORKDIR /config

COPY entrypoint.bash /config/entrypoint.bash

RUN apk add --no-cache \
    wireguard-tools \
    frr \
    iproute2 \
    iptables
    
RUN sed -i "s/ospfd=no/ospfd=yes/g" /etc/frr/daemons

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD [ "/bin/bash", "/usr/lib/frr/frrinit.sh", "status" ]

ENTRYPOINT ["/bin/bash", "/config/entrypoint.bash"]
