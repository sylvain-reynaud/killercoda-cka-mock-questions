There is a deployment named `nodeport-deployment` in the `nodeport-expose` namespace.

**Tasks:**

1.  Configure the `nodeport-deployment` so its container exposes port `80` with the protocol `TCP` and the name `http`.
2.  Create a new `Service` named `nodeport-service` that exposes the container's port `80`.
3.  Configure the new service to be of type `NodePort` to expose the pods externally.
