#!/bin/bash

set -e
set -x

trap cleanup 0 1

cleanup() {
	oc get co || true
	oc get clusterversion || true
	oc get nodes || true
	popd
}

PERF_TEST_SUITE=${1:-"pod"}
echo $PERF_TEST_SUITE

if [ -d plow ]; then
	rm -rf plow
fi

git clone https://github.com/cloud-bulldozer/plow.git

#  For internal machines we have an ES server to warehouse the results from each run. 
export ES_PORT=9200
export ES_SERVER=perf-sm5039-4-5.perf.lab.eng.rdu2.redhat.com
export PERF_TEST_ENV=${PERF_TEST_ENV:-"ovn-baremetal-ci"}

# Execute tests
pushd plow/workloads/network-perf/

# run perf host network tests
if [ $PERF_TEST_SUITE == "host" ]; then
	echo "running perf host network test"
	./run_hostnetwork_network_test_fromgit.sh $PERF_TEST_ENV
fi

sleep 5

# run perf pod network tests
if [ $PERF_TEST_SUITE == "pod" ]; then
	echo "running perf pod network test"
	./run_pod_network_test_fromgit.sh $PERF_TEST_ENV
fi

sleep 5

# run perf serviceip network tests
if [ $PERF_TEST_SUITE == "serviceip" ]; then
	echo "running perf serviceip network test"
	./run_serviceip_network_test_fromgit.sh $PERF_TEST_ENV
fi


# Multus secondary network test
# export MULTUS_CLIENT_NAD=my-ripsaw/sriov-ripsaw
# export MULTUS_SERVER_NAD=my-ripsaw/sriov-ripsaw
if [ $PERF_TEST_SUITE == "multus" ]; then
	echo "running perf multus network test"
	# ./run_multus_network_tests_fromgit.sh $PERF_TEST_ENV
fi

