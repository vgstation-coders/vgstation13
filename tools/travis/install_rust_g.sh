#!/usr/bin/env bash
set -euo pipefail

#rust_g git tag
RUST_G_VERSION=0.4.5

mkdir -p ~/.byond/bin
wget -O ~/.byond/bin/librust_g.so "https://github.com/tgstation/rust-g/releases/download/$RUST_G_VERSION/librust_g.so"
chmod +x ~/.byond/bin/librust_g.so
ldd ~/.byond/bin/librust_g.so
