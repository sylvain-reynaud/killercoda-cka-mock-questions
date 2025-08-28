A WordPress application with 3 replicas is running in the `relative-fawn` namespace on a node with the following allocatable resources: `1` CPU and `2015360Ki` of memory.

Your task is to adjust all Pod resource **requests** as follows:

1.  Divide the node's resources evenly across all 3 pods.
2.  Assign each Pod a fair share of CPU and memory, leaving enough overhead to keep the node stable.
3.  Use the exact same resource requests for both the main `wordpress` container and the `wait-for-mysql` init container.

*You are not required to change any resource limits.*

It may be helpful to temporarily scale the WordPress Deployment to 0 replicas while applying the updates. After the changes are made, ensure the Deployment is scaled back to 3 replicas and that all Pods are running and ready.
