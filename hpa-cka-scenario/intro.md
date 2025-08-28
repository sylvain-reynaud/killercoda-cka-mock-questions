# CKA Practice Exam - Question 7: HorizontalPodAutoscaler Configuration

**Time Limit: 15 minutes**  
**Weight: 8%**

## Context
You are working as a Kubernetes administrator for a company that needs to implement autoscaling for their web applications.

## Task
Configure a HorizontalPodAutoscaler (HPA) for the existing `apache-deployment` in the `autoscale` namespace  with the following exact specifications:

**Required Configuration:**
- **HPA Name:** `apache-server`
- **Namespace:** `autoscale` 
- **Target Deployment:** `apache-deployment`
- **CPU Target:** `50%`
- **Min Replicas:** `1`
- **Max Replicas:** `4`
- **Downscale Stabilization Window:** `30` seconds

## Environment Information
- A deployment named `apache-deployment` already exists in the `autoscale` namespace
- Metrics server is installed and configured 
- The deployment has appropriate resource requests configured

## Verification Commands
Use these commands to check your work:
```bash
kubectl get hpa apache-server -n autoscale
kubectl describe hpa apache-server -n autoscale