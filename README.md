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

Byre downloads its Postgres extensions (`ext-*`) from here. **The server builds**
(`postgres-*`, `mysql-*`, `mariadb-*`, `redis-*`, `valkey-*`, `mongodb-*`,
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
| `mariadb.yml` | MariaDB from the archive.mariadb.org source tarball | `mariadb-<version>` |
| `redis.yml` | Redis (download.redis.io) and Valkey (GitHub archive) | `redis-<version>`, `valkey-<version>` |
| `mongodb.yml` | Checksum-verified copy of MongoDB's official Community Server builds | `mongodb-<version>` |
| `check-versions.yml` | Daily at 00:00 UTC: opens an `Add <engine> <version>` issue for each vendor GA release `versions.json` is missing (closing it dismisses it) | none |
| `mongodb-tools.yml` | MongoDB Database Tools (`mongodump` and the rest), Go cross-compile | `mongodb-tools-<version>` |

### Build status

Every version of every binary, per platform. ✅ links to the tarball, ❌ is
planned but not published yet, — isn't built for that platform. Regenerated
from `versions.json`, `extensions.json` and the published releases by
`scripts/readme-status.py` after every build run (`readme.yml`).

<!-- status:start -->
#### Database servers (from source; MongoDB is the official build)

<table>
<tr><th>Engine</th><th>Version</th><th>macos-arm64</th><th>macos-x64</th><th>linux-x64</th><th>linux-arm64</th><th>windows-x64</th></tr>
<tr><td rowspan="6">postgres</td><td><a href="https://github.com/byreapp/byre-binaries/releases/tag/postgres-19beta4">19beta4</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/postgres-19beta4/postgres-19beta4-aarch64-apple-darwin.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/postgres-19beta4/postgres-19beta4-x86_64-apple-darwin.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/postgres-19beta4/postgres-19beta4-x86_64-unknown-linux-gnu.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/postgres-19beta4/postgres-19beta4-aarch64-unknown-linux-gnu.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/postgres-19beta4/postgres-19beta4-x86_64-pc-windows-msvc.tar.gz">✅</a></td></tr>
<tr><td><a href="https://github.com/byreapp/byre-binaries/releases/tag/postgres-18.6.0">18.6.0</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/postgres-18.6.0/postgres-18.6.0-aarch64-apple-darwin.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/postgres-18.6.0/postgres-18.6.0-x86_64-apple-darwin.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/postgres-18.6.0/postgres-18.6.0-x86_64-unknown-linux-gnu.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/postgres-18.6.0/postgres-18.6.0-aarch64-unknown-linux-gnu.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/postgres-18.6.0/postgres-18.6.0-x86_64-pc-windows-msvc.tar.gz">✅</a></td></tr>
<tr><td><a href="https://github.com/byreapp/byre-binaries/releases/tag/postgres-17.11.0">17.11.0</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/postgres-17.11.0/postgres-17.11.0-aarch64-apple-darwin.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/postgres-17.11.0/postgres-17.11.0-x86_64-apple-darwin.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/postgres-17.11.0/postgres-17.11.0-x86_64-unknown-linux-gnu.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/postgres-17.11.0/postgres-17.11.0-aarch64-unknown-linux-gnu.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/postgres-17.11.0/postgres-17.11.0-x86_64-pc-windows-msvc.tar.gz">✅</a></td></tr>
<tr><td><a href="https://github.com/byreapp/byre-binaries/releases/tag/postgres-16.15.0">16.15.0</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/postgres-16.15.0/postgres-16.15.0-aarch64-apple-darwin.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/postgres-16.15.0/postgres-16.15.0-x86_64-apple-darwin.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/postgres-16.15.0/postgres-16.15.0-x86_64-unknown-linux-gnu.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/postgres-16.15.0/postgres-16.15.0-aarch64-unknown-linux-gnu.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/postgres-16.15.0/postgres-16.15.0-x86_64-pc-windows-msvc.tar.gz">✅</a></td></tr>
<tr><td><a href="https://github.com/byreapp/byre-binaries/releases/tag/postgres-15.19.0">15.19.0</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/postgres-15.19.0/postgres-15.19.0-aarch64-apple-darwin.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/postgres-15.19.0/postgres-15.19.0-x86_64-apple-darwin.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/postgres-15.19.0/postgres-15.19.0-x86_64-unknown-linux-gnu.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/postgres-15.19.0/postgres-15.19.0-aarch64-unknown-linux-gnu.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/postgres-15.19.0/postgres-15.19.0-x86_64-pc-windows-msvc.tar.gz">✅</a></td></tr>
<tr><td><a href="https://github.com/byreapp/byre-binaries/releases/tag/postgres-14.24.0">14.24.0</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/postgres-14.24.0/postgres-14.24.0-aarch64-apple-darwin.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/postgres-14.24.0/postgres-14.24.0-x86_64-apple-darwin.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/postgres-14.24.0/postgres-14.24.0-x86_64-unknown-linux-gnu.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/postgres-14.24.0/postgres-14.24.0-aarch64-unknown-linux-gnu.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/postgres-14.24.0/postgres-14.24.0-x86_64-pc-windows-msvc.tar.gz">✅</a></td></tr>
<tr><td rowspan="4">mysql</td><td><a href="https://github.com/byreapp/byre-binaries/releases/tag/mysql-26.7.0">26.7.0</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/mysql-26.7.0/mysql-26.7.0-aarch64-apple-darwin.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/mysql-26.7.0/mysql-26.7.0-x86_64-apple-darwin.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/mysql-26.7.0/mysql-26.7.0-x86_64-unknown-linux-gnu.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/mysql-26.7.0/mysql-26.7.0-aarch64-unknown-linux-gnu.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/mysql-26.7.0/mysql-26.7.0-x86_64-pc-windows-msvc.tar.gz">✅</a></td></tr>
<tr><td><a href="https://github.com/byreapp/byre-binaries/releases/tag/mysql-9.7.2">9.7.2</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/mysql-9.7.2/mysql-9.7.2-aarch64-apple-darwin.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/mysql-9.7.2/mysql-9.7.2-x86_64-apple-darwin.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/mysql-9.7.2/mysql-9.7.2-x86_64-unknown-linux-gnu.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/mysql-9.7.2/mysql-9.7.2-aarch64-unknown-linux-gnu.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/mysql-9.7.2/mysql-9.7.2-x86_64-pc-windows-msvc.tar.gz">✅</a></td></tr>
<tr><td><a href="https://github.com/byreapp/byre-binaries/releases/tag/mysql-9.5.0">9.5.0</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/mysql-9.5.0/mysql-9.5.0-aarch64-apple-darwin.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/mysql-9.5.0/mysql-9.5.0-x86_64-apple-darwin.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/mysql-9.5.0/mysql-9.5.0-x86_64-unknown-linux-gnu.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/mysql-9.5.0/mysql-9.5.0-aarch64-unknown-linux-gnu.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/mysql-9.5.0/mysql-9.5.0-x86_64-pc-windows-msvc.tar.gz">✅</a></td></tr>
<tr><td><a href="https://github.com/byreapp/byre-binaries/releases/tag/mysql-8.4.11">8.4.11</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/mysql-8.4.11/mysql-8.4.11-aarch64-apple-darwin.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/mysql-8.4.11/mysql-8.4.11-x86_64-apple-darwin.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/mysql-8.4.11/mysql-8.4.11-x86_64-unknown-linux-gnu.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/mysql-8.4.11/mysql-8.4.11-aarch64-unknown-linux-gnu.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/mysql-8.4.11/mysql-8.4.11-x86_64-pc-windows-msvc.tar.gz">✅</a></td></tr>
<tr><td rowspan="5">mariadb</td><td><a href="https://github.com/byreapp/byre-binaries/releases/tag/mariadb-13.0.2">13.0.2</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/mariadb-13.0.2/mariadb-13.0.2-aarch64-apple-darwin.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/mariadb-13.0.2/mariadb-13.0.2-x86_64-apple-darwin.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/mariadb-13.0.2/mariadb-13.0.2-x86_64-unknown-linux-gnu.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/mariadb-13.0.2/mariadb-13.0.2-aarch64-unknown-linux-gnu.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/mariadb-13.0.2/mariadb-13.0.2-x86_64-pc-windows-msvc.tar.gz">✅</a></td></tr>
<tr><td><a href="https://github.com/byreapp/byre-binaries/releases/tag/mariadb-12.3.3">12.3.3</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/mariadb-12.3.3/mariadb-12.3.3-aarch64-apple-darwin.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/mariadb-12.3.3/mariadb-12.3.3-x86_64-apple-darwin.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/mariadb-12.3.3/mariadb-12.3.3-x86_64-unknown-linux-gnu.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/mariadb-12.3.3/mariadb-12.3.3-aarch64-unknown-linux-gnu.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/mariadb-12.3.3/mariadb-12.3.3-x86_64-pc-windows-msvc.tar.gz">✅</a></td></tr>
<tr><td><a href="https://github.com/byreapp/byre-binaries/releases/tag/mariadb-11.8.9">11.8.9</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/mariadb-11.8.9/mariadb-11.8.9-aarch64-apple-darwin.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/mariadb-11.8.9/mariadb-11.8.9-x86_64-apple-darwin.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/mariadb-11.8.9/mariadb-11.8.9-x86_64-unknown-linux-gnu.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/mariadb-11.8.9/mariadb-11.8.9-aarch64-unknown-linux-gnu.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/mariadb-11.8.9/mariadb-11.8.9-x86_64-pc-windows-msvc.tar.gz">✅</a></td></tr>
<tr><td><a href="https://github.com/byreapp/byre-binaries/releases/tag/mariadb-11.4.13">11.4.13</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/mariadb-11.4.13/mariadb-11.4.13-aarch64-apple-darwin.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/mariadb-11.4.13/mariadb-11.4.13-x86_64-apple-darwin.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/mariadb-11.4.13/mariadb-11.4.13-x86_64-unknown-linux-gnu.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/mariadb-11.4.13/mariadb-11.4.13-aarch64-unknown-linux-gnu.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/mariadb-11.4.13/mariadb-11.4.13-x86_64-pc-windows-msvc.tar.gz">✅</a></td></tr>
<tr><td><a href="https://github.com/byreapp/byre-binaries/releases/tag/mariadb-10.11.19">10.11.19</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/mariadb-10.11.19/mariadb-10.11.19-aarch64-apple-darwin.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/mariadb-10.11.19/mariadb-10.11.19-x86_64-apple-darwin.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/mariadb-10.11.19/mariadb-10.11.19-x86_64-unknown-linux-gnu.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/mariadb-10.11.19/mariadb-10.11.19-aarch64-unknown-linux-gnu.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/mariadb-10.11.19/mariadb-10.11.19-x86_64-pc-windows-msvc.tar.gz">✅</a></td></tr>
<tr><td rowspan="1">redis</td><td><a href="https://github.com/byreapp/byre-binaries/releases/tag/redis-8.10.2">8.10.2</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/redis-8.10.2/redis-8.10.2-aarch64-apple-darwin.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/redis-8.10.2/redis-8.10.2-x86_64-apple-darwin.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/redis-8.10.2/redis-8.10.2-x86_64-unknown-linux-gnu.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/redis-8.10.2/redis-8.10.2-aarch64-unknown-linux-gnu.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/redis-8.10.2/redis-8.10.2-x86_64-pc-windows-msvc.tar.gz">✅</a></td></tr>
<tr><td rowspan="1">valkey</td><td><a href="https://github.com/byreapp/byre-binaries/releases/tag/valkey-9.1.2">9.1.2</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/valkey-9.1.2/valkey-9.1.2-aarch64-apple-darwin.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/valkey-9.1.2/valkey-9.1.2-x86_64-apple-darwin.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/valkey-9.1.2/valkey-9.1.2-x86_64-unknown-linux-gnu.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/valkey-9.1.2/valkey-9.1.2-aarch64-unknown-linux-gnu.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/valkey-9.1.2/valkey-9.1.2-x86_64-pc-windows-msvc.tar.gz">✅</a></td></tr>
<tr><td rowspan="3">mongodb</td><td><a href="https://github.com/byreapp/byre-binaries/releases/tag/mongodb-9.0.4">9.0.4</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/mongodb-9.0.4/mongodb-9.0.4-aarch64-apple-darwin.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/mongodb-9.0.4/mongodb-9.0.4-x86_64-apple-darwin.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/mongodb-9.0.4/mongodb-9.0.4-x86_64-unknown-linux-gnu.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/mongodb-9.0.4/mongodb-9.0.4-aarch64-unknown-linux-gnu.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/mongodb-9.0.4/mongodb-9.0.4-x86_64-pc-windows-msvc.tar.gz">✅</a></td></tr>
<tr><td><a href="https://github.com/byreapp/byre-binaries/releases/tag/mongodb-8.0.34">8.0.34</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/mongodb-8.0.34/mongodb-8.0.34-aarch64-apple-darwin.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/mongodb-8.0.34/mongodb-8.0.34-x86_64-apple-darwin.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/mongodb-8.0.34/mongodb-8.0.34-x86_64-unknown-linux-gnu.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/mongodb-8.0.34/mongodb-8.0.34-aarch64-unknown-linux-gnu.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/mongodb-8.0.34/mongodb-8.0.34-x86_64-pc-windows-msvc.tar.gz">✅</a></td></tr>
<tr><td><a href="https://github.com/byreapp/byre-binaries/releases/tag/mongodb-7.0.45">7.0.45</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/mongodb-7.0.45/mongodb-7.0.45-aarch64-apple-darwin.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/mongodb-7.0.45/mongodb-7.0.45-x86_64-apple-darwin.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/mongodb-7.0.45/mongodb-7.0.45-x86_64-unknown-linux-gnu.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/mongodb-7.0.45/mongodb-7.0.45-aarch64-unknown-linux-gnu.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/mongodb-7.0.45/mongodb-7.0.45-x86_64-pc-windows-msvc.tar.gz">✅</a></td></tr>
<tr><td rowspan="1">mongodb-tools</td><td><a href="https://github.com/byreapp/byre-binaries/releases/tag/mongodb-tools-100.19.1">100.19.1</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/mongodb-tools-100.19.1/mongodb-tools-100.19.1-aarch64-apple-darwin.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/mongodb-tools-100.19.1/mongodb-tools-100.19.1-x86_64-apple-darwin.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/mongodb-tools-100.19.1/mongodb-tools-100.19.1-x86_64-unknown-linux-gnu.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/mongodb-tools-100.19.1/mongodb-tools-100.19.1-aarch64-unknown-linux-gnu.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/mongodb-tools-100.19.1/mongodb-tools-100.19.1-x86_64-pc-windows-msvc.tar.gz">✅</a></td></tr>
</table>

#### Postgres mirror (theseus, what Byre 0.3.0 downloads)

| Version | macos-arm64 | macos-x64 | linux-x64 | linux-arm64 | windows-x64 |
|---|---|---|---|---|---|
| [18.6.0](https://github.com/byreapp/byre-binaries/releases/tag/pg-18.6.0) | <a href="https://github.com/byreapp/byre-binaries/releases/download/pg-18.6.0/postgresql-18.6.0-aarch64-apple-darwin.tar.gz">✅</a> | <a href="https://github.com/byreapp/byre-binaries/releases/download/pg-18.6.0/postgresql-18.6.0-x86_64-apple-darwin.tar.gz">✅</a> | <a href="https://github.com/byreapp/byre-binaries/releases/download/pg-18.6.0/postgresql-18.6.0-x86_64-unknown-linux-gnu.tar.gz">✅</a> | <a href="https://github.com/byreapp/byre-binaries/releases/download/pg-18.6.0/postgresql-18.6.0-aarch64-unknown-linux-gnu.tar.gz">✅</a> | <a href="https://github.com/byreapp/byre-binaries/releases/download/pg-18.6.0/postgresql-18.6.0-x86_64-pc-windows-msvc.tar.gz">✅</a> |
| [17.11.0](https://github.com/byreapp/byre-binaries/releases/tag/pg-17.11.0) | <a href="https://github.com/byreapp/byre-binaries/releases/download/pg-17.11.0/postgresql-17.11.0-aarch64-apple-darwin.tar.gz">✅</a> | <a href="https://github.com/byreapp/byre-binaries/releases/download/pg-17.11.0/postgresql-17.11.0-x86_64-apple-darwin.tar.gz">✅</a> | <a href="https://github.com/byreapp/byre-binaries/releases/download/pg-17.11.0/postgresql-17.11.0-x86_64-unknown-linux-gnu.tar.gz">✅</a> | <a href="https://github.com/byreapp/byre-binaries/releases/download/pg-17.11.0/postgresql-17.11.0-aarch64-unknown-linux-gnu.tar.gz">✅</a> | <a href="https://github.com/byreapp/byre-binaries/releases/download/pg-17.11.0/postgresql-17.11.0-x86_64-pc-windows-msvc.tar.gz">✅</a> |
| [16.15.0](https://github.com/byreapp/byre-binaries/releases/tag/pg-16.15.0) | <a href="https://github.com/byreapp/byre-binaries/releases/download/pg-16.15.0/postgresql-16.15.0-aarch64-apple-darwin.tar.gz">✅</a> | <a href="https://github.com/byreapp/byre-binaries/releases/download/pg-16.15.0/postgresql-16.15.0-x86_64-apple-darwin.tar.gz">✅</a> | <a href="https://github.com/byreapp/byre-binaries/releases/download/pg-16.15.0/postgresql-16.15.0-x86_64-unknown-linux-gnu.tar.gz">✅</a> | <a href="https://github.com/byreapp/byre-binaries/releases/download/pg-16.15.0/postgresql-16.15.0-aarch64-unknown-linux-gnu.tar.gz">✅</a> | <a href="https://github.com/byreapp/byre-binaries/releases/download/pg-16.15.0/postgresql-16.15.0-x86_64-pc-windows-msvc.tar.gz">✅</a> |
| [15.19.0](https://github.com/byreapp/byre-binaries/releases/tag/pg-15.19.0) | <a href="https://github.com/byreapp/byre-binaries/releases/download/pg-15.19.0/postgresql-15.19.0-aarch64-apple-darwin.tar.gz">✅</a> | <a href="https://github.com/byreapp/byre-binaries/releases/download/pg-15.19.0/postgresql-15.19.0-x86_64-apple-darwin.tar.gz">✅</a> | <a href="https://github.com/byreapp/byre-binaries/releases/download/pg-15.19.0/postgresql-15.19.0-x86_64-unknown-linux-gnu.tar.gz">✅</a> | <a href="https://github.com/byreapp/byre-binaries/releases/download/pg-15.19.0/postgresql-15.19.0-aarch64-unknown-linux-gnu.tar.gz">✅</a> | <a href="https://github.com/byreapp/byre-binaries/releases/download/pg-15.19.0/postgresql-15.19.0-x86_64-pc-windows-msvc.tar.gz">✅</a> |
| [14.24.0](https://github.com/byreapp/byre-binaries/releases/tag/pg-14.24.0) | <a href="https://github.com/byreapp/byre-binaries/releases/download/pg-14.24.0/postgresql-14.24.0-aarch64-apple-darwin.tar.gz">✅</a> | <a href="https://github.com/byreapp/byre-binaries/releases/download/pg-14.24.0/postgresql-14.24.0-x86_64-apple-darwin.tar.gz">✅</a> | <a href="https://github.com/byreapp/byre-binaries/releases/download/pg-14.24.0/postgresql-14.24.0-x86_64-unknown-linux-gnu.tar.gz">✅</a> | <a href="https://github.com/byreapp/byre-binaries/releases/download/pg-14.24.0/postgresql-14.24.0-aarch64-unknown-linux-gnu.tar.gz">✅</a> | <a href="https://github.com/byreapp/byre-binaries/releases/download/pg-14.24.0/postgresql-14.24.0-x86_64-pc-windows-msvc.tar.gz">✅</a> |

#### Postgres extensions

<table>
<tr><th>Extension</th><th>Postgres</th><th>macos-arm64</th><th>macos-x64</th><th>linux-x64</th><th>linux-arm64</th><th>windows-x64</th></tr>
<tr><td rowspan="5"><a href="https://github.com/byreapp/byre-binaries/releases/tag/ext-vector-0.8.7">vector 0.8.7</a></td><td>14</td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-vector-0.8.7/vector-0.8.7-pg14-macos-arm64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-vector-0.8.7/vector-0.8.7-pg14-macos-x64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-vector-0.8.7/vector-0.8.7-pg14-linux-x64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-vector-0.8.7/vector-0.8.7-pg14-linux-arm64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-vector-0.8.7/vector-0.8.7-pg14-windows-x64.tar.gz">✅</a></td></tr>
<tr><td>15</td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-vector-0.8.7/vector-0.8.7-pg15-macos-arm64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-vector-0.8.7/vector-0.8.7-pg15-macos-x64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-vector-0.8.7/vector-0.8.7-pg15-linux-x64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-vector-0.8.7/vector-0.8.7-pg15-linux-arm64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-vector-0.8.7/vector-0.8.7-pg15-windows-x64.tar.gz">✅</a></td></tr>
<tr><td>16</td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-vector-0.8.7/vector-0.8.7-pg16-macos-arm64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-vector-0.8.7/vector-0.8.7-pg16-macos-x64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-vector-0.8.7/vector-0.8.7-pg16-linux-x64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-vector-0.8.7/vector-0.8.7-pg16-linux-arm64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-vector-0.8.7/vector-0.8.7-pg16-windows-x64.tar.gz">✅</a></td></tr>
<tr><td>17</td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-vector-0.8.7/vector-0.8.7-pg17-macos-arm64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-vector-0.8.7/vector-0.8.7-pg17-macos-x64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-vector-0.8.7/vector-0.8.7-pg17-linux-x64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-vector-0.8.7/vector-0.8.7-pg17-linux-arm64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-vector-0.8.7/vector-0.8.7-pg17-windows-x64.tar.gz">✅</a></td></tr>
<tr><td>18</td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-vector-0.8.7/vector-0.8.7-pg18-macos-arm64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-vector-0.8.7/vector-0.8.7-pg18-macos-x64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-vector-0.8.7/vector-0.8.7-pg18-linux-x64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-vector-0.8.7/vector-0.8.7-pg18-linux-arm64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-vector-0.8.7/vector-0.8.7-pg18-windows-x64.tar.gz">✅</a></td></tr>
<tr><td rowspan="5"><a href="https://github.com/byreapp/byre-binaries/releases/tag/ext-hypopg-1.4.3">hypopg 1.4.3</a></td><td>14</td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-hypopg-1.4.3/hypopg-1.4.3-pg14-macos-arm64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-hypopg-1.4.3/hypopg-1.4.3-pg14-macos-x64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-hypopg-1.4.3/hypopg-1.4.3-pg14-linux-x64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-hypopg-1.4.3/hypopg-1.4.3-pg14-linux-arm64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-hypopg-1.4.3/hypopg-1.4.3-pg14-windows-x64.tar.gz">✅</a></td></tr>
<tr><td>15</td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-hypopg-1.4.3/hypopg-1.4.3-pg15-macos-arm64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-hypopg-1.4.3/hypopg-1.4.3-pg15-macos-x64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-hypopg-1.4.3/hypopg-1.4.3-pg15-linux-x64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-hypopg-1.4.3/hypopg-1.4.3-pg15-linux-arm64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-hypopg-1.4.3/hypopg-1.4.3-pg15-windows-x64.tar.gz">✅</a></td></tr>
<tr><td>16</td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-hypopg-1.4.3/hypopg-1.4.3-pg16-macos-arm64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-hypopg-1.4.3/hypopg-1.4.3-pg16-macos-x64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-hypopg-1.4.3/hypopg-1.4.3-pg16-linux-x64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-hypopg-1.4.3/hypopg-1.4.3-pg16-linux-arm64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-hypopg-1.4.3/hypopg-1.4.3-pg16-windows-x64.tar.gz">✅</a></td></tr>
<tr><td>17</td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-hypopg-1.4.3/hypopg-1.4.3-pg17-macos-arm64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-hypopg-1.4.3/hypopg-1.4.3-pg17-macos-x64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-hypopg-1.4.3/hypopg-1.4.3-pg17-linux-x64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-hypopg-1.4.3/hypopg-1.4.3-pg17-linux-arm64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-hypopg-1.4.3/hypopg-1.4.3-pg17-windows-x64.tar.gz">✅</a></td></tr>
<tr><td>18</td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-hypopg-1.4.3/hypopg-1.4.3-pg18-macos-arm64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-hypopg-1.4.3/hypopg-1.4.3-pg18-macos-x64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-hypopg-1.4.3/hypopg-1.4.3-pg18-linux-x64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-hypopg-1.4.3/hypopg-1.4.3-pg18-linux-arm64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-hypopg-1.4.3/hypopg-1.4.3-pg18-windows-x64.tar.gz">✅</a></td></tr>
<tr><td rowspan="5"><a href="https://github.com/byreapp/byre-binaries/releases/tag/ext-pg_cron-1.6.8">pg_cron 1.6.8</a></td><td>14</td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-pg_cron-1.6.8/pg_cron-1.6.8-pg14-macos-arm64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-pg_cron-1.6.8/pg_cron-1.6.8-pg14-macos-x64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-pg_cron-1.6.8/pg_cron-1.6.8-pg14-linux-x64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-pg_cron-1.6.8/pg_cron-1.6.8-pg14-linux-arm64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-pg_cron-1.6.8/pg_cron-1.6.8-pg14-windows-x64.tar.gz">✅</a></td></tr>
<tr><td>15</td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-pg_cron-1.6.8/pg_cron-1.6.8-pg15-macos-arm64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-pg_cron-1.6.8/pg_cron-1.6.8-pg15-macos-x64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-pg_cron-1.6.8/pg_cron-1.6.8-pg15-linux-x64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-pg_cron-1.6.8/pg_cron-1.6.8-pg15-linux-arm64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-pg_cron-1.6.8/pg_cron-1.6.8-pg15-windows-x64.tar.gz">✅</a></td></tr>
<tr><td>16</td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-pg_cron-1.6.8/pg_cron-1.6.8-pg16-macos-arm64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-pg_cron-1.6.8/pg_cron-1.6.8-pg16-macos-x64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-pg_cron-1.6.8/pg_cron-1.6.8-pg16-linux-x64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-pg_cron-1.6.8/pg_cron-1.6.8-pg16-linux-arm64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-pg_cron-1.6.8/pg_cron-1.6.8-pg16-windows-x64.tar.gz">✅</a></td></tr>
<tr><td>17</td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-pg_cron-1.6.8/pg_cron-1.6.8-pg17-macos-arm64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-pg_cron-1.6.8/pg_cron-1.6.8-pg17-macos-x64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-pg_cron-1.6.8/pg_cron-1.6.8-pg17-linux-x64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-pg_cron-1.6.8/pg_cron-1.6.8-pg17-linux-arm64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-pg_cron-1.6.8/pg_cron-1.6.8-pg17-windows-x64.tar.gz">✅</a></td></tr>
<tr><td>18</td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-pg_cron-1.6.8/pg_cron-1.6.8-pg18-macos-arm64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-pg_cron-1.6.8/pg_cron-1.6.8-pg18-macos-x64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-pg_cron-1.6.8/pg_cron-1.6.8-pg18-linux-x64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-pg_cron-1.6.8/pg_cron-1.6.8-pg18-linux-arm64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-pg_cron-1.6.8/pg_cron-1.6.8-pg18-windows-x64.tar.gz">✅</a></td></tr>
<tr><td rowspan="5"><a href="https://github.com/byreapp/byre-binaries/releases/tag/ext-pg_ivm-1.16">pg_ivm 1.16</a></td><td>14</td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-pg_ivm-1.16/pg_ivm-1.16-pg14-macos-arm64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-pg_ivm-1.16/pg_ivm-1.16-pg14-macos-x64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-pg_ivm-1.16/pg_ivm-1.16-pg14-linux-x64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-pg_ivm-1.16/pg_ivm-1.16-pg14-linux-arm64.tar.gz">✅</a></td><td>—</td></tr>
<tr><td>15</td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-pg_ivm-1.16/pg_ivm-1.16-pg15-macos-arm64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-pg_ivm-1.16/pg_ivm-1.16-pg15-macos-x64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-pg_ivm-1.16/pg_ivm-1.16-pg15-linux-x64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-pg_ivm-1.16/pg_ivm-1.16-pg15-linux-arm64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-pg_ivm-1.16/pg_ivm-1.16-pg15-windows-x64.tar.gz">✅</a></td></tr>
<tr><td>16</td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-pg_ivm-1.16/pg_ivm-1.16-pg16-macos-arm64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-pg_ivm-1.16/pg_ivm-1.16-pg16-macos-x64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-pg_ivm-1.16/pg_ivm-1.16-pg16-linux-x64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-pg_ivm-1.16/pg_ivm-1.16-pg16-linux-arm64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-pg_ivm-1.16/pg_ivm-1.16-pg16-windows-x64.tar.gz">✅</a></td></tr>
<tr><td>17</td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-pg_ivm-1.16/pg_ivm-1.16-pg17-macos-arm64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-pg_ivm-1.16/pg_ivm-1.16-pg17-macos-x64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-pg_ivm-1.16/pg_ivm-1.16-pg17-linux-x64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-pg_ivm-1.16/pg_ivm-1.16-pg17-linux-arm64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-pg_ivm-1.16/pg_ivm-1.16-pg17-windows-x64.tar.gz">✅</a></td></tr>
<tr><td>18</td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-pg_ivm-1.16/pg_ivm-1.16-pg18-macos-arm64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-pg_ivm-1.16/pg_ivm-1.16-pg18-macos-x64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-pg_ivm-1.16/pg_ivm-1.16-pg18-linux-x64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-pg_ivm-1.16/pg_ivm-1.16-pg18-linux-arm64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-pg_ivm-1.16/pg_ivm-1.16-pg18-windows-x64.tar.gz">✅</a></td></tr>
<tr><td rowspan="5"><a href="https://github.com/byreapp/byre-binaries/releases/tag/ext-pg_partman-5.5.0">pg_partman 5.5.0</a></td><td>14</td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-pg_partman-5.5.0/pg_partman-5.5.0-pg14-macos-arm64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-pg_partman-5.5.0/pg_partman-5.5.0-pg14-macos-x64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-pg_partman-5.5.0/pg_partman-5.5.0-pg14-linux-x64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-pg_partman-5.5.0/pg_partman-5.5.0-pg14-linux-arm64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-pg_partman-5.5.0/pg_partman-5.5.0-pg14-windows-x64.tar.gz">✅</a></td></tr>
<tr><td>15</td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-pg_partman-5.5.0/pg_partman-5.5.0-pg15-macos-arm64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-pg_partman-5.5.0/pg_partman-5.5.0-pg15-macos-x64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-pg_partman-5.5.0/pg_partman-5.5.0-pg15-linux-x64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-pg_partman-5.5.0/pg_partman-5.5.0-pg15-linux-arm64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-pg_partman-5.5.0/pg_partman-5.5.0-pg15-windows-x64.tar.gz">✅</a></td></tr>
<tr><td>16</td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-pg_partman-5.5.0/pg_partman-5.5.0-pg16-macos-arm64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-pg_partman-5.5.0/pg_partman-5.5.0-pg16-macos-x64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-pg_partman-5.5.0/pg_partman-5.5.0-pg16-linux-x64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-pg_partman-5.5.0/pg_partman-5.5.0-pg16-linux-arm64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-pg_partman-5.5.0/pg_partman-5.5.0-pg16-windows-x64.tar.gz">✅</a></td></tr>
<tr><td>17</td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-pg_partman-5.5.0/pg_partman-5.5.0-pg17-macos-arm64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-pg_partman-5.5.0/pg_partman-5.5.0-pg17-macos-x64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-pg_partman-5.5.0/pg_partman-5.5.0-pg17-linux-x64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-pg_partman-5.5.0/pg_partman-5.5.0-pg17-linux-arm64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-pg_partman-5.5.0/pg_partman-5.5.0-pg17-windows-x64.tar.gz">✅</a></td></tr>
<tr><td>18</td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-pg_partman-5.5.0/pg_partman-5.5.0-pg18-macos-arm64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-pg_partman-5.5.0/pg_partman-5.5.0-pg18-macos-x64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-pg_partman-5.5.0/pg_partman-5.5.0-pg18-linux-x64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-pg_partman-5.5.0/pg_partman-5.5.0-pg18-linux-arm64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-pg_partman-5.5.0/pg_partman-5.5.0-pg18-windows-x64.tar.gz">✅</a></td></tr>
<tr><td rowspan="4"><a href="https://github.com/byreapp/byre-binaries/releases/tag/ext-pg_uuidv7-1.7.0">pg_uuidv7 1.7.0</a></td><td>14</td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-pg_uuidv7-1.7.0/pg_uuidv7-1.7.0-pg14-macos-arm64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-pg_uuidv7-1.7.0/pg_uuidv7-1.7.0-pg14-macos-x64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-pg_uuidv7-1.7.0/pg_uuidv7-1.7.0-pg14-linux-x64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-pg_uuidv7-1.7.0/pg_uuidv7-1.7.0-pg14-linux-arm64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-pg_uuidv7-1.7.0/pg_uuidv7-1.7.0-pg14-windows-x64.tar.gz">✅</a></td></tr>
<tr><td>15</td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-pg_uuidv7-1.7.0/pg_uuidv7-1.7.0-pg15-macos-arm64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-pg_uuidv7-1.7.0/pg_uuidv7-1.7.0-pg15-macos-x64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-pg_uuidv7-1.7.0/pg_uuidv7-1.7.0-pg15-linux-x64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-pg_uuidv7-1.7.0/pg_uuidv7-1.7.0-pg15-linux-arm64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-pg_uuidv7-1.7.0/pg_uuidv7-1.7.0-pg15-windows-x64.tar.gz">✅</a></td></tr>
<tr><td>16</td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-pg_uuidv7-1.7.0/pg_uuidv7-1.7.0-pg16-macos-arm64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-pg_uuidv7-1.7.0/pg_uuidv7-1.7.0-pg16-macos-x64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-pg_uuidv7-1.7.0/pg_uuidv7-1.7.0-pg16-linux-x64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-pg_uuidv7-1.7.0/pg_uuidv7-1.7.0-pg16-linux-arm64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-pg_uuidv7-1.7.0/pg_uuidv7-1.7.0-pg16-windows-x64.tar.gz">✅</a></td></tr>
<tr><td>17</td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-pg_uuidv7-1.7.0/pg_uuidv7-1.7.0-pg17-macos-arm64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-pg_uuidv7-1.7.0/pg_uuidv7-1.7.0-pg17-macos-x64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-pg_uuidv7-1.7.0/pg_uuidv7-1.7.0-pg17-linux-x64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-pg_uuidv7-1.7.0/pg_uuidv7-1.7.0-pg17-linux-arm64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-pg_uuidv7-1.7.0/pg_uuidv7-1.7.0-pg17-windows-x64.tar.gz">✅</a></td></tr>
<tr><td rowspan="3"><a href="https://github.com/byreapp/byre-binaries/releases/tag/ext-timescaledb-2.30.2">timescaledb 2.30.2</a></td><td>16</td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-timescaledb-2.30.2/timescaledb-2.30.2-pg16-macos-arm64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-timescaledb-2.30.2/timescaledb-2.30.2-pg16-macos-x64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-timescaledb-2.30.2/timescaledb-2.30.2-pg16-linux-x64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-timescaledb-2.30.2/timescaledb-2.30.2-pg16-linux-arm64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-timescaledb-2.30.2/timescaledb-2.30.2-pg16-windows-x64.tar.gz">✅</a></td></tr>
<tr><td>17</td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-timescaledb-2.30.2/timescaledb-2.30.2-pg17-macos-arm64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-timescaledb-2.30.2/timescaledb-2.30.2-pg17-macos-x64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-timescaledb-2.30.2/timescaledb-2.30.2-pg17-linux-x64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-timescaledb-2.30.2/timescaledb-2.30.2-pg17-linux-arm64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-timescaledb-2.30.2/timescaledb-2.30.2-pg17-windows-x64.tar.gz">✅</a></td></tr>
<tr><td>18</td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-timescaledb-2.30.2/timescaledb-2.30.2-pg18-macos-arm64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-timescaledb-2.30.2/timescaledb-2.30.2-pg18-macos-x64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-timescaledb-2.30.2/timescaledb-2.30.2-pg18-linux-x64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-timescaledb-2.30.2/timescaledb-2.30.2-pg18-linux-arm64.tar.gz">✅</a></td><td><a href="https://github.com/byreapp/byre-binaries/releases/download/ext-timescaledb-2.30.2/timescaledb-2.30.2-pg18-windows-x64.tar.gz">✅</a></td></tr>
</table>
<!-- status:end -->

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

On Windows, extensions with a `Makefile.win` (pgvector, pg_cron) use it and
timescaledb uses CMake. The rest go through `scripts/build-ext-windows.sh`,
which reads the extension's own PGXS Makefile and compiles it with MSVC. A
`skip` entry (`pg<major>-<platform>`) leaves out a combination that can't
build, such as pg_ivm on Postgres 14 for Windows, which needs globals 14
doesn't export there.

### MySQL

- **Build:** CMake with Ninja.
- **Libraries:**
  - Bundled from MySQL's own source tree: zlib, zstd, lz4, editline, protobuf, ICU and boost.
  - OpenSSL comes from the system on Linux, bundled into `lib/`, and from
    Homebrew on macOS.
- **Turned off:** Router, NDB, unit tests, and LDAP, Kerberos and FIDO auth.
- **Build time:** roughly 1 to 2 hours per platform.
- **Windows:** MSVC with Ninja, OpenSSL from vcpkg. Curl is off (only
  9.x's optional OCI/telemetry parts use it).
- **Smoke test:** `mysqld --initialize-insecure`, start the server, then `select version()`.

### MariaDB

- **Build:** CMake with Ninja.
- **Libraries:** PCRE2, zlib and fmt bundled from MariaDB's source tree.
  TLS is OpenSSL (system on Linux, Homebrew on macOS, copied into `lib/`) and
  MariaDB's bundled WolfSSL on Windows.
- **Turned off:** Galera (WSREP), the embedded server, unit tests, and the
  plugins that need extra deps: RocksDB, Mroonga, ColumnStore, Spider,
  CONNECT, S3, OQGraph, DuckDB, GSSAPI and HashiCorp key management.
- **Windows:** MSVC with Ninja, winflexbison for the parser.
- **Smoke test:** `mariadb-install-db`, start `mariadbd`, then `select version()`.

### Redis and Valkey

- **Build:** core server only (`make -C src`).
- **Not included:** TLS, and Redis 8's bundled modules (search, JSON, time
  series and bloom need Rust and GNU make 4).
- **Windows:** upstream has no native Windows build, so it's built under
  MSYS2 (a POSIX layer) and ships `msys-2.0.dll` in `bin/`. Redis' test-only
  modules are skipped there.
- **Smoke test:** `--version`, start the server, then `PING`, `SET` and `GET`.

### MongoDB

The server isn't built from source: that's many hours of Bazel and more disk
than the free runners have. `mongodb.yml` mirrors MongoDB's official
Community Server builds instead.

- **Source:** fastdl.mongodb.org. Each file is checked against the SHA-256 in
  MongoDB's `full.json`, then repackaged into the same
  `mongodb-<version>-<triple>/` layout as the other engines.
- **Linux:** the Ubuntu 22.04 build (glibc 2.35, OpenSSL 3), which also runs
  on newer distros.
- **License:** SSPL. The matching source is in
  [byreapp/mongo](https://github.com/byreapp/mongo).
- **Smoke test:** `mongod --version` on linux-x64.
- **Database Tools:** `mongodb-tools.yml` builds them from source on every
  platform. They are plain Go and build in a few minutes.

## Running a workflow

Go to **Actions**, pick the workflow, then click **Run workflow**. Every run
uses `GITHUB_TOKEN` (`contents: write`) and needs no secrets.

| Workflow | Inputs |
|---|---|
| Postgres, MySQL, MariaDB | `version`: `all` (default) or a version from `versions.json` |
| Redis + Valkey | `engine`: `all`, `redis` or `valkey`; `version`: `all` or a version |
| MongoDB tools | `version`: `all` or a version |
| MongoDB mirror | none (mirrors every `mongodb.versions` entry that isn't fully mirrored yet) |
| Postgres mirror | none (mirrors every numeric `postgres.versions` entry that isn't mirrored yet) |
| Extensions | `name`: `all` or an extension name from `extensions.json` |

- **`all`** builds only what isn't published yet. For the from-source
  workflows, that's per platform: a version missing only its macOS tarball
  runs just the macOS build.
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
- [mariadb-server](https://github.com/byreapp/mariadb-server)
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
- `scripts/plan.sh`: picks which (version, platform) builds to run, skipping published ones.
- `scripts/build-*.sh` and `scripts/test-*.sh`: the build and smoke test for each engine.
- `scripts/relocate-macos.sh` and `scripts/relocate-linux.sh`: bundle
  libraries, fix rpaths, and fail on leaked absolute paths.
- `scripts/publish.sh`: creates the prerelease and uploads the tarballs and checksums.
- `scripts/build-ext-windows.sh`, `scripts/pgxs-vars.mk`, `scripts/msvc-compat.h`:
  the MSVC build for PGXS extensions.
- `scripts/readme-status.py`: regenerates the build-status tables above.

## Issues

Report a problem with a build here. Report problems with the app itself at
[byreapp/byre-releases](https://github.com/byreapp/byre-releases/issues).
Report security problems privately (see [SECURITY.md](SECURITY.md)).
