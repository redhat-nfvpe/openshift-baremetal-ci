#!/bin/bash
set -x
set -e

trap cleanup 0 1

cleanup() {
	popd
}

pushd openshift-baremetal-ci/tests/ovn

# run unit tests of cluster network operator
./run-cluster-network-operator-unit.sh

# run origin end to end tests
./run-origin-e2e.sh
