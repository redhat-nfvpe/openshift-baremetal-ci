#!/bin/bash

set -e
set -x

trap cleanup 0 1

cleanup() {
	oc get co || true
	oc get clusterversion || true
	oc get nodes || true
	oc get pods -n openshift-sriov-network-operator || true
	popd
}

pushd openshift-baremetal-ci/tests/sriov

# sriov conformance tests don't require node policy be created.
# setting CREATE_NODE_POLICY to false to skip node policy
# configuration in run-sriov-operator.sh
export CREATE_NODE_POLICY=false
./run-sriov-operator.sh

# wait for extra 20 seconds for NodeState become Succeed
sleep 20
popd

if [ -d sriov-network-operator ]; then
        rm -rf sriov-network-operator
fi

git clone https://github.com/openshift/sriov-network-operator.git

pushd sriov-network-operator
make test-e2e-conformance

popd
pushd openshift-baremetal-ci/tests/sriov/sriov-network-operator

# There are legacy sriovnetworks blocking operator from undeploying
# remove finalizers for sriovnetwork so that 'make undeploy' can succeed
oc patch crd/sriovnetworks.sriovnetwork.openshift.io -p '{"metadata":{"finalizers":[]}}' --type=merge

make undeploy
