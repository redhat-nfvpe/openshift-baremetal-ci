#!/bin/bash
set -x
set -e

if [ ! -d "origin" ]; then
	git clone https://github.com/openshift/origin.git
fi

pushd origin

# build 'openshift-tests' binary
make WHAT=cmd/openshift-tests

OPENSHIFT_TESTS=$(realpath ./_output/local/bin/linux/amd64/openshift-tests)

# run sig-network tests
# excluding 'Disabled:' and 'Skipped:NetworkOVNKubernetes' tests
$OPENSHIFT_TESTS run all --dry-run | \
	grep -E "sig-network" | \
	grep -v "Disabled:" | \
	grep -v "Skipped:Network/OVNKubernetes" | \
	grep -v "should handle load balancer cleanup finalizer for service" | \
	grep -v "for LoadBalancer service" | \
	grep -v "should transfer ~ 1GB" | \
	grep -v "Should be able to send traffic between Pods without SNAT" | \
	$OPENSHIFT_TESTS run -f -
