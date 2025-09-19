#!/bin/sh
# Build a Debian package for toolbox.sh using dpkg-deb
set -eu

pkg_root=$(CDPATH= cd -- "$(dirname -- "$0")"/../.. && pwd -P)
version=$(sed -n '1p' "$pkg_root/VERSION")
dist_dir="$pkg_root/dist"
tmpdir=$(mktemp -d)
stage="$tmpdir/toolbox"
output_tmp="$tmpdir/toolbox_${version}_all.deb"
output="$dist_dir/toolbox_${version}_all.deb"

command -v dpkg-deb >/dev/null 2>&1 || { echo "dpkg-deb not found; install dpkg-dev" >&2; exit 1; }

trap 'rm -rf "$tmpdir"' EXIT INT HUP TERM

mkdir -p "$stage/DEBIAN" "$stage/usr/lib/toolbox" "$stage/usr/bin"

copy_tree() {
  src=$1
  dest=$2
  [ -d "$src" ] || return 0
  mkdir -p "$dest"
  cp -R "$src"/. "$dest"/
}

copy_tree "$pkg_root/bin" "$stage/usr/lib/toolbox/bin"
copy_tree "$pkg_root/lib" "$stage/usr/lib/toolbox/lib"
copy_tree "$pkg_root/tools" "$stage/usr/lib/toolbox/tools"
copy_tree "$pkg_root/templates" "$stage/usr/lib/toolbox/templates"
copy_tree "$pkg_root/docs" "$stage/usr/lib/toolbox/docs"
copy_tree "$pkg_root/tests" "$stage/usr/lib/toolbox/tests"

for file in README.md AGENTS.md TODO.md VERSION; do
  [ -f "$pkg_root/$file" ] && cp "$pkg_root/$file" "$stage/usr/lib/toolbox/"
done

cp "$pkg_root/packaging/deb/toolbox-wrapper.sh" "$stage/usr/bin/toolbox"

size_kb=$(du -sk "$stage/usr" | cut -f1)

cat > "$stage/DEBIAN/control" <<CONTROL
Package: toolbox
Version: $version
Section: utils
Priority: optional
Architecture: all
Maintainer: Toolbox.sh Maintainers <maintainers@example.com>
Installed-Size: $size_kb
Depends: dash | bash
Description: POSIX shell CLI toolkit and generator
 Portable dispatcher, libraries, and project generator for POSIX shell CLIs.
CONTROL

dpkg-deb --build "$stage" "$output_tmp" >/dev/null

mkdir -p "$dist_dir"
mv "$output_tmp" "$output"

echo "Built $output"
