#!/bin/bash                

version=${1:-""}
PTP_OPERATOR_IMAGE_DIGEST=$(skopeo inspect docker://quay.io/openshift/origin-ptp-operator:$version | jq --raw-output '.Digest')
PTP_IMAGE_DIGEST=$(skopeo inspect docker://quay.io/openshift/origin-ptp:$version | jq --raw-output '.Digest')

PTP_OPERATOR_IMAGE="quay.io/openshift/origin-ptp-operator@${PTP_OPERATOR_IMAGE_DIGEST}"
PTP_IMAGE="quay.io/openshift/origin-ptp@${PTP_IMAGE_DIGEST}"

echo "export PTP_OPERATOR_IMAGE=${PTP_OPERATOR_IMAGE}"
echo "export LINUXPTP_DAEMON_IMAGE=${PTP_IMAGE}"

export PTP_OPERATOR_IMAGE=${PTP_OPERATOR_IMAGE}
export LINUXPTP_DAEMON_IMAGE=${PTP_IMAGE}
