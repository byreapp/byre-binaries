#!/usr/bin/env python3
"""Prints one line per vendor release versions.json is missing:
    <engine> <version> patch   a newer patch of a release line we ship
    <engine> <version> line    a newer GA release line than any we ship
Versions come from each vendor's own release feed (GA only, no RCs/previews).
Run: python3 scripts/check-versions.py   (python3 ... --self-test checks the logic offline)"""
import json, os, re, subprocess, sys, urllib.request


def get(url):
    return json.load(urllib.request.urlopen(url, timeout=60))


def gh_releases(repo):
    out = subprocess.run(["gh", "api", "--paginate", f"repos/{repo}/releases", "--jq", ".[] | select(.prerelease | not) | .tag_name"],
                         capture_output=True, text=True, check=True).stdout
    return {t for t in out.split() if re.fullmatch(r"\d+\.\d+\.\d+", t)}


def postgres():
    return {f"{r['major']}.{r['latestMinor']}.0" for r in get("https://www.postgresql.org/versions.json")
            if r["supported"] and "." not in r["major"]}


def mariadb():
    lines = [r["release_id"] for r in get("https://downloads.mariadb.org/rest-api/mariadb/")["major_releases"]
             if r["release_status"] == "Stable"]
    return {v for l in lines for v in get(f"https://downloads.mariadb.org/rest-api/mariadb/{l}/")["releases"]}


def mysql():
    # MySQL has no release feed: git tags, kept only if the source tarball is on the CDN (see confirm).
    out = subprocess.run(["git", "ls-remote", "--tags", "https://github.com/mysql/mysql-server"],
                         capture_output=True, text=True, check=True).stdout
    return set(re.findall(r"refs/tags/mysql-(\d+\.\d+\.\d+)$", out, re.M))


def on_cdn(v):
    try:
        urllib.request.urlopen(urllib.request.Request(
            f"https://cdn.mysql.com/Downloads/MySQL-{v.rsplit('.', 1)[0]}/mysql-{v}.tar.gz", method="HEAD"), timeout=60)
        return True
    except OSError:
        return False


# engine: (vendor versions, release-line length, check before reporting)
UPSTREAM = {
    "postgres": (postgres, 1, None),
    "mysql": (mysql, 2, on_cdn),
    "mariadb": (mariadb, 2, None),
    "redis": (lambda: gh_releases("redis/redis"), 2, None),
    "valkey": (lambda: gh_releases("valkey-io/valkey"), 2, None),
    "mongodb": (lambda: {r["version"] for r in get("https://downloads.mongodb.org/current.json")["versions"]
                         if r["production_release"]}, 2, None),
    "mongodb-tools": (lambda: {r["version"] for r in get("https://downloads.mongodb.org/tools/db/release.json")["versions"]}, 2, None),
}


def key(v):
    return tuple(int(x) for x in v.split("."))


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
    rows = ["| Engine | We ship | Vendor latest | Missing |", "|---|---|---|---|"]
    for engine, (fetch, n, confirm) in UPSTREAM.items():
        theirs = fetch()
        ok = confirm or (lambda v: True)
        new = [(v, kind) for v, kind in missing(versions[engine]["versions"], theirs, n) if ok(v)]
        for v, kind in new:
            print(engine, v, kind)
        latest = next((v for v in sorted(theirs, key=key, reverse=True) if ok(v)), "?")
        rows.append(f"| {engine} | {', '.join(versions[engine]['versions'])} | {latest} | {', '.join(f'🆕 {v} ({kind})' for v, kind in new) or '✅ none'} |")
    # The Actions run page shows this markdown as the job summary.
    if os.environ.get("GITHUB_STEP_SUMMARY"):
        with open(os.environ["GITHUB_STEP_SUMMARY"], "a") as f:
            f.write("### Vendor versions\n\n" + "\n".join(rows) + "\n")
    else:
        print("\n".join(rows), file=sys.stderr)
