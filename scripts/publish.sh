#!/usr/bin/env bash
# Publishes dist/<engine>-<version>-*.tar.gz (+ a .sha256 each) to the PRERELEASE
# <engine>-<version>, creating it if needed. Re-runs replace assets.
set -euo pipefail
engine=$1 version=$2
tag="$engine-$version"
cd dist
ls "$tag"-*.tar.gz >/dev/null 2>&1 || { echo "Nothing built for $tag"; exit 1; }
for f in "$tag"-*.tar.gz; do sha256sum "$f" > "$f.sha256"; done
gh release view "$tag" >/dev/null 2>&1 ||
  gh release create "$tag" --prerelease --latest=false --title "$engine $version (from source)" \
    --notes "$engine $version built from the official source by $GITHUB_SERVER_URL/$GITHUB_REPOSITORY/actions/runs/$GITHUB_RUN_ID. Not used by Byre yet."
gh release upload "$tag" "$tag"-*.tar.gz "$tag"-*.tar.gz.sha256 --clobber
