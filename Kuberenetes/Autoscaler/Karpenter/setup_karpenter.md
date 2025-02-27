
---

## **🚀 Steps to Deploy Karpenter with an EKS Cluster**
This guide will cover **everything needed** to deploy **Karpenter with a new EKS cluster**, ensuring it's fully operational.

---

### **1️⃣ Deploy an EKS Cluster**
- Create an **EKS cluster without a Managed Node Group**.
- Enable **OIDC** to allow Karpenter to assume IAM roles.
- Ensure **VPC and Subnets** are correctly set up.

✔ **Required Outputs:**
  - `EKS Cluster Name`
  - `OIDC Provider URL`
  - `VPC & Subnet IDs`

#### **🔹 Create an EKS Cluster with `eksctl`**
```sh
eksctl create cluster \
  --name my-eks-cluster \
  --region us-west-2 \
  --version 1.27 \
  --without-nodegroup \
  --vpc-nat-mode Disable
```

#### **🔹 Enable OIDC**
```sh
eksctl utils associate-iam-oidc-provider \
  --cluster my-eks-cluster \
  --approve
```

---

### **2️⃣ Set Up IAM Roles for Karpenter**
- Karpenter needs IAM permissions to **provision EC2 instances** and manage scaling.

✔ **Required Outputs:**
  - `IAM Role ARN for Karpenter`

#### **🔹 Create IAM Role for Karpenter**
1️⃣ First, **fetch your OIDC provider URL**:
```sh
aws eks describe-cluster --name my-eks-cluster --query "cluster.identity.oidc.issuer" --output text
```
2️⃣ Create an **IAM trust policy** (`karpenter-trust-policy.json`):
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::<AWS_ACCOUNT_ID>:oidc-provider/<OIDC_PROVIDER_URL>"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "<OIDC_PROVIDER_URL>:sub": "system:serviceaccount:karpenter:karpenter"
        }
      }
    }
  ]
}
```
3️⃣ Create the **IAM role**:
```sh
aws iam create-role --role-name KarpenterControllerRole --assume-role-policy-document file://karpenter-trust-policy.json
```
4️⃣ Attach the required AWS-managed policies:
```sh
aws iam attach-role-policy --role-name KarpenterControllerRole --policy-arn arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy
aws iam attach-role-policy --role-name KarpenterControllerRole --policy-arn arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore
aws iam attach-role-policy --role-name KarpenterControllerRole --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly
```

---

### **3️⃣ Install Karpenter on EKS**
- Deploy Karpenter using **Helm**.
- Create a **ServiceAccount** linked to the IAM role.

✔ **Required Outputs:**
  - `Karpenter Namespace`
  - `ServiceAccount`

#### **🔹 Create a Namespace & Service Account**
```sh
kubectl create namespace karpenter
kubectl create serviceaccount karpenter -n karpenter
kubectl annotate serviceaccount karpenter -n karpenter eks.amazonaws.com/role-arn=arn:aws:iam::<AWS_ACCOUNT_ID>:role/KarpenterControllerRole
```

#### **🔹 Install Karpenter using Helm**
```sh
helm repo add karpenter https://charts.karpenter.sh
helm repo update

helm install karpenter karpenter/karpenter \
  --namespace karpenter \
  --create-namespace \
  --set serviceAccount.create=false \
  --set clusterName=my-eks-cluster \
  --set clusterEndpoint=$(aws eks describe-cluster --name my-eks-cluster --query "cluster.endpoint" --output text) \
  --set aws.defaultInstanceProfile=KarpenterNodeInstanceProfile-my-eks-cluster \
  --version v0.31.0
```

---

### **4️⃣ Create a Karpenter Provisioner**
- This defines how **Karpenter provisions nodes**.
- Supports **instance types, Spot instances, and scaling settings**.

✔ **Required Outputs:**
  - `Provisioner applied successfully`

#### **🔹 Create a `provisioner.yaml` file**
```yaml
apiVersion: karpenter.sh/v1alpha5
kind: Provisioner
metadata:
  name: default
spec:
  requirements:
    - key: karpenter.sh/capacity-type
      operator: In
      values: ["spot", "on-demand"]
    - key: kubernetes.io/arch
      operator: In
      values: ["amd64", "arm64"]
  limits:
    resources:
      cpu: 1000
  ttlSecondsAfterEmpty: 30
  provider:
    subnetSelector:
      karpenter.sh/discovery: my-eks-cluster
    securityGroupSelector:
      karpenter.sh/discovery: my-eks-cluster
```

#### **🔹 Apply the provisioner**
```sh
kubectl apply -f provisioner.yaml
```

---

### **5️⃣ Verify Karpenter is Working**
- Deploy a test workload and **ensure Karpenter provisions a node**.
- Check if **new nodes scale up and down dynamically**.

✔ **Required Outputs:**
  - `New node created by Karpenter`
  - `Autoscaling works as expected`

#### **🔹 Deploy a test workload**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: inflate
spec:
  replicas: 0
  selector:
    matchLabels:
      app: inflate
  template:
    metadata:
      labels:
        app: inflate
    spec:
      containers:
      - name: inflate
        image: public.ecr.aws/eks-distro/kubernetes/pause:3.7
        resources:
          requests:
            cpu: "1"
            memory: 2Gi
```
Apply it:
```sh
kubectl apply -f inflate.yaml
kubectl scale deployment inflate --replicas=5
```
Check if Karpenter provisions new nodes:
```sh
kubectl get nodes -w
```

---

## **📌 Summary: What Needs to Be Done?**
✅ **Step 1:** Deploy **EKS Cluster**  
✅ **Step 2:** Set up **IAM Roles & Policies**  
✅ **Step 3:** Install **Karpenter using Helm**  
✅ **Step 4:** Configure **Provisioner** for auto-scaling  
✅ **Step 5:** **Test and Verify** Karpenter is working  

---

## **🔥 Additional Considerations**
### **1️⃣ Do You Need a Managed Node Group?**
- **No, Karpenter can handle all node provisioning dynamically**.
- However, EKS requires some capacity for **CoreDNS** and system components.
- **Options**:
  - **Option 1:** Use **a small Managed Node Group** (1-2 instances).
  - **Option 2:** Use **Fargate** for system components.
  - **Option 3:** Let **Karpenter bootstrap itself** (advanced).

### **2️⃣ Using Spot Instances?**
- Karpenter **fully supports Spot Instances**.
- Modify the provisioner YAML to **prioritize Spot Instances**.

---
