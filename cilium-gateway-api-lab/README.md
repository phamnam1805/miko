# Cilium Gateway API Lab

This lab demonstrates Cilium's Gateway API implementation, showcasing modern Kubernetes ingress capabilities with advanced traffic management features.

## Overview

The Gateway API is the next-generation standard for Kubernetes ingress, providing more expressive and flexible traffic routing than traditional Ingress resources. This lab explores Cilium's native Gateway API support including HTTP/HTTPS routing, TLS termination, and traffic splitting.

**Lab Source:**
This lab is adapted from [Isovalent's Cilium Gateway API Lab](https://isovalent.com/labs/cilium-gateway-api/).

## Key Features Demonstrated

- **HTTP/HTTPS Traffic Routing** - Basic and advanced routing patterns
- **TLS Termination & Passthrough** - Certificate management and encryption handling  
- **Traffic Splitting** - Load balancing with configurable weights
- **Header-based Routing** - Advanced L7 traffic steering
- **Self-signed Certificate Management** - TLS setup for development environments

## Prerequisites

- Kubernetes cluster with Cilium CNI installed
- Cilium Gateway API feature enabled
- kubectl access to the cluster
- mkcert tool for certificate generation (optional)

## Lab Setup

### Verify Gateway API Installation

Let's verify that CRDs have been installed:
```bash
kubectl get crd \
  gatewayclasses.gateway.networking.k8s.io \
  gateways.gateway.networking.k8s.io \
  httproutes.gateway.networking.k8s.io \
  referencegrants.gateway.networking.k8s.io \
  tlsroutes.gateway.networking.k8s.io
```

Verify that Cilium was enabled and deployed with the Gateway API feature:
```bash
cilium config view | grep -w "enable-gateway-api"
```

Let's verify that a GatewayClass has been deployed and accepted:
```bash
kubectl get GatewayClass
```

## Part 1: HTTP Traffic (Gateway -> HTTPRoute)

Let's deploy the sample application in the cluster:
```bash
kubectl apply -f bookinfo.yml
```

> You can find more details about the Bookinfo application on the [Istio website](https://istio.io/v1.12/docs/examples/bookinfo/).


Let's deploy the Gateway with the following manifest
```bash
kubectl apply -f basic-http.yaml
```

Let's have another look at the Services now that the Gateway has been deployed
```bash
kubectl get svc
```
You will see a LoadBalancer service named cilium-gateway-my-gateway which was created for the Gateway API.

The same external IP address is also associated to the Gateway
```bash
kubectl get gateway
```

Let's retrieve this IP address
```bash
GATEWAY=$(kubectl get gateway my-gateway -o jsonpath='{.status.addresses[0].value}')
echo $GATEWAY
```

Check that you can make HTTP requests to that external address
```bash
curl --fail -s http://$GATEWAY/details/1 | jq
```

This time, we will route traffic based on HTTP parameters like header values, method and query parameters. Run the following command
```bash
curl -v -H 'magic: foo' "http://$GATEWAY?great=example"
```

## Part 2: HTTPS Traffic (TLS Gateway -> HTTPRoute)

For demonstration purposes we will use a TLS certificate signed by a made-up, self-signed certificate authority (CA). One easy way to do this is with mkcert.

Create a certificate that will validate bookinfo.cilium.rocks and hipstershop.cilium.rocks, as these are the host names used in this Gateway example
```bash
mkcert '*.cilium.rocks'
```

Mkcert created a key (_wildcard.cilium.rocks-key.pem) and a certificate (_wildcard.cilium.rocks.pem) that we will use for the Gateway service.

Create a Kubernetes TLS secret with this key and certificate
```bash
kubectl create secret tls demo-cert \
  --key=_wildcard.cilium.rocks-key.pem \
  --cert=_wildcard.cilium.rocks.pem
```

Let's now deploy the HTTPS Gateway to the cluster
```bash
kubectl apply -f basic-https.yaml
```

This creates a LoadBalancer service, which after around 30 seconds or so should be populated with an external IP address.

Verify that the Gateway has an load balancer IP address assigned
```bash
kubectl get gateway tls-gateway
```
```bash
GATEWAY=$(kubectl get gateway tls-gateway -o jsonpath='{.status.addresses[0].value}')
echo $GATEWAY
```

Install the Mkcert CA into your system so cURL can trust it
```bash
mkcert -install
```

Now let's make a request to the Gateway
```
curl -s \
  --resolve bookinfo.cilium.rocks:443:${GATEWAY} \
  https://bookinfo.cilium.rocks/details/1 | jq
```

## Part 3: TLSRoute (Gateway -> TLSRoute)

The NGINX server configuration is held in a Kubernetes ConfigMap. Let's create it.
```bash
kubectl create configmap nginx-configmap --from-file=nginx.conf=./nginx.conf
```

The NGINX server `index.html` is held in a Kubernetes ConfigMap. Let's create it.
```bash
kubectl create configmap index-html-configmap --from-file=index.html=./index.html
```

Review the NGINX server Deployment and the Service fronting it
```bash
yq tls-service.yaml
```

As you can see, we are deploying a container with the nginx image, mounting several files such as the HTML index, the NGINX configuration and the certs. Note that we are reusing the demo-cert TLS secret we created earlier.
```bash
kubectl apply -f tls-service.yaml
```

Verify the Service and Deployment have been deployed successfully
```bash
kubectl get svc,deployment my-nginx
```

Review the Gateway API configuration files provided in the current directory
```bash
yq tls-gateway.yaml \
   tls-route.yaml
```

They are almost identical to the one we reviewed in the previous tasks. Just notice the Passthrough mode set in the Gateway manifest. Previously, we used the HTTPRoute resource. This time, we are using TLSRoute.

Earlier you saw how you can terminate the TLS connection at the Gateway. That was using the Gateway API in Terminate mode. In this instance, the Gateway is in Passthrough mode: the difference is that the traffic remains encrypted all the way through between the client and the pod.

In other words:
    - In Terminate:
        - Client -> Gateway: HTTPS
        - Gateway -> Pod: HTTP
    - In Passthrough:
        - Client -> Gateway: HTTPS
        - Gateway -> Pod: HTTPS

Let's now deploy the Gateway and the TLSRoute to the cluster
```bash
kubectl apply -f tls-gateway.yaml -f tls-route.yaml
```

This creates a LoadBalancer service, which after around 30 seconds or so should be populated with an external IP address.

Verify that the Gateway has a LoadBalancer IP address assigned
```bash
kubectl get gateway cilium-tls-gateway
GATEWAY=$(kubectl get gateway cilium-tls-gateway -o jsonpath='{.status.addresses[0].value}')
echo $GATEWAY
```

Let's also double check the TLSRoute has been provisioned successfully and has been attached to the Gateway.
```bash
kubectl get tlsroutes.gateway.networking.k8s.io -o json | jq '.items[0].status.parents[0]'
```

Now let's make a request over HTTPS to the Gateway
```bash
curl -v \
  --resolve "nginx.cilium.rocks:443:$GATEWAY" \
  "https://nginx.cilium.rocks:443"
```

The data should be properly retrieved, using HTTPS (and thus, the TLS handshake was properly achieved).

There are several things to note in the output.

It should be successful (you should see at the end, a HTML output with Cilium rocks.).
The connection was established over port 443 - you should see Connected to nginx.cilium.rocks port 443 .
You should see TLS handshake and TLS version negotiation. Expect the negotiations to have resulted in TLSv1.3 being used.
Expect to see a successful certificate verification (look out for SSL certificate verify ok).

## Part 4: Traffic Splitting

First, let's deploy a sample echo application in the cluster. The application will reply to the client and, in the body of the reply, will include information about the pod and node receiving the original request. We will use this information to illustrate that the traffic is split between multiple Kubernetes Services.
```bash
kubectl apply -f echo-servers.yaml
```

Let's deploy the Gateway and HTTPRoute with the following manifest
```bash
kubectl apply -f my-gateway.yaml
kubectl apply -f load-balancing-http-route.yaml
```

This Rule is essentially a simple L7 proxy route: for HTTP traffic with a path starting with /echo, forward the traffic over to the echo-1 and echo-2 Services over port 8080 and 8090 respectively. Notice the even 50/50 weighing.


```bash
GATEWAY=$(kubectl get gateway my-gateway -o jsonpath='{.status.addresses[0].value}')
echo $GATEWAY
```

Check that you can make HTTP requests to that external address
```bash
curl --fail -s http://$GATEWAY/echo
```

Notice that, in the reply, you get the name of the pod that received the query. For example
```
"POD_NAME":"echo-2-8644f78f4b-h4fw8"
```

Let's double check that traffic is evenly split across multiple Pods by running a loop and counting the requests
```bash
for _ in {1..500}; do
  curl -s http://$GATEWAY/echo | jq -r '.environment.POD_NAME' >> curlresponses.txt;
done
```

Verify that the responses have been (more or less) evenly spread.
```bash
cat curlresponses.txt | sort | uniq -c
```

This time, we will be applying a different weight. Replace the weights from 50 for both echo-1 and echo-2 to 99 for echo-1 and 1 for echo-2.

Apply it again and let's run another loop and count the replies again, with the following command
```bash
for _ in {1..500}; do
  curl -s http://$GATEWAY/echo | jq -r '.environment.POD_NAME' >> curlresponses991.txt;
done
```

Verify that the responses are spread with about 99% of them to echo-1 and about 1% of them to echo-2
```bash
cat curlresponses991.txt | sort | uniq -c
```
