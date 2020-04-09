#!/bin/bash

set -e
set -x

export OPENSHIFT_MAJOR_VERSION=${OPENSHIFT_MAJOR_VERSION:-"4.4"}
export NETWORK_TYPE=${NETWORK_TYPE:-"OVNKubernetes"}

# export PULL_SECRET=${PULL_SECRET:-""}
# [ -z $PULL_SECRET ] && echo "empty pull secret, exiting" && exit 1

trap cleanup 0 1

cleanup() {
	oc get nodes || true
	oc get co || true
	oc get clusterversion || true
	popd
}

yum install -y git ansible

rm -rf baremetal-deploy
# git clone https://github.com/openshift-kni/baremetal-deploy.git
git clone https://github.com/zshi-redhat/baremetal-deploy.git

pushd baremetal-deploy/ansible-ipi-install

git checkout ipv6

IFCFG_DIR="roles/installer/files/customize_filesystem/master/etc/sysconfig/network-scripts"
mkdir -p $IFCFG_DIR

# cp -rf /root/ipi-config/ifcfg-eno1 $IFCFG_DIR/ifcfg-eno1
cp -rf /root/ipi-config/ansible.cfg ./ansible.cfg
cp -rf /root/ipi-config/playbook.yml ./playbook.yml
cp -rf /root/ipi-config/inventory.hosts inventory/inventory.hosts

sed -i -e "s/^version=.*/version=\"latest-${OPENSHIFT_MAJOR_VERSION}\"/g" inventory/inventory.hosts
sed -i -e "s/^build=.*/build=\"dev\"/g" inventory/inventory.hosts
# update network type {OpenShiftSDN|OVNKubernetes}, default is OVNKubernetes
sed -i -e "s/^#network_type=.*/network_type=\"${NETWORK_TYPE}\"/g" inventory/inventory.hosts

sleep 2

podman ps --all
sleep 2

ANSIBLE_FORCE_COLOR=true ansible-playbook -i inventory/inventory.hosts playbook.yml --skip-tags="packages,network,services,firewall"
