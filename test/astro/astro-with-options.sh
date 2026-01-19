#!/bin/bash

# Test with custom options

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

WORKSPACE_FOLDER="${_REMOTE_WORKSPACE_FOLDER:-/workspace}"

# Feature-specific tests
check "custom project exists" bash -c "test -d ${WORKSPACE_FOLDER}/my-custom-project"
check "package.json exists" bash -c "test -f ${WORKSPACE_FOLDER}/my-custom-project/package.json"
check "astro command works" bash -c "cd ${WORKSPACE_FOLDER}/my-custom-project && npx astro --version"

# Report results
reportResults
