<p align="center">
  <img src=".github/assets/icon.png" width="128" height="128" alt="Byre logo">
</p>

<h1 align="center">byre-binaries</h1>

<p align="center">
  Database server binaries for <a href="https://byre.app">Byre</a>, built from source on GitHub Actions.
</p>

This repo builds the database servers and Postgres extensions Byre runs, and
publishes each one as a GitHub prerelease. All of it is built from upstream
source. The one exception is the Postgres mirror, which copies the
[theseus-rs](https://github.com/theseus-rs/postgresql-binaries) builds Byre
downloads today.

Byre downloads its Postgres extensions (`ext-*`) from here. **The from-source
server builds** (`postgres-*`, `mysql-*`, `redis-*`, `valkey-*`, `mongodb-*`,
`mongodb-tools-*`) **aren't used by the app yet.**

The app itself (installers, updater `latest.json`, changelog, app issues) lives
in [byreapp/byre-releases](https://github.com/byreapp/byre-releases). That repo
holds only the app. Every database binary is published here.

## What's built

| Workflow | What it builds | Tags |
|---|---|---|
| `postgres.yml` | PostgreSQL from the ftp.postgresql.org tarball | `postgres-<version>` |
| `postgres-mirror.yml` | Checksum-verified copy of the theseus-rs Postgres builds Byre downloads | `pg-<version>` |
| `extensions.yml` | Postgres extensions listed in `extensions.json`, compiled against the theseus build for each major | `ext-<name>-<version>` |
| `mysql.yml` | MySQL from the cdn.mysql.com source tarball | `mysql-<version>` |
| `redis.yml` | Redis (download.redis.io) and Valkey (GitHub archive) | `redis-<version>`, `valkey-<version>` |
| `mongodb.yml` | MongoDB server from the mongodb/mongo `r<version>` tag (manual, needs a larger runner) | `mongodb-<version>` |
| `mongodb-tools.yml` | MongoDB Database Tools (`mongodump` and the rest), Go cross-compile | `mongodb-tools-<version>` |

### Versions and platforms

From `versions.json`. To regenerate the table, run
`jq -r 'to_entries[]|"| \(.key) | \(.value.versions|join(", ")) | \(.value.platforms|join(", ")) |"' versions.json`.

| Engine | Versions | Platforms |
|---|---|---|
| postgres | 19beta4, 18.6.0, 17.11.0, 16.15.0, 15.19.0, 14.24.0 | macos-arm64, macos-x64, linux-x64, linux-arm64, windows-x64 |
| mysql | 26.7.0, 9.7.2, 9.5.0, 8.4.11 | macos-arm64, macos-x64, linux-x64, linux-arm64 |
| redis | 8.10.2 | macos-arm64, macos-x64, linux-x64, linux-arm64 |
| valkey | 9.1.2 | macos-arm64, macos-x64, linux-x64, linux-arm64 |
| mongodb | 9.1.0-alpha0, 8.0.32, 7.0.43 | linux-x64 |
| mongodb-tools | 100.19.1 | macos-arm64, macos-x64, linux-x64, linux-arm64, windows-x64 |

Notes on the table:

- `19beta4` and `9.1.0-alpha0` are upstream pre-releases. Their release
  titles and notes say so.
- The mirror covers only the numeric Postgres versions, because theseus
  doesn't publish betas.
- Extension versions and their Postgres majors are listed in `extensions.json`.

**Platform triples:**

| Platform | Triple | Runner |
|---|---|---|
| macos-arm64 | `aarch64-apple-darwin` | `macos-latest` |
| macos-x64 | `x86_64-apple-darwin` | `macos-15-intel` |
| linux-x64 | `x86_64-unknown-linux-gnu` | `ubuntu-22.04` |
| linux-arm64 | `aarch64-unknown-linux-gnu` | `ubuntu-22.04-arm` |
| windows-x64 | `x86_64-pc-windows-msvc` | `windows-latest` |

The Linux builds use Ubuntu 22.04, so they run on glibc 2.35 or newer. The macOS
builds link Homebrew bottles, so they need the runner's macOS version or newer.

## Releases and tags

Everything is published as a **prerelease**, so nothing here becomes the
repo's `latest`.

- **From-source builds:** tag `<engine>-<version>`. Each asset is
  `<engine>-<version>-<triple>.tar.gz` with a matching `.sha256`. Each tarball
  holds a single top-level directory, `<engine>-<version>-<triple>/`, containing
  `bin/ lib/ share/ …`.
- **Postgres mirror:** tag `pg-<version>`. It keeps theseus' asset names,
  `postgresql-<version>-<triple>.tar.gz` and `.sha256`.
- **Extensions:** tag `ext-<name>-<version>`. There is one tarball per Postgres
  major and platform, laid out as `lib/…` and `share/extension/…`, ready to
  unpack over a Postgres install.

## Engine notes

### Postgres

- **Layout** matches theseus: `bin/ lib/ share/ include/`. Extensions go in
  `lib/` and `share/extension/`. All of `contrib/` is included.
- **Libraries:**
  - Built with OpenSSL, ICU, LZ4 and zlib.
  - On macOS and Linux, also built with uuid-ossp and libedit.
  - On Windows there is no readline and no uuid-ossp.
  - Not included on any platform: LLVM JIT, zstd, libxml, PL/Python, LDAP, GSSAPI.
- **Build systems:**
  - macOS and Linux: autoconf.
  - Windows 16 and later: meson.
  - Windows 14 and 15: the legacy perl MSVC build.
  - Windows dependencies come from vcpkg.
- **Relocatable builds:**
  - `scripts/relocate-macos.sh` bundles the Homebrew dylibs into `lib/` and
    rewrites them to `@rpath`, with rpath `@loader_path/…`.
  - `scripts/relocate-linux.sh` bundles everything outside glibc, libgcc and
    libstdc++, and sets RUNPATH to `$ORIGIN/…`.
  - Both scripts fail the build if any absolute path survives. They check with
    `otool -L` and `ldd`.
  - On Windows, the DLLs sit next to the `.exe` files.
- **Smoke test,** run on a freshly extracted copy:
  - `initdb`, then `pg_ctl start`.
  - `psql` running `select version()`.
  - An ICU collation, an LZ4 column, and pgcrypto (which uses OpenSSL).

### Extensions

`extensions.json` mirrors the `extensions` list and the Postgres `exact`
versions from `src-tauri/catalog.json` in byreapp/byre. Bump both files
together. Each extension is built against the exact theseus build Byre
downloads for that major, so the ABI always matches.

### MySQL

- **Build:** CMake with Ninja.
- **Libraries:**
  - Bundled from MySQL's own source tree: zlib, zstd, lz4, editline, protobuf, ICU and boost.
  - OpenSSL comes from the system on Linux, bundled into `lib/`, and from
    Homebrew on macOS.
- **Turned off:** Router, NDB, unit tests, and LDAP, Kerberos and FIDO auth.
- **Build time:** roughly 1 to 2 hours per platform.
- **Not built for Windows.**
- **Smoke test:** `mysqld --initialize-insecure`, start the server, then `select version()`.

### Redis and Valkey

- **Build:** core server only (`make -C src`).
- **Not included:** TLS, and Redis 8's bundled modules (search, JSON, time
  series and bloom need Rust and GNU make 4).
- **Not built for Windows,** because upstream has no native Windows build.
- **Smoke test:** `--version`, start the server, then `PING`, `SET` and `GET`.

### MongoDB

`mongodb.yml` is manual and isn't run routinely.

- **Why:** a from-source `mongod` and `mongos` build is many hours of C++:
  SCons for 7.0, Bazel for 8.0 and later. On the standard runner it would
  likely hit the 6-hour job limit and can run out of disk or RAM.
- **Runner:** run it on a GitHub larger runner (16+ cores, 64 GB RAM, 100+ GB
  disk) by passing that runner's label as `runner`. Larger runners cost money,
  even on public repos.
- **Platforms:** only linux-x64 is wired up.
- **Database Tools:** `mongodb-tools.yml` builds them on every platform. They
  are plain Go and build in a few minutes.

## Running a workflow

Go to **Actions**, pick the workflow, then click **Run workflow**. Every run
uses `GITHUB_TOKEN` (`contents: write`) and needs no secrets.

| Workflow | Inputs |
|---|---|
| Postgres, MySQL | `version`: `all` (default) or a version from `versions.json` |
| Redis + Valkey | `engine`: `all`, `redis` or `valkey`; `version`: `all` or a version |
| MongoDB tools | `version`: `all` or a version |
| MongoDB | `version` (required); `runner`: a larger-runner label |
| Postgres mirror | none (mirrors every numeric `postgres.versions` entry that isn't mirrored yet) |
| Extensions | `name`: `all` or an extension name from `extensions.json` |

- **`all`** builds only what isn't fully published. For the from-source
  workflows, that is any version still missing a platform tarball.
- **A specific version** rebuilds just that version and replaces its assets.
- **A failing platform** doesn't stop the others from publishing.

From the CLI:

```sh
gh workflow run postgres.yml -R byreapp/byre-binaries -f version=18.6.0
gh workflow run redis.yml -R byreapp/byre-binaries -f engine=valkey -f version=all
```

To add a version, add it to `versions.json` (or `extensions.json`), then run the
workflow with `all`.

All builds run in this public repo because public repos get free Actions
minutes, macOS and Windows included. Don't run them in the private
byreapp/byre repo.

You can also run the build scripts locally on macOS or Linux, for example
`scripts/build-postgres.sh 18.6.0 out/postgres-18.6.0-local`, then
`scripts/test-postgres.sh <tarball>`.

## Backup sources

The byreapp org keeps forks of every upstream, in case an official download
goes away:

- [postgres](https://github.com/byreapp/postgres)
- [mysql-server](https://github.com/byreapp/mysql-server)
- [mongo](https://github.com/byreapp/mongo)
- [mongo-tools](https://github.com/byreapp/mongo-tools)
- [redis](https://github.com/byreapp/redis)
- [valkey](https://github.com/byreapp/valkey)
- [KeyDB](https://github.com/byreapp/KeyDB)
- [postgresql-binaries](https://github.com/byreapp/postgresql-binaries), the theseus fork

If an official download goes away, point the download URL in the matching
`scripts/build-*.sh` (or workflow) at the fork's tag archive.

## Files

- `versions.json`: the engines, versions and platforms to build.
- `extensions.json`: the Postgres extensions to build. Keep it in sync with
  byre's `catalog.json`.
- `scripts/plan.sh`: picks which versions to build, skipping fully published ones.
- `scripts/build-*.sh` and `scripts/test-*.sh`: the build and smoke test for each engine.
- `scripts/relocate-macos.sh` and `scripts/relocate-linux.sh`: bundle
  libraries, fix rpaths, and fail on leaked absolute paths.
- `scripts/publish.sh`: creates the prerelease and uploads the tarballs and checksums.

## Issues

Report a problem with a build here. Report problems with the app itself at
[byreapp/byre-releases](https://github.com/byreapp/byre-releases/issues).
Report security problems privately (see [SECURITY.md](SECURITY.md)).
