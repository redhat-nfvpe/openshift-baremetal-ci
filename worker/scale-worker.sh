#!/bin/bash

set -x

# Worker Node OpenShift API Interface MACs
# nfvpe-06: 3c:fd:fe:a0:d5:e1
# nfvpe-07: 3c:fd:fe:ba:0a:78 -> used to have problem of becoming link down on switch side
# nfvpe-07: 3c:fd:fe:ba:0a:79 <- currently use this address as baremetal API interface
# nfvpe-08: 3c:fd:fe:ba:07:9c

#workerNode=nfvpe-07

workerNode=$1
timeout=1800

if [ "$workerNode" == "nfvpe-06" ];then
	MAC="3c:fd:fe:a0:d5:e1"
elif [ "$workerNode" == "nfvpe-07" ];then
	MAC="3c:fd:fe:ba:0a:78"
elif [ "$workerNode" == "nfvpe-08" ];then
	MAC="3c:fd:fe:ba:07:9c"
else
	echo "workerNode $workerNode is not supported, please specify valid worker node 'nfvpe-06,nfvpe-07,nfvpe-08'"
	exit 1
fi

wait_for_worker() {
	worker=$1
	state=$2
	interval=$3
	count=0
	
	echo "Waiting for worker $worker to beome $state ..."
	while [ "$(oc get baremetalhosts --all-namespaces | grep $worker | grep $state)" = "" ]
	do
		sleep $interval
		count=$((count+1))
		let timepassed="$count*$interval"
		if [ $timepassed -gt $timeout ]; then
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

if [ "$(oc get baremetalhosts --all-namespaces | grep $workerNode | grep 'provisioned')" != "" ]; then
	oc scale --replicas=0 machinesets sriov-worker-0 -n openshift-machine-api
fi

if [ "$(oc get baremetalhosts --all-namespaces | grep $workerNode | grep 'provisioning')" != "" ]; then
	wait_for_worker $workerNode provisioned 30
	oc scale --replicas=0 machinesets sriov-worker-0 -n openshift-machine-api
fi

if [ "$(oc get baremetalhosts --all-namespaces | grep $workerNode)" == "" ]; then
	echo "Adding work node $workerNode definition"
	oc apply -f templates/$workerNode.yaml --namespace=openshift-machine-api
fi

wait_for_worker $workerNode ready 5

desiredWorkerNum=$(oc get machinesets -n openshift-machine-api | tail -n1 | awk -F' ' '{print $2}')

desiredWorkerNum=$((desiredWorkerNum+1))

oc scale --replicas=$desiredWorkerNum machinesets sriov-worker-0 -n openshift-machine-api

wait_for_worker $workerNode provisioned 30


while true
do
	workerIP=$(ip neighbor | grep -i $MAC | tail -n1 | cut  -d" " -f1)
        up=$(ssh_execute $workerIP "uptime -p" | awk -F' ' '{ print $2 }')
        if (( $(echo "$up > 3" | bc -l) )); then
                break
        fi
	sleep 30
done

workerIP=$(ip neighbor | grep -i $MAC | tail -n1 | cut  -d" " -f1)



# In 4.3, node can come up without setting below config
# 192.168.111.1 dns can be correctly configured in /etc/resolve.conf

#ssh_execute $workerIP "sudo sed -i -e '\$a\192.168.111.5 api-int.sriov.dev.metalkube.org api-int' /etc/hosts"
#ssh_execute $workerIP "sudo sed -i '/192.168.111.1/d' /etc/resolv.conf"
#ssh_execute $workerIP "sudo sed -i -e 's/^search .*/& \nnameserver 192.168.111.1/g' /etc/resolv.conf"
#ssh_execute $workerIP "sudo systemctl restart crio"


echo "Waiting for worker $workerNode to appear as OpenShift node ..."
count=0
while [ "$(oc get nodes -o wide | grep $workerIP | awk -F' ' '{print $2}')" != "Ready" ]
do
	oc get csr -o name | xargs -n 1 oc adm certificate approve || true
	sleep 30
	let count++
	let timepassed="$count*30"
	if (( $timepassed > 1200 )); then
		echo "Time out waiting for $workerNode to appear as OpenShift node."
		exit 1
	fi
done

sleep 10

workerIP=$(ip neighbor | grep -i $MAC | tail -n1 | cut  -d" " -f1)

oc apply -f templates/performance.yaml

# After applying performance.yaml config, node will become rebooted -> NotReady
echo "Waiting for worker $workerNode to become 'NotReady,SchedulingDisabled' ..."
count=0
while [ "$(oc get nodes -o wide | grep $workerIP | awk -F' ' '{print $2}')" != *"NotReady,SchedulingDisabled"* ]
do
	sleep 30
	let count++
	let timepassed="$count*30"
	if (( $timepassed > 1200 )); then
		echo "Time out waiting for $workerNode to become 'NotReady,SchedulingDisabled'."
		exit 1
	fi
done

while true
do
        up=$(ssh_execute $workerIP "uptime -p" | awk -F' ' '{ print $2 }')
        if (( $(echo "$up > 2" | bc -l) )); then
                break
        fi
	sleep 30
done

#ssh_execute $workerIP "sudo sed -i '/192.168.111.1/d' /etc/resolv.conf"
#ssh_execute $workerIP "sudo sed -i -e 's/^search .*/& \nnameserver 192.168.111.1/g' /etc/resolv.conf"

echo "Waiting for worker $workerNode to become Ready after applying hugepage config ..."
count=0
while [ "$(oc get nodes -o wide | grep $workerIP | awk -F' ' '{print $2}')" != "Ready" ]
do
	oc get csr -o name | xargs -n 1 oc adm certificate approve || true
	sleep 30
	let count++
	let timepassed="$count*30"
	if (( $timepassed > 1200 )); then
		echo "Time out waiting for $workerNode to become Ready after applying hugepage config."
		exit 1
	fi
done
