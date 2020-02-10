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

pushd openshift-baremetal-ci/tests/ovn/scale

for ns in $(seq 1 $NAMESPACE); do
	oc create ns "test-"$ns
	oc create -f templates/scale-deployment.yaml -n "test-"$ns
	oc wait --for condition=available -n "test-"$ns deployment/$DEPLOYMENT --timeout=120s
done

/usr/bin/python checktimetoscale.py $SCALE $NAMESPACE $DEPLOYMENT
