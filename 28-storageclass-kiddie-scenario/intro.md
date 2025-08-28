Your task is to create a new `StorageClass` and configure it as the default for the cluster.

**Requirements:**

1.  Create a new `StorageClass` named `local-kiddie`.
2.  It must use the existing provisioner: `rancher.io/local-path`.
3.  Set its `volumeBindingMode` to `WaitForFirstConsumer`.
4.  Make the `local-kiddie` `StorageClass` the **only** default `StorageClass` in the cluster.
5.  Do **not** modify any existing `Deployments` or `PersistentVolumeClaims`.
