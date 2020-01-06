#!/bin/bash
set -x
set -e

if [ ! -d "cluster-network-operator" ]; then
	git clone https://github.com/openshift/cluster-network-operator.git
fi

pushd cluster-network-operator

# install golang
yum install -y golang

# set scripts to print commands and their arguments
sed -i '1 a\set -x' hack/test-go.sh
sed -i '1 a\set -x' hack/test-sec.sh

# run hack/test-go.sh
./hack/test-go.sh

# install latest 'gosec' to /usr/local/bin
curl -sfL https://raw.githubusercontent.com/securego/gosec/master/install.sh | sh -s -- -b /usr/local/bin latest

# run hack/test-sec.sh
./hack/test-sec.sh
