#!/bin/bash

set -e
set -x

export OPENSHIFT_MAJOR_VERSION=${OPENSHIFT_MAJOR_VERSION:-"4.3"}

# export PULL_SECRET=${PULL_SECRET:-""}
# [ -z $PULL_SECRET ] && echo "empty pull secret, exiting" && exit 1

trap cleanup 0 1

cleanup() {
	# Gather bootstrap & master logs
	./requirements/openshift-install gather bootstrap \
		--dir=./ocp --bootstrap 192.168.111.10 \
		--master 192.168.111.11 \
		--master 192.168.111.12 \
		--master 192.168.111.13 || true

	# Destroy bootstrap VM
	# virsh destroy dev-bootstrap || true
	virsh list --name | grep bootstrap | xargs virsh destroy || true

	./requirements/oc --config ./ocp/auth/kubeconfig get nodes || true
	./requirements/oc --config ./ocp/auth/kubeconfig get co || true
	./requirements/oc --config ./ocp/auth/kubeconfig get clusterversion || true
	popd
}

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
sleep 320

# Wait for bootstrap complete
./requirements/openshift-install --dir ./ocp wait-for bootstrap-complete --log-level debug

sleep 30
cp -rf ./requirements/oc /usr/local/bin/
./requirements/oc --config ./ocp/auth/kubeconfig get nodes || true

sleep 30
# Start Openshift-installer wait-for when image-registry is rendered
# This allows us to wait a few more mins for cluster to come up
while [ "$(./requirements/oc --config ./ocp/auth/kubeconfig get co | grep image-registry)" == "" ]
do
	sleep 10
	echo "waiting for image-registry operator to be deployed"
done

sleep 20
# Patch storage to emptyDir to workthrough warning: "Unable to apply resources: storage backend not configured"
# Comment out, this is only required for pre-4.2 releases
#./requirements/oc --config ./ocp/auth/kubeconfig patch configs.imageregistry.operator.openshift.io cluster \
#	-p '{"spec":{"storage":{"emptyDir":{}}}}' --type='merge'

# Patch storage to 'Removed' managementState. This makes image-registry operator become Available immediately
# ./requirements/oc --config ./ocp/auth/kubeconfig patch configs.imageregistry.operator.openshift.io cluster \
# 	-p '{"spec":{"managementState": "Removed"}}' --type='merge'

# Wait for install complete
./requirements/openshift-install --dir ./ocp wait-for install-complete --log-level debug
