# WireGuard FRR

WireGuard FRR is a docker container that runs a WireGuard VPN server and FRR (Free Range Routing) for dynamic routing using ospf.

## 🛠️ Setup

```bash
# Clone the repository
git clone https://github.com/riseupgroup/wireguard-frr.git

# Change to the directory
cd wireguard-frr
```

### ⚙️ Configuration

1. Set the environment variables in the `compose.yaml`
    - `ROUTER_ID`: Your peers unique ID (e.g. the peer ip in the tunnel `"10.0.0.1"`)
    - `ALLOW_ROUTING_INTO_NETWORK`: Set to `true` to allow routing from the default interface to all peers
    - `NETWORKS`: The networks your peer should announce for routing (e.g. something the node should announce `"192.168.0.0/24 172.20.0.0/24"`)
    - `NEIGHBOR_RANGE`: The network range for all OSPF neighbors (e.g. `"10.0.0.0/24"`)
    - `NEIGHBORS`: All OSPF neighbors to peer with (e.g. `"10.0.0.1 10.0.0.2"`)
2. For each remote peer, create a wireguard config file in the `wireguard` directory
    - Use `wireguard.conf.example` as a template
    - `Address`: The IP address of the peer in the tunnel (e.g. `10.0.0.1`)
    - `PrivateKey`: The private key of the peer (generate keys using: `wg genkey | tee privatekey | wg pubkey > publickey`)
    - `PublicKey`: The public key of the remote peer
    - `Endpoint`: The endpoint of the remote peer (e.g. `example.com:51820`)

### 🚀 Run the container

```bash
docker compose up -d # add `--build` after updating
```

## 📢 Contributing

Feel free to **open issues** or **submit pull requests** on GitHub! 🚀

## 📜 License

This project is licensed under the MIT License.
