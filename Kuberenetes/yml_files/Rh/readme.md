
---

# 🚀 **Care Management Application Deployment on Kubernetes**

This repository contains Kubernetes manifests for deploying the **Care Management Application** in the `qa` namespace. The deployment includes a **Deployment**, an **Ingress** resource for external access, and a **Service** for internal communication. Below is a comprehensive guide to understanding and using these components.

---

## 📋 **Table of Contents**
1. [Overview](#overview)
2. [Components](#components)
   - [Deployment](#deployment)
   - [Service](#service)
   - [Ingress](#ingress)
3. [How to Use](#how-to-use)
4. [Directory Structure](#directory-structure)
5. [Troubleshooting](#troubleshooting)

---

## 🌟 **Overview**

The **Care Management Application** is deployed as a scalable, stateless service using Kubernetes. The manifests define the following:

1. **Deployment**: Ensures two replicas of the application are running with resource constraints.
2. **Service**: Exposes the application internally within the cluster using a `ClusterIP`.
3. **Ingress**: Routes external traffic to the application via the `/caremanagement` path.

This setup ensures high availability, scalability, and secure access to the application.

---

## 🛠️ **Components**

### **1. Deployment**

#### **Purpose**
The **Deployment** manages the lifecycle of the Care Management Application. It ensures that two replicas of the application are always running and pulls the latest image from Amazon Elastic Container Registry (ECR).

#### **Key Features**
- **Replicas**: Maintains two instances of the application for high availability.
- **Resource Constraints**: Defines CPU and memory requests/limits to optimize resource usage.
- **Image Pull Policy**: Always pulls the latest image (`imagePullPolicy: Always`).

#### **Manifest**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: caremanagement
  namespace: qa
  labels:
    app: caremanagement-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: caremanagement-app
  template:
    metadata:
      labels:
        app: caremanagement-app
    spec:
      containers:
        - name: caremanagement-app
          image: 991433499337.dkr.ecr.us-east-1.amazonaws.com/caremanagement2.0:qa1.0.1
          ports:
            - containerPort: 80
              protocol: TCP
          imagePullPolicy: Always
          resources:
            requests:
              cpu: "100m"
              memory: "128Mi"
            limits:
              cpu: "200m"
              memory: "256Mi"
```

---

### **2. Service**

#### **Purpose**
The **Service** exposes the application internally within the cluster. It uses a `ClusterIP` to allow communication between other services or pods in the same namespace.

#### **Key Features**
- **Type**: `ClusterIP` ensures internal-only access.
- **Selector**: Matches Pods with the label `app: caremanagement-svc`.
- **Ports**: Maps port `80` on the Service to port `80` on the Pods.

#### **Manifest**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: caremanagement
  namespace: qa
  labels:
    run: caremanagement-svc
spec:
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
  selector:
    app: caremanagement-svc
  type: ClusterIP
```

---

### **3. Ingress**

#### **Purpose**
The **Ingress** routes external HTTP traffic to the Care Management Application. It uses NGINX as the ingress controller and maps the `/caremanagement` path to the Service.

#### **Key Features**
- **Annotations**: Configures NGINX-specific settings like regex support.
- **Path-Based Routing**: Routes traffic to the application based on the `/caremanagement` path.
- **Namespace**: Scoped to the `qa` namespace.

#### **Manifest**
```yaml
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: caremanagement-app
  namespace: qa
  annotations:
    kubernetes.io/ingress.class: nginx
    nginx.ingress.kubernetes.io/use-regex: 'true'
spec:
  rules:
    - http:
        paths:
          - path: /caremanagement             
            backend:
              serviceName: caremanagement
              servicePort: 80
```

---

## 🚀 **How to Use**

### 1. Apply the Manifests
Apply the manifests to your Kubernetes cluster using `kubectl`:
```bash
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl apply -f ingress.yaml
```

### 2. Verify the Deployment
Check the status of the Deployment, Service, and Ingress:
```bash
kubectl get deployments -n qa
kubectl get services -n qa
kubectl get ingress -n qa
```

### 3. Access the Application
- **Internal Access**: Use the Service's `ClusterIP` to access the application within the cluster.
- **External Access**: Navigate to `http://<ingress-host>/caremanagement` in your browser.

### 4. Scale the Application
Scale the Deployment to increase or decrease the number of replicas:
```bash
kubectl scale deployment caremanagement --replicas=3 -n qa
```

---

## 📂 **Directory Structure**

The repository should have the following structure:

```
.
├── deployment.yaml       # Deployment manifest for the Care Management Application.
├── service.yaml          # Service manifest for internal communication.
├── ingress.yaml          # Ingress manifest for external access.
└── README.md             # This file.
```

---

## ❓ **Troubleshooting**

### 1. **Pods Not Running**
- Check the Pod logs for errors:
  ```bash
  kubectl logs <pod-name> -n qa
  ```
- Verify that the image exists in ECR and is accessible:
  ```bash
  aws ecr describe-images --repository-name caremanagement2.0 --image-ids imageTag=qa1.0.1
  ```

### 2. **Ingress Not Working**
- Ensure the NGINX Ingress Controller is installed and running:
  ```bash
  kubectl get pods -n ingress-nginx
  ```
- Verify the Ingress resource is correctly configured:
  ```bash
  kubectl describe ingress caremanagement-app -n qa
  ```

### 3. **Resource Limits**
- If Pods are being evicted due to resource constraints, adjust the `requests` and `limits` in the Deployment manifest.

---

## 🤝 **Contributing**

If you encounter issues or have suggestions for improvement, feel free to open an issue or submit a pull request. Contributions are always welcome!

---

## 📜 **License**

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

## 📞 **Contact**

For questions or support, contact the DevOps team:
- Email: devops@example.com
- Slack: #devops-channel

---
