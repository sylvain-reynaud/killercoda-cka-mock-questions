Your task is to install Argo CD in a Kubernetes cluster using Helm. The Custom Resource Definitions (CRDs) for Argo CD have already been installed on the cluster.

Follow the steps below to complete the installation:

1.  Add the official Argo CD Helm repository with the name `argo`.
2.  Generate a Helm template from the `argo/argo-cd` chart, using version `7.7.3`, for the `argocd` namespace.
3.  Configure the chart to **not** install CRDs, as they are already present.
4.  Save the final generated YAML manifest to `/home/argo/argo.helm.yaml`.
