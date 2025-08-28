A `PersistentVolume` has already been created and is available for use. Your task is to create a `PersistentVolumeClaim` and use it to provide persistent storage to a MariaDB deployment.

A deployment manifest is available at `/root/maria.deploy.yaml`.

Follow the steps below:

1.  Create a `PersistentVolumeClaim` named `MariaDB` in the `mariadb` namespace with the following specifications:
    *   **Access Mode**: `ReadWriteOnce`
    *   **Storage Capacity**: `250Mi`
2.  Edit the deployment manifest at `/root/maria.deploy.yaml` to mount the newly created PVC.
3.  Create the deployment using the modified manifest file.
4.  Verify that the deployment is running and stable.
