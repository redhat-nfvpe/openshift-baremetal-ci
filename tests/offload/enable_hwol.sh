#!/bin/bash
set -x
set -e

pushd openshift-baremetal-ci/tests/sriov
export SUBSCRIPTION=false
export CREATE_NODE_POLICY=false
./run-sriov-operator.sh
popd

pushd openshift-baremetal-ci/tests/offload
oc apply -f pool.yaml
oc apply -f policy-cx5.yaml
oc apply -f nad.yaml
popd

oc wait mcp offload --for='condition=UPDATING=True' --timeout=300s

# Wait until MCO finishes its work or it reachs the 20mins timeout
until
  oc wait mcp offload --for='condition=UPDATED=True' --timeout=10s && \
  oc wait mcp offload --for='condition=UPDATING=False' --timeout=10s && \
  oc wait mcp offload --for='condition=DEGRADED=False' --timeout=10s; 
do
  sleep 10
  echo "Some MachineConfigPool DEGRADED=True,UPDATING=True,or UPDATED=False";
done

until oc get sriovnetworknodestate -n openshift-sriov-network-operator worker-advnetlab24 -o yaml | grep "syncStatus: Succeeded"
do
    echo "wait until sriovnetworkpolicy synced..."
    sleep 3
done
