# MongoDB Deployment on Kubernetes

This folder contains configurations for deploying MongoDB on Kubernetes cluster with two different approaches.

## Overview

MongoDB can be deployed using either:
1. **Deployment + ClusterIP Service** - Simple single-instance deployment
2. **StatefulSet + Headless Service** - Scalable deployment with persistent storage

Both approaches use:
- `mongodb-configmap.yaml` - Configuration data (database URL)
- `mongodb-secret.yaml` - Sensitive data (username, password)
- `mongo-express.yaml` - Web-based MongoDB admin interface

## Method 1: Deployment with ClusterIP Service

This method deploys MongoDB as a single instance using Deployment and exposes it via ClusterIP service.

### Files Required:
- `mongodb-configmap.yaml` - Contains database URL
- `mongodb-secret.yaml` - Contains MongoDB credentials
- `mongodb.yaml` - MongoDB Deployment + ClusterIP Service
- `mongo-express.yaml` - Mongo Express web interface

### Deployment Steps:
```bash
# 1. Apply ConfigMap
kubectl apply -f mongodb-configmap.yaml

# 2. Apply Secret
kubectl apply -f mongodb-secret.yaml

# 3. Deploy MongoDB
kubectl apply -f mongodb.yaml

# 4. Deploy Mongo Express
kubectl apply -f mongo-express.yaml
```

### Access:
- MongoDB: Internal access via `mongodb-service:27017`
- Mongo Express: External access via LoadBalancer service

## Method 2: StatefulSet with Headless Service

This method deploys MongoDB using StatefulSet for scalability and persistent storage with Headless Service for stable network identity.

### Files Required:
- `mongodb-configmap.yaml` - Contains database URL
- `mongodb-secret.yaml` - Contains MongoDB credentials
- `mongodb-headless-service.yaml` - Headless service for StatefulSet
- `mongodb-stateful-set.yaml` - MongoDB StatefulSet configuration

### Deployment Steps:
```bash
# 1. Apply ConfigMap
kubectl apply -f mongodb-configmap.yaml

# 2. Apply Secret
kubectl apply -f mongodb-secret.yaml

# 3. Create Headless Service
kubectl apply -f mongodb-headless-service.yaml

# 4. Deploy StatefulSet
kubectl apply -f mongodb-stateful-set.yaml
```

### Initialize Replica Set (Optional):
```bash
# Initialize MongoDB replica set for high availability
./init-replica-set.sh
```

### Access:
- MongoDB Pods: Direct access via `mongodb-stateful-set-0.mongodb-headless-service:27017`
- Replica Set: Multiple pods for high availability
- Mongo Express: Requires Ingress configuration for external access from outside the cluster

## Configuration Details

### ConfigMap (`mongodb-configmap.yaml`)
Contains non-sensitive configuration:
```yaml
data:
  database_url: mongodb-headless-service  # or mongodb-service for Method 1
```

### Secret (`mongodb-secret.yaml`)
Contains sensitive credentials (base64 encoded):
```yaml
data:
  mongo_root_username: <base64-encoded-username>
  mongo_root_password: <base64-encoded-password>
```

## Verification

Check deployment status:
```bash
# Check pods
kubectl get pods

# Check services
kubectl get services

# Check persistent volumes (Method 2 only)
kubectl get pv,pvc

# Check logs
kubectl logs deployment/mongodb-deployment  # Method 1
kubectl logs mongodb-stateful-set-0         # Method 2
```

## Cleanup

Remove all resources:
```bash
# Method 1
kubectl delete -f mongo-express.yaml
kubectl delete -f mongodb.yaml
kubectl delete -f mongodb-secret.yaml
kubectl delete -f mongodb-configmap.yaml

# Method 2
kubectl delete -f mongodb-stateful-set.yaml
kubectl delete -f mongodb-headless-service.yaml
kubectl delete -f mongodb-secret.yaml
kubectl delete -f mongodb-configmap.yaml
```

## Notes

- **Method 1** is suitable for development and testing environments
- **Method 2** is recommended for production environments requiring scalability and data persistence
- Ensure proper resource limits and requests are configured based on your cluster capacity
- For production use, consider enabling authentication and TLS encryption