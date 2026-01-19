#!/bin/bash

# Test with custom options

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
check "custom project exists" test -d "my-custom-project"
check "package.json exists" test -f "my-custom-project/package.json"
check "astro command works" bash -c "cd my-custom-project && npx astro --version"

# Report results
reportResults