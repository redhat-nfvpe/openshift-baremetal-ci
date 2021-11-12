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

svc=$(oc -n egressrouter get svc egressrouter-svc -ojsonpath='{.spec.clusterIP}')
podip=$(oc get pods -l app=egress-router-cni -n egressrouter -ojsonpath='{.items[0].status.podIP}')

set +e
oc -n egressrouter exec testpod-egressrouter-worker-24 -- curl $svc:80
if [ $? == 0 ]; then
	echo "curl to service $svc:80 succeeded, expected"
else
	echo "expect curl to service $svc:80 to succeed, but failed"
	exit 1
fi

oc -n egressrouter exec testpod-egressrouter-worker-24 -- curl $svc:5000
if [ $? == 0 ]; then
	echo "curl to service $svc:5000 succeeded, expected"
else
	echo "expect curl to service $svc:5000 to succeed, but failed"
	exit 1
fi

oc -n egressrouter exec testpod-egressrouter-worker-24 -- curl $svc:6000
if [ $? == 0 ]; then
	echo "curl to service $svc:6000 succeeded, expected"
else
	echo "expect curl to service $svc:6000 to succeed, but failed"
	exit 1
fi

oc -n egressrouter exec testpod-egressrouter-worker-24 -- curl $podip:80
if [ $? == 0 ]; then
	echo "curl to endpoint pod $podip:80 succeeded, expected"
else
	echo "expect curl to endpoint pod $podip:80 to succeed, but failed"
	exit 1
fi

oc -n egressrouter exec testpod-egressrouter-worker-24 -- curl $podip:8080
if [ $? == 0 ]; then
	echo "curl to endpoint pod $podip:8080 succeeded, expected"
else
	echo "expect curl to endpoint pod $podip:8080 to succeed, but failed"
	exit 1
fi

oc -n egressrouter exec testpod-egressrouter-worker-24 -- curl $podip:8888
if [ $? == 0 ]; then
	echo "curl to endpoint pod $podip:8888 succeeded, expected"
else
	echo "expect curl to endpoint pod $podip:8888 to succeed, but failed"
	exit 1
fi
set -e
