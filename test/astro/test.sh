#!/usr/bin/env bash

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

WORKSPACE_FOLDER="${_REMOTE_WORKSPACE_FOLDER:-/workspace}"

# Feature-specific tests
check "astro installed globally" command -v astro
check "astro global version" astro --version

# Report results
reportResults
