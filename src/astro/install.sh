#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Copyright (c) 2026 anmx
# For full license text, see https://opensource.org/licenses/MIT
#
# Description: Installs Astro using npm/npx

set -e

VERSION="${VERSION:-latest}"
TEMPLATE="${TEMPLATE:-minimal}"
PROJECT="${PROJECT:-astro-project}"
INTEGRATIONS="${INTEGRATIONS//,/ }"
SKIPPROJECTCREATION="${SKIPPROJECTCREATION:-false}"
INSTALLGLOBALLY="${INSTALLGLOBALLY:-false}"

WORKSPACE_FOLDER="${_REMOTE_WORKSPACE_FOLDER:-/workspace}"
REMOTE_USER="${_REMOTE_USER:-node}"

# Ensure Node.js is installed
if ! command -v npm &> /dev/null; then
    echo "ERROR: npm is not installed. Please install Node.js first."
    echo "Add the 'ghcr.io/devcontainers/features/node' feature before this one."
    exit 1
fi

if ! command -v npx &> /dev/null; then
    echo "ERROR: npx is not installed. Please install Node.js first."
    echo "Add the 'ghcr.io/devcontainers/features/node' feature before this one."
    exit 1
fi

# Normalize version string (remove 'astro@' prefix if present)
if [[ "$VERSION" == *@* ]]; then
    VERSION="${VERSION##*@}"
fi

echo "===================================="
echo "Installing Astro"
echo "===================================="
echo "Version: ${VERSION}"
echo "Template: ${TEMPLATE}"
echo "Project Name: ${PROJECT}"
echo "Skip Project Creation: ${SKIPPROJECTCREATION}"
echo "Install Globally: ${INSTALLGLOBALLY}"
if [[ -n "${INTEGRATIONS}" ]]; then
    echo "Integrations: ${INTEGRATIONS}"
fi
echo "===================================="

# Install Astro globally if requested
if [[ "${INSTALLGLOBALLY}" == "true" ]]; then
    echo "Installing Astro CLI globally..."
    sudo npm install -g "astro@${VERSION}"
    echo "Astro CLI installed globally: $(astro --version 2>/dev/null || echo 'version check failed')"
fi

# Skip project creation if requested
if [[ "${SKIPPROJECTCREATION}" == "true" ]]; then
    echo "INFO: Skipping project creation as requested."
    exit 0
fi

PROJECT_PATH="${WORKSPACE_FOLDER}/${PROJECT}"
# Check if project already exists at the target location
if [[ -d "${PROJECT_PATH}" ]]; then
    echo "WARNING: Project directory '${PROJECT_PATH}' already exists. Skipping creation."
else
    echo "Creating project directory at '${PROJECT_PATH}'"
    mkdir -m 755 -p "${PROJECT_PATH}"
fi

cd "${WORKSPACE_FOLDER}"

# Create Astro project
echo "Creating Astro project astro project using astro version: ${VERSION}"
CREATE_ARGS=("${PROJECT}" "--template" "${TEMPLATE}" "--yes" "--skip-houston")

if [[ -n "${INTEGRATIONS}" ]]; then
    read -ra INTEGRATION_ARRAY <<< "${INTEGRATIONS}"
    for integration in "${INTEGRATION_ARRAY[@]}"; do
        CREATE_ARGS+=("--add" "$integration")
    done
fi

npm create "astro@${VERSION}" -- "${CREATE_ARGS[@]}"

# Update permissions to match the remote user
echo "Updating permissions for ${PROJECT_PATH} to user ${REMOTE_USER}..."
chown -R "${REMOTE_USER}:${REMOTE_USER}" "${PROJECT_PATH}"

# Verify installation
cd "${PROJECT}"
if [[ INSTALLED_VERSION=$(npx astro --version 2> /dev/null) ]]; then
    echo "Successfully installed astro $INSTALLED_VERSION in ${PROJECT}"
else
    echo "ERROR: Failed to install astro"
    exit 1
fi

echo "Done!"
