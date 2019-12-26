#!/bin/bash

set -e
set -x

export OPENSHIFT_MAJOR_VERSION=${OPENSHIFT_MAJOR_VERSION:-"4.3"}

# export PULL_SECRET=${PULL_SECRET:-""}
# [ -z $PULL_SECRET ] && echo "empty pull secret, exiting" && exit 1

yum install -y git

rm -rf kni-upi-lab
git clone https://github.com/redhat-nfvpe/kni-upi-lab.git

pushd kni-upi-lab

sed -i -e "s/^OPENSHIFT_RHCOS_MAJOR_REL=.*/OPENSHIFT_RHCOS_MAJOR_REL=\"${OPENSHIFT_MAJOR_VERSION}\"/g" ./common.sh

cp -rf /root/upi-config/site-config.yaml cluster/
cp -rf /root/upi-config/install-config.yaml cluster/
cp -rf /root/upi-config/ha-lab-ipmi-creds.yaml cluster/

make clean

./prep_bm_host.sh
make all
sleep 5
make con-start
sleep 5

podman ps
sleep 2

sleep 20
./scripts/manage.sh deploy cluster

sleep 30
./scripts/manage.sh deploy workers

# Wait for extra 5min for bootstrap to complete
sleep 600

# Wait for bootstrap complete
./requirements/openshift-install --dir ./ocp wait-for bootstrap-complete --log-level debug

sleep 30
cp -rf ./requirements/oc /usr/local/bin/
./requirements/oc --config ./ocp/auth/kubeconfig get nodes

# Destroy bootstrap VM
virsh destroy dev-bootstrap || true
virsh undefine dev_bootstrap || true

sleep 30
while [ "$(./requirements/oc --config ./ocp/auth/kubeconfig get co | grep image-registry)" == "" ]
do
	sleep 10
	echo "waiting for image-registry operator to be deployed"
done

sleep 5
# patch storage to emptyDir to workthrough warning: "Unable to apply resources: storage backend not configured"
./requirements/oc --config ./ocp/auth/kubeconfig patch configs.imageregistry.operator.openshift.io cluster \
	-p '{"spec":{"emptyDir":{}}}' --type='merge'

# Wait for install complete
./requirements/openshift-install --dir ./ocp wait-for install-complete --log-level debug

./requirements/oc --config ./ocp/auth/kubeconfig get nodes
./requirements/oc --config ./ocp/auth/kubeconfig get co
./requirements/oc --config ./ocp/auth/kubeconfig get clusterversion

popd
