#!/bin/bash
set -x

if [ ! -d "origin" ]; then
	git clone https://github.com/openshift/origin.git
fi

pushd origin

# build 'openshift-tests' binary
make WHAT=cmd/openshift-tests

OPENSHIFT_TESTS=$(realpath ./_output/local/bin/linux/amd64/openshift-tests)

# run 'TestAuthorizationResourceAccessReview should succeed' first
# as it may be affected by other tests
$OPENSHIFT_TESTS run openshift/conformance/serial --dry-run | \
	grep -E "TestAuthorizationResourceAccessReview should succeed" | \
	$OPENSHIFT_TESTS run -f -

# run 'validates resource limits of pods that are allowed to run' first
# as it may be affected by other tests that doesn't release CPUs immediately
$OPENSHIFT_TESTS run openshift/conformance/serial --dry-run | \
	grep -E "validates resource limits of pods that are allowed to run" | \
	$OPENSHIFT_TESTS run -f -

# run conformance serial tests
$OPENSHIFT_TESTS run openshift/conformance/serial --dry-run | \
	grep -v "TestAuthorizationResourceAccessReview should succeed" | \
	grep -v "validates resource limits of pods that are allowed to run" | \
	grep -v "test RequestHeaders IdP" | \
	grep -v "ldap group sync can sync groups from ldap" | \
	$OPENSHIFT_TESTS run -o ./comformance-serial.e2e.log --junit-dir /serial.junit -f -

# Frequent Failed Tests
# 1. [Feature:OpenShiftAuthorization][Serial] authorization  TestAuthorizationResourceAccessReview should succeed [Suite:openshift/conformance/serial]

# There are additional service accounts be created by other test cases which lead to failure when checking 'who can view deploymentconfigs' in this test.


# 2. [sig-scheduling] SchedulerPredicates [Serial] validates resource limits of pods that are allowed to run  [Conformance] [Suite:openshift/conformance/serial/minimal] [Suite:k8s]

# This test checks pod cannot be scheduled if CPU resource limits cannot be satisfied. It first creates a pod that use up to 70% CPUs on each node, then try to schedule another Pod that requesting 50% CPUs on each node, finially it checks if another Pod cannot be scheduled. The failure of this test is due to there are CPUs not freed when the first Pod(requesting 70% CPUs on each node) gets created, so it use less than 70% CPUs from node, when the second Pod gets created, it can still get 50% CPUs.


# 3. [Serial] [Feature:OAuthServer] [RequestHeaders] [IdP] test RequestHeaders IdP [Suite:openshift/conformance/serial]

# This test requires accurate time (in the level of seconds) on each Node because it checks the Pod creation timestamp. On OpenShift Baremetal CI env, the delay of system clock is differ from node to node, usually the delay is large than 1 second which makes the test fails.


# 4. [Suite:openshift/oauth][Serial] ldap group sync can sync groups from ldap [Suite:openshift/conformance/serial]

# 'find' command not found in test pod which results in failure. `find` binary is included in `findutil` rpm package on fedora 29 (which is used as base image of this test pod), but it seems the installation of `findutil` on base image fails (there is no log message in the installation code)
