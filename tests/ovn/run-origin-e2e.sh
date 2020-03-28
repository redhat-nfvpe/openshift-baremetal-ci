#!/bin/bash
set -x
set -e

pushd origin

OPENSHIFT_TESTS=$(realpath ./_output/local/bin/linux/amd64/openshift-tests)

# run sig-network tests
# excluding 'Disabled:' and 'Skipped:NetworkOVNKubernetes' tests
$OPENSHIFT_TESTS run openshift/conformance --dry-run | \
	grep -E "sig-network" | \
	grep -v "Disabled:" | \
	grep -v "Skipped:Network/OVNKubernetes" | \
	grep -v "should handle load balancer cleanup finalizer for service" | \
	grep -v "for LoadBalancer service" | \
	grep -v "should transfer ~ 1GB" | \
	grep -v "Should be able to send traffic between Pods without SNAT" | \
	grep -v "Networking should provide Internet connection for containers" | \
	$OPENSHIFT_TESTS run -f -

popd
