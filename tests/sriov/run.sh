#!/bin/bash

set -e
set -x

trap cleanup 0 1

cleanup() {
	oc get co || true
	oc get clusterversion || true
	oc describe nodes || true
	oc get nodes || true
	oc get pods -n openshift-sriov-network-operator || true
	oc get pods -n default || true
	./cleanup.sh || true
	popd
}

pushd openshift-baremetal-ci/tests/sriov

# ./apply-performance-conf.sh

sleep 20

# wget http://lacrosse.corp.redhat.com/~zshi/ocp/image-references.sh
# source ./image-references.sh

export SUBSCRIPTION=false
./run-sriov-operator.sh

sleep 20

./pod.sh
