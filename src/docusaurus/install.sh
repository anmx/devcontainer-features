#!/usr/bin/env bash

set -e

DOCUSAURUS_TITLE=${DOCUSAURUS_TITLE:-"Docusaurus"}
DOCUSAURUS_DOCS_PATH=${DOCUSAURUS_DOCS_PATH:-"docs"}
DOCUSAURUS_VERSION=${DOCUSAURUS_VERSION:-"latest"}

echo "Installing Docusaurus..."

if [[ ! -d "${DOCUSAURUS_TITLE}" ]]; then

    # Initialize a new Docusaurus project
    npx --yes create-docusaurus@${DOCUSAURUS_VERSION} ${DOCUSAURUS_TITLE} classic --javascript

    # Create docs path if it doesn't exist
    if [[ ! -d "${DOCUSAURUS_TITLE}/${DOCUSAURUS_DOCS_PATH}" ]]; then
        echo "Creating Docusaurus docs path ${DOCUSAURUS_TITLE}/${DOCUSAURUS_DOCS_PATH}"
        mkdir -p "${DOCUSAURUS_TITLE}/${DOCUSAURUS_DOCS_PATH}"
    fi

fi

echo "Docusaurus installation complete."
