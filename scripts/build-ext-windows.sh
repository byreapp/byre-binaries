#!/usr/bin/env bash
# Builds a PGXS extension with MSVC and installs it into a Postgres root, like
# `make install` does elsewhere. Windows Postgres has no working PGXS, so the
# extension's Makefile is read with GNU make against a stub (pgxs-vars.mk) for
# MODULE_big/MODULES/OBJS/DATA, then compiled with cl and linked with link.
#   build-ext-windows.sh <extension source dir> <postgres root>
# Needs: MSVC dev env (ilammy/msvc-dev-cmd), GNU make on PATH.
# Options are written -x, not /x: Git Bash rewrites "/x" into a path.
set -euo pipefail
# Paths below are already Windows-style; MSYS would split "-FoD:/a/…" at the colon.
export MSYS_NO_PATHCONV=1
src=$(cygpath -m "$1") root=$(cygpath -m "$2")
here=$(cygpath -m "$(cd "$(dirname "$0")" && pwd)")
shim=$(cygpath -m "$(mktemp -d)")
# pg_config that answers --pgxs with the stub and forwards everything else
# (pg_partman's Makefile checks --version).
printf '#!/bin/sh\n[ "$1" = --pgxs ] && { echo "%s"; exit 0; }\nexec "%s" "$@"\n' \
  "$(cygpath -m "$here/pgxs-vars.mk")" "$root/bin/pg_config.exe" > "$shim/pg_config"
chmod +x "$shim/pg_config"
# USE_PGXS=1: Makefiles that also build in-tree (pgaudit) only use PGXS when it is set.
mk() { make -s -C "$src" PG_CONFIG="$shim/pg_config" USE_PGXS=1 "$@"; }

vars=$(mk byre-vars | tr -d '\r')
var() { sed -n "s/^$1=//p" <<<"$vars"; }
read -ra objs <<<"$(var OBJS)"
read -ra modules <<<"$(var MODULES)"
read -ra exts <<<"$(var EXTENSION)"
read -ra data <<<"$(var DATA)"
big=$(var MODULE_big)

w=$(cygpath -m "$root")
cflags=(-nologo -O2 -MD -fp:fast -I"$w/include/server/port/win32_msvc" -I"$w/include/server/port/win32"
  -I"$w/include/server" -I"$w/include" -I"$(cygpath -m "$src")" -FI"$(cygpath -m "$here/msvc-compat.h")")
# eval: PG_CPPFLAGS is shell-quoted (pgaudit: -DPGAUDIT_VERSION="\"19.0\"").
eval "cppflags=($(var PG_CPPFLAGS))"
rm -f "$src/byre-defs.h"
for f in "${cppflags[@]}"; do
  case $f in
    -I?*) cflags+=(-I"$(cygpath -m "$src/${f#-I}")") ;;
    # Into a header: quoted values don't survive MSYS -> cl command-line quoting.
    # Windows make hands the quoting over raw (\"19.0\"): strip it, re-quote strings.
    -D?*) d=${f#-D}; [[ $d == *=* ]] || d="$d=1"; v=${d#*=}; q=${v//[\\\"]/}
          [ "$q" = "$v" ] || q="\"$q\""
          printf '#define %s %s\n' "${d%%=*}" "$q" >> "$src/byre-defs.h" ;;
  esac
done
[ -f "$src/byre-defs.h" ] && cflags+=(-FI"$(cygpath -m "$src/byre-defs.h")")
# Our own PG 19+ builds use OpenSSL but don't ship its headers (theseus' do); libpq-be.h
# (pgaudit) includes them. The runner's OpenSSL 3 headers match well enough.
ossl="C:/Program Files/OpenSSL/include"
[ -f "$root/include/openssl/ssl.h" ] || [ ! -d "$ossl" ] || cflags+=(-I"$ossl")
# Same rule as pgvector's Makefile.win: 18+ headers need C11 (and its conforming
# preprocessor, for PG_MODULE_MAGIC_DATA's __VA_ARGS__).
pgnum=$(sed -n 's/^#define PG_VERSION_NUM //p' "$root/include/server/pg_config.h" | tr -d '\r')
[ "$pgnum" -ge 180000 ] && cflags+=(-std:c11)
# MSVC has no ssize_t; code that skips postgres.h (pg_hashids) uses it bare.
cflags+=(-Dssize_t=intptr_t)
# Git's coreutils `link` would shadow MSVC's.
msvc="$(cygpath -u "$VCToolsInstallDir")/bin/Hostx64/x64"

# dll <name> <source.c>...: compile, then export every external function, as
# Postgres' own MSVC build does (gendef): _PG_init and bgworker entry points
# aren't PGDLLEXPORT in every major.
dll() {
  local name=$1 o objs=() ; shift
  for c in "$@"; do
    o="${c%.c}.obj"
    # Scanners PGXS would generate with flex (pg_hint_plan's query_scan.c).
    [ -f "$src/$c" ] || [ ! -f "$src/${c%.c}.l" ] || win_flex -o "$src/$c" "$src/${c%.c}.l"
    "$msvc/cl.exe" "${cflags[@]}" -c "$(cygpath -m "$src/$c")" -Fo"$(cygpath -m "$src/$o")"
    objs+=("$(cygpath -m "$src/$o")")
  done
  { echo EXPORTS; "$msvc/dumpbin.exe" -nologo -symbols "${objs[@]}" | tr -d '\r' |
      awk '/SECT/ && /\(\)/ && /External/ {print $NF}' | grep -v '^[?_]_' | sort -u; } > "$src/$name.def"
  "$msvc/link.exe" -nologo -DLL -OUT:"$(cygpath -m "$root/lib/$name.dll")" -DEF:"$(cygpath -m "$src/$name.def")" \
    "${objs[@]}" "$w/lib/postgres.lib" "$w/lib/libpq.lib"
}

if [ -n "$big" ]; then
  srcs=() && for o in "${objs[@]}"; do srcs+=("${o%.o}.c"); done
  dll "$big" "${srcs[@]}"
fi
for m in "${modules[@]}"; do dll "$(basename "$m")" "$m.c"; done

mkdir -p "$root/share/extension"
for f in "${data[@]}"; do
  [ -f "$src/$f" ] || mk "$f" # DATA_built and generated scripts (pg_cron, pg_partman)
  cp "$src/$f" "$root/share/extension/"
done
for e in "${exts[@]}"; do cp "$src/$e.control" "$root/share/extension/"; done
