#!/bin/bash
set -x

ssh_execute() {
	host=$1
	cmd=$2
	ssh -q -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -l core $host "$cmd"
}

for ip in 11 12 13 15 16; do
	ssh_execute 192.168.111.$ip "sudo bash -c \"echo '[registries.search]' > /etc/containers/registries.conf\""
	ssh_execute 192.168.111.$ip "sudo bash -c \"echo registries = [\'registry.access.redhat.com\', \'docker.io\', \'registry.fedoraproject.org\', \'quay.io\', \'registry.centos.org\'] >> /etc/containers/registries.conf\""
	ssh_execute 192.168.111.$ip "sudo bash -c \"echo [registries.insecure] >> /etc/containers/registries.conf\""
	ssh_execute 192.168.111.$ip "sudo bash -c \"echo registries = [\'registry-proxy.engineering.redhat.com\'] >> /etc/containers/registries.conf\""
	ssh_execute 192.168.111.$ip "sudo systemctl restart crio"
done

export HCO_VERSION=2.3.0
export HCO_CHANNEL=2.3
export TARGET_NAMESPACE=openshift-cnv
export APP_REGISTRY=rh-verified-operators
export PRIVATE_REPO=true
export QUAY_USERNAME=
export QUAY_PASSWORD=

./deploy_marketplace.sh
