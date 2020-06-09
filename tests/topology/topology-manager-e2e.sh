#!/bin/bash
set -x

if [ ! -d "origin" ]; then
	git clone https://github.com/fromanirh/origin.git
fi

# create sriov network before pushd origin folder
oc create -f templates/sn-intel.yaml

pushd origin
# fetch the fix to be submitted to openshift
git checkout e2e-tm-fix-concurrent-creation-test
# make sure to pull the last changes
git pull --rebase

# build 'openshift-tests' binary
make WHAT=cmd/openshift-tests

OPENSHIFT_TESTS=$(realpath ./_output/local/bin/linux/amd64/openshift-tests)

# add SR-IOV related environment variables
# https://github.com/fromanirh/origin/blob/topomgr-e2e-tests-ci/test/extended/topology_manager/README.md
export SRIOV_NETWORK_NAMESPACE=default
export SRIOV_NETWORK=sriov-intel
export RESOURCE_NAME=openshift.io/intelnics

$OPENSHIFT_TESTS run openshift/conformance --dry-run | \
	grep -E "TopologyManager" | \
	$OPENSHIFT_TESTS run -f -
