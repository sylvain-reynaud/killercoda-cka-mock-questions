#!/bin/bash

# 1. Verify cri-dockerd package is installed
if ! dpkg -s cri-dockerd >/dev/null 2>&1; then
    echo "Error: 'cri-dockerd' package is not installed."
    exit 1
fi
echo "OK: cri-dockerd package is installed."

# 2. Verify cri-docker service is enabled and active
if ! systemctl is-enabled --quiet cri-docker.service; then
    echo "Error: 'cri-docker.service' is not enabled."
    exit 1
fi
echo "OK: cri-docker.service is enabled."

if ! systemctl is-active --quiet cri-docker.service; then
    echo "Error: 'cri-docker.service' is not active."
    exit 1
fi
echo "OK: cri-docker.service is active."

# 3. Verify system parameters
PARAMS=(
    "net.bridge.bridge-nf-call-iptables=1"
    "net.ipv6.conf.all.forwarding=1"
    "net.ipv4.ip_forward=1"
    "net.netfilter.nf_conntrack_max=131072"
)

for param in "${PARAMS[@]}"; do
    key=${param%=*}
    expected_value=${param#*=}
    current_value=$(sysctl -n $key)

    if [ "$current_value" != "$expected_value" ]; then
        echo "Error: System parameter '$key' is set to '$current_value', but should be '$expected_value'."
        exit 1
    fi
    echo "OK: System parameter '$key' is set correctly."
done

echo "done"
exit 0
