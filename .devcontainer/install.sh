#!/bin/sh

set -e

RELEASES_URL="https://github.com/balena-io/balena-cli/releases"

downloadJSON() {
    url="$2"

    echo "Fetching $url.."
    if test -x "$(command -v curl)"; then
        response=$(curl -s -L -w 'HTTPSTATUS:%{http_code}' -H 'Accept: application/json' "$url")
        body=$(echo "$response" | sed -e 's/HTTPSTATUS\:.*//g')
        code=$(echo "$response" | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
    elif test -x "$(command -v wget)"; then
        temp=$(mktemp)
        body=$(wget -q --header='Accept: application/json' -O - --server-response "$url" 2> "$temp")
        code=$(awk '/^  HTTP/{print $2}' < "$temp" | tail -1)
        rm "$temp"
    else
        echo "Neither curl nor wget was available to perform http requests."
        exit 1
    fi
    if [ "$code" != 200 ]; then
        echo "Request failed with code $code"
        exit 1
    fi

    eval "$1='$body'"
}

downloadFile() {
    url="$1"
    destination="$2"

    echo "Fetching $url.."
    if test -x "$(command -v curl)"; then
        code=$(curl -s -w '%{http_code}' -L "$url" -o "$destination")
    elif test -x "$(command -v wget)"; then
        code=$(wget -q -O "$destination" --server-response "$url" 2>&1 | awk '/^  HTTP/{print $2}' | tail -1)
    else
        echo "Neither curl nor wget was available to perform http requests."
        exit 1
    fi

    if [ "$code" != 200 ]; then
        echo "Request failed with code $code"
        exit 1
    fi
}

if [ -z "$RELEASE_TAG" ]; then
    downloadJSON LATEST_RELEASE "$RELEASES_URL/latest"
    RELEASE_TAG=$(echo "${LATEST_RELEASE}" | tr -s '\n' ' ' | sed 's/.*"tag_name":"//' | sed 's/".*//' )
fi
echo "Release Tag = $RELEASE_TAG"

# fetch the real release data to make sure it exists before we attempt a download
downloadJSON RELEASE_DATA "$RELEASES_URL/tag/$RELEASE_TAG"

BINARY="balena-cli-$RELEASE_TAG-linux-x64-standalone.zip"
BINARY_URL="$RELEASES_URL/download/$RELEASE_TAG/$BINARY"
DOWNLOAD_FILE=$(mktemp)
downloadFile "$BINARY_URL" "$DOWNLOAD_FILE"

echo "Unzip file: $DOWNLOAD_FILE to $1"
unzip -qq $DOWNLOAD_FILE -d $1
