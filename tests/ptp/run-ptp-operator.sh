#!/bin/bash

set -e
set -x

PTP_OPERATOR_REPO=https://github.com/zshi-redhat/ptp-operator.git
PTP_OPERATOR_NAMESPACE=openshift-ptp

# WORKER_NODE=dev-worker-0
WORKER_NODE=nfvpe-08.oot.lab.eng.bos.redhat.com
NUM_OF_WORKER=$(oc get nodes | grep worker | wc -l)
NUM_OF_MASTER=$(oc get nodes | grep master | wc -l)
NUM_OF_NODES=$(oc get nodes | grep 'worker\|master' | wc -l)

if [ ! -d "ptp-operator" ]; then
	git clone $PTP_OPERATOR_REPO
	pushd ptp-operator
	git checkout fix-env-var-name
	popd
fi

pushd ptp-operator
make deploy-setup

oc wait --for condition=available deployment ptp-operator -n $PTP_OPERATOR_NAMESPACE --timeout=60s
sleep 30

for i in {1..10}; do
	sleep 10
	daemonset=$(oc get ds linuxptp-daemon \
			-n $PTP_OPERATOR_NAMESPACE | tail -n 1 | awk '{print $4}')

	if [ $daemonset -eq $NUM_OF_NODES ]; then
		break
	fi

	if [ $i -eq 10 ]; then
		exit 1
	fi
done
popd

pushd templates
oc create -f ptpconfig_cr.yaml
sleep 30
oc delete -f ptpconfig_cr.yaml
popd
