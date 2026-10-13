#!/usr/bin/env bash
# Prints the builds to run for <engine>, as a JSON array of {version, target}.
#   plan.sh <engine> all <targets>     every (version, target) whose tarball isn't published yet
#   plan.sh <engine> <ver> <targets>   every target of that version (must be in versions.json)
# <targets> is the workflow's JSON array of {os, platform, triple, ...}; only
# those whose platform versions.json lists for <engine> are planned. So a run
# that failed on one platform retries just that platform.
# Without <targets>: the JSON array of versions with anything left to build.
set -euo pipefail
engine=$1 want=$2 targets=${3:-}
versions_only=; [ -n "$targets" ] || versions_only=1 targets='[
  {"platform": "macos-arm64", "triple": "aarch64-apple-darwin"},
  {"platform": "macos-x64", "triple": "x86_64-apple-darwin"},
  {"platform": "linux-x64", "triple": "x86_64-unknown-linux-gnu"},
  {"platform": "linux-arm64", "triple": "aarch64-unknown-linux-gnu"},
  {"platform": "windows-x64", "triple": "x86_64-pc-windows-msvc"}]'
targets=$(jq -c --arg e "$engine" --slurpfile v versions.json \
  '[.[] | select(.platform as $p | $v[0][$e].platforms | index($p))]' <<<"$targets")
out='[]'
for v in $(jq -r --arg e "$engine" '.[$e].versions[]' versions.json); do
  if [ "$want" = all ]; then
    have=$(gh release view "$engine-$v" --repo "$GITHUB_REPOSITORY" --json assets -q '[.assets[].name]' 2>/dev/null || echo '[]')
  elif [ "$want" = "$v" ]; then
    have='[]'
  else
    continue
  fi
  # A target counts as published once its tarball and .sha256 are both there.
  out=$(jq -c --arg e "$engine" --arg v "$v" --argjson have "$have" --argjson t "$targets" \
    '. + [$t[] | select(("\($e)-\($v)-\(.triple).tar.gz" as $f | ($have | index($f)) and ($have | index($f + ".sha256"))) | not) | {version: $v, target: .}]' <<<"$out")
done
if [ "$want" != all ] && [ "$out" = '[]' ]; then echo "$engine $want isn't in versions.json" >&2; exit 1; fi
if [ -n "$versions_only" ]; then jq -c '[.[].version] | unique' <<<"$out"; else echo "$out"; fi
