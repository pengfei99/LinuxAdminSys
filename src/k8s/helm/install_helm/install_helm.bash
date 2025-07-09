#!/bin/bash

set -euo pipefail

HELM_VERSION="v3.9.4"
HELM_TAR="helm-${HELM_VERSION}-linux-amd64.tar.gz"
HELM_URL="https://get.helm.sh/${HELM_TAR}"
TMP_DIR="/tmp/helm-install"
HELM_DIR="linux-amd64"

mkdir -p "$TMP_DIR"
cd "$TMP_DIR"

echo "Downloading Helm ${HELM_VERSION} to ${TMP_DIR}..."
wget -q "${HELM_URL}"

echo "Extracting Helm..."
tar -xzf "${HELM_TAR}"

echo "Setting execution permission..."
chmod a+x "${HELM_DIR}/helm"

echo "Moving Helm binary to /usr/local/bin..."
sudo mv "${HELM_DIR}/helm" /usr/local/bin/helm

echo "Cleaning up..."
rm -rf "$TMP_DIR"

echo "Verifying Helm installation..."
if command -v helm >/dev/null 2>&1; then
    helm version
    echo "Helm installed successfully."
else
    echo "Helm installation failed."
    exit 1
fi