A MariaDB Deployment in the `mariadb` namespace was accidentally deleted, but its `PersistentVolume` was retained. Your task is to restore the deployment and reconnect it to its persistent storage.

A template for the deployment manifest is available at `~/mariadb-deploy.yaml`.

**Tasks:**

1.  Create a `PersistentVolumeClaim` named `mariadb` in the `mariadb` namespace with the following specifications:
    *   **Access Mode**: `ReadWriteOnce`
    *   **Storage Capacity**: `250Mi`
2.  Edit the deployment manifest at `~/mariadb-deploy.yaml` to mount the `mariadb` PVC.
3.  Apply the updated deployment manifest to the cluster.
4.  Ensure the MariaDB deployment is running and stable, successfully using the existing volume.
