#!/usr/bin/env bash
# Smoke-tests a redis/valkey tarball from a fresh directory: --version, start, PING.
set -euo pipefail
engine=$1 tarball=$(cd "$(dirname "$2")" && pwd)/$(basename "$2")
dir=$(mktemp -d)
tar xzf "$tarball" -C "$dir"
bin=$(echo "$dir"/*/bin)
# Windows: launch through cmd, like Byre does (a native parent). Since msys2-runtime
# 3.6.12 an .exe with its bundled msys-2.0.dll exits 127 when started from MSYS bash.
run() { if [[ $(uname -s) == MSYS* ]]; then cmd //c "$(cygpath -w "$1")" "${@:2}"; else "$@"; fi; }
run "$bin/$engine-server" --version
run "$bin/$engine-server" --port 63799 --daemonize yes --dir "$dir" --logfile "$dir/log"
trap 'run "$bin/$engine-cli" -p 63799 shutdown nosave || true' EXIT
for _ in $(seq 20); do run "$bin/$engine-cli" -p 63799 ping 2>/dev/null | grep -q PONG && break; sleep 0.5; done
run "$bin/$engine-cli" -p 63799 set byre ok
[ "$(run "$bin/$engine-cli" -p 63799 get byre | tr -d '\r')" = ok ] || { cat "$dir/log"; exit 1; }
echo "$engine OK"
