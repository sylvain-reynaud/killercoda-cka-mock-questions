After a recent cluster migration, the `kube-apiserver` on the controlplane node is failing to start. The `etcd` instance is running correctly, but the API server cannot connect to it.

Your task is to diagnose the problem and fix the `kube-apiserver` configuration.

**Hint:**

*   The `kube-apiserver` is configured as a static pod. Check its manifest in `/etc/kubernetes/manifests/`.
*   `etcd` has two primary ports: a client port (`2379`) and a peer port (`2380`). Ensure the API server is configured to use the correct one.
