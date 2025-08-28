The `cert-manager` application has been deployed to the cluster.

Your task is to inspect its Custom Resource Definitions (CRDs) using `kubectl`.

**Tasks:**

1.  List all Custom Resource Definitions related to `cert-manager` and save the output to a file named `crds.yaml`.
2.  Extract the documentation for the `subject` field from the `Certificate` CRD's specification and save it to a file named `subject.yaml`.

**Hint:**

*   For the first step, you can pipe the output of `kubectl get crds` to `grep`.
*   For the second step, you can use a `jsonpath` output to navigate the CRD's schema.
