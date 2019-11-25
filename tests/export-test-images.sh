#!/bin/bash

PTP_OPERATOR_RAW=$(oc get istag -n ocp 4.3-art-latest:ptp-operator \
	-o jsonpath='{.image.dockerImageMetadata.Config.Labels.url}')

PTP_RAW=$(oc get istag -n ocp 4.3-art-latest:ptp \
	-o jsonpath='{.image.dockerImageMetadata.Config.Labels.url}')

SRIOV_DEVICE_PLUGIN_RAW=$(oc get istag -n ocp 4.3-art-latest:sriov-network-device-plugin \
	-o jsonpath='{.image.dockerImageMetadata.Config.Labels.url}')

SRIOV_CNI_RAW=$(oc get istag -n ocp 4.3-art-latest:sriov-cni \
	-o jsonpath='{.image.dockerImageMetadata.Config.Labels.url}')

NETWORK_RESOURCES_INJECTOR_RAW=$(oc get istag -n ocp 4.3-art-latest:sriov-dp-admission-controller \
	-o jsonpath='{.image.dockerImageMetadata.Config.Labels.url}')

SRIOV_CONFIG_DAEMON_RAW=$(oc get istag -n ocp 4.3-art-latest:sriov-network-config-daemon \
	-o jsonpath='{.image.dockerImageMetadata.Config.Labels.url}')

SRIOV_WEBHOOK_RAW=$(oc get istag -n ocp 4.3-art-latest:sriov-network-webhook \
	-o jsonpath='{.image.dockerImageMetadata.Config.Labels.url}')

SRIOV_OPERATOR_RAW=$(oc get istag -n ocp 4.3-art-latest:sriov-network-operator \
	-o jsonpath='{.image.dockerImageMetadata.Config.Labels.url}')

echo $PTP_OPERATOR_RAW
echo $PTP_RAW

echo $SRIOV_DEVICE_PLUGIN_RAW
echo $SRIOV_CNI_RAW
echo $NETWORK_RESOURCES_INJECTOR_RAW
echo $SRIOV_CONFIG_DAEMON_RAW
echo $SRIOV_WEBHOOK_RAW
echo $SRIOV_OPERATOR_RAW

PTP_OPERATOR_IMAGE=$(echo $PTP_OPERATOR_RAW | awk -F'/' '{print "quay.io/openshift-release-dev/ocp-v4.0-art-dev:"$NF"-"$(NF-2)}')
PTP_IMAGE=$(echo $PTP_RAW | awk -F'/' '{print "quay.io/openshift-release-dev/ocp-v4.0-art-dev:"$NF"-"$(NF-2)}')

SRIOV_DEVICE_PLUGIN_IMAGE=$(echo $SRIOV_DEVICE_PLUGIN_RAW | awk -F'/' '{print "quay.io/openshift-release-dev/ocp-v4.0-art-dev:"$NF"-"$(NF-2)}')
SRIOV_CNI_IMAGE=$(echo $SRIOV_CNI_RAW | awk -F'/' '{print "quay.io/openshift-release-dev/ocp-v4.0-art-dev:"$NF"-"$(NF-2)}')
NETWORK_RESOURCES_INJECTOR_IMAGE=$(echo $NETWORK_RESOURCES_INJECTOR_RAW | awk -F'/' '{print "quay.io/openshift-release-dev/ocp-v4.0-art-dev:"$NF"-"$(NF-2)}')
SRIOV_CONFIG_DAEMON_IMAGE=$(echo $SRIOV_CONFIG_DAEMON_RAW | awk -F'/' '{print "quay.io/openshift-release-dev/ocp-v4.0-art-dev:"$NF"-"$(NF-2)}')
SRIOV_WEBHOOK_IMAGE=$(echo $SRIOV_WEBHOOK_RAW | awk -F'/' '{print "quay.io/openshift-release-dev/ocp-v4.0-art-dev:"$NF"-"$(NF-2)}')
SRIOV_OPERATOR_IMAGE=$(echo $SRIOV_OPERATOR_RAW | awk -F'/' '{print "quay.io/openshift-release-dev/ocp-v4.0-art-dev:"$NF"-"$(NF-2)}')

echo $PTP_OPERATOR_IMAGE
echo $PTP_IMAGE

echo $SRIOV_DEVICE_PLUGIN_IMAGE
echo $SRIOV_CNI_IMAGE
echo $NETWORK_RESOURCES_INJECTOR_IMAGE
echo $SRIOV_CONFIG_DAEMON_IMAGE
echo $SRIOV_WEBHOOK_IMAGE
echo $SRIOV_OPERATOR_IMAGE

#export SRIOV_NETWORK_OPERATOR_IMAGE=${SRIOV_OPERATOR_IMAGE}
#export SRIOV_NETWORK_WEBHOOK_IMAGE=${SRIOV_WEBHOOK_IMAGE}
#export SRIOV_NETWORK_CONFIG_DAEMON_IMAGE=${SRIOV_CONFIG_DAEMON_IMAGE}
#export NETWORK_RESOURCES_INJECTOR_IMAGE=${NETWORK_RESOURCES_INJECTOR_IMAGE}
#export SRIOV_DEVICE_PLUGIN_IMAGE=${SRIOV_DEVICE_PLUGIN_IMAGE}
#export SRIOV_CNI_IMAGE=${SRIOV_CNI_IMAGE}

echo "export SRIOV_NETWORK_OPERATOR_IMAGE=${SRIOV_OPERATOR_IMAGE}"
echo "export SRIOV_NETWORK_WEBHOOK_IMAGE=${SRIOV_WEBHOOK_IMAGE}"
echo "export SRIOV_NETWORK_CONFIG_DAEMON_IMAGE=${SRIOV_CONFIG_DAEMON_IMAGE}"
echo "export NETWORK_RESOURCES_INJECTOR_IMAGE=${NETWORK_RESOURCES_INJECTOR_IMAGE}"
echo "export SRIOV_DEVICE_PLUGIN_IMAGE=${SRIOV_DEVICE_PLUGIN_IMAGE}"
echo "export SRIOV_CNI_IMAGE=${SRIOV_CNI_IMAGE}"
