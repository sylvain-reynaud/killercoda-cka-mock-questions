An existing deployment named `front-end` is running in the `sp-culator` namespace, but it is not correctly configured to expose its container port.

Your task is to reconfigure the deployment and expose it using a `NodePort` service.

**Tasks:**

1.  Reconfigure the `front-end` deployment to expose port `80/tcp` for its `nginx` container.
2.  Create a new `Service` named `front-end-svc`.
3.  The new service must expose the container's port `80/tcp`.
4.  Configure the service to be of type `NodePort` to make it accessible on the node's IP address.
