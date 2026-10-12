#!/usr/bin/env bash
# Smoke-tests a postgres tarball from a fresh directory (proves it's relocatable):
# initdb, start, and exercise icu, lz4 and openssl (via pgcrypto).
set -euo pipefail
tarball=$(cd "$(dirname "$1")" && pwd)/$(basename "$1")
dir=$(mktemp -d)
tar xzf "$tarball" -C "$dir"
pg=$(echo "$dir"/*)
"$pg/bin/initdb" -D "$dir/data" -U postgres -A trust >/dev/null
"$pg/bin/pg_ctl" -D "$dir/data" -l "$dir/log" -o "-p 54329" -w start || { cat "$dir/log"; exit 1; }
trap '"$pg/bin/pg_ctl" -D "$dir/data" -m fast stop' EXIT
"$pg/bin/psql" -h 127.0.0.1 -p 54329 -U postgres -v ON_ERROR_STOP=1 \
  -c 'select version()' \
  -c "create collation de (provider = icu, locale = 'de-DE')" \
  -c 'create table t (x text compression lz4)' \
  -c 'create extension pgcrypto' \
  -c "select encode(digest('byre', 'sha256'), 'hex')"
