The control-plane node in this cluster, which is running the `CRI-O` container runtime, is currently in a `NotReady` state because a Container Network Interface (CNI) has not been installed.

Your task is to install the Calico CNI to make the cluster functional.

**Task:**

Install Calico v3.28.2 by applying the following manifests in order:

1.  The Tigera Calico operator:
    `https://raw.githubusercontent.com/projectcalico/calico/v3.28.2/manifests/tigera-operator.yaml`

2.  The default Calico custom resource definition, which specifies the installation configuration:
    `https://raw.githubusercontent.com/projectcalico/calico/v3.28.2/manifests/custom-resources.yaml`

After installation, the node should become `Ready`.
