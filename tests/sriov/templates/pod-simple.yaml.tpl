apiVersion: v1
kind: Pod
metadata:
  name: testpod-simple
  annotations:
    k8s.v1.cni.cncf.io/networks: '${nad}'
spec:
  containers:
  - name: appcntr1
    image: zenghui/centos-dpdk
    imagePullPolicy: IfNotPresent
    command: [ "/bin/bash", "-c", "--" ]
    args: [ "while true; do sleep 300000; done;" ]
