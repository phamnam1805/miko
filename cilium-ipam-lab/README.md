# Cilium LoadBalancer IPAM & L2 Announcements Lab

This lab demonstrates Cilium's LoadBalancer IP Address Management (IPAM) and Layer 2 Announcements functionality for providing external access to Kubernetes services without requiring cloud provider load balancers.

## Overview

This hands-on lab shows how to configure Cilium to automatically assign external IP addresses to LoadBalancer services and announce them via ARP/NDP to make them accessible from outside the cluster. This is particularly useful for on-premises or bare-metal Kubernetes deployments.

**Lab Source:**
This lab is adapted from [Isovalent's Cilium LoadBalancer IPAM & L2 Announcements Lab](https://isovalent.com/labs/cilium-lb-ipam-l2-announcements/).

## Key Concepts

### Cilium LoadBalancer IPAM
- **Purpose**: Automatically assigns external IP addresses to LoadBalancer services
- **Benefits**: Eliminates dependency on cloud provider load balancers
- **Configuration**: Uses IP pools to define available address ranges

### Cilium L2 Announcement Policy  
- **Purpose**: Announces assigned IPs via ARP (IPv4) or NDP (IPv6) protocols
- **Benefits**: Makes services accessible from external networks
- **Mechanism**: Responds to ARP requests for assigned LoadBalancer IPs

## Lab Components

### Application (`star-wars-app.yaml`)
Star Wars themed application deployment featuring:
- **DeathStar Service**: Backend service configured as LoadBalancer type
- **External IP Requirement**: DeathStar service needs external IP for outside access

### Cilium IP Pool (`cilium-ip-pool.yaml`)
IP address management configuration:
- **Address Range**: 192.168.105.230 - 192.168.105.239 (10 available IPs)
- **Auto-Assignment**: Automatically assigns IPs to LoadBalancer services with defined selectors

### L2 Announcement Policy (`cilium-l2-policy.yaml`)
Layer 2 network announcement configuration:
- **ARP Responses**: Responds to ARP requests for assigned IPs
- **Service Discovery**: Makes LoadBalancer services discoverable on local network
- **Node Selection**: Configures which nodes can announce IPs

## Lab Instructions

### Step 1: Deploy the Star Wars Application

```bash
kubectl apply -f star-wars-app.yaml
```

Verify the DeathStar service is created but has no external IP yet:
```bash
kubectl get svc deathstar
```

### Step 2: Configure Cilium IP Pool

Apply the IP pool configuration to define available LoadBalancer IP range:
```bash
kubectl apply -f cilium-ip-pool.yaml
```

Verify the IP pool is created:
```bash
kubectl get ciliumloadbalancerippool
```

### Step 3: Configure L2 Announcement Policy

Apply the L2 announcement policy to enable ARP responses:
```bash
kubectl apply -f cilium-l2-policy.yaml
```

Verify the policy is applied:
```bash
kubectl get ciliuml2announcementpolicy
```

### Step 4: Verify External IP Assignment

Check that the DeathStar service now has an external IP from the pool:
```bash
kubectl get svc deathstar
```

You should see an IP from the range 192.168.5.230-239 assigned to the EXTERNAL-IP field.

### Step 5: Test External Connectivity

From a machine on the same network (192.168.5.0/24), test connectivity:
```bash
# Replace <EXTERNAL-IP> with the assigned IP
curl http://<EXTERNAL-IP>/v1/
```

### Step 6: Monitor ARP Traffic (Optional)

Monitor ARP traffic to see L2 announcements in action:
```bash
# On the external machine
sudo tcpdump -i <interface> arp host <EXTERNAL-IP>
```

## Expected Results

1. **IP Assignment**: DeathStar service receives external IP from pool (192.168.5.230-239)
2. **ARP Responses**: Cilium nodes respond to ARP requests for the assigned IP
3. **External Access**: Service is accessible from external network via assigned IP
4. **Load Balancing**: Traffic is distributed across available DeathStar pods

## Key Learning Points

- **IPAM Integration**: Understanding how Cilium manages LoadBalancer IP allocation
- **L2 Networking**: Learning ARP-based service announcement mechanisms  
- **On-Premises Solutions**: Implementing LoadBalancer services without cloud providers
- **Network Policies**: Configuring IP pools and announcement policies
- **Service Mesh**: External access patterns for microservices architectures

## Troubleshooting

**Service has no external IP:**
- Verify IP pool is properly configured and has available addresses
- Check Cilium agent logs for IPAM errors

**External connectivity fails:**
- Ensure L2 announcement policy is applied
- Verify network routing to the IP pool subnet
- Check ARP table on external machines

**ARP issues:**
- Confirm nodes can announce on the correct network interface
- Verify no IP conflicts exist in the network range

## Cleanup

Remove all lab resources:
```bash
kubectl delete -f cilium-l2-policy.yaml
kubectl delete -f cilium-ip-pool.yaml  
kubectl delete -f star-wars-app.yaml
```

## Further Learning

- Explore BGP announcements as an alternative to L2 announcements
- Configure multiple IP pools for different service classes
- Implement network policies to secure LoadBalancer services
- Investigate integration with external load balancers

---
*This lab provides hands-on experience with Cilium's advanced LoadBalancer capabilities for on-premises Kubernetes deployments! 🚀*