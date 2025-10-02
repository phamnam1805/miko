# Star Wars Cilium Network Policy Lab

This directory contains the Star Wars example from Cilium for learning network policies and observability.

## Overview

This lab demonstrates network policy enforcement using both Kubernetes and Cilium network policies with a Star Wars themed application scenario.

## Files Description

### Application Deployment
- **`star-wars-app.yaml`** - Main application deployment (adapted from [Cilium's official example](https://raw.githubusercontent.com/cilium/cilium/HEAD/examples/minikube/http-sw-app.yaml))
- **`star-wars-ingress.yaml`** - Ingress configuration for external access

### Network Policies
- **`k8s-network-policy.yaml`** - Standard Kubernetes NetworkPolicy configuration
- **`cilium-network-policy.yaml`** - Cilium-specific network policy with advanced features

### Visual References  
- **`k8s-network-policy.png`** - Network topology diagram for Kubernetes policy
- **`cilium-network-policy.png`** - Network topology diagram for Cilium policy

## Application Components

The Star Wars application consists of:
- **DeathStar Service** - Main backend service (using `cilium/deathstar` image)
- **TieFighter Pod** - "Good guy" client pod
- **X-Wing Pod** - "Bad guy" client pod

## Setup and Usage

### 1. Deploy the Application
```bash
kubectl create namespace star-wars
kubectl -n star-wars apply -f star-wars-app.yaml
kubectl -n star-wars apply -f star-wars-ingress.yaml
```

### 2. Enable Cilium Hubble with UI for Traffic Observability
```bash
cilium hubble disable
cilium hubble enable --ui
cilium hubble ui
```

### 3. Test Kubernetes Network Policy

Apply the standard Kubernetes NetworkPolicy:
```bash
kubectl -n star-wars apply -f k8s-network-policy.yaml
```

**Expected Behavior:**
- ❌ X-Wing: Cannot access `deathstar/v1/request-landing`
- ✅ TieFighter: Can access both `deathstar/v1/request-landing` and `deathstar/v1/exhaust-port`

### 4. Test Cilium Network Policy

Switch to Cilium NetworkPolicy for more granular control:
```bash
kubectl -n star-wars delete -f k8s-network-policy.yaml
kubectl -n star-wars apply -f cilium-network-policy.yaml
```

**Expected Behavior:**
- ❌ X-Wing: Still cannot access `deathstar/v1/request-landing`
- ✅ TieFighter: Can access `deathstar/v1/request-landing`
- ❌ TieFighter: Cannot access `deathstar/v1/exhaust-port` (blocked by Cilium policy)

## Key Learning Points

1. **Policy Comparison**: Understanding differences between Kubernetes and Cilium network policies
2. **Granular Control**: Cilium policies offer HTTP-level filtering capabilities
3. **Observability**: Using Hubble to visualize network traffic and policy enforcement
4. **Security Patterns**: Implementing microsegmentation in microservices architecture

## Traffic Testing

Test connectivity between pods:
```bash
# From TieFighter pod
kubectl -n star-wars exec tiefighter -- curl -s -XPOST deathstar.star-wars.svc.cluster.local/v1/request-landing
kubectl -n star-wars exec tiefighter -- curl -s -XPUT deathstar.star-wars.svc.cluster.local/v1/exhaust-port

# From X-Wing pod  
kubectl -n star-wars exec xwing -- curl -s -XPOST deathstar.star-wars.svc.cluster.local/v1/request-landing
```

## Cleanup

Remove all resources:
```bash
kubectl -n star-wars delete -f cilium-network-policy.yaml
kubectl -n star-wars delete -f star-wars-ingress.yaml
kubectl -n star-wars delete -f star-wars-app.yaml
kubectl delete namespace star-wars
```

## Visual References

The network policy behaviors are illustrated in the corresponding PNG diagrams:
- `k8s-network-policy.png` - Shows Kubernetes NetworkPolicy enforcement
- `cilium-network-policy.png` - Shows Cilium NetworkPolicy with HTTP-level controls