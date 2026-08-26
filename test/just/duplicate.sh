#!/bin/bash

# Run by `devcontainer features test` when it installs "just" twice in the
# same image (once with default options, once with randomized options) to
# make sure a duplicate installation doesn't leave the tool broken.

set -e

source dev-container-features-test-lib

check "just" just --version
reportResults
