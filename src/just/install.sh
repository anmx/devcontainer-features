#!/usr/bin/env bash
#
# Description: Installs just, a command runner.

set -e

# Install dependencies
# jq is used to reliably select the correct release asset and read its
# browser_download_url from the GitHub API response (see below), rather than
# assembling the download URL ourselves.
(apt-get update && apt-get install -y --no-install-recommends curl ca-certificates jq) > /dev/null

REPO="casey/just"
VERSION="${VERSION:-latest}"
INSTALLCOMPLETIONS="${INSTALLCOMPLETIONS:-false}"

# Validate VERSION shape early. The actual existence of the release/tag is
# verified later against the GitHub API.
if [[ "$VERSION" != "latest" && ! "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Unsupported version: $VERSION"
    exit 1
fi


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

    local RAW_ARCH
    RAW_ARCH="$(uname -m)"

    # Map uname's arch string to the arch token just actually publishes in
    # its release asset names. These are NOT always identical (e.g. uname
    # reports "armv7l" but just's assets use "armv7").
    local JUST_ARCH
    local LIBC="musl"
    case "$RAW_ARCH" in
    x86_64)
        JUST_ARCH="x86_64"
        ;;
    aarch64)
        JUST_ARCH="aarch64"
        ;;
    armv7l)
        JUST_ARCH="armv7"
        LIBC="musleabihf"
        ;;
    *)
        echo "Unsupported architecture: $RAW_ARCH"
        exit 1
        ;;
    esac

    # Resolve the release metadata from the GitHub API instead of guessing a
    # download URL. This is more reliable than assembling the URL ourselves,
    # since it always reflects the actual assets GitHub published for this
    # release, rather than an assumed naming scheme.
    local API_URL
    if [ "$VERSION" = "latest" ]; then
        API_URL="https://api.github.com/repos/$REPO/releases/latest"
    else
        API_URL="https://api.github.com/repos/$REPO/releases/tags/$VERSION"
    fi

    # Write the API response to a file rather than a shell variable: piping
    # it through echo can mangle backslash escapes (e.g. in the release
    # body), which corrupts the JSON before jq gets to parse it.
    # -f: fail (non-zero exit) on HTTP errors instead of writing an error
    # page to disk and silently continuing.
    local RELEASE_JSON_FILE
    RELEASE_JSON_FILE="$(mktemp)"
    curl -fsSL "$API_URL" -o "$RELEASE_JSON_FILE"

    # Surface GitHub API errors (rate limiting, unknown tag, etc.) instead of
    # failing later with a confusing "no asset found" message.
    local API_ERROR
    API_ERROR="$(jq -r '.message // empty' "$RELEASE_JSON_FILE")"
    if [ -n "$API_ERROR" ]; then
        rm -f "$RELEASE_JSON_FILE"
        echo "GitHub API error while querying $API_URL: $API_ERROR"
        exit 1
    fi

    VERSION="$(jq -r '.tag_name // empty' "$RELEASE_JSON_FILE")"
    if [ -z "$VERSION" ]; then
        rm -f "$RELEASE_JSON_FILE"
        echo "Failed to resolve just release from $API_URL"
        exit 1
    fi

    # Match the asset by name (anchored so e.g. "arm" cannot match "armv7",
    # and "musl" cannot match "musleabihf"), then use the exact
    # browser_download_url GitHub reports for it, rather than assembling the
    # download URL ourselves.
    local ASSET_REGEX
    ASSET_REGEX="^just-[0-9.]+-${JUST_ARCH}-unknown-linux-${LIBC}\\.tar\\.gz\$"

    local ASSET_NAME URL
    ASSET_NAME="$(jq -r --arg re "$ASSET_REGEX" '.assets[]? | select(.name | test($re)) | .name' "$RELEASE_JSON_FILE" | head -n1)"
    URL="$(jq -r --arg re "$ASSET_REGEX" '.assets[]? | select(.name | test($re)) | .browser_download_url' "$RELEASE_JSON_FILE" | head -n1)"

    if [ -z "$URL" ]; then
        rm -f "$RELEASE_JSON_FILE"
        echo "No release asset found for arch '$JUST_ARCH' (libc '$LIBC') in just $VERSION ($API_URL)"
        exit 1
    fi

    # just publishes a SHA256SUMS asset alongside the binaries on recent
    # releases. Look it up now (same release metadata, no extra API call)
    # so the downloaded archive can be verified before it's extracted.
    local SUMS_URL
    SUMS_URL="$(jq -r '.assets[]? | select(.name == "SHA256SUMS") | .browser_download_url' "$RELEASE_JSON_FILE" | head -n1)"

    rm -f "$RELEASE_JSON_FILE"

    local TMP_DIR
    TMP_DIR="$(mktemp -d)"
    local ARCHIVE_PATH="$TMP_DIR/$ASSET_NAME"

    echo "Downloading: $URL"
    curl -fsSL "$URL" -o "$ARCHIVE_PATH"

    if [ -n "$SUMS_URL" ]; then
        local SUMS_PATH="$TMP_DIR/SHA256SUMS"
        curl -fsSL "$SUMS_URL" -o "$SUMS_PATH"

        local EXPECTED_SHA ACTUAL_SHA
        EXPECTED_SHA="$(awk -v f="$ASSET_NAME" '$2 == f { print $1; exit }' "$SUMS_PATH")"
        if [ -z "$EXPECTED_SHA" ]; then
            rm -rf "$TMP_DIR"
            echo "ERROR: '$ASSET_NAME' not listed in SHA256SUMS for just $VERSION. Refusing to install an unverifiable binary."
            exit 1
        fi

        ACTUAL_SHA="$(sha256sum "$ARCHIVE_PATH" | awk '{ print $1 }')"
        if [ "$EXPECTED_SHA" != "$ACTUAL_SHA" ]; then
            rm -rf "$TMP_DIR"
            echo "ERROR: checksum mismatch for '$ASSET_NAME' (expected $EXPECTED_SHA, got $ACTUAL_SHA). Refusing to install a corrupted or tampered download."
            exit 1
        fi
        echo "Checksum verified for $ASSET_NAME"
    else
        echo "WARNING: no SHA256SUMS asset found for just $VERSION; skipping checksum verification."
    fi

    tar -xzf "$ARCHIVE_PATH" -C "$TMP_DIR"

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
