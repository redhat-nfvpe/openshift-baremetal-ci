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

if [ -d sriov-tests ]; then
        rm -rf sriov-tests
fi

git clone https://github.com/openshift/sriov-tests.git

pushd openshift-baremetal-ci/tests/sriov

# sriov conformance tests don't require node policy be created.
# setting CREATE_NODE_POLICY to false to skip node policy
# configuration in run-sriov-operator.sh
export CREATE_NODE_POLICY=false
./run-sriov-operator.sh

# wait for extra 20 seconds for NodeState become Succeed
sleep 20
popd

pushd sriov-tests
./scripts/run-conformance.sh

popd
pushd openshift-baremetal-ci/tests/sriov/sriov-network-operator
make undeploy
