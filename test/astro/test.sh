#!/usr/bin/env bash

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

WORKSPACE_FOLDER="${_REMOTE_WORKSPACE_FOLDER:-/workspace}"

# Feature-specific tests
check "astro command exists in project" bash -c "cd ${WORKSPACE_FOLDER}/astro-project && npx astro --version"
check "project directory exists" test -d "${WORKSPACE_FOLDER}/astro-project"
check "package.json exists" test -f "${WORKSPACE_FOLDER}/astro-project/package.json"
check "astro is in package.json" grep -q "astro" "${WORKSPACE_FOLDER}/astro-project/package.json"

# Report results
reportResults
