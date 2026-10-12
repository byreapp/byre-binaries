#!/usr/bin/env bash
# Builds MySQL <version> from the official source tarball (cdn.mysql.com, boost
# is bundled in extra/ since 8.3) into <prefix> and makes it relocatable.
# Everything but OpenSSL is MySQL's bundled copy; Router, NDB, tests, LDAP,
# Kerberos and FIDO auth are left out.
set -euo pipefail
version=$1 prefix=$2
here=$(cd "$(dirname "$0")" && pwd)
rm -rf "$prefix" "$prefix-src" && mkdir -p "$prefix" "$prefix-src"
prefix=$(cd "$prefix" && pwd)
src="$prefix-src"
curl -fsSL "https://cdn.mysql.com/Downloads/MySQL-${version%.*}/mysql-$version.tar.gz" | tar xz -C "$src" --strip-components=1

opts=(
  -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$prefix"
  -DWITH_ZLIB=bundled -DWITH_ZSTD=bundled -DWITH_LZ4=bundled -DWITH_EDITLINE=bundled
  -DWITH_PROTOBUF=bundled -DWITH_FIDO=none -DWITH_ROUTER=OFF -DWITH_NDB=OFF
  -DWITH_UNIT_TESTS=OFF -DINSTALL_MYSQLTESTDIR= -DWITH_AUTHENTICATION_LDAP=OFF
  -DWITH_AUTHENTICATION_KERBEROS=OFF -DWITH_AUTHENTICATION_FIDO=OFF
)
case "$(uname -s)" in
  Darwin)
    # A path (not "system") makes MySQL copy openssl into lib/ itself.
    opts+=(-DWITH_SSL="$(brew --prefix openssl@3)" -DCMAKE_EXE_LINKER_FLAGS=-Wl,-headerpad_max_install_names
      -DCMAKE_SHARED_LINKER_FLAGS=-Wl,-headerpad_max_install_names -DCMAKE_MODULE_LINKER_FLAGS=-Wl,-headerpad_max_install_names) ;;
  Linux) opts+=(-DWITH_SSL=system) ;;
esac
cmake -S "$src" -B "$src/build" "${opts[@]}"
cmake --build "$src/build"
cmake --install "$src/build"
rm -rf "$src" # frees ~10 GB before packaging
case "$(uname -s)" in
  Darwin) "$here/relocate-macos.sh" "$prefix" ;;
  Linux) "$here/relocate-linux.sh" "$prefix" ;;
esac
