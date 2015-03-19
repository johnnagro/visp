# cjdns for Virtual ISPs

- Automatic setup of cjdns IPTunnel on server and client
- IPTunnel Announcements
- IPTunnel Leases

## Random Notes

Reading list:

- https://github.com/hyperboria/cjdns/blob/master/doc/tunnel.md
- https://github.com/hyperboria/cjdns/blob/master/doc/nat-gateway.md
- http://web.cjdns.ca/faq.txt

Client setup:

```
ip addr add dev tun0 172.23.23.2 (cjdns does it already)
ip route add dev tun0 172.23.23.0/24
ip route add default via 172.23.23.1
```

Make sure UDP peerings use the original gateway, e.g. your ISP:

```
ip route add 37.139.20.30 via 192.168.3.1
ip route add 188.166.62.155 via 192.168.3.1
```

Server setup:

```
ip addr add dev tun0 172.23.23.1
ip route add dev tun0 172.23.23.0/24
```

Packet forwarding, and NAT:

```
echo 1 > /proc/sys/net/ipv4/conf/all/forwarding

iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables -A FORWARD -i eth0 -o tun0 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i eth0 -o tun0 -j ACCEPT
```

Tunnel Announcements:

- server: listen on [fc12::3456]:12234
- client: GET [fc12::3456]:12234/tunnels
- client: POST [fc12::3456]:12234/lease
- server: create lease 172.23.23.2, allowConnection()
- client: connectTo()

```
GET /tunnels
[
  {
    "lease": "http://[fc12::3456]:12234/lease",
    "routes": ["default", "172.23.23.0/24", "8.8.8.8"]
  }
]

GET /lease
POST /lease
{
  "public_key": "asdf.k",
  "ipv4_address": "172.23.23.2/24",
  "routes": ["default", "172.23.23.0/24", "8.8.8.8"],
  "gateways": ["172.23.23.1"]
}

GET /nameservers (later)
```

## License

Published under the terms of the GNU General Public License, version 3 or later.
See [LICENSE](LICENSE) file.
