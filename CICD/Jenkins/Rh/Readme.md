
---

# 🚀 **Jenkins Pipeline for Deploying Applications to Kubernetes**

This repository contains a **declarative Jenkins pipeline** designed to automate the deployment of applications to a Kubernetes cluster. The pipeline supports building Docker images, uploading them to Amazon Elastic Container Registry (ECR), and deploying them to a Kubernetes environment using Helm or Kubernetes manifests.

---

## 📋 **Table of Contents**
1. [Overview](#overview)
2. [Pipeline Parameters](#pipeline-parameters)
3. [Pipeline Stages](#pipeline-stages)
4. [Prerequisites](#prerequisites)
5. [How to Use](#how-to-use)
6. [Directory Structure](#directory-structure)
7. [Troubleshooting](#troubleshooting)

---

## 🌟 **Overview**

The Jenkins pipeline automates the following tasks:
- Building Docker images for your application.
- Uploading the Docker image to Amazon ECR.
- Downloading necessary secrets and configuration files from AWS S3.
- Connecting to a VPN for secure access to the Kubernetes cluster.
- Deploying the application to a Kubernetes environment using Helm or Kubernetes manifests.

The pipeline is highly configurable and supports conditional execution of stages based on branch names, parameters, and other conditions.

---

## 🔧 **Pipeline Parameters**

The pipeline accepts the following parameters:

| Parameter Name         | Type          | Default Value | Description                                                                 |
|------------------------|---------------|---------------|-----------------------------------------------------------------------------|
| `Microservice_ECR_repo`| String        | `pccportal`   | The name of the ECR repository where the Docker image will be stored.       |
| `Environ`              | String        | `prod`        | The target environment (e.g., `prod`, `dev`).                               |
| `Deploy`               | Boolean       | `false`       | Whether to execute the "Deploy" stage.                                      |

---

## 🛠️ **Pipeline Stages**

The pipeline consists of the following stages:

### 1. **prod?**
   - Determines whether the pipeline is running in the `prod` environment.
   - Sets environment-specific variables like `GitTagPrefix` and `GitAndImageTag`.

### 2. **Build Image**
   - Builds the Docker image using the `Dockerfile` in the repository.
   - Tags the image with a version derived from the Git tag and build number.

### 3. **Get Secret Files, Enter VPN**
   - Downloads secret files and configuration files from AWS S3.
   - Connects to a VPN to securely access the Kubernetes cluster.

### 4. **Upload Image to ECR**
   - Authenticates to Amazon ECR.
   - Pushes the Docker image to the specified ECR repository.

### 5. **Deploy**
   - Clones the deployment repository (e.g., Helm charts or Kubernetes manifests).
   - Deploys the application to the Kubernetes cluster using `kubectl`.

---

## ⚙️ **Prerequisites**

Before running the pipeline, ensure the following prerequisites are met:

1. **Jenkins Setup**:
   - Jenkins must be installed and configured with the necessary plugins (e.g., Docker, AWS, Kubernetes).

2. **AWS Credentials**:
   - AWS credentials must be configured in Jenkins for accessing ECR and S3.

3. **Kubernetes Cluster**:
   - A Kubernetes cluster must be available and accessible via `kubectl`.

4. **VPN Configuration**:
   - The VPN configuration files (e.g., `.ovpn`) must be available in the specified S3 bucket.

5. **Repository Access**:
   - Jenkins must have access to the deployment repository (e.g., Bitbucket or GitHub).

---

## 🚀 **How to Use**

### 1. Trigger the Pipeline
- Navigate to the Jenkins dashboard.
- Select the pipeline job and click **Build with Parameters**.
- Provide values for the parameters (`Microservice_ECR_repo`, `Environ`, `Deploy`).

### 2. Monitor the Build
- View the console output to monitor the progress of each stage.
- If any stage fails, review the logs for troubleshooting.

### 3. Verify Deployment
- After the pipeline completes, verify that the application is running in the Kubernetes cluster:
  ```bash
  kubectl get pods -n <namespace>
  ```

---

## 📂 **Directory Structure**

The repository should have the following structure:

```
.
├── Jenkinsfile          # The declarative Jenkins pipeline script.
├── Dockerfile           # The Dockerfile for building the application image.
├── deploy/              # Directory containing Kubernetes manifests or Helm charts.
│   ├── deployment.yaml
│   ├── service.yaml
│   └── ingress.yaml
└── README.md            # This file.
```

---

## ❓ **Troubleshooting**

### 1. **Pipeline Fails at "Upload Image to ECR"**
- Ensure AWS credentials are correctly configured in Jenkins.
- Verify that the ECR repository exists and has the correct permissions.

### 2. **Deployment Fails**
- Check the Kubernetes context and namespace:
  ```bash
  kubectl config current-context
  kubectl config view
  ```
- Verify that the secrets (e.g., `.dockerconfigjson`) are correctly configured in the cluster.

### 3. **VPN Connection Issues**
- Ensure the `.ovpn` file and credentials are correctly downloaded from S3.
- Test the VPN connection manually before running the pipeline.

---

## 🤝 **Contributing**

If you encounter issues or have suggestions for improvement, feel free to open an issue or submit a pull request. Contributions are always welcome!

---

## 📜 **License**

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

## 📞 **Contact**


---
