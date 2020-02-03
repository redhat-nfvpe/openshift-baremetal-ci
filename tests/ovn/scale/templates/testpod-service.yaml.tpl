apiVersion: v1
kind: Service
metadata:
  name: ovn-service-${index}
  labels:
    run: ovn-service-${index}
spec:
  ports:
  - port: 80
    protocol: TCP
  selector:
    run: ovn-service-${index}
