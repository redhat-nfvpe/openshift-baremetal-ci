#!/bin/bash

set -e
set -x

trap cleanup 0 1

cleanup() {
	oc get co || true
	oc get clusterversion || true
	oc get nodes || true
	oc get pods -n default || true
	popd
}

pushd openshift-baremetal-ci/tests/topology

./topology-manager-e2e.sh
