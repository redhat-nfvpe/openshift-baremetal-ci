#!/bin/bash

set -e
set -x

trap cleanup 0 1

cleanup() {
	oc get co || true
	oc get clusterversion || true
	oc get nodes || true
	oc get pods -n openshift-ptp || true
	oc get pods -n default || true
	./cleanup.sh || true
	popd
}

pushd openshift-baremetal-ci/tests/ptp
./run-ptp-operator.sh
popd

pushd openshift-baremetal-ci/tests/ptp/ptp-operator
make functests
popd
