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
