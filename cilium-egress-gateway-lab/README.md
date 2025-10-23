
Adapted from https://isovalent.com/labs/cilium-egress-gateway/

node worker-2 will be allowed to access the outpost application
```bash
WORKER_2_IP=$(kubectl get node worker-2 -o jsonpath='{.status.addresses[?(@.type=="InternalIP")].address}')
WORKER_2_IP=192.168.105.105
docker run -d \
  --name remote-outpost \
  -e "ALLOWED_IP=$WORKER_2_IP" \
  -p 192.168.105.10:8000:8000 \
   quay.io/isovalent-dev/egressgw-whatismyip:latest
```


Retrieve the container's IP in a variable
```bash
OUTPOST=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' remote-outpost)
echo $OUTPOST
```

And test it
```bash
curl http://$OUTPOST:8000
```

You will get
```shell
Access denied. Your source IP (172.17.0.1) doesn't match the allowed IP (192.168.105.105)
```

Let's deploy two starships in the default namespace: an imperial Tie Fighter and a rebel X-Wing. We'll adjust the labels to reflect their loyalty
```bash
kubectl apply -f tiefighter.yaml
kubectl apply -f xwing.yaml
```

```bash
kubectl get pod --show-labels
```

Now try to reach the outpost container from the Tie Fighter
```bash
kubectl exec -ti tiefighter -- curl --max-time 2 http://$OUTPOST:8000
```

You will get a similar result with the X-Wing
```bash
kubectl exec -ti xwing -- curl --max-time 2 http://$OUTPOST:8000
```