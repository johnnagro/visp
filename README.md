# cjdns for Virtual ISPs

- server: listen on [fc12::3456]:12234
- client: GET [fc12::3456]:12234/tunnels
- client: POST [fc12::3456]:12234/lease
- server: create lease 172.23.23.2, allowConnection()
- client: connectTo()

```
ip addr add dev tun0 172.23.23.1
ip route add dev tun0 172.23.23.0/24
```

```
ip addr add dev tun0 172.23.23.2 (cjdns does it already)
ip route add dev tun0 172.23.23.0/24
ip route add default via 172.23.23.1

ip route add 37.139.20.30 via 192.168.3.1
ip route add 188.166.62.155 via 192.168.3.1

echo 1 > /proc/sys/net/ipv4/conf/all/forwarding

iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables -A FORWARD -i eth0 -o tun0 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i eth0 -o tun0 -j ACCEPT
```

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
