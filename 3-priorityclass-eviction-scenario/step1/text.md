You are working in a Kubernetes cluster where resources are constrained. In the `priority` namespace, a `busybox-logger` Pod is stuck in a `Pending` state due to insufficient CPU. Another Deployment is already running in the namespace with a low priority.

Your task is to ensure the `busybox-logger` Deployment can run by managing Pod priorities.

1.  Create a new `PriorityClass` named `high-priority`. Its value should be exactly **one less** than the highest existing user-defined `PriorityClass` value.
2.  Patch the `busybox-logger` Deployment to use this new `high-priority` class.
3.  Ensure the `busybox-logger` Deployment rolls out successfully. This is expected to cause the eviction of Pods from other Deployments in the namespace.

*Do not modify any other Deployments directly.*
