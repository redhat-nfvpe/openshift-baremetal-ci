#!/bin/bash

set -e
set -x

trap cleanup 0 1

cleanup() {
	pushd openshift-baremetal-ci/tests/offload/egressfirewall
	oc delete -f pod-egressfirewall.yaml || true
	oc delete -f egressfirewall.yaml || true
	oc delete -f namespace.yaml || true
	popd
}

pushd openshift-baremetal-ci/tests/offload/egressfirewall
oc apply -f namespace.yaml
popd

sleep 1

pushd openshift-baremetal-ci/tests/offload/egressfirewall
oc apply -f pod-egressfirewall.yaml
popd

sleep 2
oc wait --for condition=ready pods testpod-egressfirewall-worker-24 -n egressfirewall --timeout=30s

set +e
oc -n egressfirewall exec testpod-egressfirewall-worker-24 -- ping -c 10 google.com
if [ $ret == 0 ]; then
	echo "ping to google.com succeeded, expected"
else
	echo "expect ping to google.com to succeed, but failed"
	exit 1
fi

oc -n egressfirewall exec testpod-egressfirewall-worker-24 -- ping -c 10 redhat.com
if [ $ret == 0 ]; then
	echo "ping to redhat.com succeeded, expected"
else
	echo "expect ping to redhat.com to succeed, but failed"
	exit 1
fi
set -e

pushd openshift-baremetal-ci/tests/offload/egressfirewall
echo "apply egress firewall rules to deny access to redhat.com"
oc apply -f egressfirewall.yaml
popd

sleep 5

set +e
oc -n egressfirewall exec testpod-egressfirewall-worker-24 -- ping -c 10 google.com
if [ $ret == 0 ]; then
	echo "ping to google.com succeeded, expected"
else
	echo "expect ping to google.com to succeed, but failed"
	exit 1
fi

oc -n egressfirewall exec testpod-egressfirewall-worker-24 -- ping -c 10 redhat.com
if [ $ret == 0 ]; then
	echo "expect ping to redhat.com to fail, but succeeded"
	exit 1
else
	echo "ping to redhat.com failed, expected"
fi
set -e
