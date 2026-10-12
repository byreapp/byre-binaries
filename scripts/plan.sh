#!/usr/bin/env bash
# Prints the JSON array of <engine> versions to build.
#   plan.sh <engine> all      versions in versions.json not yet fully published
#   plan.sh <engine> <ver>    just that version (must be in versions.json)
# "Fully published" = the <engine>-<ver> release has a tarball + .sha256 for
# every platform listed, so a run that failed on one platform gets retried.
set -euo pipefail
engine=$1 want=$2
want_assets=$(( $(jq --arg e "$engine" '.[$e].platforms | length' versions.json) * 2 ))
out=()
for v in $(jq -r --arg e "$engine" '.[$e].versions[]' versions.json); do
  if [ "$want" = all ]; then
    have=$(gh release view "$engine-$v" --repo "$GITHUB_REPOSITORY" --json assets -q '.assets | length' 2>/dev/null || echo 0)
    [ "$have" -ge "$want_assets" ] && continue
  elif [ "$want" != "$v" ]; then
    continue
  fi
  out+=("$v")
done
if [ "$want" != all ] && [ ${#out[@]} -eq 0 ]; then echo "$engine $want isn't in versions.json" >&2; exit 1; fi
printf '%s\n' "${out[@]}" | jq -Rnc '[inputs | select(length > 0)]'
