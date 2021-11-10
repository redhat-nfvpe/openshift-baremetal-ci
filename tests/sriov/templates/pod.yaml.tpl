apiVersion: v1
kind: Pod
metadata:
  name: testpod${pod_index}
  annotations:
    k8s.v1.cni.cncf.io/networks: '${nad}'
spec:
  nodeSelector:
    kubernetes.io/hostname: ${node}
  containers:
  - name: appcntr1
    image: quay.io/pliurh/centos-dpdk
    imagePullPolicy: IfNotPresent
    command: [ "/bin/bash", "-c", "--" ]
    args: [ "while true; do sleep 300000; done;" ]
    securityContext:
      privileged: true
      capabilities:
        add: ["NET_RAW"]
