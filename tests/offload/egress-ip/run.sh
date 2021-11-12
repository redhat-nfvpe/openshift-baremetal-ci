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

oc label nodes worker-advnetlab24 k8s.ovn.org/egress-assignable="" --overwrite

pushd openshift-baremetal-ci/tests/offload/egress-ip
oc apply -f namespace.yaml
oc apply -f egressip.yaml
popd

sleep 5


pushd openshift-baremetal-ci/tests/offload/egress-ip
if [ $TestMode == OVN ]; then
	oc apply -f pod-egressip.yaml
elif [ $TestMode == SRIOV ]; then
	oc apply -f sriovpod-egressip.yaml
else
        exit 1
fi
popd

sleep 2
oc wait --for condition=ready pods testpod-egressip-worker-24 -n egressip --timeout=30s

oc -n egressip exec testpod-egressip-worker-24 -- ping -c 10 redhat.com

pushd openshift-baremetal-ci/tests/offload/egress-ip
oc delete -f pod-egressip.yaml
oc delete -f egressip.yaml
oc delete -f namespace.yaml
popd

oc label nodes worker-advnetlab24 k8s.ovn.org/egress-assignable-
