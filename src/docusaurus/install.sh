#!/usr/bin/env bash

set -e


# Dynamic variable with defaults
DOCUSAURUS_TITLE=${DOCUSAURUS_TITLE:-"Docusaurus"}
DOCUSAURUS_DOCS_PATH=${DOCUSAURUS_DOCS_PATH:-"docs"}
DOCUSAURUS_VERSION=${DOCUSAURUS_VERSION:-"latest"}

# Static variables
DOCUSAURUS_BASE_PATH="${CODESPACE_VSCODE_FOLDER:-.}"

echo "Installing Docusaurus..."

if [[ ! -d "${DOCUSAURUS_BASE_PATH}" ]]; then

    mkdir -p "${DOCUSAURUS_BASE_PATH}"
    cd ${DOCUSAURUS_BASE_PATH}

    # Initialize a new Docusaurus project
    npx --yes create-docusaurus@${DOCUSAURUS_VERSION} "${DOCUSAURUS_TITLE}" classic --javascript

    # Create docs path if it doesn't exist
    if [[ ! -d "${DOCUSAURUS_BASE_PATH}/${DOCUSAURUS_TITLE}/${DOCUSAURUS_DOCS_PATH}" ]]; then
        echo "Creating Docusaurus docs path \"${DOCUSAURUS_BASE_PATH}/${DOCUSAURUS_TITLE}/${DOCUSAURUS_DOCS_PATH}\""
        mkdir -p "${DOCUSAURUS_BASE_PATH}/${DOCUSAURUS_TITLE}/${DOCUSAURUS_DOCS_PATH}"
    fi

fi

echo "Docusaurus installation complete."
