When an autoscaler has reached its **maximum node limit** (e.g., 5 nodes in your case) and all nodes are fully utilized, Kubernetes will not be able to schedule additional pods. This situation is known as a **pending pod scenario**, where new pods remain in the `Pending` state because there are no available resources to schedule them.

Here’s how you can handle this situation effectively:

---

### **1. Analyze the Root Cause**
Before taking any action, it's important to understand why the cluster has reached its maximum capacity:
- **Check Pending Pods**: Identify which pods are pending and why.
  ```bash
  kubectl get pods --field-selector=status.phase=Pending
  kubectl describe pod <pod-name>
  ```
  Look for events like `Insufficient CPU`, `Insufficient Memory`, or other resource constraints.

- **Cluster Resource Usage**: Check the overall resource usage of the cluster.
  ```bash
  kubectl top nodes
  kubectl top pods
  ```

- **Autoscaler Logs**: Review the logs of the cluster autoscaler to see if it attempted to scale up but was constrained by the maximum limit.
  ```bash
  kubectl logs -n kube-system deployment/cluster-autoscaler
  ```

---

### **2. Immediate Solutions**

#### **Option 1: Increase the Maximum Node Limit**
If your workload requires more resources and the current maximum limit is too restrictive, you can increase the maximum number of nodes allowed by the autoscaler.

For example, if you're using a managed Kubernetes service like AWS EKS, GKE, or AKS, update the autoscaler configuration to allow more nodes:
- **AWS EKS**: Update the Auto Scaling Group (ASG) maximum size.
- **GKE**: Modify the node pool's maximum size.
- **AKS**: Update the node pool's maximum count.

Example for AWS EKS:
```bash
aws autoscaling update-auto-scaling-group \
    --auto-scaling-group-name <asg-name> \
    --max-size 10
```

#### **Option 2: Manually Add Nodes**
If increasing the autoscaler limit is not immediately feasible, you can manually add nodes to the cluster:
- Add a new node manually to the cluster and ensure it joins the Kubernetes control plane.
- Once the new node is available, the scheduler will assign pending pods to it.

#### **Option 3: Scale Down Non-Critical Workloads**
If adding nodes is not an option, consider freeing up resources by scaling down non-critical workloads:
- Reduce the number of replicas for deployments that are not critical.
  ```bash
  kubectl scale deployment <deployment-name> --replicas=<lower-number>
  ```
- Delete unused or low-priority pods to free up resources.

---

### **3. Long-Term Solutions**

#### **Option 1: Optimize Resource Requests and Limits**
Ensure that your pods' resource requests (`requests`) and limits (`limits`) are appropriately configured. Over-requesting resources can lead to inefficient utilization of nodes.

Example Pod Spec:
```yaml
resources:
  requests:
    cpu: "500m"
    memory: "512Mi"
  limits:
    cpu: "1"
    memory: "1Gi"
```
- Use tools like **Vertical Pod Autoscaler (VPA)** to automatically adjust resource requests and limits based on actual usage.

#### **Option 2: Enable Cluster Autoscaler with Higher Limits**
Ensure that the cluster autoscaler is properly configured and has sufficient headroom to scale up when needed. Adjust the maximum node limit to accommodate peak workloads.

#### **Option 3: Use Spot Instances or Preemptible Nodes**
To reduce costs and increase capacity, consider using spot instances (AWS) or preemptible nodes (GCP). These are cheaper but may be terminated with short notice. You can configure taints and tolerations to run non-critical workloads on these nodes.

Example Taint for Spot Instances:
```bash
kubectl taint nodes <spot-node> spot=true:PreferNoSchedule
```

#### **Option 4: Implement Horizontal Pod Autoscaler (HPA)**
Use the **Horizontal Pod Autoscaler (HPA)** to scale your application horizontally by adding more replicas of your pods instead of relying solely on adding more nodes.

Example HPA Configuration:
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: my-app-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: my-app
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 50
```

#### **Option 5: Use Multi-Cluster Deployments**
If your workload consistently exceeds the capacity of a single cluster, consider deploying across multiple clusters using tools like **Kubernetes Federation** or **Cluster API**.

---

### **4. Monitoring and Alerts**
Set up monitoring and alerts to proactively detect when your cluster is nearing its capacity:
- Use tools like **Prometheus**, **Grafana**, or cloud-native monitoring solutions (e.g., AWS CloudWatch, GCP Monitoring).
- Configure alerts for high CPU/memory usage, pending pods, or autoscaler failures.

Example Alert Rule for Pending Pods:
```yaml
alert: TooManyPendingPods
expr: sum(kube_pod_status_phase{phase="Pending"}) > 5
for: 5m
labels:
  severity: critical
annotations:
  summary: "Too many pending pods in the cluster"
  description: "There are {{ $value }} pending pods in the cluster."
```

---

### **5. Example Workflow to Resolve the Issue**
1. **Identify Pending Pods**:
   ```bash
   kubectl get pods --field-selector=status.phase=Pending
   kubectl describe pod <pod-name>
   ```

2. **Check Node Resource Usage**:
   ```bash
   kubectl top nodes
   ```

3. **Increase Autoscaler Limit** (if possible):
   ```bash
   aws autoscaling update-auto-scaling-group \
       --auto-scaling-group-name <asg-name> \
       --max-size 10
   ```

4. **Scale Down Non-Critical Workloads**:
   ```bash
   kubectl scale deployment <non-critical-deployment> --replicas=1
   ```

5. **Optimize Resource Requests**:
   Review and adjust resource requests and limits for your pods.

6. **Enable HPA**:
   Configure Horizontal Pod Autoscaler to scale workloads dynamically.

---
