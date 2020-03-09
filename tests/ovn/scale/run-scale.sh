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

NUM_OF_WORKER=$(oc get nodes | grep worker- | wc -l)
NUM_OF_MASTER=$(oc get nodes | grep master- | wc -l)
NUM_OF_NODES=$(oc get nodes | grep 'worker-\|master-' | wc -l)

if (( $NUM_OF_WORKER > 1 )); then
	export SCALE=${SCALE:-400}
	export NAMESPACE=${NAMESPACE:-100}
else
	export SCALE=${SCALE:-200}
	export NAMESPACE=${NAMESPACE:-50}
fi
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
