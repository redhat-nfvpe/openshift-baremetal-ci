#!/bin/bash

set -e

cd $WORKSPACE/origin

make WHAT=cmd/openshift-tests

export OPENSHIFT_TESTS=$WORKSPACE/origin/_output/local/bin/linux/amd64/openshift-tests
export KUBECONFIG=$WORKSPACE/../OCP-Networking-Multus-Install-KNI-08/dev-scripts/ocp/auth/kubeconfig

$OPENSHIFT_TESTS run all --dry-run  | grep "sriov" | $OPENSHIFT_TESTS run -f -
$OPENSHIFT_TESTS run all --dry-run  | grep "dpdk" | $OPENSHIFT_TESTS run -f -
$OPENSHIFT_TESTS run all --dry-run  | grep "rdma" | $OPENSHIFT_TESTS run -f -
