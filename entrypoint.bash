#!/bin/bash

EXIT=0
if [ -z "$ROUTER_ID" ]; then
    echo "ROUTER_ID is not set (e.g. \"10.0.0.1\")"
    EXIT=1
fi

if [ -z "$NETWORKS" ]; then
    echo "NETWORKS is not set (e.g. \"192.168.0.0/24 172.20.0.0/24\")"
    EXIT=1
fi

if [ -z "$NEIGHBOR_RANGE" ]; then
    echo "NEIGHBOR_RANGE is not set (e.g. \"10.0.0.0/24\")"
    EXIT=1
fi

if [ -z "$NEIGHBORS" ]; then
    echo "NEIGHBORS is not set (e.g. \"10.0.0.1 10.0.0.2\")"
    EXIT=1
fi

if [ $EXIT -ne 0 ]; then
    exit $EXIT
fi

HOSTNAME=$(cat /etc/hostname)
CONFIG="/etc/frr/frr.conf"
CONFIGS=(/etc/wireguard/*)
DEFAULT_ROUTE=$(ip route show default | grep -o -e "[^ ]\+ dev [^ ]\+")
DEFAULT_DEVICE=$(echo $DEFAULT_ROUTE | awk "{print \$2}")

cat > $CONFIG << EOF
hostname $HOSTNAME
log stdout informational
no ipv6 forwarding
service integrated-vtysh-config
!
EOF

for path in ${CONFIGS[@]}; do
    filename=${path##*/}
    interface=${filename%.*}

    wg-quick down $interface
    wg-quick up $interface
    iptables -I FORWARD 1 -i $interface -j ACCEPT
    iptables -I FORWARD 1 -o $interface -j ACCEPT

    iptables -t nat -I POSTROUTING 1 -s $NEIGHBOR_RANGE -o $DEFAULT_DEVICE -j MASQUERADE
    for network in ${NETWORKS[@]}; do
        iptables -t nat -I POSTROUTING 1 -s $network -o $DEFAULT_DEVICE -j MASQUERADE
    done

    cat >> $CONFIG << EOF
interface $interface
    ip ospf dead-interval 240
    ip ospf hello-interval 5
    ip ospf priority 200
exit
EOF
done

cat >> $CONFIG << EOF
!
router ospf
    ospf router-id $ROUTER_ID
    redistribute kernel route-map mp-lan
EOF

for network in ${NETWORKS[@]}; do
    echo "    network $network area 0" >> $CONFIG
done

echo "    network $NEIGHBOR_RANGE area 0" >> $CONFIG
for neighbor in ${NEIGHBORS[@]}; do
    echo "    neighbor $neighbor" >> $CONFIG
done

echo "exit" >> $CONFIG
echo "!" >> $CONFIG

for network in ${NETWORKS[@]}; do
    echo "access-list ac-lan permit $network" >> $CONFIG
done

echo "!" >> $CONFIG

for neighbor in ${NEIGHBORS[@]}; do
    echo "access-list ac-ospf permit $neighbor/32" >> $CONFIG
done

cat >> $CONFIG << EOF
!
route-map mp-lan permit 10
    match ip address ac-lan
exit
!
route-map mp-ospf permit 10
    match ip address ac-ospf
exit
!
line vty
EOF

for network in ${NETWORKS[@]}; do
    ip route add $network via $DEFAULT_ROUTE
done

/usr/lib/frr/frrinit.sh start
PID=$(cat /run/frr/watchfrr.pid)
tail -f /proc/$PID/fd/2
