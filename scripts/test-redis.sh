#!/usr/bin/env bash
# Smoke-tests a redis/valkey tarball from a fresh directory: --version, start, PING.
set -euo pipefail
engine=$1 tarball=$(cd "$(dirname "$2")" && pwd)/$(basename "$2")
dir=$(mktemp -d)
tar xzf "$tarball" -C "$dir"
bin=$(echo "$dir"/*/bin)
"$bin/$engine-server" --version
"$bin/$engine-server" --port 63799 --daemonize yes --dir "$dir" --logfile "$dir/log"
trap '"$bin/$engine-cli" -p 63799 shutdown nosave || true' EXIT
for _ in $(seq 20); do "$bin/$engine-cli" -p 63799 ping 2>/dev/null | grep -q PONG && break; sleep 0.5; done
"$bin/$engine-cli" -p 63799 set byre ok
[ "$("$bin/$engine-cli" -p 63799 get byre)" = ok ] || { cat "$dir/log"; exit 1; }
echo "$engine OK"
