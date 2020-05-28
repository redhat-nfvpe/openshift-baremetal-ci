#!/bin/bash
set -x

if [ ! -d "origin" ]; then
	git clone https://github.com/fromanirh/origin.git
fi

pushd origin
# fetch the fix to be submitted to openshift
git checkout e2e-tm-fix-concurrent-creation-test
# make sure to pull the last changes
git pull --rebase

# build 'openshift-tests' binary
make WHAT=cmd/openshift-tests

OPENSHIFT_TESTS=$(realpath ./_output/local/bin/linux/amd64/openshift-tests)

$OPENSHIFT_TESTS run openshift/conformance --dry-run | \
	grep -E "TopologyManager" | \
	$OPENSHIFT_TESTS run -f -
