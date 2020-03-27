#!/bin/bash

set -e
set -x

trap cleanup 0 1

cleanup() {
	oc get co || true
	oc get clusterversion || true
	oc get nodes || true
	oc get pods -n openshift-sriov-network-operator || true
	oc get pods -n default || true
	./cleanup.sh || true
	popd
}

pushd openshift-baremetal-ci/tests/sriov

./apply-performance-conf.sh

sleep 20

export SUBSCRIPTION=false
./run-sriov-operator.sh

sleep 20

./topology-manager-e2e.sh
