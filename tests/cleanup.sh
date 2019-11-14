#!/bin/bash

pushd templates
oc delete -f pod-simple.yaml
oc delete -f pod1.yaml
oc delete -f pod2.yaml
oc delete -f pod3.yaml
oc delete -f pod4.yaml
oc delete -f pod5.yaml
oc delete -f pod6.yaml
oc delete -f pod7.yaml
oc delete -f pod8.yaml
oc delete -f pod9.yaml
oc delete -f sn-intel.yaml
oc delete -f sn-static-ipam.yaml
popd

pushd templates
oc delete -f policy-intel.yaml
sleep 60
popd

pushd sriov-network-operator
make undeploy
popd
