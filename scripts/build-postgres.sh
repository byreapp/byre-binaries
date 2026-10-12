#!/usr/bin/env bash
# Builds PostgreSQL <version> (catalog form, e.g. 18.6.0, or a beta like 19beta4) from the official
# source tarball into <prefix> and makes it relocatable. Layout matches theseus:
# bin/ lib/ share/ include/ (prefix contains "postgres", so no postgresql/ subdirs).
# Features: openssl, icu, lz4, zlib, uuid-ossp (not Windows), libedit (not Windows).
set -euo pipefail
version=$1 prefix=$2
here=$(cd "$(dirname "$0")" && pwd)
src_ver=${version%.*} # 18.6.0 -> 18.6; 19beta4 stays 19beta4
major=${version%%[.a-z]*}
rm -rf "$prefix" "$prefix-src" && mkdir -p "$prefix" "$prefix-src"
prefix=$(cd "$prefix" && pwd)
work="$prefix-src"
if [[ $(uname -s) == MINGW* && $major == 16 ]]; then
  # 16's tarball ships distprep output (gram.c, …), which meson refuses to build
  # over. 17+ tarballs don't, so only 16 on Windows builds from the git tag.
  git clone -q --depth 1 --branch "REL_${src_ver//./_}" https://github.com/postgres/postgres "$work"
else
  curl -fsSL "https://ftp.postgresql.org/pub/source/v$src_ver/postgresql-$src_ver.tar.bz2" | tar xj -C "$work" --strip-components=1
fi
cd "$work"

unix_build() {
  ./configure --prefix="$prefix" --with-openssl --with-icu --with-lz4 --with-uuid=e2fs \
    --with-libedit-preferred --without-ldap --with-pgport=5432 "$@"
  make -j"$(getconf _NPROCESSORS_ONLN)"
  make install
  make -C contrib -j"$(getconf _NPROCESSORS_ONLN)"
  make -C contrib install
  # The configure line asks; this proves we got it.
  for f in USE_ICU USE_LZ4 USE_OPENSSL HAVE_LIBZ; do grep -q "^#define $f 1" src/include/pg_config.h; done
}

case "$(uname -s)" in
  Darwin)
    [ -z "${CI:-}" ] || brew install icu4c openssl@3 lz4 pkgconf >/dev/null
    export PKG_CONFIG_PATH="$(brew --prefix icu4c)/lib/pkgconfig:$(brew --prefix openssl@3)/lib/pkgconfig:$(brew --prefix lz4)/lib/pkgconfig"
    export CPPFLAGS="-I$(brew --prefix openssl@3)/include -I$(brew --prefix lz4)/include"
    # Headerpad: room for relocate-macos.sh to rewrite load commands.
    export LDFLAGS="-L$(brew --prefix openssl@3)/lib -L$(brew --prefix lz4)/lib -Wl,-headerpad_max_install_names"
    unix_build
    "$here/relocate-macos.sh" "$prefix"
    ;;
  Linux)
    unix_build --disable-rpath
    "$here/relocate-linux.sh" "$prefix"
    ;;
  MINGW*|MSYS*)
    # Needs: MSVC dev env (ilammy/msvc-dev-cmd), vcpkg deps installed by the
    # workflow at $VCPKG_INSTALLED, meson+ninja, winflexbison on PATH.
    deps=$(cygpath -m "$VCPKG_INSTALLED")
    # Git's /usr/bin/link (coreutils) shadows MSVC's link.exe otherwise.
    export PATH="$(cygpath -u "$VCToolsInstallDir")/bin/Hostx64/x64:$PATH"
    if [ "$major" -ge 16 ]; then
      export PKG_CONFIG="$deps/tools/pkgconf/pkgconf.exe"
      export PKG_CONFIG_PATH="$deps/lib/pkgconfig;$deps/share/pkgconfig"
      meson setup build . --prefix "$(cygpath -m "$prefix")" --buildtype release \
        -Dauto_features=disabled -Dssl=openssl -Dicu=enabled -Dlz4=enabled -Dzlib=enabled \
        -Dreadline=disabled -Dextra_include_dirs="$deps/include" -Dextra_lib_dirs="$deps/lib"
      meson compile -C build
      meson install -C build
    else
      # 14/15 only have the old perl MSVC build; it expects the layout of the
      # standalone Windows installers, so stage vcpkg's files that way.
      legacy="$work/deps" && mkdir -p "$legacy/lib64"
      cp -R "$VCPKG_INSTALLED"/{include,lib,bin} "$legacy/"
      cp "$VCPKG_INSTALLED/tools/openssl/openssl.exe" "$legacy/bin/" # Solution.pm runs it for the version
      for z in zlib z; do [ -f "$VCPKG_INSTALLED/lib/$z.lib" ] && cp "$VCPKG_INSTALLED/lib/$z.lib" "$legacy/lib/zdll.lib" && break; done
      cp "$VCPKG_INSTALLED/lib/lz4.lib" "$legacy/lib/liblz4.lib"
      cp "$VCPKG_INSTALLED"/lib/{icuin,icuuc,icudt}.lib "$legacy/lib64/"
      l=$(cygpath -m "$legacy")
      cat > src/tools/msvc/config.pl <<EOF
our \$config = { asserts => 0, ldap => 0, icu => '$l', lz4 => '$l', openssl => '$l', zlib => '$l' };
1;
EOF
      echo '$ENV{MSBFLAGS}="/m"; 1;' > src/tools/msvc/buildenv.pl
      (cd src/tools/msvc && PATH="/c/Strawberry/perl/bin:$PATH" perl build.pl && PATH="/c/Strawberry/perl/bin:$PATH" perl install.pl "$(cygpath -m "$prefix")")
    fi
    # Windows looks next to the .exe for DLLs.
    cp "$VCPKG_INSTALLED"/bin/*.dll "$prefix/bin/"
    ;;
esac
cp COPYRIGHT "$prefix/"
echo "Built PostgreSQL $src_ver into $prefix"
