#!/bin/bash

pushd templates

oc delete -f pod-simple.yaml
oc delete -f sn-intel.yaml

popd

pushd sriov-network-operator
make undeploy
popd
