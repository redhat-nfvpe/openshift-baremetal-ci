#!/bin/bash

set -e
set -x

yum install -y wget skopeo jq


SRIOV_OPERATOR_REPO=https://github.com/openshift/sriov-network-operator.git
SRIOV_OPERATOR_NAMESPACE=openshift-sriov-network-operator

# WORKER_NODE=ci-worker-0
# WORKER_NODE=nfvpe-08.oot.lab.eng.bos.redhat.com
export WORKER_NAME_PREFIX=${WORKER_NODE:-"ci-worker"}
export SUBSCRIPTION=${SUBSCRIPTION:-false}

NUM_OF_WORKER=$(oc get nodes | grep worker | wc -l)
NUM_OF_MASTER=$(oc get nodes | grep master- | wc -l)

if [ $SUBSCRIPTION == false ]; then
	if [ ! -d "sriov-network-operator" ]; then
		sudo git clone $SRIOV_OPERATOR_REPO
	fi

	pushd sriov-network-operator
	make deploy-setup
	popd
else
	pushd templates
	oc apply -f subscription.yaml
	popd
	sleep 20
fi

oc wait --for condition=available deployment sriov-network-operator -n $SRIOV_OPERATOR_NAMESPACE --timeout=60s
sleep 30
#oc wait --for condition=available ds operator-webhook -n $SRIOV_OPERATOR_NAMESPACE --timeout=60s

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

if [ $SUBSCRIPTION == false ]; then
	pushd templates
else
	pushd templates
fi

for worker in $(seq 0 $((NUM_OF_WORKER-1))); do
	oc label node $WORKER_NAME_PREFIX-$worker \
		--overwrite=true feature.node.kubernetes.io/network-sriov.capable=true
done

# Wait for operator webhook to become ready
sleep 30

oc create -f policy-intel.yaml

for i in {1..12}; do
	sleep 10
	cni=$(oc get ds sriov-cni \
			-n $SRIOV_OPERATOR_NAMESPACE | tail -n 1 | awk '{print $4}')
	dp=$(oc get ds sriov-device-plugin \
			-n $SRIOV_OPERATOR_NAMESPACE | tail -n 1 | awk '{print $4}')

	if [ $cni -eq $NUM_OF_WORKER ] && [ $dp -eq $NUM_OF_WORKER ]; then
		break
	fi

	if [ $i -eq 12 ]; then
		exit 1
	fi
done

#Wait for device plugin be rebooted
sleep 30

for i in {1..30}; do
	sleep 20
	count=0
	for worker in $(seq 0 $((NUM_OF_WORKER-1))); do
		resource=$(oc get node $WORKER_NAME_PREFIX-$worker \
			-o jsonpath="{.status.allocatable.openshift\.io/intelnics}")

		if [ $resource -eq 4 ]; then
			count=$((count+1))
		fi
	done

	if [ $count == $NUM_OF_WORKER ]; then
		break
	fi

	if [ $i -eq 30 ]; then
		exit 1
	fi
done

popd
