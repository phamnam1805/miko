```bash
kubectl create deployment web --image=gcr.io/google-samples/hello-app:1.0
```

```bash
kubectl expose deployment web --type=NodePort --port=8080 --target-port=8080
```

ingress.yaml
```yaml

apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: example-ingress
spec:
  ingressClassName: cilium
  rules:
    - host: hello-world.info
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: web
                port:
                  number: 8080

```

Get Ingress Address
```bash
kubectl get ingress
```