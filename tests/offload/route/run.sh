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
	pushd openshift-baremetal-ci/tests/offload/route
	oc delete -f pod-route.yaml || true
	oc delete -f namespace.yaml || true
	popd
}

pushd openshift-baremetal-ci/tests/offload/route
oc apply -f namespace.yaml
popd

sleep 1

pushd openshift-baremetal-ci/tests/offload/route
if [ $TestMode == OVN ]; then
        oc apply -f pod-route.yaml
elif [ $TestMode == SRIOV ]; then
        oc apply -f sriovpod-route.yaml
else
        exit 1
fi
popd

sleep 2
oc wait --for condition=ready pods testpod-route-worker-24 -n route --timeout=30s
oc -n route expose pod/testpod-route-worker-24
oc -n route expose svc testpod-route-worker-24
sleep 1
oc -n route get route testpod-route-worker-24 -o yaml

host=$(oc -n route get route testpod-route-worker-24 -ojsonpath='{.spec.host}')

set +e
curl $host
if [ $? == 0 ]; then
	echo "ping to google.com succeeded, expected"
else
	echo "expect ping to google.com to succeed, but failed"
	exit 1
fi
set -e
