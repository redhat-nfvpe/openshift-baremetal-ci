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
oc apply -f egressfirewall.yaml
popd

sleep 5

pushd openshift-baremetal-ci/tests/offload/egressfirewall
oc apply -f pod-egressfirewall.yaml
popd

sleep 2
oc wait --for condition=ready pods testpod-egressfirewall-worker-24 -n egressfirewall --timeout=30s

ret=$(oc -n egressfirewall exec testpod-egressfirewall-worker-24 -- ping -c 10 google.com)

if [ $ret == 0 ]; then
	echo "ping to google.com to succeed, expected"
else
	echo "expect ping to google.com to succeed, but failed"
	exit 1
fi

ret=$(oc -n egressfirewall exec testpod-egressfirewall-worker-24 -- ping -c 10 redhat.com)

if [ $ret == 0 ]; then
	echo "expect ping to redhat.com to fail, but succeeded"
	exit 1
else
	echo "ping to redhat.com to fail, expected"
fi

