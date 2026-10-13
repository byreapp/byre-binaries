#!/usr/bin/env bash
# Builds redis or valkey <version> from the official source into <prefix>/bin.
# No TLS and no Redis 8 modules. Windows: run inside MSYS2 (gcc, make).
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
# Windows: an MSYS2 (Cygwin-style POSIX) build; its dlfcn.h hides Dl_info,
# which debug.c uses, unless __GNU_VISIBLE.
[[ $(uname -s) == MSYS* ]] && sed -i 's/__GNU_VISIBLE/1/' /usr/include/dlfcn.h
# src/ directly: Redis 8's top-level `make` also builds the modules (search,
# json, …), which need Rust and GNU make 4.
make -C src -j"$(getconf _NPROCESSORS_ONLN)"
make -C src install PREFIX="$prefix"
cp COPYING LICENSE* "$prefix/" 2>/dev/null || true
case "$(uname -s)" in
  Darwin) "$here/relocate-macos.sh" "$prefix" ;;
  Linux) "$here/relocate-linux.sh" "$prefix" ;;
  # The POSIX layer (msys-2.0.dll, …) ships next to the .exe.
  MSYS*) ldd "$prefix"/bin/*.exe | awk '$3 ~ /^\/usr\/bin\// {print $3}' | sort -u | xargs -r cp -t "$prefix/bin/" ;;
esac
