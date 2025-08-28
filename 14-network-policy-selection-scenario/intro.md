You have `frontend` and `backend` deployments running in separate, corresponding namespaces. The `backend` namespace is configured with a `default-deny-all` ingress policy, blocking all incoming traffic.

Your task is to enable communication from the `frontend` pods to the `backend` pods by selecting and applying the correct network policy from a set of provided files.

**Rules:**

*   The policy you apply must be the **most restrictive (least permissive)** one that still allows the required traffic.
*   You must **not** delete or modify the existing `default-deny-all` policy.
*   A collection of policy YAML files is available in the `~/netpol` directory.

**Task:**

1.  Analyze the deployments and the provided policy files in `~/netpol`.
2.  Choose the single, correct policy that allows ingress traffic from `frontend` pods to `backend` pods on the required port.
3.  Apply only that one policy to the cluster.
