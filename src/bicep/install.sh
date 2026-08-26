#!/usr/bin/env bash
#
# Description: Installs the Bicep CLI.

set -e

REPO="Azure/bicep"
VERSION="${VERSION:-latest}"

# Bicep releases don't publish a standalone checksum file, but the GitHub
# Releases API reports a GitHub-computed sha256 "digest" for every asset.
# Since we already need to call the API to resolve "latest" (and to locate
# the right asset), we reuse that same response to fetch the digest and
# verify the download afterwards -- no extra network round-trip needed.
ASSET_NAME="bicep-linux-x64"

if [ "$(id -u)" -ne 0 ]; then
    echo "Script must be run as root. Use sudo, su, or add \"USER root\" to your Dockerfile before running this script."
    exit 1
fi

# Install dependencies.
# jq is used to reliably select the release asset and its digest from the
# GitHub API response, rather than parsing JSON with grep/sed.
(apt-get update && apt-get install -y --no-install-recommends curl ca-certificates jq) > /dev/null

echo "Installing Bicep CLI..."

# Resolve the release metadata from the GitHub API instead of assembling a
# download URL by hand. This also gives us the asset's digest for
# verification below.
if [ "$VERSION" = "latest" ]; then
    API_URL="https://api.github.com/repos/$REPO/releases/latest"
else
    API_URL="https://api.github.com/repos/$REPO/releases/tags/$VERSION"
fi

# Write the API response to a file rather than a shell variable: piping it
# through echo can mangle backslash escapes (e.g. in the release body),
# which corrupts the JSON before jq gets to parse it.
# -f: fail (non-zero exit) on HTTP errors instead of writing an error page
# to disk and silently continuing.
RELEASE_JSON_FILE="$(mktemp)"
curl -fsSL "$API_URL" -o "$RELEASE_JSON_FILE"

# Surface GitHub API errors (rate limiting, unknown tag, etc.) instead of
# failing later with a confusing "no asset found" message.
API_ERROR="$(jq -r '.message // empty' "$RELEASE_JSON_FILE")"
if [ -n "$API_ERROR" ]; then
    rm -f "$RELEASE_JSON_FILE"
    echo "GitHub API error while querying $API_URL: $API_ERROR"
    exit 1
fi

VERSION="$(jq -r '.tag_name // empty' "$RELEASE_JSON_FILE")"
if [ -z "$VERSION" ]; then
    rm -f "$RELEASE_JSON_FILE"
    echo "Failed to resolve bicep release from $API_URL"
    exit 1
fi

URL="$(jq -r --arg name "$ASSET_NAME" '.assets[]? | select(.name == $name) | .browser_download_url' "$RELEASE_JSON_FILE" | head -n1)"
DIGEST="$(jq -r --arg name "$ASSET_NAME" '.assets[]? | select(.name == $name) | .digest' "$RELEASE_JSON_FILE" | head -n1)"

rm -f "$RELEASE_JSON_FILE"

if [ -z "$URL" ]; then
    echo "No release asset named '$ASSET_NAME' found for bicep $VERSION ($API_URL)"
    exit 1
fi

TMP_DIR="$(mktemp -d)"
BINARY_PATH="$TMP_DIR/$ASSET_NAME"

echo "Downloading: $URL"
curl -fsSL "$URL" -o "$BINARY_PATH"

if [ -n "$DIGEST" ] && [ "$DIGEST" != "null" ]; then
    EXPECTED_SHA="${DIGEST#sha256:}"
    ACTUAL_SHA="$(sha256sum "$BINARY_PATH" | awk '{ print $1 }')"
    if [ "$EXPECTED_SHA" != "$ACTUAL_SHA" ]; then
        rm -rf "$TMP_DIR"
        echo "ERROR: checksum mismatch for '$ASSET_NAME' (expected $EXPECTED_SHA, got $ACTUAL_SHA). Refusing to install a corrupted or tampered download."
        exit 1
    fi
    echo "Checksum verified for $ASSET_NAME"
else
    echo "WARNING: GitHub did not report a digest for '$ASSET_NAME'; skipping checksum verification."
fi

install -d /usr/local/bin
install -m 755 "$BINARY_PATH" /usr/local/bin/bicep

rm -rf "$TMP_DIR"
apt-get clean
rm -rf /var/lib/apt/lists/*

echo "Successfully installed bicep $VERSION"
bicep --version
