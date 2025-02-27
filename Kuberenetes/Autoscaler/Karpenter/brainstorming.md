

---

# **🚀 Brainstorming Session: Implementing a Hybrid Approach (ASG + Karpenter)**  

Since you already have an **EKS cluster with ASG (via Launch Template) but without Cluster Autoscaler**, and you **plan to use Karpenter for dynamic scaling**, we need to focus on a **hybrid strategy that ensures optimal performance, cost-efficiency, and stability**.  

---

## **📌 Goals of Our Hybrid Setup**  

1. ✅ **ASG for Baseline Capacity** → Ensures system pods like `coredns`, `kube-proxy`, and monitoring agents always have a node to run on.  
2. ✅ **Karpenter for Dynamic Scaling** → Automatically provisions additional worker nodes based on pod demands.  
3. ✅ **Avoid Scheduling Conflicts** → Ensure that workloads are properly assigned to either **ASG nodes** or **Karpenter nodes** without interference.  
4. ✅ **Enable Cost Optimization** → Use **Spot instances** with Karpenter when possible, while **keeping ASG for stability**.  

---

## **🧠 Key Considerations for ASG + Karpenter**  

### **1️⃣ What Should Run on ASG vs. Karpenter?**  
| **Component** | **Runs on ASG?** | **Runs on Karpenter?** | **Why?** |
|--------------|----------------|----------------|-------------|
| **CoreDNS, Kube-Proxy** | ✅ Yes | ❌ No | Critical system components need guaranteed availability. |
| **Monitoring Agents (e.g., Prometheus, FluentBit)** | ✅ Yes | ❌ No | Should always be running. |
| **Long-lived Applications (e.g., StatefulSets, DBs)** | ✅ Yes | ❌ No | These workloads should not move frequently. |
| **Stateless Workloads (e.g., Web Apps, Microservices)** | ❌ No | ✅ Yes | These can scale dynamically based on traffic. |
| **Batch Jobs, Event-Driven Workloads** | ❌ No | ✅ Yes | Ideal for Spot instances via Karpenter. |

💡 **Summary:** ASG is for critical, always-on workloads. Karpenter is for everything else.  

---

## **🚀 How Does Karpenter Scale? Based on Requests or Actual Usage?**  

| **Factor** | **Does Karpenter React?** |
|------------|-------------------------|
| **Pod Requests (CPU & Memory)** | ✅ Yes (Triggers new nodes if needed) |
| **Pod Actual Usage** | ❌ No (Karpenter doesn’t monitor real-time usage) |
| **Overprovisioned Nodes** | ❌ No (You must manually deploy a buffer pod) |
| **Empty Nodes** | ✅ Yes (Removes them if `ttlSecondsAfterEmpty` is set) |

### **TL;DR**  
🚀 **Karpenter scales nodes based on requested resources, not actual usage**.  
✅ **To optimize scaling, right-size your requests, use overprovisioning, and enable `ttlSecondsAfterEmpty`**.  

---

## **🛠️ Optimizing Karpenter Scaling Strategy**  

### **1️⃣ Right-Size Your Pod Requests**  
- If requests are too **low**, Karpenter may place **too many pods on a node**, leading to resource exhaustion.  
- If requests are too **high**, Karpenter may create **larger-than-needed nodes**, wasting money.  

💡 **Fix:** Use Kubernetes **Vertical Pod Autoscaler (VPA)** to adjust pod requests dynamically.  

---

### **2️⃣ Enable Overprovisioning for Fast Scale-Ups**  
Since Karpenter provisions nodes **only when needed**, there could be a slight delay when new pods request resources.  

💡 **Fix:** Deploy a small number of "always available" buffer nodes using a **low-priority overprovisioning pod**:  
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: overprovisioning
spec:
  replicas: 1
  template:
    spec:
      priorityClassName: system-cluster-critical
      containers:
      - name: overprovision
        image: public.ecr.aws/eks-distro/kubernetes/pause:3.7
        resources:
          requests:
            cpu: "100m"
            memory: "128Mi"
```
- This ensures that at least **one spare node** is **always available** for immediate scheduling.  

---

### **3️⃣ Set `ttlSecondsAfterEmpty` to Remove Idle Nodes**  
By default, Karpenter **does not remove nodes** unless configured.  

💡 **Fix:** Add this to your provisioner:  
```yaml
ttlSecondsAfterEmpty: 60
```
This ensures **nodes are terminated if they remain empty for 60 seconds**.  

---

### **4️⃣ Prevent Workloads from Running on ASG Nodes**  
Since ASG nodes should **only** run essential workloads, you must **taint ASG nodes** so that normal workloads aren’t scheduled on them.  

**Step 1: Apply a taint to ASG nodes**  
```sh
kubectl taint nodes <asg-node-name> dedicated=asg-only:NoSchedule
```
This ensures that **only specific workloads can run on ASG nodes**.  

**Step 2: Add tolerations to system workloads (e.g., CoreDNS)**  
Modify the CoreDNS deployment:  
```yaml
tolerations:
  - key: "dedicated"
    operator: "Equal"
    value: "asg-only"
    effect: "NoSchedule"
```
Now, **only CoreDNS and other critical pods will run on ASG nodes**.  

---

### **5️⃣ Configure Karpenter to Avoid ASG Nodes**  
Now, Karpenter should provision **only new nodes**, avoiding ASG nodes.  

Modify the Karpenter **Provisioner**:  
```yaml
apiVersion: karpenter.sh/v1alpha5
kind: Provisioner
metadata:
  name: karpenter
spec:
  requirements:
    - key: "karpenter.sh/capacity-type"
      operator: In
      values: ["spot", "on-demand"]
    - key: "kubernetes.io/arch"
      operator: In
      values: ["amd64", "arm64"]
    - key: "dedicated"
      operator: NotIn
      values: ["asg-only"]  # Ensures Karpenter nodes are separate from ASG nodes
  limits:
    resources:
      cpu: "100"
  provider:
    subnetSelector:
      karpenter.sh/discovery: $CLUSTER_NAME
    securityGroupSelector:
      karpenter.sh/discovery: $CLUSTER_NAME
  ttlSecondsAfterEmpty: 60  # Terminate unused nodes after 60s
```
Now, **Karpenter nodes will only be used for dynamic workloads**.  

---

## **🚀 TL;DR: Final Setup**
| **Component** | **Configuration** |
|--------------|------------------|
| **Auto Scaling Group (ASG)** | Min=1, Max=3, Runs **system workloads only** |
| **Karpenter** | **Handles all other workloads dynamically** |
| **Taints & Tolerations** | **ASG nodes tainted** so only system pods run on them |
| **Provisioner Config** | **Prevents scheduling on ASG nodes**, supports Spot/On-demand |

🚀 **Now you have a hybrid setup where ASG ensures stability, and Karpenter provides dynamic autoscaling!** 🚀  

---

## **🔍 Next Steps**
1. ✅ Implement **taints/tolerations** to separate ASG and Karpenter nodes.  
2. ✅ Test Karpenter by deploying a sample workload and scaling up.  
3. ✅ Monitor Karpenter logs to check provisioning behavior:  
   ```sh
   kubectl logs -n karpenter -l app.kubernetes.io/name=karpenter
   ```
4. ✅ Optimize Karpenter **instance types** and **Spot pricing** for cost efficiency.  

---
