#!/usr/bin/env bash
#
# Description: Installs just, a command runner.

set -euo pipefail

cleanup() {
    if [ -n "${TMP_DIR:-}" ] && [ -d "$TMP_DIR" ]; then
        rm -rf "$TMP_DIR"
    fi

    apt-get clean
    rm -rf /var/lib/apt/lists/*
}

trap cleanup EXIT

_meet_dependencies() {
    # Check if apt-get is available
    if ! command -v apt-get >/dev/null 2>&1; then
        echo "Error: apt-get not found. This script is for Debian-based systems." >&2
        return 1
    fi

    local missing_dependencies=""
    for cmd in curl tar gzip install mktemp jq; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            missing_dependencies="${missing_dependencies} ${cmd}"
        fi
    done

    if [ -n "$missing_dependencies" ]; then
        echo "(*) Installing missing dependencies: ${missing_dependencies}..."
        apt-get update -y > /dev/null
        # shellcheck disable=SC2086
        if ! apt-get install -y --no-install-recommends ${missing_dependencies} > /dev/null; then
            echo "Error: Failed to install dependencies." >&2
            return 1
        fi
    fi
}

_get_platform_info() {
    local OS
    OS="$(uname -s)"
    if [ "$OS" != "Linux" ]; then
        echo "Unsupported OS: $OS"
        exit 1
    fi

    local ARCH
    ARCH="$(uname -m)"
    echo "$ARCH"
}

_get_version_info() {
    local VERSION
    VERSION="${VERSION:-latest}"

    local LATEST
    LATEST="$(curl -sL https://api.github.com/repos/casey/just/releases/latest | jq -r ".tag_name")"
    # Validate and set VERSION
    if [ "$VERSION" = "latest" ]; then
        VERSION="$LATEST"
    elif [[ ! "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo "Unsupported version: $VERSION"
        exit 1
    fi

    echo "$VERSION"
}

_download_and_install() {
    local VERSION="$1"
    local ARCH="$2"

    local LIBC="musl"
    case "$ARCH" in
    aarch64 | x86_64) ;;
    armv7l)
        LIBC="musleabihf"
        ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
    esac

    local TMP_DIR
    TMP_DIR="$(mktemp -d)"

    local URL="https://github.com/casey/just/releases/download/$VERSION/just-$VERSION-$ARCH-unknown-linux-$LIBC.tar.gz"
    echo "Downloading: $URL"

    curl -L "$URL" | tar -xz -C "$TMP_DIR"

    install -d /usr/local/bin
    install -m 755 "$TMP_DIR/just" /usr/local/bin/

    install -d /usr/local/share/man/man1
    install "$TMP_DIR/just.1" /usr/local/share/man/man1/

    if [ "$INSTALLCOMPLETIONS" = "true" ]; then
        install -d /usr/share/bash-completion/completions
        install "$TMP_DIR/completions/just.bash" /usr/share/bash-completion/completions/
        install -d /usr/share/zsh/site-functions
        install "$TMP_DIR/completions/just.zsh" /usr/share/zsh/site-functions/
    fi

    rm -rf "$TMP_DIR"
}

main() {
    if [ "$(id -u)" -ne 0 ]; then
        echo "Script must be run as root. Use sudo, su, or add \"USER root\" to your Dockerfile before running this script."
        exit 1
    fi

    _meet_dependencies

    local VERSION
    VERSION="$(_get_version_info)"

    local ARCH
    ARCH="$(_get_platform_info)"

    INSTALLCOMPLETIONS="${INSTALLCOMPLETIONS:-false}"

    _download_and_install "$VERSION" "$ARCH"

    echo "Successfully installed just $VERSION"
    just --version
}

main "$@"
