A single-node `kubeadm` cluster was recently migrated to a new machine, and it is now broken. The control plane is down, and the node is in a `NotReady` state.

Your task is to diagnose the issues, repair the cluster configuration, and bring it back to a fully operational state.

**Hints:**

*   The previous cluster configuration used an external `etcd` server, but the new setup should use the local `etcd` instance that `kubeadm` provides.
*   Check the static pod manifests in `/etc/kubernetes/manifests/`.
*   Use `crictl ps` and `crictl logs` to inspect the state and output of the control plane containers.

**Tasks:**

1.  Identify the broken cluster components and the root cause of their failure.
2.  Fix the configuration of all broken components to use the correct, local `etcd` server and restore their connection to the API server.
3.  Ensure you restart any necessary services for your changes to take effect.
4.  Verify that the node returns to a `Ready` state and that all pods in the `kube-system` namespace are running correctly.
