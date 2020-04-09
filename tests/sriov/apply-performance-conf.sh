#!/bin/bash

set -x

ssh_execute() {
        host=$1
        cmd=$2
        ssh -q -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -l core $host "$cmd"
}

oc apply -f templates/performance.yaml

#echo "Waiting for worker node to become 'NotReady,SchedulingDisabled' ..."
#count=0
#while [ "$(oc get nodes -o wide | grep "worker-0" | awk -F' ' '{print $2}')" != "NotReady,SchedulingDisabled" ]
#do
#	sleep 30
#	count=$(($count+1))
#	timepassed=$(($count*30))
#	if (( $timepassed > 1200 )); then
#		echo "Time out waiting for worker node to become 'NotReady,SchedulingDisabled'."
#		exit 1
#	fi
#done

echo "Waiting for performance.yaml be applied on all nodes"

NUM_OF_NODES=$(oc get nodes -o wide | grep 'worker-\|master-' | wc -l)
NUM_OF_MASTERS=$(oc get nodes -o wide | grep 'master-' | wc -l)
NUM_OF_WORKERS=$(oc get nodes -o wide | grep 'worker-' | wc -l)
NODE_IPS=$(oc get nodes -o wide | grep 'worker-\|master-' | awk -F' ' '{print $6}')
WORKER_IPS=$(oc get nodes -o wide | grep 'worker-' | awk -F' ' '{print $6}')

time_count=0
while (( $time_count < 120 ))
do
	sleep 30
	time_count=$((time_count+1))

	node_count=0
	worker_count=0
	for node_ip in $NODE_IPS
	do
		output=$(ssh_execute $node_ip "sudo cat /etc/kubernetes/kubelet.conf")
		if grep -q "TopologyManager" <<< "$output" ;then
			node_count=$((node_count+1))
			echo "OK"
		fi
	done

	for worker_ip in $WORKER_IPS
	do
		output=$(ssh_execute $worker_ip "sudo cat /proc/cmdline")
		if grep -q "hugepage" <<< "$output" ;then
			worker_count=$((worker_count+1))
			echo "OK"
		fi
	done

	if [ $node_count == $NUM_OF_NODES ] && [ $worker_count == $NUM_OF_WORKERS ]; then
		break
	fi
done

echo "Waiting for nodes to become Ready after applying performance config ..."
count=0
while [ "$(oc get nodes -o wide | grep "worker-0" | awk -F' ' '{print $2}')" != "Ready" ] || \
      [ "$(oc get nodes -o wide | grep "worker-1" | awk -F' ' '{print $2}')" != "Ready" ] || \
      [ "$(oc get nodes -o wide | grep "master-0" | awk -F' ' '{print $2}')" != "Ready" ] || \
      [ "$(oc get nodes -o wide | grep "master-1" | awk -F' ' '{print $2}')" != "Ready" ] || \
      [ "$(oc get nodes -o wide | grep "master-2" | awk -F' ' '{print $2}')" != "Ready" ];
do
	sleep 30
	count=$(($count+1))
	timepassed=$(($count*30))
	if (( $timepassed > 1200 )); then
		echo "Time out waiting for nodes to become Ready after applying performance config."
		exit 1
	fi
done
