An existing WordPress deployment is running in the `wordpress-sidecar` namespace.

Your task is to update the `wordpress` deployment to add a sidecar container for log monitoring.

1.  Edit the `wordpress` deployment.
2.  Add a new container named `sidecar` that uses the `busybox:stable` image.
3.  The new `sidecar` container must run the command: `/bin/sh -c "tail -f /var/log/wordpress.log"`
4.  Add a shared `emptyDir` volume to the Pod.
5.  Mount this shared volume at `/var/log` in **both** the `wordpress` and `sidecar` containers to make the log file available.
6.  Ensure the deployment successfully rolls out with the new configuration.
