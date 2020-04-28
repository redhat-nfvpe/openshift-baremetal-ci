#!/bin/bash
set -x

if [ ! -d "origin" ]; then
	git clone https://github.com/openshift/origin.git
fi

pushd origin

# build 'openshift-tests' binary
make WHAT=cmd/openshift-tests

OPENSHIFT_TESTS=$(realpath ./_output/local/bin/linux/amd64/openshift-tests)

$OPENSHIFT_TESTS run openshift/conformance --dry-run | \
	grep -E "TopologyManager" | \
	$OPENSHIFT_TESTS run -f -
