#!/usr/bin/env bash
# Smoke-tests a mysql tarball from a fresh directory: --initialize-insecure,
# start, select version().
set -euo pipefail
tarball=$(cd "$(dirname "$1")" && pwd)/$(basename "$1")
dir=$(mktemp -d)
tar xzf "$tarball" -C "$dir"
my=$(echo "$dir"/mysql-*)
sock=/tmp/byre-mysql-test.sock # macOS caps socket paths at 104 chars
"$my/bin/mysqld" --no-defaults --basedir="$my" --datadir="$dir/data" --initialize-insecure
"$my/bin/mysqld" --no-defaults --basedir="$my" --datadir="$dir/data" --port=33069 \
  --socket="$sock" --mysqlx=OFF --log-error="$dir/err.log" &
trap '"$my/bin/mysqladmin" -uroot -h127.0.0.1 -P33069 shutdown || true' EXIT
for _ in $(seq 60); do "$my/bin/mysqladmin" -uroot -h127.0.0.1 -P33069 ping >/dev/null 2>&1 && break; sleep 1; done
"$my/bin/mysql" -uroot -h127.0.0.1 -P33069 -e 'select version()' || { cat "$dir/err.log"; exit 1; }
