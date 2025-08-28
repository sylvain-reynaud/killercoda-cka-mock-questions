You're working in a Kubernetes cluster with an existing Deployment named `busybox-logger` running in a namespace called `priority`.
The cluster already has at least one user-defined `PriorityClass`.

Perform the following tasks:

1. Create a new `PriorityClass` named `high-priority` for user workloads. The value of this `PriorityClass` should be exactly one less than the highest existing user-defined `PriorityClass` value.

2. Patch the existing Deployment `busybox-logger` in the `priority` namespace to use the newly created `high-priority` `PriorityClass`.
