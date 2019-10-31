#!/bin/bash

set -e
set -x

SRIOV_OPERATOR_REPO=https://github.com/openshift/sriov-network-operator.git
SRIOV_OPERATOR_NAMESPACE=openshift-sriov-network-operator

WORKER_NODE=localhost
NUM_OF_WORKER=$(oc get nodes | grep worker | wc -l)
NUM_OF_MASTER=$(oc get nodes | grep master | wc -l)

oc label node $WORKER_NODE --overwrite=true feature.node.kubernetes.io/network-sriov.capable=true

if [ ! -d "sriov-network-operator" ]; then
	git clone $SRIOV_OPERATOR_REPO
fi

pushd sriov-network-operator
make deploy-setup

oc wait --for condition=available deployment sriov-network-operator -n $SRIOV_OPERATOR_NAMESPACE --timeout=60s
sleep 30
#oc wait --for condition=available ds operator-webhook -n $SRIOV_OPERATOR_NAMESPACE --timeout=60s
#oc wait --for condition=available ds network-resources-injector -n $SRIOV_OPERATOR_NAMESPACE --timeout=60s
#oc wait --for condition=available ds sriov-network-config-daemon -n $SRIOV_OPERATOR_NAMESPACE --timeout=60s

for i in {1..10}; do
	sleep 10
	injector=$(oc get ds network-resources-injector \
			-n $SRIOV_OPERATOR_NAMESPACE | tail -n 1 | awk '{print $4}')
	webhook=$(oc get ds operator-webhook \
			-n $SRIOV_OPERATOR_NAMESPACE | tail -n 1 | awk '{print $4}')
	daemonset=$(oc get ds sriov-network-config-daemon \
			-n $SRIOV_OPERATOR_NAMESPACE | tail -n 1 | awk '{print $4}')

	if [ $injector -eq $NUM_OF_MASTER ] && [ $webhook -eq $NUM_OF_MASTER ] \
		&& [ $daemonset -eq $NUM_OF_WORKER ]; then
		break
	fi

	if [ $i -eq 10 ]; then
		exit 1
	fi
done
popd

pushd templates

# Wait for operator webhook to become ready
sleep 30
oc create -f policy-intel.yaml

#oc wait --for condition=available ds sriov-cni -n $SRIOV_OPERATOR_NAMESPACE --timeout=60s
#oc wait --for condition=available ds sriov-device-plugin -n $SRIOV_OPERATOR_NAMESPACE --timeout=60s

for i in {1..10}; do
	sleep 10
	cni=$(oc get ds sriov-cni \
			-n $SRIOV_OPERATOR_NAMESPACE | tail -n 1 | awk '{print $4}')
	dp=$(oc get ds sriov-device-plugin \
			-n $SRIOV_OPERATOR_NAMESPACE | tail -n 1 | awk '{print $4}')

	if [ $cni -eq 1 ] && [ $dp -eq 1 ]; then
		break
	fi

	if [ $i -eq 10 ]; then
		exit 1
	fi
done

#Wait for device plugn be rebooted
sleep 30
#oc wait --for condition=available ds sriov-cni -n $SRIOV_OPERATOR_NAMESPACE --timeout=60s
#oc wait --for condition=available ds sriov-device-plugin -n $SRIOV_OPERATOR_NAMESPACE --timeout=60s

for i in {1..12}; do
	sleep 10
	resource=$(oc get node $WORKER_NODE -o jsonpath="{.status.allocatable.openshift\.io/intelnics}")

	if [ $resource -eq 4 ]; then
		break
	fi

	if [ $i -eq 12 ]; then
		exit 1
	fi
done

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

popd
