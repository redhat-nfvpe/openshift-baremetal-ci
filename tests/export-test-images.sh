#!/bin/bash

# IMAGE_SOURCE could be "origin" or "art"
IMAGE_SOURCE=${1:-"origin"}

for v in 4.3 4.4 4.5
do
	if [[ $IMAGE_SOURCE == "art" ]]; then
		PTP_OPERATOR_RAW=$(oc get istag -n ocp $v-art-latest:ptp-operator \
			-o jsonpath='{.image.dockerImageMetadata.Config.Labels.url}')

		PTP_RAW=$(oc get istag -n ocp $v-art-latest:ptp \
			-o jsonpath='{.image.dockerImageMetadata.Config.Labels.url}')

		SRIOV_DEVICE_PLUGIN_RAW=$(oc get istag -n ocp $v-art-latest:sriov-network-device-plugin \
			-o jsonpath='{.image.dockerImageMetadata.Config.Labels.url}')

		SRIOV_CNI_RAW=$(oc get istag -n ocp $v-art-latest:sriov-cni \
			-o jsonpath='{.image.dockerImageMetadata.Config.Labels.url}')

		NETWORK_RESOURCES_INJECTOR_RAW=$(oc get istag -n ocp $v-art-latest:sriov-dp-admission-controller \
			-o jsonpath='{.image.dockerImageMetadata.Config.Labels.url}')

		SRIOV_CONFIG_DAEMON_RAW=$(oc get istag -n ocp $v-art-latest:sriov-network-config-daemon \
			-o jsonpath='{.image.dockerImageMetadata.Config.Labels.url}')

		SRIOV_WEBHOOK_RAW=$(oc get istag -n ocp $v-art-latest:sriov-network-webhook \
			-o jsonpath='{.image.dockerImageMetadata.Config.Labels.url}')

		SRIOV_OPERATOR_RAW=$(oc get istag -n ocp $v-art-latest:sriov-network-operator \
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

	elif [[ $IMAGE_SOURCE == "origin" ]]; then
		PTP_OPERATOR_IMAGE_DIGEST=$(skopeo inspect docker://quay.io/openshift/origin-ptp-operator:$v | jq --raw-output '.Digest')
		PTP_IMAGE_DIGEST=$(skopeo inspect docker://quay.io/openshift/origin-ptp:$v | jq --raw-output '.Digest')
		SRIOV_DEVICE_PLUGIN_IMAGE_DIGEST=$(skopeo inspect docker://quay.io/openshift/origin-sriov-network-device-plugin:$v | jq --raw-output '.Digest')
		SRIOV_CNI_IMAGE_DIGEST=$(skopeo inspect docker://quay.io/openshift/origin-sriov-cni:$v | jq --raw-output '.Digest')
		NETWORK_RESOURCES_INJECTOR_IMAGE_DIGEST=$(skopeo inspect docker://quay.io/openshift/origin-sriov-dp-admission-controller:$v | jq --raw-output '.Digest')
		SRIOV_CONFIG_DAEMON_IMAGE_DIGEST=$(skopeo inspect docker://quay.io/openshift/origin-sriov-network-config-daemon:$v | jq --raw-output '.Digest')
		SRIOV_WEBHOOK_IMAGE_DIGEST=$(skopeo inspect docker://quay.io/openshift/origin-sriov-network-webhook:$v | jq --raw-output '.Digest')
		SRIOV_OPERATOR_IMAGE_DIGEST=$(skopeo inspect docker://quay.io/openshift/origin-sriov-network-operator:$v | jq --raw-output '.Digest')

		PTP_OPERATOR_IMAGE="quay.io/openshift/origin-ptp-operator@${PTP_OPERATOR_IMAGE_DIGEST}"
		PTP_IMAGE="quay.io/openshift/origin-ptp@${PTP_IMAGE_DIGEST}"
		SRIOV_DEVICE_PLUGIN_IMAGE="quay.io/openshift/origin-sriov-network-device-plugin@${SRIOV_DEVICE_PLUGIN_IMAGE_DIGEST}"
		SRIOV_CNI_IMAGE="quay.io/openshift/origin-sriov-cni@${SRIOV_CNI_IMAGE_DIGEST}"
		NETWORK_RESOURCES_INJECTOR_IMAGE="quay.io/openshift/origin-sriov-dp-admission-controller@${NETWORK_RESOURCES_INJECTOR_IMAGE_DIGEST}"
		SRIOV_CONFIG_DAEMON_IMAGE="quay.io/openshift/origin-sriov-network-config-daemon@${SRIOV_CONFIG_DAEMON_IMAGE_DIGEST}"
		SRIOV_WEBHOOK_IMAGE="quay.io/openshift/origin-sriov-network-webhook@${SRIOV_WEBHOOK_IMAGE_DIGEST}"
		SRIOV_OPERATOR_IMAGE="quay.io/openshift/origin-sriov-network-operator@${SRIOV_OPERATOR_IMAGE_DIGEST}"
	else
		echo "Incorrect image source $IMAGE_SOURCE"
		echo "Image source could either be 'origin' or 'art'"
		exit 1
	fi

	echo "export PTP_OPERATOR_IMAGE=${PTP_OPERATOR_IMAGE}"
	echo "export LINUXPTP_DAEMON_IMAGE=${PTP_IMAGE}"
	echo "export SRIOV_NETWORK_OPERATOR_IMAGE=${SRIOV_OPERATOR_IMAGE}"
	echo "export SRIOV_NETWORK_WEBHOOK_IMAGE=${SRIOV_WEBHOOK_IMAGE}"
	echo "export SRIOV_NETWORK_CONFIG_DAEMON_IMAGE=${SRIOV_CONFIG_DAEMON_IMAGE}"
	echo "export NETWORK_RESOURCES_INJECTOR_IMAGE=${NETWORK_RESOURCES_INJECTOR_IMAGE}"
	echo "export SRIOV_DEVICE_PLUGIN_IMAGE=${SRIOV_DEVICE_PLUGIN_IMAGE}"
	echo "export SRIOV_CNI_IMAGE=${SRIOV_CNI_IMAGE}"

	echo "#!/bin/bash" > $v-image-references.sh

	echo "export PTP_OPERATOR_IMAGE=${PTP_OPERATOR_IMAGE}" >> $v-image-references.sh
	echo "export LINUXPTP_DAEMON_IMAGE=${PTP_IMAGE}" >> $v-image-references.sh
	echo "export SRIOV_NETWORK_OPERATOR_IMAGE=${SRIOV_OPERATOR_IMAGE}" >> $v-image-references.sh
	echo "export SRIOV_NETWORK_WEBHOOK_IMAGE=${SRIOV_WEBHOOK_IMAGE}" >> $v-image-references.sh
	echo "export SRIOV_NETWORK_CONFIG_DAEMON_IMAGE=${SRIOV_CONFIG_DAEMON_IMAGE}" >> $v-image-references.sh
	echo "export NETWORK_RESOURCES_INJECTOR_IMAGE=${NETWORK_RESOURCES_INJECTOR_IMAGE}" >> $v-image-references.sh
	echo "export SRIOV_DEVICE_PLUGIN_IMAGE=${SRIOV_DEVICE_PLUGIN_IMAGE}" >> $v-image-references.sh
	echo "export SRIOV_CNI_IMAGE=${SRIOV_CNI_IMAGE}" >> $v-image-references.sh

	chmod a+x $v-image-references.sh
done
