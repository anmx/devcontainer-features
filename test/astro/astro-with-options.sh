#!/bin/bash

# Test with custom options

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Project scaffolding runs via postCreateCommand in the context of the
# workspace folder, so checks use paths relative to the current directory
# (the actual mounted workspace) rather than guessing a mount path.

# Feature-specific tests
check "custom project exists" bash -c "test -d ./my-custom-project"
check "package.json exists" bash -c "test -f ./my-custom-project/package.json"
check "astro command works" bash -c "cd ./my-custom-project && npx astro --version"

# Report results
reportResults
