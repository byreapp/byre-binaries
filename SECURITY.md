# Security

Please don't report security problems in a public issue. Use
[private vulnerability reporting](https://github.com/byreapp/byre-releases/security/advisories/new)
on byreapp/byre-releases instead, and say that it's about byre-binaries.

Useful things to include:

- The release tag and asset, for example `postgres-18.6.0` and
  `postgres-18.6.0-aarch64-apple-darwin.tar.gz`.
- What you found.
- How to reproduce it.

## Supported versions

Only the versions currently listed in `versions.json` and `extensions.json` get
rebuilt. When an upstream security release comes out, its version replaces the
old one there.

Every asset has a `.sha256` next to it. Check it before you use the tarball:

```sh
sha256sum -c <asset>.tar.gz.sha256
```
