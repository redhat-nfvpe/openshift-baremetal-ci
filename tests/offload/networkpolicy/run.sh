#!/bin/bash

set -e
set -x

TestMode=OVN

while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    -s|--sriov)
      TestMode=SRIOV
      shift # past argument
      ;;
    -d|--default)
      TestMode=OVN
      shift # past argument
      ;;
    *)    # unknown option
      TestMode=OVN
      shift # past argument
      ;;
  esac
done

trap cleanup 0 1

cleanup() {
	pushd openshift-baremetal-ci/tests/offload/networkpolicy
	oc delete -f pod-networkpolicy.yaml || true
	oc delete -f networkpolicy.yaml || true
	oc delete -f namespace.yaml || true
	popd
}

pushd openshift-baremetal-ci/tests/offload/networkpolicy
oc apply -f namespace.yaml
popd

sleep 1

pushd openshift-baremetal-ci/tests/offload/networkpolicy
oc apply -f pod-client.yaml -n default
oc apply -f pod-client.yaml -n networkpolicy
if [ $TestMode == OVN ]; then
        oc apply -f pod-networkpolicy.yaml
elif [ $TestMode == SRIOV ]; then
        oc apply -f sriovpod-networkpolicy.yaml
else
        exit 1
fi
popd

sleep 2
oc wait --for condition=ready pods clientpod-networkpolicy-worker-24 -n default --timeout=30s
oc wait --for condition=ready pods clientpod-networkpolicy-worker-24 -n networkpolicy --timeout=30s
oc wait --for condition=ready pods testpod-networkpolicy-worker-24 -n networkpolicy --timeout=30s
podip=$(oc get pods testpod-networkpolicy-worker-24 -n networkpolicy -ojsonpath='{.status.podIP}')

set +e
oc -n default exec clientpod-networkpolicy-worker-24 -- ping -c 10 $podip
if [ $? == 0 ]; then
	echo "ping to testpod-networkpolicy '$podip' from different namespace succeeded, expected"
else
	echo "expect ping to testpod-networkpolicy '$podip' from different namespace to succeed, but failed"
	exit 1
fi

oc -n networkpolicy exec clientpod-networkpolicy-worker-24 -- ping -c 10 $podip
if [ $? == 0 ]; then
	echo "ping to testpod-networkpolicy '$podip' from same namespace succeeded, expected"
else
	echo "expect ping to testpod-networkpolicy '$podip' from same namespace to succeed, but failed"
	exit 1
fi
set -e

pushd openshift-baremetal-ci/tests/offload/networkpolicy
oc apply -f networkpolicy-deny-by-default.yaml
popd

sleep 3

set +e
oc -n default exec clientpod-networkpolicy-worker-24 -- ping -c 10 $podip
if [ $? == 0 ]; then
	echo "expect ping to testpod-networkpolicy '$podip' from different namespace to fail, but succeeded"
	exit 1
else
	echo "ping to testpod-networkpolicy '$podip' from different namespace failed, expected"
fi

oc -n networkpolicy exec clientpod-networkpolicy-worker-24 -- ping -c 10 $podip
if [ $? == 0 ]; then
	echo "expect ping to testpod-networkpolicy '$podip' from same namespace to fail, but succeeded"
	exit 1
else
	echo "ping to testpod-networkpolicy '$podip' from same namespace failed, expected"
fi
set -e

pushd openshift-baremetal-ci/tests/offload/networkpolicy
oc apply -f networkpolicy-allow-same-namespace.yaml
popd

sleep 3

set +e
oc -n default exec clientpod-networkpolicy-worker-24 -- ping -c 10 $podip
if [ $? == 0 ]; then
	echo "expect ping to testpod-networkpolicy '$podip' from different namespace to fail, but succeeded"
	exit 1
else
	echo "ping to testpod-networkpolicy '$podip' from different namespace failed, expected"
fi

oc -n networkpolicy exec clientpod-networkpolicy-worker-24 -- ping -c 10 $podip
if [ $? == 0 ]; then
	echo "ping to testpod-networkpolicy '$podip' from same namespace succeeded, expected"
else
	echo "expect ping to testpod-networkpolicy '$podip' from same namespace to succeed, but failed"
	exit 1
fi
set -e
