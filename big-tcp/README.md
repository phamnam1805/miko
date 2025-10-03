# Cilium Big TCP Lab

This lab demonstrates Cilium's Big TCP feature for improving network performance with large packets on both IPv4 and IPv6.

## Overview

Big TCP allows sending packets larger than the traditional 64KB limit, significantly improving network throughput and reducing latency for high-bandwidth applications. This feature requires Linux kernel 6.3+ and provides up to 40% performance improvements.

**Lab Source:**
This lab is adapted from [Isovalent's Cilium Big TCP Lab](https://isovalent.com/labs/cilium-big-tcp/).

## Prerequisites

- Kubernetes cluster with Cilium CNI
- Linux kernel 6.3 or above
- kubectl access to the cluster

## Lab Setup

### Install Big TCP Compatible Kernel

To support BIG TCP for IPv4 and IPv6, we will need a recent Linux kernel (6.3 and above is required).

Let's install the 6.4.0 kernel with the script below. The upgrade will be pretty seamless.
```bash
wget https://raw.githubusercontent.com/pimlie/ubuntu-mainline-kernel.sh/master/ubuntu-mainline-kernel.sh
chmod +x ubuntu-mainline-kernel.sh
mv ubuntu-mainline-kernel.sh /usr/local/bin/
ubuntu-mainline-kernel.sh -c
ubuntu-mainline-kernel.sh -i v6.4.0
```

Reboot then check the kernel version
```bash
reboot
uname -ar
```

## Part 1: Big TCP for IPv4

Let's verify BIG TCP for IPv4 is not enabled in cilium yet
```bash
cilium config view | grep ipv4-big-tcp
```

To run our performance tests, we will be using netperf. Netperf is a benchmark that can be used to measure the performance of many different types of networking. It provides tests for both unidirectional throughput, and end-to-end latency.

Let's deploy a netperf client and a netperf server
```bash
kubectl apply -f https://raw.githubusercontent.com/NikAleksandrov/cilium/42b93676d85783aa167105a91e44078ce6731297/test/bigtcp/netperf.yaml
```

Get netperf-server IP address
```bash
NETPERF_SERVER=$(kubectl get pod netperf-server -o jsonpath='{.status.podIPs}' | jq -r -c '.[].ip | select(contains(":") == false)')
echo $NETPERF_SERVER
```

Let's now start the performance test. That is done by executing a netperf on the client towards the server, using large sized packets (80,000 bytes) and setting the testing output with -O to show the statistics on the latency in microseconds and the throughput in the number of packets per seconds.
```bash
kubectl exec netperf-client -- \
  netperf -t TCP_RR -H ${NETPERF_SERVER} -- \
  -r80000:80000 -O MIN_LATENCY,P90_LATENCY,P99_LATENCY,THROUGHPUT
```

Take a note of the performance results. They will vary every time but expect the throughput to be between 4,000 and 8,000 packets per seconds.

Once enabled in Cilium, all nodes will be automatically configured with BIG TCP. There is no cluster downtime when enabling this feature, albeit the Kubernetes Pods must be restarted for the changes to take effect.
```bash
cilium config set enable-ipv4-big-tcp true
```

Let's redeploy the Pods for the BIG TCP changes to be reflected
```bash
kubectl delete -f https://raw.githubusercontent.com/NikAleksandrov/cilium/42b93676d85783aa167105a91e44078ce6731297/test/bigtcp/netperf.yaml
kubectl apply -f https://raw.githubusercontent.com/NikAleksandrov/cilium/42b93676d85783aa167105a91e44078ce6731297/test/bigtcp/netperf.yaml
```

Let’s run another netperf test. 
```bash
NETPERF_SERVER=$(kubectl get pod netperf-server -o jsonpath='{.status.podIPs}' | jq -r -c '.[].ip | select(contains(":") == false)')
echo $NETPERF_SERVER
kubectl exec netperf-client -- \
  netperf -t TCP_RR -H ${NETPERF_SERVER} -- \
  -r80000:80000 -O MIN_LATENCY,P90_LATENCY,P99_LATENCY,THROUGHPUT
```

Again, expect the results to fluctuate but if you compare the results, you will see that the latency has reduced across the board.

Expect to see a significant improvement in throughput in packets per second (8,000 to 12,000) - it's a significant performance improvement when enabling BIG TCP!

## Part 2: Big TCP for IPv6

Let's verify BIG TCP for IPv6 is not enabled yet
```bash
cilium config view | grep ipv6-big-tcp
```

Let's first check the GSO on the node. You will see a value of 65536 – the 64K limit described earlier in the lab.
```bash
docker exec kind-worker ip -d -j link show dev eth0 | jq -c '.[0].gso_max_size'
```

Let's deploy a netperf client and a netperf server
```bash
kubectl apply -f https://raw.githubusercontent.com/NikAleksandrov/cilium/42b93676d85783aa167105a91e44078ce6731297/test/bigtcp/netperf.yaml
```

Let's check the GSO for the netperf-server Pods. Again, expect to see 64K
```bash
kubectl exec netperf-server -- \
  ip -d -j link show dev eth0 | \
  jq -c '.[0].gso_max_size'
```

Finally, let's run a performance test. First, let's get the IPv6 address of the netperf server
```bash
NETPERF_SERVER=$(kubectl get pod netperf-server -o jsonpath='{.status.podIPs}' | jq -r -c '.[].ip | select(contains(":") == true)')
echo $NETPERF_SERVER
```

Let's now start the performance test
```bash
kubectl exec netperf-client -- \
  netperf -t TCP_RR -H ${NETPERF_SERVER} -- \
  -r80000:80000 -O MIN_LATENCY,P90_LATENCY,P99_LATENCY,THROUGHPUT
```

Run the tests several times. Take a note of the latency and throughput results.

While they may fluctuate, the throughput tends to be between 4,000 and 8,000 packets per seconds.

Let's now compare when we enable BIG TCP.

Once enabled in Cilium, all nodes will be automatically configured with BIG TCP. There is no cluster downtime when enabling this feature, albeit the Kubernetes Pods must be restarted for the changes to take effect.

```bash
cilium config set enable-ipv6-big-tcp true
```

Let’s now verify the GSO settings on the node
```bash
docker exec kind-worker ip -d -j link show dev eth0 | \
  jq -c '.[0].gso_max_size'
```

Expect to see a reply of 196608. 196608 bytes is 192KB: the current optimal GRO/GSO value with Cilium is 192K but it can eventually be raised to 512K if additional performance benefits are observed.

As you will shortly see, the performance results with 192K were impressive, even for small-sized request/response-type workloads.

Let's redeploy the Pods for the GSO to be reflected
```bash
kubectl delete -f https://raw.githubusercontent.com/NikAleksandrov/cilium/42b93676d85783aa167105a91e44078ce6731297/test/bigtcp/netperf.yaml
kubectl apply -f https://raw.githubusercontent.com/NikAleksandrov/cilium/42b93676d85783aa167105a91e44078ce6731297/test/bigtcp/netperf.yaml
```

Let's check the GSO on our netperf Pods to see if they've been adjusted
```bash
kubectl exec netperf-server -- ip -d -j link show dev eth0 | jq -c '.[0].gso_max_size'
kubectl exec netperf-client -- ip -d -j link show dev eth0 | jq -c '.[0].gso_max_size'
```

Again, expect 196608 for both Pods.

Let’s run another netperf test. First, let's get the IPv6 address of the re-deployed netperf server
```bash
NETPERF_SERVER=$(kubectl get pod netperf-server -o jsonpath='{.status.podIPs}' | jq -r -c '.[].ip | select(contains(":") == true)')
echo $NETPERF_SERVER
```

Run the tests several times
```bash
kubectl exec netperf-client -- \
  netperf -t TCP_RR -H ${NETPERF_SERVER} -- \
  -r80000:80000 -O MIN_LATENCY,P90_LATENCY,P99_LATENCY,THROUGHPUT
```

Compare with the tests you did previously.

Expect the latency to have gone down and the throughput to have increased (typically, 8,000 to 10,000 packets per second).

As you can see, for both IPv4 and IPv6, we are seeing a 40% boost in throughput!🚀