#!/bin/bash                

version=${1:-""}

SRIOV_DEVICE_PLUGIN_IMAGE_DIGEST=$(skopeo inspect docker://quay.io/openshift/origin-sriov-network-device-plugin:$version | jq --raw-output '.Digest')
SRIOV_CNI_IMAGE_DIGEST=$(skopeo inspect docker://quay.io/openshift/origin-sriov-cni:$version | jq --raw-output '.Digest')
NETWORK_RESOURCES_INJECTOR_IMAGE_DIGEST=$(skopeo inspect docker://quay.io/openshift/origin-sriov-dp-admission-controller:$version | jq --raw-output '.Digest')
SRIOV_CONFIG_DAEMON_IMAGE_DIGEST=$(skopeo inspect docker://quay.io/openshift/origin-sriov-network-config-daemon:$version | jq --raw-output '.Digest')
SRIOV_WEBHOOK_IMAGE_DIGEST=$(skopeo inspect docker://quay.io/openshift/origin-sriov-network-webhook:$version | jq --raw-output '.Digest')
SRIOV_OPERATOR_IMAGE_DIGEST=$(skopeo inspect docker://quay.io/openshift/origin-sriov-network-operator:$version | jq --raw-output '.Digest')

SRIOV_DEVICE_PLUGIN_IMAGE="quay.io/openshift/origin-sriov-network-device-plugin@${SRIOV_DEVICE_PLUGIN_IMAGE_DIGEST}"
SRIOV_CNI_IMAGE="quay.io/openshift/origin-sriov-cni@${SRIOV_CNI_IMAGE_DIGEST}"
NETWORK_RESOURCES_INJECTOR_IMAGE="quay.io/openshift/origin-sriov-dp-admission-controller@${NETWORK_RESOURCES_INJECTOR_IMAGE_DIGEST}"
SRIOV_CONFIG_DAEMON_IMAGE="quay.io/openshift/origin-sriov-network-config-daemon@${SRIOV_CONFIG_DAEMON_IMAGE_DIGEST}"
SRIOV_WEBHOOK_IMAGE="quay.io/openshift/origin-sriov-network-webhook@${SRIOV_WEBHOOK_IMAGE_DIGEST}"
SRIOV_OPERATOR_IMAGE="quay.io/openshift/origin-sriov-network-operator@${SRIOV_OPERATOR_IMAGE_DIGEST}"

echo "export SRIOV_NETWORK_OPERATOR_IMAGE=${SRIOV_OPERATOR_IMAGE}"
echo "export SRIOV_NETWORK_WEBHOOK_IMAGE=${SRIOV_WEBHOOK_IMAGE}"
echo "export SRIOV_NETWORK_CONFIG_DAEMON_IMAGE=${SRIOV_CONFIG_DAEMON_IMAGE}"
echo "export NETWORK_RESOURCES_INJECTOR_IMAGE=${NETWORK_RESOURCES_INJECTOR_IMAGE}"
echo "export SRIOV_DEVICE_PLUGIN_IMAGE=${SRIOV_DEVICE_PLUGIN_IMAGE}"
echo "export SRIOV_CNI_IMAGE=${SRIOV_CNI_IMAGE}"

export SRIOV_NETWORK_OPERATOR_IMAGE=${SRIOV_OPERATOR_IMAGE}
export SRIOV_NETWORK_WEBHOOK_IMAGE=${SRIOV_WEBHOOK_IMAGE}
export SRIOV_NETWORK_CONFIG_DAEMON_IMAGE=${SRIOV_CONFIG_DAEMON_IMAGE}
export NETWORK_RESOURCES_INJECTOR_IMAGE=${NETWORK_RESOURCES_INJECTOR_IMAGE}
export SRIOV_DEVICE_PLUGIN_IMAGE=${SRIOV_DEVICE_PLUGIN_IMAGE}
export SRIOV_CNI_IMAGE=${SRIOV_CNI_IMAGE}
