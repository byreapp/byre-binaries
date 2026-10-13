#!/usr/bin/env python3
"""Rewrites the build-status tables in README.md (between the status markers)
from versions.json, extensions.json and the repo's published release assets.
  ✅ published (links to the tarball)   ❌ planned, not published   — not built for it
Needs `gh` (GH_TOKEN) and GITHUB_REPOSITORY (default byreapp/byre-binaries)."""
import json, os, re, subprocess

REPO = os.environ.get("GITHUB_REPOSITORY", "byreapp/byre-binaries")
PLATFORMS = {
    "macos-arm64": "aarch64-apple-darwin",
    "macos-x64": "x86_64-apple-darwin",
    "linux-x64": "x86_64-unknown-linux-gnu",
    "linux-arm64": "aarch64-unknown-linux-gnu",
    "windows-x64": "x86_64-pc-windows-msvc",
}
HEAD = "| " + " | ".join(PLATFORMS) + " |"

pages = subprocess.run(
    ["gh", "api", f"repos/{REPO}/releases", "--paginate", "--jq", ".[] | {tag_name, assets: [.assets[] | {name, browser_download_url}]}"],
    check=True, capture_output=True, text=True,
).stdout.split("\n")
assets = {}  # tag -> {asset name: url}
for line in filter(None, pages):
    r = json.loads(line)
    assets[r["tag_name"]] = {a["name"]: a["browser_download_url"] for a in r["assets"]}


def cell(tag, name, wanted):
    if not wanted:
        return "—"
    url = assets.get(tag, {}).get(name)
    return f'<a href="{url}">✅</a>' if url else "❌"


def link(tag, text):
    return f'<a href="https://github.com/{REPO}/releases/tag/{tag}">{text}</a>'


def grouped(head, groups):
    """HTML table (markdown has no rowspan): one cell per group spans its rows.
    groups: [(label, [[cell, ...], ...])]"""
    rows = ["<table>", "<tr>" + "".join(f"<th>{h}</th>" for h in head) + "</tr>"]
    for label, cells in groups:
        for i, c in enumerate(cells):
            first = f'<td rowspan="{len(cells)}">{label}</td>' if i == 0 else ""
            rows.append("<tr>" + first + "".join(f"<td>{x}</td>" for x in c) + "</tr>")
    return rows + ["</table>"]


versions = json.load(open("versions.json"))
exts = json.load(open("extensions.json"))
out = []

out += ["#### Database servers (from source)", ""]
out += grouped(["Engine", "Version", *PLATFORMS], [
    (engine, [[link(f"{engine}-{v}", v)] +
              [cell(f"{engine}-{v}", f"{engine}-{v}-{t}.tar.gz", p in spec["platforms"]) for p, t in PLATFORMS.items()]
              for v in spec["versions"]])
    for engine, spec in versions.items()])

out += ["", "#### Postgres mirror (theseus, what Byre downloads)", "", "| Version " + HEAD, "|---|" + "---|" * len(PLATFORMS)]
for pg in exts["postgres"]:
    tag = f"pg-{pg['exact']}"
    cells = [cell(tag, f"postgresql-{pg['exact']}-{t}.tar.gz", True) for t in PLATFORMS.values()]
    out.append(f"| [{pg['exact']}](https://github.com/{REPO}/releases/tag/{tag}) | " + " | ".join(cells) + " |")

out += ["", "#### Postgres extensions", ""]
groups = []
for e in exts["extensions"]:
    tag = f"ext-{e['name']}-{e['version']}"
    groups.append((link(tag, f"{e['name']} {e['version']}"), [
        [m] + [cell(tag, f"{e['name']}-{e['version']}-pg{m}-{p}.tar.gz",
                    p in e["platforms"] and f"pg{m}-{p}" not in e.get("skip", []))
               for p in PLATFORMS]
        for m in e["majors"]]))
out += grouped(["Extension", "Postgres", *PLATFORMS], groups)

readme = open("README.md").read()
new = re.sub(r"(<!-- status:start -->\n).*?(<!-- status:end -->)",
             lambda m: m[1] + "\n".join(out) + "\n" + m[2], readme, flags=re.S)
assert new != readme or "<!-- status:start -->" in readme, "status markers missing from README.md"
open("README.md", "w").write(new)
