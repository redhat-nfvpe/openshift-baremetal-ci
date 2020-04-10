#!/bin/bash

set -e
set -x

yum install -y wget skopeo jq


SRIOV_OPERATOR_REPO=https://github.com/openshift/sriov-network-operator.git
SRIOV_OPERATOR_NAMESPACE=openshift-sriov-network-operator

NUM_OF_WORKER=$(oc get nodes | grep worker | wc -l)
NUM_OF_MASTER=$(oc get nodes | grep master- | wc -l)

if [ ! -d "sriov-network-operator" ]; then
	sudo git clone $SRIOV_OPERATOR_REPO
fi

pushd sriov-network-operator

# override SR-IOV images with 4.3.z version
if oc version | grep 4.3 ; then
	git checkout release-4.3

	rm -rf ./4.3-image-references.sh
	wget http://lacrosse.corp.redhat.com/~zshi/ocp/4.3-image-references.sh
	source ./4.3-image-references.sh
fi
# override SR-IOV images with 4.4 version
if oc version | grep 4.4 ; then
	git checkout release-4.4

	rm -rf ./4.4-image-references.sh
	wget http://lacrosse.corp.redhat.com/~zshi/ocp/4.4-image-references.sh
	source ./4.4-image-references.sh
fi
# override SR-IOV images with 4.5 version
if oc version | grep 4.5 ; then
	git checkout master

	rm -rf ./4.5-image-references.sh
	wget http://lacrosse.corp.redhat.com/~zshi/ocp/4.5-image-references.sh
	source ./4.5-image-references.sh
fi

make deploy-setup
popd

oc wait --for condition=available deployment sriov-network-operator -n $SRIOV_OPERATOR_NAMESPACE --timeout=60s
sleep 30

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

for worker in $(oc get nodes | grep worker- | awk '{print $1}'); do
	oc label node $worker \
		--overwrite=true feature.node.kubernetes.io/network-sriov.capable=true
done
