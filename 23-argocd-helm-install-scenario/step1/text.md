Your task is to install Argo CD using its official Helm chart.

Note that the required Custom Resource Definitions (CRDs) for the chart have already been pre-installed in the cluster for you.

**Exercise Requirements:**

1.  Add the official Argo CD Helm repository with the name `argo`.
2.  Generate a Helm template named `argo-helm.yaml` in the `/` directory. This template should be for chart version `7.7.3` and target the `argocd` namespace.
    *   **Important**: Configure the template generation to **not** include CRDs.
3.  Install Argo CD using Helm with the release name `argocd`.
    *   Use the same chart version (`7.7.3`).
    *   Install it into the `argocd` namespace.
    *   Configure the installation to **not** install CRDs.

You do not need to configure access to the Argo CD server UI.
