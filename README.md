# byre-binaries

From-source builds of the database servers [Byre](https://byre.app) runs, so
Byre can eventually ship binaries it built itself instead of downloading
third-party ones.

**Byre does not use these yet.** The app still downloads Postgres from
[theseus-rs/postgresql-binaries](https://github.com/theseus-rs/postgresql-binaries)
and MySQL/MongoDB from the vendors' CDNs (see `src-tauri/catalog.json` in the
private byreapp/byre repo). Nothing here changes the app or its catalog.

## What's built

`versions.json` lists, per engine, the versions to build and the platforms each
engine supports. Postgres/MySQL/MongoDB versions mirror the catalog's `exact`
values; Redis and Valkey are the latest stable releases.

| Engine | Source | Platforms | Workflow |
|---|---|---|---|
| postgres | ftp.postgresql.org tarball | macos-arm64, macos-x64, linux-x64, linux-arm64, windows-x64 | `postgres.yml` |
| redis | download.redis.io tarball | macOS + Linux (no native Windows) | `redis.yml` |
| valkey | GitHub source archive | macOS + Linux | `redis.yml` |
| mysql | cdn.mysql.com source tarball (boost bundled) | macOS + Linux (no Windows yet) | `mysql.yml` |
| mongodb-tools | mongodb/mongo-tools tag | all five (Go cross-compile, CGO off) | `mongodb-tools.yml` |
| mongodb | mongodb/mongo `r<version>` tag | linux-x64, **manual, large runner** | `mongodb.yml` |

Each version is published as a **prerelease** tagged `<engine>-<version>` with
assets `<engine>-<version>-<triple>.tar.gz` and a matching `.sha256`. Triples:
`aarch64-apple-darwin`, `x86_64-apple-darwin`, `x86_64-unknown-linux-gnu`,
`aarch64-unknown-linux-gnu`, `x86_64-pc-windows-msvc`. Every tarball holds one
top-level directory `<engine>-<version>-<triple>/`.

### Postgres

- Layout matches theseus: `bin/ lib/ share/ include/` (extensions in `lib/`,
  `share/extension/`), plus all of `contrib/`.
- Built with OpenSSL, ICU, LZ4, zlib, and (macOS/Linux) uuid-ossp + libedit.
  Windows: no readline, no uuid-ossp. Not included: LLVM JIT, zstd, libxml,
  PL/Python, LDAP, GSSAPI.
- Autoconf on macOS/Linux; meson (16+) or the legacy perl MSVC build (14/15)
  on Windows, with dependencies from vcpkg.
- Relocatable: `scripts/relocate-macos.sh` copies non-system dylibs (Homebrew
  openssl/icu/lz4) into `lib/`, rewrites them to `@rpath/…` with rpath
  `@loader_path/../lib`; `scripts/relocate-linux.sh` bundles everything outside
  glibc/libgcc/libstdc++ (openssl, icu, lz4, libedit, …) and sets RUNPATH
  `$ORIGIN/../lib`. Both **fail the build** if any `/opt/homebrew`,
  `/usr/local` or build-path reference survives (checked with `otool -L` /
  `ldd`). On Windows the vcpkg DLLs sit next to the `.exe`s.
- Smoke test runs from a freshly extracted copy: `initdb`, `pg_ctl start`,
  `psql -c 'select version()'`, an ICU collation, an LZ4 column and pgcrypto
  (OpenSSL).
- macOS builds link Homebrew bottles, so they need the runner's macOS version
  or newer.

### Redis / Valkey

Core server only (`make -C src`): no TLS, and none of Redis 8's bundled modules
(search, JSON, time series, bloom — they need Rust and GNU make 4). Smoke test:
`<engine>-server --version`, start, `PING`/`SET`/`GET`.

### MySQL

CMake + Ninja with MySQL's bundled zlib/zstd/lz4/editline/protobuf/ICU/boost and
OpenSSL from the system (Linux, bundled into `lib/` by the relocate script) or
Homebrew (macOS, copied by MySQL's own `WITH_SSL=<path>` logic). Router, NDB,
unit tests, LDAP/Kerberos/FIDO auth are off. About 1–2 h per platform. Smoke test:
`mysqld --initialize-insecure`, start, `select version()`. Windows isn't built.

### MongoDB

`mongodb.yml` exists but isn't run. A from-source `mongod` + `mongos` build is
many hours of C++ (SCons for 7.0, Bazel for 8.0+). On the standard
4-vCPU / 16 GB / ~14 GB-free-disk runner it likely won't finish inside the 6 h
job limit and can run out of disk or RAM. To run it you need a GitHub
**larger runner** (16+ cores, 64 GB RAM, 100+ GB disk), which costs money even
on public repos. Create one for the org and pass its label as the `runner`
input. Only linux-x64 is wired up. The Database Tools (`mongodump` etc.) are
plain Go and do get built (`mongodb-tools.yml`).

## Running

Actions → pick the workflow → **Run workflow**. `version` (and `engine` for
Redis + Valkey) defaults to `all`, which builds every version in
`versions.json` that isn't fully published yet (any platform tarball missing).
A specific version rebuilds just that one, replacing its assets. One platform
failing doesn't stop the others from publishing.

To add a version: append it to `versions.json` and run the workflow with `all`.

Everything runs here, not in the private byreapp/byre repo, because public
repos get free Actions minutes (macOS and Windows included). Releases use
`GITHUB_TOKEN` (`contents: write`); no secrets.

## Backup sources

If an official download is down, byreapp mirrors the upstream sources:
[postgres](https://github.com/byreapp/postgres),
[mysql-server](https://github.com/byreapp/mysql-server),
[mongo](https://github.com/byreapp/mongo),
[mongo-tools](https://github.com/byreapp/mongo-tools),
[redis](https://github.com/byreapp/redis),
[valkey](https://github.com/byreapp/valkey),
[KeyDB](https://github.com/byreapp/KeyDB),
and [postgresql-binaries](https://github.com/byreapp/postgresql-binaries)
(the theseus fork). Swap the download URL in the matching `scripts/build-*.sh`
(or workflow) for the fork's tag archive.

## Files

- `versions.json`: what to build
- `scripts/plan.sh`: picks versions to build (skips fully published ones)
- `scripts/build-*.sh`, `scripts/test-*.sh`: per-engine build and smoke test,
  runnable locally (`scripts/build-postgres.sh 18.6.0 out/postgres-18.6.0-x`)
- `scripts/relocate-{macos,linux}.sh`: bundle libs, fix rpaths, fail on leaks
- `scripts/publish.sh`: creates the prerelease and uploads tarballs + checksums
