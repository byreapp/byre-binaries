#!/usr/bin/env bash
# Makes the install tree at <root> relocatable on Linux:
#   - copies every shared lib it links that isn't part of glibc/libgcc/libstdc++
#     (openssl, icu, lz4, …) into lib/
#   - sets each ELF's RUNPATH to $ORIGIN/<relative path to lib> (keeping any
#     $ORIGIN entries the build added, e.g. MySQL's lib/private)
#   - fails if anything resolves outside the tree (or not at all) afterwards.
set -euo pipefail
root=$(cd "$1" && pwd)
lib="$root/lib"
mkdir -p "$lib"
# Present on every glibc distro; everything else gets bundled.
system='^(linux-vdso|linux-gate|ld-linux[^ ]*|libc|libm|libdl|libpthread|librt|libresolv|libutil|libgcc_s|libstdc\+\+)\.so'

elfs() { find "$root" -type f ! -name '*.a' ! -name '*.o' -print0 | xargs -0 file | grep -E 'ELF .*(executable|shared object)' | cut -d: -f1 | sort -u; }
deps() { ldd "$1" 2>/dev/null | awk '/=>/ {print $1, $3}'; }

# ldd resolves transitively, so one pass over the original tree finds them all.
for f in $(elfs); do
  while read -r name path; do
    [[ $name =~ $system ]] && continue
    case "$path" in "$root"/*|not) continue;; esac
    [ -e "$lib/$name" ] || { cp -L "$path" "$lib/$name"; chmod u+w "$lib/$name"; }
  done < <(deps "$f")
done

for f in $(elfs); do
  readelf -d "$f" 2>/dev/null | grep -q NEEDED || continue # static
  rel=$(realpath --relative-to="$(dirname "$f")" "$lib")
  rp='$ORIGIN'; [ "$rel" = . ] || rp="\$ORIGIN/$rel"
  old=$(patchelf --print-rpath "$f" 2>/dev/null || true)
  for e in ${old//:/ }; do
    if [[ $e == '$ORIGIN'* && $e != "$rp" ]]; then rp="$rp:$e"; fi
  done
  patchelf --set-rpath "$rp" "$f"
done

bad=0
for f in $(elfs); do
  while read -r name path; do
    [[ $name =~ $system ]] && continue
    case "$path" in "$root"/*) ;; *) echo "$f: $name => $path"; bad=1;; esac
  done < <(deps "$f")
done
[ $bad = 0 ] && echo "relocate-linux: $(elfs | wc -l) ELF files OK"
exit $bad
