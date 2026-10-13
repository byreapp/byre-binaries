#!/usr/bin/env bash
# Smoke-tests a mariadb tarball from a fresh directory: install-db, start,
# select version().
set -euo pipefail
tarball=$(cd "$(dirname "$1")" && pwd)/$(basename "$1")
dir=$(mktemp -d)
command -v cygpath >/dev/null && dir=$(cygpath -m "$dir") # native mariadbd on Windows
tar xzf "$tarball" -C "$dir"
my=$(echo "$dir"/mariadb-*)
if [ -f "$my/bin/mariadb-install-db.exe" ]; then
  "$my/bin/mariadb-install-db.exe" --datadir="$dir/data"
else
  # root gets a normal (empty) password over TCP instead of unix_socket auth.
  "$my/scripts/mariadb-install-db" --no-defaults --basedir="$my" --datadir="$dir/data" \
    --auth-root-authentication-method=normal
fi
sock=/tmp/byre-mariadb-test.sock # macOS caps socket paths at 104 chars
"$my/bin/mariadbd" --no-defaults --basedir="$my" --datadir="$dir/data" --port=33070 \
  --socket="$sock" --log-error="$dir/err.log" &
trap '"$my/bin/mariadb-admin" -uroot -h127.0.0.1 -P33070 shutdown || true' EXIT
for _ in $(seq 60); do "$my/bin/mariadb-admin" -uroot -h127.0.0.1 -P33070 ping >/dev/null 2>&1 && break; sleep 1; done
"$my/bin/mariadb" -uroot -h127.0.0.1 -P33070 -e 'select version()' || { cat "$dir/err.log"; exit 1; }
