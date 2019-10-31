#!/bin/bash

set -e
set -x

# Test simple SR-IOV pod
pushd templates
oc create -f sn-intel.yaml
sleep 1
oc create -f pod-simple.yaml
sleep 1
oc wait --for condition=ready pods testpod-simple -n default --timeout=60s

for i in {1..6}; do
	sleep 10
	pod_state=$(oc get pods testpod-simple | tail -n 1 | awk '{print $3}')

	if [ "$pod_state" == "Running" ]; then
		break
	fi

	if [ $i -eq 6 ]; then
		exit 1
	fi
done

oc exec testpod-simple -- ip link show net1
oc exec testpod-simple -- ethtool -i net1
oc exec testpod-simple -- env | grep PCIDEVICE

oc delete -f pod-simple.yaml
oc delete -f sn-intel.yaml
popd

# Test ping between two pods
pushd templates
oc create -f sn-intel.yaml
sleep 1

oc create -f pod1.yaml
sleep 1
oc wait --for condition=ready pods testpod1 -n default --timeout=60s
oc create -f pod2.yaml
sleep 1
oc wait --for condition=ready pods testpod2 -n default --timeout=60s

for i in {1..6}; do
	sleep 10
	pod_state=$(oc get pods testpod2 | tail -n 1 | awk '{print $3}')

	if [ "$pod_state" == "Running" ]; then
		break
	fi

	if [ $i -eq 6 ]; then
		exit 1
	fi
done

oc exec testpod1 -- ip link show net1
oc exec testpod1 -- ethtool -i net1
oc exec testpod1 -- env | grep PCIDEVICE
pod1_ipv4=$(oc exec testpod1 -- ip addr show net1 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1)

oc exec testpod2 -- ip link show net1
oc exec testpod2 -- ethtool -i net1
oc exec testpod2 -- env | grep PCIDEVICE
oc exec testpod2 -- ping -c 10 $pod1_ipv4 -I net1

oc delete -f pod1.yaml
oc delete -f pod2.yaml
oc delete -f sn-intel.yaml
popd

# Test NUMA single-numa-node policy
pushd templates
oc create -f sn-intel.yaml
sleep 1

oc create -f pod1.yaml
sleep 1
oc wait --for condition=ready pods testpod1 -n default --timeout=60s
oc create -f pod2.yaml
sleep 1
oc wait --for condition=ready pods testpod2 -n default --timeout=60s
oc create -f pod3.yaml
sleep 1
oc wait --for condition=ready pods testpod3 -n default --timeout=60s
oc create -f pod4.yaml
sleep 1
oc wait --for condition=ready pods testpod4 -n default --timeout=60s

for i in {1..6}; do
	sleep 10
	pod_state=$(oc get pods testpod2 | tail -n 1 | awk '{print $3}')

	if [ "$pod_state" == "Running" ]; then
		break
	fi

	if [ $i -eq 6 ]; then
		exit 1
	fi
done

oc exec testpod1 -- ip link show net1
oc exec testpod1 -- ethtool -i net1
oc exec testpod1 -- env | grep PCIDEVICE
pod1_ipv4=$(oc exec testpod1 -- ip addr show net1 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1)

oc exec testpod2 -- ip link show net1
oc exec testpod2 -- ethtool -i net1
oc exec testpod2 -- env | grep PCIDEVICE
pod2_ipv4=$(oc exec testpod2 -- ip addr show net1 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1)

oc exec testpod3 -- ip link show net1
oc exec testpod3 -- ethtool -i net1
oc exec testpod3 -- env | grep PCIDEVICE
pod3_ipv4=$(oc exec testpod3 -- ip addr show net1 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1)

oc exec testpod4 -- ip link show net1
oc exec testpod4 -- ethtool -i net1
oc exec testpod4 -- env | grep PCIDEVICE
pod4_ipv4=$(oc exec testpod4 -- ip addr show net1 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1)

oc exec testpod4 -- ping -c 5 $pod1_ipv4 -I net1
oc exec testpod4 -- ping -c 5 $pod2_ipv4 -I net1
oc exec testpod4 -- ping -c 5 $pod3_ipv4 -I net1

oc delete -f pod4.yaml
sleep 1
oc create -f pod5.yaml
# Check that Topology Affinity un-satisified

oc delete -f pod1.yaml
oc delete -f pod2.yaml
oc delete -f pod3.yaml
oc delete -f pod5.yaml
oc delete -f sn-intel.yaml
popd
