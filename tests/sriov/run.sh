#!/bin/bash

set -e
set -x

trap cleanup 0 1

cleanup() {
	oc get clusterversion || true
	oc describe nodes || true
	oc get nodes || true
	oc get pods -n openshift-sriov-network-operator || true
	oc get pods -n default || true
	./cleanup.sh || true
	popd
}

pushd openshift-baremetal-ci/tests/sriov

wget http://lacrosse.corp.redhat.com/~zshi/ocp/image-references.sh
source ./image-references.sh

./run-sriov-operator.sh

sleep 20

./run-pod.sh
