#!/bin/bash

set -e

# Worker Node OpenShift API Interface MACs
# nfvpe-06: 3c:fd:fe:a0:d5:e1
# nfvpe-07: 3c:fd:fe:ba:0a:78
# nfvpe-08: 3c:fd:fe:ba:07:9c

workerNode=nfvpe-07
timeout=1800

wait_for_worker() {
	worker=$1
	state=$2
	interval=$3
	count=0
	
	echo "Waiting for worker $worker to beome $state ..."
	while [ "$(oc get baremetalhosts --all-namespaces | grep $worker | grep $state)" = "" ]
	do
		sleep $interval
		let count++
		let timepassed="$count*$interval"
		if (( $timepassed > $timeout )); then
			echo "Time out waiting for $worker to become $state."
			exit 1
		fi
	done
}

ssh_execute() {
	host=$1
	cmd=$2
	ssh -q -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -l core $host "$cmd"
}

if [ oc get baremetalhosts --all-namespaces | grep $workerNode | grep "provisioned" ]; then
	oc scale --replicas=0 machinesets sriov-worker-0 -n openshift-machine-api
fi

if [ oc get baremetalhosts --all-namespaces | grep $workerNode | grep "provisioning" ]; then
	wait_for_worker $workerNode provisioned 30
	oc scale --replicas=0 machinesets sriov-worker-0 -n openshift-machine-api
fi

if [ ! oc get baremetalhosts --all-namespaces | grep $workerNode ]; then
	echo "Adding work node $workerNode definition"
	oc apply -f templates/worker-crs.yaml --namespace=openshift-machine-api 
fi

wait_for_worker $workerNode ready 5

oc scale --replicas=1 machinesets sriov-worker-0 -n openshift-machine-api

wait_for_worker $workerNode provisioned 30


while true
do
	workerIP=$(ip neighbor | grep -i 3c:fd:fe:ba:0a:78 | tail -n1 | cut  -d" " -f1)
        up=$(ssh_execute $workerIP "uptime -p" | awk -F', ' '{ print $NF }' | cut -d ' ' -f1)
        if (( $(echo "$up > 3" | bc -l) )); then
                break
        fi
done

workerIP=$(ip neighbor | grep -i 3c:fd:fe:ba:0a:78 | tail -n1 | cut  -d" " -f1)
ssh_execute $workerIP "sudo sed -i -e '\$a\192.168.111.5 api-int.sriov.dev.metalkube.org api-int' /etc/hosts"
ssh_execute $workerIP "sudo sed -i '/192.168.111.1/d' /etc/resolv.conf" 
ssh_execute $workerIP "sudo sed -i -e 's/^search oot.lab.eng.bos.redhat.com.*/& \nnameserver 192.168.111.1/g' /etc/resolv.conf"
ssh_execute $workerIP "sudo systemctl restart crio"


echo "Waiting for worker $worker to appear as OpenShift node ..."
count=0
while [ "$(oc get nodes | grep $workerNode)" = "" ]
do
	oc get csr -o name | xargs -n 1 oc adm certificate approve
	sleep 5
	let count++
	let timepassed="$count*5"
	if (( $timepassed > 600 )); then
		echo "Time out waiting for $worker to appear as OpenShift node."
		exit 1
	fi
done
