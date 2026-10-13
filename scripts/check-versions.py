#!/usr/bin/env python3
"""Prints one line per upstream release versions.json is missing:
    <engine> <version> patch   a newer patch of a release line we ship
    <engine> <version> line    a release line newer than any we ship (may be an RC/preview)
Upstream versions come from the projects' git tags (git ls-remote, no API limits).
Run: python3 scripts/check-versions.py   (python3 ... --self-test checks the logic offline)"""
import json, re, subprocess, sys

# engine: (repo, tag regex capturing the version, release-line length)
UPSTREAM = {
    "postgres": ("postgres/postgres", r"REL_(\d+)_(\d+)", 1),
    "mysql": ("mysql/mysql-server", r"mysql-(\d+\.\d+\.\d+)", 2),
    "mariadb": ("MariaDB/server", r"mariadb-(\d+\.\d+\.\d+)", 2),
    "redis": ("redis/redis", r"(\d+\.\d+\.\d+)", 2),
    "valkey": ("valkey-io/valkey", r"(\d+\.\d+\.\d+)", 2),
    "mongodb": ("mongodb/mongo", r"r(\d+\.\d+\.\d+)", 2),
    "mongodb-tools": ("mongodb/mongo-tools", r"(\d+\.\d+\.\d+)", 2),
}


def key(v):
    return tuple(int(x) for x in v.split("."))


def upstream(repo, pattern):
    out = subprocess.run(["git", "ls-remote", "--tags", f"https://github.com/{repo}"],
                         capture_output=True, text=True, check=True).stdout
    found = set()
    for ref in out.split():
        m = re.fullmatch(r"refs/tags/" + pattern, ref)
        if m:  # postgres tags REL_18_6 → 18.6.0, the layout versions.json uses
            found.add(".".join(m.groups()) + ".0" if len(m.groups()) == 2 else m.group(1))
    return found


def missing(ours, theirs, n):
    """ours: versions.json versions (non-numeric ones like 19beta4 are ignored)."""
    ours = [v for v in ours if re.fullmatch(r"[\d.]+", v)]
    line = lambda v: key(v)[:n]
    newest = {}
    for v in theirs:
        if line(v) not in newest or key(v) > key(newest[line(v)]):
            newest[line(v)] = v
    shipped = {line(v): v for v in sorted(ours, key=key)}
    top = max(shipped)
    for l, v in sorted(newest.items()):
        if l in shipped and key(v) > key(shipped[l]):
            yield v, "patch"
        elif l > top:
            yield v, "line"


def self_test():
    got = list(missing(["9.7.2", "8.4.11", "26beta"], {"8.4.12", "8.4.10", "9.7.2", "8.0.40", "9.8.0", "10.0.1"}, 2))
    assert got == [("8.4.12", "patch"), ("9.8.0", "line"), ("10.0.1", "line")], got
    assert list(missing(["18.6.0", "19beta4"], {"18.7.0", "19.0.0", "17.12.0"}, 1)) == [("18.7.0", "patch"), ("19.0.0", "line")]
    print("ok")


if __name__ == "__main__":
    if sys.argv[1:] == ["--self-test"]:
        sys.exit(self_test())
    versions = json.load(open("versions.json"))
    for engine, (repo, pattern, n) in UPSTREAM.items():
        for v, kind in missing(versions[engine]["versions"], upstream(repo, pattern), n):
            print(engine, v, kind)
