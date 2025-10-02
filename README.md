# Miko Project

A hands-on learning project for Kubernetes and Cilium networking. This repository contains various configurations and examples to explore container orchestration, service mesh, and advanced networking concepts.

## Project Overview

Miko serves as a practical playground for learning:
- **Kubernetes fundamentals** - Deployments, Services, StatefulSets, and more
- **Cilium networking** - Advanced CNI features, ingress, and security policies
- **Container orchestration** - Real-world application deployment patterns

## Directory Structure

### `k8s-multi-nodes/`
Kubernetes cluster deployment configurations for macOS using Lima VMs:

**Components:**
- **Lima VM Templates** - Virtual machine configurations for cluster nodes
- **Kubeadm Bootstrap** - Kubernetes cluster initialization scripts
- **Network Configuration** - CNI and networking setup for multi-node cluster
- **Task Automation** - Taskfile.yaml for streamlined cluster management

**Features:**
- Multi-node Kubernetes cluster on macOS
- Lima-based lightweight virtualization
- Automated cluster provisioning and management
- Development-friendly local cluster setup

### `mongo/`
MongoDB deployment configurations with multiple approaches:

**Components:**
- **MongoDB Deployment/StatefulSet** - Database server configurations
- **Mongo Express** - Web-based MongoDB administration interface
- **ConfigMaps & Secrets** - Configuration and credential management

**Features:**
- Single-instance deployment with ClusterIP service
- StatefulSet deployment with persistent storage and headless service
- Replica set configuration for high availability
- Secure credential management

### `ingress/`
Cilium ingress configurations for external access:

**Components:**
- **Ingress Gateway** - Cilium-powered ingress controller setup
- **Route Configuration** - Traffic routing rules for services
- **TLS Termination** - SSL/TLS certificate management

**Features:**
- Exposes Mongo Express web interface externally
- Cilium-native ingress implementation
- Advanced load balancing and traffic management

### `self-signed-certs/`
Self-signed certificate generation toolkit for TLS learning:

**Components:**
- **Certificate Generation Script** - Automated OpenSSL-based certificate creation
- **Configuration Templates** - CA, server, and client certificate configurations
- **Security Best Practices** - ECC curves and proper certificate extensions

**Features:**
- Complete PKI setup with CA, server, and client certificates
- Configurable output directory and certificate parameters
- Development-ready TLS certificates for learning purposes
- Compatible with modern security standards and policies

### `star-wars-isovalent-lab/`
Cilium network policy demonstration using Star Wars themed application:

**Components:**
- **Star Wars Application** - DeathStar service with TieFighter and X-Wing client pods
- **Network Policy Examples** - Both Kubernetes and Cilium network policy configurations
- **Traffic Observability** - Hubble integration for network traffic visualization
- **Policy Comparisons** - Visual diagrams showing policy enforcement differences

**Features:**
- Hands-on network policy learning with themed scenario
- Comparison between Kubernetes and Cilium network policies
- HTTP-level traffic filtering with Cilium policies
- Real-time network observability with Hubble UI

## Learning Goals

This project helps you understand:
- Kubernetes workload patterns (Deployment vs StatefulSet)
- Service discovery and networking
- Persistent storage management
- Ingress and external traffic handling
- Configuration management with ConfigMaps and Secrets
- Cilium advanced networking features

## Contributing

This is a personal learning project. Feel free to fork and experiment with your own modifications!

---
*Happy learning with Kubernetes and Cilium! 🚀*