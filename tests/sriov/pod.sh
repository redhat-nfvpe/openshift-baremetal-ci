#!/bin/bash

set -e
set -x

export WORKER_NAME_PREFIX=${WORKER_NODE:-"ci-worker"}
export NIC_VENDOR=${NIC_VENDOR:-"intel"}

inspect_pod() {
	pod_name=$1
	oc exec $pod_name -- ip link show net1
	oc exec $pod_name -- ethtool -i net1
	oc exec $pod_name -- env | grep PCIDEVICE
}

wait_for_pod_running() {
	pod_name=$1
	for i in {1..6}; do
		sleep 10
		pod_state=$(oc get pods $pod_name | tail -n 1 | awk '{print $3}')

		if [ "$pod_state" == "Running" ]; then
			break
		fi

		if [ $i -eq 6 ]; then
			exit 1
		fi
	done
}

vf_ipv4() {
	pod_name=$1
	oc exec $pod_name -- ip addr show net1 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1
}

vf_ipv6() {
	pod_name=$1
	oc exec $pod_name -- ip addr show net1 | grep "inet6\b" | grep global | awk '{print $2}' | cut -d/ -f1
}

vf_mac() {
	pod_name=$1
	oc exec $pod_name -- ip link show net1 | grep 'link/ether' | awk '{print $2}'
}

pod_default_route_ipv4() {
	pod_name=$1
	oc exec $pod_name -- ip route | grep default | awk '{print $3}'
}

pod_default_route_ipv6() {
	pod_name=$1
	oc exec $pod_name -- ip -6 route | grep default | awk '{print $3}'
}

# Test simple SR-IOV pod
pushd templates
oc create -f sn-$NIC_VENDOR.yaml
sleep 1
oc create -f pod-simple.yaml
sleep 1
oc wait --for condition=ready pods testpod-simple -n default --timeout=60s

wait_for_pod_running testpod-simple
inspect_pod testpod-simple

oc delete -f pod-simple.yaml
oc delete -f sn-$NIC_VENDOR.yaml
popd

# Test ping between two pods
pushd templates
oc create -f sn-$NIC_VENDOR.yaml
sleep 1
export pod_index=1
export nad=sriov-$NIC_VENDOR
export node=$WORKER_NAME_PREFIX-0
envsubst <"pod.yaml.tpl" >"pod1.yaml"
export pod_index=2
export nad=sriov-$NIC_VENDOR
export node=$WORKER_NAME_PREFIX-0
envsubst <"pod.yaml.tpl" >"pod2.yaml"
oc create -f pod1.yaml
oc create -f pod2.yaml
sleep 1
oc wait --for condition=ready pods testpod1 -n default --timeout=60s
oc wait --for condition=ready pods testpod2 -n default --timeout=60s

wait_for_pod_running testpod2
inspect_pod testpod1
inspect_pod testpod2

pod1_ipv4=$(vf_ipv4 testpod1)
oc exec testpod2 -- ping -c 10 $pod1_ipv4 -I net1

oc delete -f pod1.yaml
oc delete -f pod2.yaml
oc delete -f sn-$NIC_VENDOR.yaml
rm -rf pod1.yaml
rm -rf pod2.yaml
popd

# Test NUMA single-numa-node policy
pushd templates
oc create -f sn-$NIC_VENDOR.yaml
sleep 1

export pod_index=1
export nad=sriov-$NIC_VENDOR
export node=$WORKER_NAME_PREFIX-0
envsubst <"pod.yaml.tpl" >"pod1.yaml"
export pod_index=2
envsubst <"pod.yaml.tpl" >"pod2.yaml"
export pod_index=3
envsubst <"pod.yaml.tpl" >"pod3.yaml"
export pod_index=4
envsubst <"pod.yaml.tpl" >"pod4.yaml"
export pod_index=5
envsubst <"pod.yaml.tpl" >"pod5.yaml"
oc create -f pod1.yaml
oc create -f pod2.yaml
oc create -f pod3.yaml
oc create -f pod4.yaml
sleep 1
oc wait --for condition=ready pods testpod1 -n default --timeout=60s
oc wait --for condition=ready pods testpod2 -n default --timeout=60s
oc wait --for condition=ready pods testpod3 -n default --timeout=60s
oc wait --for condition=ready pods testpod4 -n default --timeout=60s

wait_for_pod_running testpod4
inspect_pod testpod1
inspect_pod testpod2
inspect_pod testpod3
inspect_pod testpod4

pod1_ipv4=$(vf_ipv4 testpod1)
pod2_ipv4=$(vf_ipv4 testpod2)
pod3_ipv4=$(vf_ipv4 testpod3)
pod4_ipv4=$(vf_ipv4 testpod4)

oc exec testpod4 -- ping -c 5 $pod1_ipv4 -I net1
oc exec testpod4 -- ping -c 5 $pod2_ipv4 -I net1
oc exec testpod4 -- ping -c 5 $pod3_ipv4 -I net1

oc delete -f pod4.yaml
oc create -f pod5.yaml
sleep 1
oc wait --for condition=ready pods testpod5 -n default --timeout=60s
wait_for_pod_running testpod5
inspect_pod testpod5
oc exec testpod5 -- ping -c 5 $pod1_ipv4 -I net1
oc exec testpod5 -- ping -c 5 $pod2_ipv4 -I net1
oc exec testpod5 -- ping -c 5 $pod3_ipv4 -I net1

## Check that Topology Affinity un-satisified
#for i in {1..10}; do
#	sleep 1
#	pod_state=$(oc get pods testpod5 | tail -n 1 | awk '{print $3 $4 $5}')
#
#	if [ "$pod_state" == "TopologyAffinityError" ]; then
#		break
#	fi
#
#	if [ $i -eq 10 ]; then
#		exit 1
#	fi
#done

