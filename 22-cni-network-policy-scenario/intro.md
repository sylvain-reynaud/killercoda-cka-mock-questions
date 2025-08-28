The control-plane node in this cluster is currently in a `NotReady` state because a Container Network Interface (CNI) has not been installed.

Your task is to install and configure a CNI that meets the specified requirements. You must choose one of the following options and install it using the provided manifest URL:

*   **Flannel (v0.26.1)**: `https://github.com/flannel-io/flannel/releases/download/v0.26.1/kube-flannel.yml`
*   **Calico (v3.28.2)**: `https://raw.githubusercontent.com/projectcalico/calico/v3.28.2/manifests/tigera-operator.yaml`

The CNI you choose **must** meet the following requirements:

1.  It must allow pods to communicate with each other.
2.  It must support **network policy enforcement**.
