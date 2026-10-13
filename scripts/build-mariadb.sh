#!/usr/bin/env bash
# Builds MariaDB <version> from the official source tarball (archive.mariadb.org)
# into <prefix> and makes it relocatable. SSL, PCRE2, zlib and fmt are MariaDB's
# bundled copies (WolfSSL for TLS), so no system OpenSSL; storage engines and
# plugins that pull in extra deps (RocksDB, Mroonga, ColumnStore, Spider,
# CONNECT, S3, Galera, GSSAPI, HashiCorp) are left out.
set -euo pipefail
version=$1 prefix=$2
here=$(cd "$(dirname "$0")" && pwd)
rm -rf "$prefix" "$prefix-src" && mkdir -p "$prefix" "$prefix-src"
prefix=$(cd "$prefix" && pwd)
src="$prefix-src"
# Short source path on Windows: the build tree's paths pass MAX_PATH (260) otherwise.
[[ $(uname -s) == MINGW* ]] && src=/d/m && rm -rf "$src" && mkdir -p "$src"
curl -fsSL "https://archive.mariadb.org/mariadb-$version/source/mariadb-$version.tar.gz" | tar xz -C "$src" --strip-components=1

opts=(
  -G Ninja -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_INSTALL_PREFIX="$prefix"
  -DWITH_SSL=bundled -DWITH_PCRE=bundled -DWITH_ZLIB=bundled -DWITH_LIBFMT=bundled
  -DWITH_UNIT_TESTS=OFF -DINSTALL_MYSQLTESTDIR= -DINSTALL_SQLBENCHDIR= -DWITH_EMBEDDED_SERVER=OFF
  -DWITH_WSREP=OFF -DPLUGIN_ROCKSDB=NO -DPLUGIN_MROONGA=NO -DPLUGIN_COLUMNSTORE=NO
  -DPLUGIN_SPIDER=NO -DPLUGIN_CONNECT=NO -DPLUGIN_S3=NO -DPLUGIN_AUTH_GSSAPI=NO
  -DPLUGIN_AUTH_GSSAPI_CLIENT=OFF -DPLUGIN_HASHICORP_KEY_MANAGEMENT=NO -DPLUGIN_OQGRAPH=NO
)
case "$(uname -s)" in
  Darwin)
    opts+=(-DCMAKE_EXE_LINKER_FLAGS=-Wl,-headerpad_max_install_names
      -DCMAKE_SHARED_LINKER_FLAGS=-Wl,-headerpad_max_install_names -DCMAKE_MODULE_LINKER_FLAGS=-Wl,-headerpad_max_install_names) ;;
  MINGW*)
    # Needs: MSVC dev env, ninja and winflexbison on PATH (see mariadb.yml).
    # Git's coreutils `link` would shadow MSVC's.
    export PATH="$(cygpath -u "$VCToolsInstallDir")/bin/Hostx64/x64:$PATH"
    opts+=(-DCMAKE_INSTALL_PREFIX="$(cygpath -m "$prefix")" -DBISON_EXECUTABLE="$(cygpath -m "$(command -v win_bison.exe)")"
      -DCMAKE_C_COMPILER=cl -DCMAKE_CXX_COMPILER=cl) ;;
esac
cmake -S "$src" -B "$src/build" "${opts[@]}"
cmake --build "$src/build"
cmake --install "$src/build" --strip
rm -rf "$src" # frees the build tree before packaging
case "$(uname -s)" in
  Darwin) "$here/relocate-macos.sh" "$prefix" ;;
  Linux) "$here/relocate-linux.sh" "$prefix" ;;
esac