oc delete -f pod1.yaml
oc delete -f pod2.yaml
oc delete -f pod3.yaml
oc delete -f pod5.yaml
oc delete -f sn-$NIC_VENDOR.yaml
rm -rf pod1.yaml pod2.yaml pod3.yaml pod4.yaml pod5.yaml
popd

# runtimeConfig, MAC and IP
pushd templates
oc create -f sn-$NIC_VENDOR-static.yaml
sleep 1
export pod_index=6
export nad='[{"name": "sriov-$NIC_VENDOR","mac": "CA:FE:C0:FF:EE:01","ips": ["10.10.10.11/24", "2001::1/64"]}]'
export node=$WORKER_NAME_PREFIX-0
envsubst <"pod.yaml.tpl" >"pod6.yaml"
oc create -f pod6.yaml

export pod_index=7
export nad='[{"name": "sriov-$NIC_VENDOR","mac": "CA:FE:C0:FF:EE:02","ips": ["10.10.10.12/24", "2001::2/64"]}]'
export node=$WORKER_NAME_PREFIX-1
envsubst <"pod.yaml.tpl" >"pod7.yaml"
oc create -f pod7.yaml

sleep 1
oc wait --for condition=ready pods testpod6 -n default --timeout=60s
oc wait --for condition=ready pods testpod7 -n default --timeout=60s

wait_for_pod_running testpod7
inspect_pod testpod6
pod6_mac=$(vf_mac testpod6)
pod6_ipv4=$(vf_ipv4 testpod6)
pod6_ipv6=$(vf_ipv6 testpod6)

if [ "$pod6_mac" != "ca:fe:c0:ff:ee:01" ]; then
	exit 1
fi

if [ "$pod6_ipv4" != "10.10.10.11" ]; then
	exit 1
fi

if [ "$pod6_ipv6" != "2001::1" ]; then
	exit 1
fi

inspect_pod testpod7
pod7_mac=$(vf_mac testpod7)
pod7_ipv4=$(vf_ipv4 testpod7)
pod7_ipv6=$(vf_ipv6 testpod7)

if [ "$pod7_mac" != "ca:fe:c0:ff:ee:02" ]; then
	exit 1
fi

if [ "$pod7_ipv4" != "10.10.10.12" ]; then
	exit 1
fi

if [ "$pod7_ipv6" != "2001::2" ]; then
	exit 1
fi

oc exec testpod7 -- ping -c 5 $pod6_ipv4 -I net1
oc exec testpod7 -- ping6 -c 5 $pod6_ipv6 -I net1

oc delete -f pod6.yaml
oc delete -f pod7.yaml
oc delete -f sn-$NIC_VENDOR-static.yaml
rm -rf pod6.yaml
rm -rf pod7.yaml
popd

# default route override
pushd templates
oc create -f sn-$NIC_VENDOR-static.yaml
sleep 1
export pod_index=8
export nad='[{"name": "sriov-$NIC_VENDOR","ips": ["10.129.10.11/24", "2001::11/64"],"default-route": ["10.129.10.1", "2001::1"]}]'
export node=$WORKER_NAME_PREFIX-0
envsubst <"pod.yaml.tpl" >"pod8.yaml"
oc create -f pod8.yaml
sleep 1
export pod_index=9
export nad='[{"name": "sriov-$NIC_VENDOR","ips": ["10.129.10.12/24", "2001::12/64"],"default-route": ["10.129.10.1", "2001::1"]}]'
export node=$WORKER_NAME_PREFIX-1
envsubst <"pod.yaml.tpl" >"pod9.yaml"
oc create -f pod9.yaml

oc wait --for condition=ready pods testpod8 -n default --timeout=60s
oc wait --for condition=ready pods testpod9 -n default --timeout=60s

wait_for_pod_running testpod9
inspect_pod testpod8
pod8_ipv4=$(vf_ipv4 testpod8)
pod8_ipv6=$(vf_ipv6 testpod8)
pod8_default_route_ipv4=$(pod_default_route_ipv4 testpod8)
pod8_default_route_ipv6=$(pod_default_route_ipv6 testpod8)

if [ "$pod8_ipv4" != "10.129.10.11" ]; then
	exit 1
fi

if [ "$pod8_ipv6" != "2001::11" ]; then
	exit 1
fi

if [ "$pod8_default_route_ipv4" != "10.129.10.1" ]; then
	exit 1
fi

if [ "$pod8_default_route_ipv6" != "2001::1" ]; then
	exit 1
fi

inspect_pod testpod9
pod9_ipv4=$(vf_ipv4 testpod9)
pod9_ipv6=$(vf_ipv6 testpod9)
pod9_default_route_ipv4=$(pod_default_route_ipv4 testpod9)
pod9_default_route_ipv6=$(pod_default_route_ipv6 testpod9)

if [ "$pod9_ipv4" != "10.129.10.12" ]; then
	exit 1
fi

if [ "$pod9_ipv6" != "2001::12" ]; then
	exit 1
fi

if [ "$pod9_default_route_ipv4" != "10.129.10.1" ]; then
	exit 1
fi

if [ "$pod9_default_route_ipv6" != "2001::1" ]; then
	exit 1
fi

oc exec testpod9 -- ping -c 5 $pod8_ipv4 -I net1
oc exec testpod9 -- ping6 -c 5 $pod8_ipv6 -I net1

oc delete -f pod8.yaml
oc delete -f pod9.yaml
oc delete -f sn-$NIC_VENDOR-static.yaml
popd
