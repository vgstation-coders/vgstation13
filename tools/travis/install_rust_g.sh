#!/usr/bin/env bash
# Downloads the prebuilt 32-bit Linux rust_g into the given directory
# (default ~/.byond/bin). The version comes from RUST_G_VERSION in
# dependencies.sh, the same pin the server build uses.
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
. "$repo_root/dependencies.sh"

dest="${1:-$HOME/.byond/bin}"
mkdir -p "$dest"

curl -fSsL --retry 5 --retry-all-errors -o "$dest/librust_g.so" \
	"https://github.com/tgstation/rust-g/releases/download/$RUST_G_VERSION/librust_g.so"
chmod +x "$dest/librust_g.so"
ldd "$dest/librust_g.so"
