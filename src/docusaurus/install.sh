#!/usr/bin/env bash

set -e

DOCUSAURUS_TITLE=${DOCUSAURUS_TITLE:-"Docusaurus"}
DOCUSAURUS_DOCS_PATH=${DOCUSAURUS_DOCS_PATH:-"docs"}
DOCUSAURUS_VERSION=${DOCUSAURUS_VERSION:-"latest"}

echo "Installing Docusaurus..."

if [[ ! -d "${DOCUSAURUS_TITLE}" ]]; then

    # Initialize a new Docusaurus project
    npx --yes create-docusaurus@${DOCUSAURUS_VERSION} "${DOCUSAURUS_TITLE}" classic --javascript

    # Create docs path if it doesn't exist
    if [[ ! -d "${DOCUSAURUS_TITLE}/${DOCUSAURUS_DOCS_PATH}" ]]; then
        echo "Creating Docusaurus docs path ${DOCUSAURUS_TITLE}/${DOCUSAURUS_DOCS_PATH}"
        mkdir -p "${DOCUSAURUS_TITLE}/${DOCUSAURUS_DOCS_PATH}"
    fi

    # Update baseUrl in docusaurus.config.js
    sed -i -E "s|(baseUrl: )([\"\'])([^\"\']*)(\2)(,)?|\1'/${DOCUSAURUS_DOCS_PATH}/'\5|g" "${DOCUSAURUS_TITLE}/docusaurus.config.js"
fi

# Run Docusaurus in development mode
if [[ -f "${DOCUSAURUS_TITLE}/docusaurus.config.js" ]]; then
    (cd "${DOCUSAURUS_TITLE}" && npm run start &)
else
    echo "Docusaurus installation failed: docusaurus.config.js not found."
    exit 1
fi

echo "Docusaurus installation complete."
