
---

# 🚀 **K3s Cluster Setup Script** 🌟

This script automates the installation and configuration of a lightweight Kubernetes cluster using [K3s](https://k3s.io/). It also sets up users, configures permissions, and prepares the environment for seamless interaction with the cluster.

Whether you're managing a development environment or deploying a production-ready cluster, this script simplifies the process and ensures consistency across installations.

---

## 📜 **Table of Contents**

1. [🚀 Overview](#-overview)
2. [🔧 Prerequisites](#-prerequisites)
3. [⚙️ Script Functionality](#️-script-functionality)
4. [⚡ Usage Instructions](#-usage-instructions)
5. [🛠️ Configuration Details](#️-configuration-details)
6. [📚 Logs and Backups](#-logs-and-backups)
7. [⚠️ Troubleshooting](#️-troubleshooting)
8. [🌟 Understanding K3s and Rancher](#-understanding-k3s-and-rancher)
9. [🚀 Optional: Integrating Rancher with K3s](#-optional-integrating-rancher-with-k3s)

---

## 🚀 **Overview**

This script performs the following tasks:
1. **System Update**: Ensures the system is up-to-date.
2. **Dependency Installation**: Installs necessary tools like `curl`, `jq`, and optionally Docker.
3. **K3s Installation**: Deploys K3s (lightweight Kubernetes) with proper kubeconfig permissions.
4. **User Management**: Creates default users (e.g., `raj`) and adds them to the `k3s` group for cluster access.
5. **Kubeconfig Setup**: Copies the kubeconfig file to user home directories and fixes permissions.
6. **Namespace Creation**: Creates a `dev` namespace for development workloads.
7. **Docker Installation (Optional)**: Installs Docker if requested.

The script is designed to be modular, secure, and easy to use.

---

## 🔧 **Prerequisites**

Before running the script, ensure the following:
- **Linux Distribution**: CentOS, RHEL, or Ubuntu (or any distro that supports `yum`).
- **Root Access**: You need `sudo` privileges to execute the script.
- **Network Connectivity**: The machine must have internet access to download dependencies and install K3s.
- **Disk Space**: Ensure sufficient disk space for K3s and Docker (if installed).

Install required packages if necessary:
```bash
sudo yum install -y curl jq
```

---

## ⚙️ **Script Functionality**

### 1. **System Update**
Updates the system packages to ensure compatibility and security.

### 2. **Dependency Installation**
Installs essential tools like `curl` and `jq`. Optionally replaces `curl-minimal` with `curl` if needed.

### 3. **K3s Installation**
Deploys K3s with the `--write-kubeconfig-mode 640` flag to ensure proper permissions for the kubeconfig file (`/etc/rancher/k3s/k3s.yaml`).

### 4. **User Management**
Creates default users (e.g., `raj`) and adds them to the `k3s` group. Optionally assigns passwords or disables password-based login.

### 5. **Kubeconfig Setup**
Copies the kubeconfig file to each user's home directory (e.g., `/home/raj/.kube/config`) and sets appropriate ownership and permissions.

### 6. **Namespace Creation**
Creates a `dev` namespace for development workloads.

### 7. **Docker Installation (Optional)**
Installs Docker if the user specifies the `-y` flag during execution.

---

## ⚡ **Usage Instructions**

1. Save the script to a file, e.g., `k3s_setup.sh`.
2. Make it executable:
   ```bash
   chmod +x k3s_setup.sh
   ```
3. Run the script:
   ```bash
   sudo ./k3s_setup.sh [install_docker]
   ```
   - Replace `[install_docker]` with `y` to install Docker or leave it blank to skip Docker installation.

4. After execution:
   - Switch to the `raj` user:
     ```bash
     sudo su - raj
     ```
   - Test `kubectl`:
     ```bash
     kubectl get nodes
     ```

---

## 🛠️ **Configuration Details**

### **Key Files Modified**
- `/etc/rancher/k3s/k3s.yaml`: Updated with proper permissions (`640`) and ownership (`root:k3s`).
- `/home/<user>/.kube/config`: Copied from the main kubeconfig file for each user.
- `/etc/systemd/system/k3s.service`: K3s service configuration.

### **Services Installed**
- `k3s`: Lightweight Kubernetes.
- `docker` (optional): Container runtime.

### **Users Created**
- Default user: `raj` (can be customized in the script).

---

## 📚 **Logs and Backups**

### **Logs**
- All actions are logged to `/var/log/install.log`.
- Console output provides real-time progress updates.

### **Backups**
- No critical files are overwritten without backups. Existing configurations are preserved where applicable.

---

## ⚠️ **Troubleshooting**

### **Common Issues**
1. **Permission Denied for Kubeconfig**
   - Ensure the kubeconfig file (`/etc/rancher/k3s/k3s.yaml`) has `640` permissions and is owned by `root:k3s`.
   - Run the following commands as root:
     ```bash
     chmod 640 /etc/rancher/k3s/k3s.yaml
     chown root:k3s /etc/rancher/k3s/k3s.yaml
     ```

2. **K3s Installation Fails**
   - Verify network connectivity and DNS resolution.
   - Check logs for errors:
     ```bash
     journalctl -u k3s
     ```

3. **User Cannot Access Kubectl**
   - Ensure the user is added to the `k3s` group:
     ```bash
     sudo usermod -aG k3s <username>
     ```
   - Log out and log back in for group changes to take effect.

4. **Docker Installation Fails**
   - Ensure `yum` repositories are enabled and up-to-date:
     ```bash
     sudo yum update -y
     ```

### **Debugging Commands**
- Check K3s status:
  ```bash
  systemctl status k3s
  ```
- Verify kubeconfig permissions:
  ```bash
  ls -l /etc/rancher/k3s/k3s.yaml
  ```
- Test `kubectl` access:
  ```bash
  kubectl get nodes
  ```

---

## 🌟 **Understanding K3s and Rancher**

### **What is K3s?**
[K3s](https://k3s.io/) is a lightweight, certified Kubernetes distribution designed for resource-constrained environments. It is ideal for edge computing, IoT devices, and small-scale deployments. Key features include:
- Minimal resource usage (e.g., 512MB RAM).
- Single binary installation for simplicity.
- Built-in components like `kubectl`, `containerd`, and `traefik`.

### **What is Rancher?**
[Rancher](https://rancher.com/) is a Kubernetes management platform that simplifies the deployment, operation, and scaling of Kubernetes clusters. It provides:
- A centralized dashboard for managing multiple clusters.
- Monitoring, logging, and alerting tools.
- Role-based access control (RBAC) for teams.
- Support for deploying applications via Helm charts.

### **How Do K3s and Rancher Work Together?**
While **K3s** is a standalone Kubernetes runtime, **Rancher** acts as an optional management layer. Rancher is not required to use K3s, but it can enhance your experience by providing:
- Centralized cluster management.
- A user-friendly UI for deploying and monitoring workloads.
- Advanced features like multi-cluster support and centralized monitoring.

The kubeconfig file generated by K3s (`/etc/rancher/k3s/k3s.yaml`) can be used by Rancher to connect to and manage your K3s cluster if you choose to integrate Rancher later.

### **Do You Need Rancher for This Script?**
No, **Rancher is not required** to use this script or manage your K3s cluster. The script focuses solely on setting up K3s and configuring user access. You can manage your cluster directly using `kubectl` and other Kubernetes-native tools.

However, if you plan to:
- Manage multiple clusters,
- Provide a graphical interface for easier management,
- Enable advanced monitoring and RBAC,

you can integrate Rancher into your workflow after running this script.

---

## 🚀 **Optional: Integrating Rancher with K3s**

If you decide to use Rancher to manage your K3s cluster, follow these steps:

1. **Install Rancher**:
   Deploy Rancher on a separate server or VM using Docker:
   ```bash
   docker run -d --restart=unless-stopped -p 80:80 -p 443:443 --privileged rancher/rancher
   ```

2. **Access the Rancher UI**:
   Open a browser and navigate to the Rancher server's IP address. Complete the initial setup and create an admin account.

3. **Import Your K3s Cluster**:
   - In the Rancher UI, go to **Clusters > Import Existing Cluster**.
   - Copy the provided registration command and run it on your K3s node:
     ```bash
     curl --insecure -sfL https://<RANCHER_SERVER>/v3/import/<TOKEN>.yaml | kubectl apply -f -
     ```
   - This will connect your K3s cluster to Rancher.

4. **Manage via Rancher**:
   Once imported, you can use Rancher’s UI to deploy workloads, monitor resources, and manage your cluster.

---

## 🎉 **Final Thoughts**

This script is designed to simplify the setup of a K3s cluster while ensuring security and usability. Whether you're a developer or an administrator, it provides a solid foundation for working with Kubernetes.

Feel free to customize the script to suit your specific needs, such as adding more users, namespaces, or additional tools.

Happy clustering! 🚀

---

## 📄 **License**

This script is provided under the **MIT License**. Feel free to modify, distribute, and use it as you see fit. Just don’t forget to give credit where it’s due! 😉

---

