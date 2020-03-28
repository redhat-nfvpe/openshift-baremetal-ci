#!/bin/bash
set -x
set -e

trap cleanup 0 1

cleanup() {
	popd
}

pushd openshift-baremetal-ci/tests/ovn

if [ ! -d "origin" ]; then
	git clone https://github.com/openshift/origin.git
fi

pushd origin

# override SR-IOV images with 4.3.z version
if oc version | grep 4.3 ; then
	git checkout release-4.3
fi
# override SR-IOV images with 4.4 version
if oc version | grep 4.4 ; then
	git checkout release-4.4
fi
# override SR-IOV images with 4.5 version
if oc version | grep 4.5 ; then
	git checkout release-4.5
fi

popd

# build 'openshift-tests' binary
make WHAT=cmd/openshift-tests

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
