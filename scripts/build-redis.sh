#!/usr/bin/env bash
# Builds redis or valkey <version> from the official source into <prefix>/bin.
# No TLS and no Redis 8 modules (they need Rust and more); plain `make`.
set -euo pipefail
engine=$1 version=$2 prefix=$3
here=$(cd "$(dirname "$0")" && pwd)
rm -rf "$prefix" "$prefix-src" && mkdir -p "$prefix" "$prefix-src"
prefix=$(cd "$prefix" && pwd)
case "$engine" in
  redis) url="https://download.redis.io/releases/redis-$version.tar.gz" ;;
  valkey) url="https://github.com/valkey-io/valkey/archive/refs/tags/$version.tar.gz" ;;
esac
curl -fsSL "$url" | tar xz -C "$prefix-src" --strip-components=1
cd "$prefix-src"
make -j"$(getconf _NPROCESSORS_ONLN)"
make install PREFIX="$prefix"
cp COPYING LICENSE* "$prefix/" 2>/dev/null || true
case "$(uname -s)" in
  Darwin) "$here/relocate-macos.sh" "$prefix" ;;
  Linux) "$here/relocate-linux.sh" "$prefix" ;;
esac
