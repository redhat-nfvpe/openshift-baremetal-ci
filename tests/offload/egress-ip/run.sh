#!/bin/bash

set -e
set -x

oc label nodes worker-advnetlab24 k8s.ovn.org/egress-assignable=""

pushd openshift-baremetal-ci/tests/offload/egress-ip
oc apply -f namespace.yaml
oc apply -f egressip.yaml
popd

sleep 5

pushd openshift-baremetal-ci/tests/offload/egress-ip
oc apply -f pod-egressip.yaml
popd

sleep 2
oc wait --for condition=ready pods testpod-egressip-worker-24 -n egressip --timeout=30s

oc exec testpod-egressip-worker-24 -- ping -c 10 redhat.com

pushd openshift-baremetal-ci/tests/offload/egress-ip
oc delete -f pod-egressip.yaml
oc delete -f egressip.yaml
oc delete -f namespace.yaml
popd

oc label nodes worker-advnetlab24 k8s.ovn.org/egress-assignable-
