apiVersion: apps/v1
kind: Deployment
metadata:
  name: ovn-deployment-${index}
spec:
  selector:
    matchLabels:
      run: ovn-service-${index}
  replicas: ${replica}
  template:
    metadata:
      labels:
        run: ovn-service-${index}
    spec:
      containers:
      - name: ovn-service-${index}
        image: nginx
        ports:
        - containerPort: 80
