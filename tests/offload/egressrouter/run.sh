#!/bin/bash

set -e
set -x

trap cleanup 0 1

cleanup() {
	pushd openshift-baremetal-ci/tests/offload/egressrouter
	oc delete -f pod-egressrouter.yaml || true
	oc delete -f egressrouter-svc.yaml || true
	oc delete -f egressrouter.yaml || true
	oc delete -f namespace.yaml || true
	popd
}

pushd openshift-baremetal-ci/tests/offload/egressrouter
oc apply -f namespace.yaml
oc apply -f egressrouter.yaml
popd

sleep 5

pushd openshift-baremetal-ci/tests/offload/egressrouter
oc apply -f egressrouter-svc.yaml
oc apply -f pod-egressrouter.yaml
popd

sleep 2
oc wait --for condition=ready pods testpod-egressrouter-worker-24 -n egressrouter --timeout=30s

svc=$(oc get svc egressrouter-svc -ojsonpath='{.spec.clusterIP}')

set +e
oc -n egressrouter exec testpod-egressrouter-worker-24 -- curl $svc:80
if [ $? == 0 ]; then
	echo "curl to $svc:80 succeeded, expected"
else
	echo "expect curl to $svc:80 to succeed, but failed"
	exit 1
fi
set -e
