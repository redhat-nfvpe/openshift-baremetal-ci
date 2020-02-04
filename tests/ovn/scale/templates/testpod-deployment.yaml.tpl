apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend-deployment-${index}
spec:
  selector:
    matchLabels:
      run: test-service-${index}
  replicas: ${replica}
  template:
    metadata:
      labels:
        run: test-service-${index}
    spec:
      containers:
      - name: test-service-${index}
        image: nginx
        ports:
        - containerPort: 80
