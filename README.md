# Wireguard FRR

Wireguard FRR is a docker container that runs a Wireguard VPN server and FRR (Free Range Routing) for dynamic routing using ospf.

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
    - `NETWORKS`: The networks your peer should announce for routing (e.g. something the node should announce `"192.168.0.0/24 172.20.0.0/24"`)
    - `NEIGHBOR_RANGE`: The network range for all OSPF neighbors (e.g. `"10.0.0.0/24"`)
    - `NEIGHBORS`: All OSPF neighbors to peer with (e.g. `"10.0.0.1 10.0.0.2"`)
2. Create a wireguard config file in the `wireguard` directory
    - Use `wireguard.conf.example` as a template
    - `Address`: The IP address of the peer in the tunnel (e.g. `10.0.0.1`)
    - `PrivateKey`: The private key of the peer (generate keys using: `wg genkey | tee privatekey | wg pubkey > publickey`)
    - For each remote peer, add a `[Peer]` section with the following fields:
        - `PublicKey`: The public key of the remote peer
        - `Endpoint`: The endpoint of the remote peer (e.g. `example.com:51820`)
        - Also copy the other fields from the example config

### 🚀 Run the container

```bash
docker compose up -d
```

## 📢 Contributing

Feel free to **open issues** or **submit pull requests** on GitHub! 🚀

## 📜 License

This project is licensed under the MIT License.
