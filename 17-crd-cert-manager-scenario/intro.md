The `cert-manager` has been installed on the cluster, which includes its Custom Resource Definitions (CRDs).

Your task is to use `kubectl` to interact with these CRDs to extract specific information.

**Tasks:**

1.  Generate a list of all Custom Resource Definitions provided by `cert-manager`.
2.  Save this list to a file named `~/resources.yaml` using the default `kubectl` output format.
3.  Using `kubectl`, find the documentation for the `subject` field within the `Certificate` Custom Resource's specification.
4.  Save this specific documentation snippet to a file named `~/subject.yaml`.
