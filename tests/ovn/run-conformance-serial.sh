#!/bin/bash
set -x

if [ ! -d "origin" ]; then
	git clone https://github.com/openshift/origin.git
fi

pushd origin

# build 'openshift-tests' binary
make WHAT=cmd/openshift-tests

OPENSHIFT_TESTS=$(realpath ./_output/local/bin/linux/amd64/openshift-tests)

# run conformance serial tests
$OPENSHIFT_TESTS run openshift/conformance/serial \
	-o ./comformance-serial.e2e.log \
	--junit-dir ./serial.junit
