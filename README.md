# cjdns for Virtual ISPs

- pick subnet, e.g. 172.23.23.0/24
- set up ip on server
- start announcing
- on knock, allowConnection*()

http://[fc06:c135:28a5:8c0b:dd4e:bcb6:d4d6:c96d]:11236

```
GET /tunnels
[
  {
    "publicKey": "asdf.k",
    "routes": ["0.0.0.0/0", "172.23.23.0/24"],
    "gateways": ["172.23.23.1"]
  }
]

GET /knock
POST /knock
{
  "ipv4_address": "172.23.23.2/24",
  "routes": ["0.0.0.0/0", "172.23.23.0/24"],
  "gateways": ["172.23.23.1"]
}

GET /nameservers (later)
```
