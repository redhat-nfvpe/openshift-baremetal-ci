#!/bin/bash
set -x

if [ ! -d "origin" ]; then
	# up until the e2e tests are merged upstream, we need to use fromani's fork
	git clone https://github.com/fromanirh/origin.git
fi

pushd origin
# this branch contains the stable patches which will be part of PRs against
# openshift/origin
git checkout topomgr-e2e-tests-ci
# up until all the tests are merged, we need to make sure we always pull
# the latest fixes and tests.
git pull --rebase

# build 'openshift-tests' binary
make WHAT=cmd/openshift-tests

OPENSHIFT_TESTS=$(realpath ./_output/local/bin/linux/amd64/openshift-tests)

$OPENSHIFT_TESTS run openshift/conformance --dry-run | \
	grep -E "TopologyManager" | \
	$OPENSHIFT_TESTS run -f -
