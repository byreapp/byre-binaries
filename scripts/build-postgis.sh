#!/usr/bin/env bash
# PostGIS for the Extensions workflow ("build": "postgis" in extensions.json).
# Ships postgis + postgis_topology. No raster (GDAL alone is ~60 MB), sfcgal or
# address_standardizer.
#
#   install <src> <root> <major> <version>
#       Put PostGIS into the Postgres tree <root>; the workflow's lib +
#       share/extension snapshot packages what it added. Unix: built from <src>
#       against Homebrew/apt GEOS + PROJ. Windows: OSGeo's official bundle.
#   deps <out> <root>
#       Add what PostGIS links (Unix: into out/lib, relocated; Windows: out/bin,
#       which Byre copies next to postgres.exe) and PROJ's proj.db (out/share/proj:
#       PROJ looks in <dir of libproj>/../share/proj, i.e. Postgres' share/).
#   test <tarball> <pg.tgz>
#       Install the tarball into a fresh Postgres the way Byre does, create the
#       extensions and transform a point (needs proj.db from that location).
set -euo pipefail
cmd=$1
case "$(uname -s)" in MINGW*|MSYS*) os=windows ;; Darwin) os=macos ;; *) os=linux ;; esac
here=$(cd "$(dirname "$0")" && pwd)
bundle=$PWD/pgis-bundle

case $cmd in
install)
  src=$2 root=$3 m=$4 ver=$5
  if [ $os = windows ]; then
    rm -rf "$bundle" && mkdir "$bundle"
    curl -fsSL "https://download.osgeo.org/postgis/windows/pg$m/postgis-bundle-pg$m-${ver}x64.zip" -o pgis.zip
    unzip -q pgis.zip -d "$bundle"
    b=$(echo "$bundle"/*)
    cp "$b"/lib/postgis-3.dll "$b"/lib/postgis_topology-3.dll "$root/lib/"
    cp "$b"/share/extension/postgis.control "$b"/share/extension/postgis--*.sql \
      "$b"/share/extension/postgis_topology* "$root/share/extension/"
    exit 0
  fi
  build=$PWD/pgis-build
  rm -rf "$build" && cp -R "$src" "$build" && cd "$build" # fresh tree per major
  opts=(--with-pgconfig="$root/bin/pg_config" --without-raster --without-address-standardizer)
  mk=()
  if [ $os = macos ]; then
    export CC=clang
    # theseus' Intel build has NLS on: c.h includes libintl.h (not on the default path there).
    export CPPFLAGS="-I$(brew --prefix gettext)/include"
    opts+=(--with-geosconfig="$(brew --prefix geos)/bin/geos-config" --with-jsondir="$(brew --prefix json-c)"
      --with-protobufdir="$(brew --prefix protobuf-c)" --with-xml2config="$(brew --prefix libxml2)/bin/xml2-config")
    # PG_SYSROOT: theseus' pg_config names its CI's SDK. Header pad: room for
    # relocate-macos.sh's rewritten install names and rpath.
    mk=("PG_SYSROOT=$(xcrun --show-sdk-path)" "PG_LDFLAGS=-Wl,-headerpad_max_install_names")
  fi
  ./configure "${opts[@]}"
  # Man pages include raster2pgsql.1, which a no-raster build lacks; Byre doesn't need them.
  perl -pi -e 's/^install: comments-install man-install/install: comments-install/' doc/Makefile
  make -j4 "${mk[@]}"
  make install "${mk[@]}"
  ;;
deps)
  out=$2 root=$3
  mkdir -p "$out/share/proj"
  if [ $os = windows ]; then
    # Walk the import tables; take whatever the bundle has that Postgres doesn't.
    b=$(echo "$bundle"/*)
    mkdir -p "$out/bin"
    queue=("$out"/lib/*.dll)
    while [ ${#queue[@]} -gt 0 ]; do
      f=${queue[0]} queue=("${queue[@]:1}")
      for d in $(dumpbin -nologo -dependents "$f" | tr -d '\r' | awk '/\.dll$/ {print $1}'); do
        [ -f "$b/bin/$d" ] && [ ! -f "$out/bin/$d" ] && [ ! -f "$root/bin/$d" ] || continue
        cp "$b/bin/$d" "$out/bin/"
        queue+=("$out/bin/$d")
      done
    done
    cp "$b"/share/contrib/postgis-*/proj/proj.db "$out/share/proj/"
  else
    "$here/relocate-$os.sh" "$out"
    proj=/usr/share/proj; [ $os = macos ] && proj=$(brew --prefix proj)/share/proj
    cp "$proj/proj.db" "$out/share/proj/"
  fi
  ;;
test)
  tarball=$(cd "$(dirname "$2")" && pwd)/$(basename "$2") pgtgz=$3
  t=$(mktemp -d)
  mkdir "$t/pg" "$t/ext" && tar xzf "$pgtgz" -C "$t/pg" && tar xzf "$tarball" -C "$t/ext"
  root=$(cd "$(dirname "$(find "$t/pg" -path '*/bin/pg_config*' | head -1)")/.." && pwd)
  # What Byre's install does: lib, share/*, and bin/ files Postgres doesn't have.
  cp "$t"/ext/lib/* "$root/lib/" && cp -R "$t"/ext/share/* "$root/share/"
  if [ -d "$t/ext/bin" ]; then for f in "$t"/ext/bin/*; do [ -e "$root/bin/${f##*/}" ] || cp "$f" "$root/bin/"; done; fi
  # Hide the build machine's PROJ data, so only the shipped proj.db can satisfy it.
  [ $os = macos ] && mv "$(brew --prefix proj)/share/proj" "$t/proj-hidden"
  [ $os = linux ] && sudo mv /usr/share/proj "$t/proj-hidden"
  "$root/bin/initdb" -D "$t/data" -U postgres -A trust >/dev/null
  "$root/bin/pg_ctl" -D "$t/data" -o "-p 54329" -l "$t/log" -w start >/dev/null || { cat "$t/log"; exit 1; }
  trap '"$root/bin/pg_ctl" -D "$t/data" -m fast stop >/dev/null || true' EXIT
  "$root/bin/psql" -p 54329 -U postgres -v ON_ERROR_STOP=1 -Atc "create extension postgis; create extension postgis_topology;
    select postgis_full_version(); select ST_AsText(ST_Transform(ST_SetSRID(ST_Point(1, 1), 4326), 3857), 0);" | tr -d '\r' | tee "$t/q"
  grep -qx 'POINT(111319 111325)' "$t/q"
  [ $os = macos ] && mv "$t/proj-hidden" "$(brew --prefix proj)/share/proj"
  [ $os = linux ] && sudo mv "$t/proj-hidden" /usr/share/proj
  echo "postgis OK"
  ;;
esac
