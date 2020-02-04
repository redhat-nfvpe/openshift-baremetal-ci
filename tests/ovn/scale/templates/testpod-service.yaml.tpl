apiVersion: v1
kind: Service
metadata:
  name: test-service-${index}
  labels:
    run: test-service-${index}
spec:
  ports:
  - port: 80
    protocol: TCP
  selector:
    run: test-service-${index}
