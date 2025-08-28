#!/bin/bash

# Download the cri-dockerd package to the user's home directory
wget https://github.com/Mirantis/cri-dockerd/releases/download/v0.3.1/cri-dockerd_0.3.1-0.ubuntu-jammy_amd64.deb -O ~/cri-dockerd_0.3.1.3-0.ubuntu-jammy_amd64.deb

echo "cri-dockerd package downloaded to home directory."
