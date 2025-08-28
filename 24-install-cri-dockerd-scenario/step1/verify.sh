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

echo "done"
exit 0
