#!/bin/bash
# Downloads 32-bit libcurl and its dependencies and unpacks them into the given
# directory, without installing them. BYOND is a 32-bit program and needs them.
# CI caches that directory and puts it on LD_LIBRARY_PATH when running BYOND.
set -euo pipefail

dest="$1"
work="$(mktemp -d)"
mkdir -p "$work/debs/partial" "$work/root" "$dest"

sudo dpkg --add-architecture i386
sudo apt-get update
sudo apt-get install -y --download-only --no-install-recommends -o Dir::Cache::archives="$work/debs" libcurl4t64:i386

for deb in "$work"/debs/*.deb; do
	case "$(basename "$deb")" in
		# The runner image has its own 32-bit libc and GCC runtime.
		# A second copy of libc next to the image's loader would crash.
		libc6_* | libgcc-s1_* | gcc-*-base_*) continue ;;
	esac
	dpkg -x "$deb" "$work/root"
done

for dir in "$work/root/lib/i386-linux-gnu" "$work/root/usr/lib/i386-linux-gnu"; do
	if [ -d "$dir" ] && [ ! -L "$dir" ]; then
		find "$dir" -maxdepth 1 -name '*.so*' -exec cp -a {} "$dest/" \;
	fi
done

sudo rm -rf "$work"
