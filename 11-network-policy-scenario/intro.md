You have two deployments, `frontend` and `backend`, running in separate namespaces (`frontend` and `backend`, respectively).

Your task is to implement a `NetworkPolicy` to allow traffic from the `frontend` pods to the `backend` pods while adhering to the principle of least privilege.

**Task:**

Create a `NetworkPolicy` named `allow-frontend` in the `backend` namespace that:

1.  Applies to pods with the label `app: backend`.
2.  Allows **ingress** traffic only from pods in the `frontend` namespace that have the label `app: frontend`.
3.  The policy should only allow traffic to `TCP` port `80` on the backend pods.
