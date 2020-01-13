#!/bin/bash
set -x
set -e

trap cleanup 0 1

cleanup() {
	popd
}

pushd openshift-baremetal-ci/tests/ovn

OVN_TEST_SUITE=${1:-"network"}
echo $OVN_TEST_SUITE

# run origin end to end sig-network tests
if [ $OVN_TEST_SUITE == "network" ]; then
	echo "running origin sig-network e2e tests"
	./run-origin-e2e.sh
fi

# run origin conformance parallel tests
if [ $OVN_TEST_SUITE == "parallel" ]; then
	echo "running origin conformance parallel e2e tests"
	./run-conformance-parallel.sh
fi

# run origin conformance serial tests
if [ $OVN_TEST_SUITE == "serial" ]; then
	echo "running origin conformance serial e2e tests"
	./run-conformance-serial.sh
fi

# run unit tests of cluster network operator
if [ $OVN_TEST_SUITE == "unit" ]; then
	echo "running cluster network operator unit tests"
	./run-cluster-network-operator-unit.sh
fi
