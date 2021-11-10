#!/bin/bash

set -e
set -x

yum install -y wget skopeo jq


SRIOV_OPERATOR_REPO=https://github.com/openshift/sriov-network-operator.git
SRIOV_OPERATOR_NAMESPACE=openshift-sriov-network-operator

export WORKER_NAME_PREFIX=${WORKER_NODE:-"ci-worker"}
export SUBSCRIPTION=${SUBSCRIPTION:-false}
export CREATE_NODE_POLICY=${CREATE_NODE_POLICY:-true}

NUM_OF_WORKER=$(oc get nodes | grep worker | wc -l)
NUM_OF_MASTER=$(oc get nodes | grep master- | wc -l)
NUM_OF_BM_WORKER=$(oc get node -o=custom-columns=NAME:.metadata.name | grep worker| wc -l)

if [ $SUBSCRIPTION == false ]; then
	if [ ! -d "sriov-network-operator" ]; then
		sudo git clone $SRIOV_OPERATOR_REPO
	fi

	pushd sriov-network-operator

	# override SR-IOV images with 4.3.z version
	if oc version | grep "Client Version: 4.3" ; then
		git checkout release-4.3
		source ../origin-images.sh 4.3
	fi
	# override SR-IOV images with 4.4 version
	if oc version | grep "Client Version: 4.4" ; then
		git checkout release-4.4
		source ../origin-images.sh 4.4
	fi
	# override SR-IOV images with 4.5 version
	if oc version | grep "Client Version: 4.5" ; then
		git checkout release-4.5
		source ../origin-images.sh 4.5
	fi
	# override SR-IOV images with 4.6 version
	if oc version | grep "Client Version: 4.6" ; then
		git checkout release-4.6
		source ../origin-images.sh 4.6
	fi

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

for worker in $(oc get nodes | grep worker- | awk '{print $1}'); do
	oc label node $worker \
		--overwrite=true feature.node.kubernetes.io/network-sriov.capable=true
done

if [ $CREATE_NODE_POLICY == false ]; then
	echo "Skip node policy configuration as CREATE_NODE_POLICY is $CREATE_NODE_POLICY"
	exit 0
fi

# Wait for operator webhook to become ready
sleep 30

oc create -f policy-intel.yaml
sleep 1
oc create -f policy-intel-dpdk.yaml

for i in {1..30}; do
	sleep 10
	dp=$(oc get ds sriov-device-plugin \
			-n $SRIOV_OPERATOR_NAMESPACE | tail -n 1 | awk '{print $4}')

	if [ $dp -eq $NUM_OF_BM_WORKER ]; then
		break
	fi

	if [ $i -eq 60 ]; then
		exit 1
	fi
done

#Wait for device plugin be rebooted
sleep 30

for i in {1..60}; do
	sleep 20
	count=0
	for worker in $(oc get nodes | grep worker- | awk '{print $1}'); do
		resource_sriov=$(oc get node $worker \
			-o jsonpath="{.status.allocatable.openshift\.io/intelnics}")

		resource_dpdk=$(oc get node $worker \
			-o jsonpath="{.status.allocatable.openshift\.io/inteldpdk}")

		if [ $resource_sriov -eq 10 ] && [ $resource_dpdk -eq 10 ]; then
			count=$((count+1))
		fi
	done

	if [ $count == $NUM_OF_BM_WORKER ]; then
		break
	fi

	if [ $i -eq 60 ]; then
		exit 1
	fi
done

popd
