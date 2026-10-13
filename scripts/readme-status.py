#!/usr/bin/env python3
"""Rewrites the build-status tables in README.md (between the status markers)
from versions.json, extensions.json and the repo's published release assets,
and the extensions + Postgres versions in catalog.json — the live catalog the
Byre app fetches, so only what's actually published shows up in the app.
  ✅ published (links to the tarball)   ❌ planned, not published   — not built for it
Needs `gh` (GH_TOKEN) and GITHUB_REPOSITORY (default byreapp/byre-binaries)."""
import datetime, json, os, re, subprocess

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

out += ["#### Database servers (from source; MongoDB is the official build)", ""]
out += grouped(["Engine", "Version", *PLATFORMS], [
    (engine, [[link(f"{engine}-{v}", v)] +
              [cell(f"{engine}-{v}", f"{engine}-{v}-{t}.tar.gz", p in spec["platforms"]) for p, t in PLATFORMS.items()]
              for v in spec["versions"]])
    for engine, spec in versions.items()])

out += ["", "#### Postgres mirror (theseus, what Byre 0.3.0 downloads)", "", "| Version " + HEAD, "|---|" + "---|" * len(PLATFORMS)]
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


# --- catalog.json (the app's live catalog; engines other than Postgres are hand-edited)
cat = json.load(open("catalog.json"))
before = json.dumps({k: v for k, v in cat.items() if k != "updated"}, sort_keys=True)
old = {e["name"]: e for e in cat["extensions"]}
live = []
for e in exts["extensions"]:
    n, v = e["name"], e["version"]
    tag = f"ext-{n}-{v}"
    have = {(m, p) for m in e["majors"] for p in PLATFORMS if f"{n}-{v}-pg{m}-{p}.tar.gz" in assets.get(tag, {})}
    prev = old.get(n, {})
    if not have:  # this version isn't published yet: keep serving the previous one
        live += [prev] if prev else []
        continue
    majors = [m for m in e["majors"] if any((m, p) in have for p in PLATFORMS)]
    plats = [p for p in PLATFORMS if any((m, p) in have for m in majors)]
    entry = {"name": n, "title": prev.get("title", n), "version": v,
             "description": prev.get("description", ""), "source": e["source"]}
    if prev.get("preload"):
        entry["preload"] = True
    entry |= {"url": f"https://github.com/{REPO}/releases/download/{tag}/{n}-{v}-pg{{major}}-{{platform}}.tar.gz",
              "majors": majors, "platforms": plats}
    skip = [f"pg{m}-{p}" for m in majors for p in plats if (m, p) not in have]
    if skip:
        entry["skip"] = skip
    live.append(entry)
cat["extensions"] = live

# Postgres: Byre 0.4+ builds the postgres-<tag> URL from `exact` ("19beta4" ↔
# "19.0.0-beta4"), so a published postgres-<tag> release means that version is
# out. No `url`: 0.3.0 reads a Postgres url as a Postgres.app DMG (and, lacking
# one, shows a beta as unavailable; its releases still come from theseus).
pg = next(e for e in cat["engines"] if e["id"] == "postgres")
for v in versions["postgres"]["versions"]:
    if not any(n.endswith(".tar.gz") for n in assets.get(f"postgres-{v}", {})):
        continue
    num, pre = re.match(r"([\d.]+)(.*)", v).groups()
    major = num.split(".")[0]
    exact = f"{major}.0.0-{pre}" if pre else v
    cur = next((x for x in pg["versions"] if x["major"] == major), None)
    if cur and pre and not cur.get("beta"):
        continue  # the final release is out; don't regress to a pre-release
    if not cur:
        pg["versions"].append(cur := {"major": major})
    cur.pop("url", None)
    cur["exact"] = exact
    if pre:
        cur["beta"] = True
    else:
        cur.pop("beta", None)
pg["versions"].sort(key=lambda x: int(x["major"]), reverse=True)

if json.dumps({k: v for k, v in cat.items() if k != "updated"}, sort_keys=True) != before or "updated" not in cat:
    cat = {"updated": datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"), **{k: v for k, v in cat.items() if k != "updated"}}
    open("catalog.json", "w").write(json.dumps(cat, indent=2, ensure_ascii=False) + "\n")
