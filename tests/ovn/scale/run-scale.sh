#!/bin/bash

set -e
set -x

trap cleanup 0 1

cleanup() {
	for ns in $(seq 1 $NAMESPACE); do
		oc delete -f templates/scale-deployment.yaml -n "test-"$ns || true
		sleep 1
		oc delete ns "test-"$ns || true
	done
	popd
}

export SCALE=${SCALE:-400}
export NAMESPACE=${NAMESPACE:-100}
export DEPLOYMENT=${DEPLOYMENT:-"scale-deployment"}
export TIMEOUT=${TIMEOUT:-600}

pushd openshift-baremetal-ci/tests/ovn/scale

for ns in $(seq 1 $NAMESPACE); do
	oc create ns "test-"$ns
	oc create -f templates/scale-deployment.yaml -n "test-"$ns
done

for ns in $(seq 1 $NAMESPACE); do
	oc wait --for condition=available -n "test-"$ns deployment/$DEPLOYMENT --timeout=${TIMEOUT}s
done

/usr/bin/python checktimetoscale.py $SCALE $NAMESPACE $DEPLOYMENT
