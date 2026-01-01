#!/usr/bin/env bash
#
# Description: Installs just, a command runner.

set -e

LATEST="$(curl -sL https://api.github.com/repos/casey/just/releases/latest | sed -n 's/.*"tag_name": "\([0-9.]*\)".*/\1/p')"
VERSION="${VERSION:-$LATEST}"
INSTALLCOMPLETIONS="${INSTALLCOMPLETIONS:-false}"

main() {
    if [ "$(id -u)" -ne 0 ]; then
        echo "Script must be run as root. Use sudo, su, or add \"USER root\" to your Dockerfile before running this script."
        exit 1
    fi

    local OS
    OS="$(uname -s)"

    if [ "$OS" != "Linux" ]; then
        echo "Unsupported OS: $OS"
        exit 1
    fi

    local ARCH
    ARCH="$(uname -m)"

    local LIBC
    LIBC="musl"

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

    (apt-get update && apt-get install -y --no-install-recommends curl ca-certificates) > /dev/null

    local TMP_DIR
    TMP_DIR="$(mktemp -d)"

    local URL
    URL="https://github.com/casey/just/releases/download/$VERSION/just-$VERSION-$ARCH-unknown-linux-$LIBC.tar.gz"
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
    apt-get clean
    rm -rf /var/lib/apt/lists/*

    echo "Successfully installed just $VERSION"
    just --version
}

main "$@"
