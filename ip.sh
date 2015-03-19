#!/usr/bin/env bash

set -ex

# Narrow script for working with interfaces and routes.
# Meant for password-less sudo.
#
# Usage:
#   sudo ./ip.sh tun tun0 fc12::3456
#   sudo ./ip.sh addr tun0 172.23.23.2
#   sudo ./ip.sh route tun0 172.23.23.0/24
#   sudo ./ip.sh gw default 172.23.23.1
#
# If peered over UDP, add host routes before adding the default route:
#   sudo ./ip.sh gw 37.139.20.30 192.168.3.1

cmd=$1
ifname=$2
addr=$3

if [[ "$cmd" = "tun" ]]; then
  ip tuntap add mode tun dev "$ifname"
  ip addr add "$addr"/8 dev "$ifname"
  ip link set mtu 1304 dev "$ifname"
  ip link set "$ifname" up
fi

if [[ "$cmd" = "addr" ]]; then
  ip addr add dev "$ifname" "$addr"
fi

if [[ "$cmd" = "route" ]]; then
  ip route add dev "$ifname" "$addr"
fi

if [[ "$cmd" = "default" ]]; then
  ip route add default via "$addr"
fi

if [[ "$cmd" = "host" ]]; then
  echo TODO: add host route
  exit 1
fi
