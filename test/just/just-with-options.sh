#!/bin/bash

# Test with a pinned version and completions enabled

set -e

source dev-container-features-test-lib

check "just version is pinned" bash -c "just --version | grep -q ' 1.45.0$'"
check "bash completion installed" bash -c "test -f /usr/share/bash-completion/completions/just.bash"
check "zsh completion installed" bash -c "test -f /usr/share/zsh/site-functions/just.zsh"
check "man page installed" bash -c "test -f /usr/local/share/man/man1/just.1"

reportResults
