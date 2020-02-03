#!/bin/bash

set -e
set -x

trap cleanup 0 1

cleanup() {
	EXIT_CODE=$?
	oc -n $TEST_NAMESPACE get deployments
	for index in $(seq 1 $SERVICE_NUM); do
		oc delete -f testpod-deployment-${index}.yaml || true
		oc delete -f testpod-service-${index}.yaml || true
		rm -rf testpod-deployment-${index}.yaml
		rm -rf testpod-service-${index}.yaml
	done
	oc delete -f testpod-daemon.yaml || true
	oc delete -f debugpod.yaml || true
	popd
	if [ $EXIT_CODE == 0 ]; then
		echo "# Success"
	else
		echo "# Failed"
	fi
	TOTAL_DURATION=$((DURATION_ALL_SERVICES_CREATED + \
			  DURATION_ALL_PODS_CREATED + \
			  DURATION_ALL_PODS_BECOME_AVAILABLE + \
			  DURATION_CHECK_ALL_PODS_CONNECTIVITY + \
			  DURATION_CHECK_ALL_SERVICES_CONNECTIVITY))
	set +x
	echo "# Test parameters:"
	echo "# Number of Pods:             $POD_NUM"
	echo "# Number of Services:         $SERVICE_NUM"
	echo "# Number of Pods per Service: $(( POD_NUM/SERVICE_NUM ))"
	echo "# Time elapsed TOTAL:                           $TOTAL_DURATION (s)"
	echo "# Time elapsed ALL_PODS_CREATED:                $DURATION_ALL_PODS_CREATED (s)"
	echo "# Time elapsed ALL_PODS_BECOME_AVAILABLE:       $DURATION_ALL_PODS_BECOME_AVAILABLE (s)"
	echo "# Time elapsed ALL_SERVICES_CREATED:            $DURATION_ALL_SERVICES_CREATED (s)"
	echo "# Time elapsed CHECK_ALL_PODS_CONNECTIVITY:     $DURATION_CHECK_ALL_PODS_CONNECTIVITY (s)"
	echo "# Time elapsed CHECK_ALL_SERVICES_CONNECTIVITY: $DURATION_CHECK_ALL_SERVICES_CONNECTIVITY (s)"
}

export POD_NUM=${POD_NUM:-400}
export SERVICE_NUM=${SERVICE_NUM:-100}
export TIMEOUT=${TIMEOUT:-300}
export TEST_NAMESPACE=${TEST_NAMESPACE:-"default"}

NUM_OF_WORKER=$(oc get nodes | grep worker- | wc -l)
NUM_OF_MASTER=$(oc get nodes | grep master- | wc -l)
NUM_OF_NODES=$(oc get nodes | grep 'worker-\|master-' | wc -l)

# Download test pod image on each node
pushd templates
oc create -f testpod-daemon.yaml -n $TEST_NAMESPACE
sleep 1

for i in {1..6}; do
	sleep 10
	daemonset=$(oc get ds ovn-service \
		-n $TEST_NAMESPACE | tail -n 1 | awk '{print $4}')

	if [ $daemonset -eq $NUM_OF_NODES ]; then
		break
	fi

	if [ $i -eq 6 ]; then
		exit 1
	fi
done
oc delete -f testpod-daemon.yaml -n $TEST_NAMESPACE
sleep 5

oc create -f debugpod.yaml -n $TEST_NAMESPACE
sleep 1
oc wait --for condition=ready pods debugpod -n $TEST_NAMESPACE --timeout=${TIMEOUT}s

# install nslookup in debugpod to check service availability
oc -n $TEST_NAMESPACE exec debugpod -- yum install -y bind-utils

replica=$(( POD_NUM/SERVICE_NUM ))
for index in $(seq 1 $SERVICE_NUM); do
	export replica index
	envsubst <"testpod-service.yaml.tpl" >"testpod-service-${index}.yaml"
	envsubst <"testpod-deployment.yaml.tpl" >"testpod-deployment-${index}.yaml"
done

SECONDS=0
for index in $(seq 1 $SERVICE_NUM); do
	oc create -f testpod-deployment-${index}.yaml -n $TEST_NAMESPACE
done
DURATION_ALL_PODS_CREATED=$SECONDS

SECONDS=0
for index in $(seq 1 $SERVICE_NUM); do
	oc wait --for condition=available -n $TEST_NAMESPACE deployment/ovn-deployment-${index} --timeout=${TIMEOUT}s
done
DURATION_ALL_PODS_BECOME_AVAILABLE=$SECONDS

sleep 1

SECONDS=0
for index in $(seq 1 $SERVICE_NUM); do
	NUM_OF_PODS=$(oc get pods -n $TEST_NAMESPACE -l run=ovn-service-${index} -o yaml | grep -w podIP | wc -l)
	POD_IPS=$(oc get pods -n $TEST_NAMESPACE -l run=ovn-service-${index} -o yaml | grep -w podIP)
	count=0
	for j in $(seq 1 $NUM_OF_PODS); do
		podName=$(oc get pods -n $TEST_NAMESPACE -l run=ovn-service-${index} -o name | awk "NR==$j")
		podIP=$(oc get -n $TEST_NAMESPACE $podName -o json | jq -r '.status.podIP')
		if oc -n $TEST_NAMESPACE exec debugpod -- curl --silent --fail $podIP > /dev/null; then
			count=$(($count+1))
		fi
	done

	if [ $count == $NUM_OF_PODS ]; then
		continue
	else
		exit 1
	fi
done
DURATION_CHECK_ALL_PODS_CONNECTIVITY=$SECONDS

SECONDS=0
for index in $(seq 1 $SERVICE_NUM); do
	oc create -f testpod-service-${index}.yaml -n $TEST_NAMESPACE
done
DURATION_ALL_SERVICES_CREATED=$SECONDS

SECONDS=0
for index in $(seq 1 $SERVICE_NUM); do
	oc -n $TEST_NAMESPACE exec debugpod -- nslookup ovn-service-${index}
done
DURATION_CHECK_ALL_SERVICES_CONNECTIVITY=$SECONDS
