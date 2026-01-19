#!/usr/bin/env bash

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
check "astro command exists in project" bash -c "cd astro-project && npx astro --version"
check "project directory exists" test -d "astro-project"
check "package.json exists" test -f "astro-project/package.json"
check "astro is in package.json" grep -q "astro" "astro-project/package.json"

# Report results
reportResults
