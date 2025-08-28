The `cert-manager` application has been deployed to the cluster.

Your task is to verify its installation by inspecting its Custom Resource Definitions (CRDs) using `kubectl`.

**Tasks:**

1.  Create a list of all `cert-manager` Custom Resource Definitions (CRDs) and save it to `~/resources.yaml`.
    *   **Important**: You must use `kubectl`'s default output format. Do not specify an output format (`-o`). Failure to follow this will result in an incorrect score.
2.  Using `kubectl`, extract the documentation for the `subject` specification field of the `Certificate` Custom Resource and save it to `~/subject.yaml`.
    *   For this second task, you may use any `kubectl` output format you prefer.
