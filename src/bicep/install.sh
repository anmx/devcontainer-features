#!/bin/bash
set -e

BICEP_VERSION="${VERSION:-"latest"}"

# Install Bicep CLI
echo "Installing Bicep CLI..."

if [ "${BICEP_VERSION}" = "latest" ]; then
    BICEP_VERSION=$(curl -s "https://api.github.com/repos/Azure/bicep/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
fi

# Ensure /usr/local/bin exists
if [[ ! -d "/usr/local/bin" ]]; then
    mkdir -p /usr/local/bin
fi

# download binary
curl -sL "https://github.com/Azure/bicep/releases/download/${BICEP_VERSION}/bicep-linux-x64" -o /usr/local/bin/bicep

# set permissions
chmod +x /usr/local/bin/bicep
