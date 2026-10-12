#!/usr/bin/env bash
# Makes the install tree at <root> relocatable on macOS:
#   - copies every non-system dylib it links (Homebrew openssl, icu, …) into lib/
#   - rewrites those links and the tree's own absolute install names to @rpath/<name>
#   - gives every binary one rpath, @loader_path/<relative path to lib>
#   - drops absolute rpaths, re-signs (ad hoc), then fails if any /opt/homebrew,
#     /usr/local or build-prefix path is left in a load command.
# Link with -headerpad_max_install_names so the rewrites fit.
set -euo pipefail
root=$(cd "$1" && pwd)
lib="$root/lib"
mkdir -p "$lib"

machos() { find "$root" -type f ! -name '*.a' ! -name '*.o' -print0 | xargs -0 file | grep 'Mach-O' | cut -d: -f1 | sort -u; }
foreign() { case "$1" in /opt/homebrew/*|/usr/local/*|"$root"/*) return 0;; esac; return 1; }

# Copy a dependency and, recursively, what it links (absolute Homebrew paths or
# @loader_path siblings, as icu4c uses).
bundle() {
  local src=$1 name d
  name=$(basename "$src")
  [ -e "$lib/$name" ] && return 0
  cp -L "$src" "$lib/$name"; chmod u+w "$lib/$name"
  for d in $(otool -L "$src" | tail -n +2 | awk '{print $1}'); do
    case "$d" in
      /opt/homebrew/*|/usr/local/*) bundle "$d" ;;
      @loader_path/*) bundle "$(dirname "$(realpath "$src")")/${d#@loader_path/}" ;;
    esac
  done
}
for f in $(machos); do
  for dep in $(otool -L "$f" | tail -n +2 | awk '{print $1}'); do
    case "$dep" in /opt/homebrew/*|/usr/local/*) bundle "$dep" ;; esac
  done
done

for f in $(machos); do
  chmod u+w "$f"
  for dep in $(otool -L "$f" | tail -n +2 | awk '{print $1}'); do
    if foreign "$dep"; then install_name_tool -change "$dep" "@rpath/$(basename "$dep")" "$f"; fi
  done
  if otool -hv "$f" | grep -q DYLIB; then install_name_tool -id "@rpath/$(basename "$f")" "$f"; fi
  for rp in $(otool -l "$f" | awk '/LC_RPATH/{getline; getline; print $2}'); do
    case "$rp" in @*) ;; *) install_name_tool -delete_rpath "$rp" "$f";; esac
  done
  rel=$(python3 -c 'import os,sys; print(os.path.relpath(sys.argv[1], sys.argv[2]))' "$lib" "$(dirname "$f")")
  want="@loader_path/$rel"; [ "$rel" = . ] && want=@loader_path
  if ! otool -l "$f" | grep -q "path $want "; then install_name_tool -add_rpath "$want" "$f"; fi
  codesign --force -s - "$f" 2>/dev/null
done

# Verify: nothing may point outside the tree except /usr/lib and /System.
bad=0
for f in $(machos); do
  if otool -L "$f" | tail -n +2 | awk '{print $1}' | grep -vE '^(@rpath|@loader_path|@executable_path|/usr/lib/|/System/)'; then
    echo "^ leaked into $f"; bad=1
  fi
  if otool -l "$f" | awk '/LC_RPATH/{getline; getline; print $2}' | grep -v '^@'; then
    echo "^ absolute rpath in $f"; bad=1
  fi
done
[ $bad = 0 ] && echo "relocate-macos: $(machos | wc -l | tr -d ' ') Mach-O files OK"
exit $bad
