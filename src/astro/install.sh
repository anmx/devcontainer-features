#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Copyright (c) 2026 anmx
# For full license text, see https://opensource.org/licenses/MIT
#
# Description: Installs Astro using npm/npx

set -e

VERSION="${VERSION:-latest}"
TEMPLATE="${TEMPLATE:-minimal}"
PROJECT="${PROJECT:-astro-workspace}"
INTEGRATIONS="${INTEGRATIONS//,/ }"
SKIPPROJECTCREATION="${SKIPPROJECTCREATION:-false}"
INSTALLGLOBALLY="${INSTALLGLOBALLY:-false}"

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
echo "Project Name: ${PROJECTNAME}"
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

# Check if project already exists
if [[ -d "${PROJECT_PATH}" ]]; then
    echo "WARNING: Project directory '${PROJECT_PATH}' already exists. Skipping creation."
    exit 0
fi

echo "Creating Astro project astro project using astro version: ${VERSION}"
if [[ ! -z "${INTEGRATIONS}" ]]; then
    echo "Adding integrations: ${INTEGRATIONS}"
    npm create "astro@${VERSION}" "${PROJECT}" -- --template "${TEMPLATE}" --add "${INTEGRATIONS}" --yes --skip-houston
else
    npm create "astro@${VERSION}" "${PROJECT}" -- --template "${TEMPLATE}" --yes --skip-houston
fi

cd "${PROJECT}"
if [[ INSTALLED_VERSION=$(npx astro --version 2> /dev/null) ]]; then
    echo "Successfully installed astro $INSTALLED_VERSION in ${PROJECT}"
else
    echo "ERROR: Failed to install astro"
    exit 1
fi

echo "Done!"