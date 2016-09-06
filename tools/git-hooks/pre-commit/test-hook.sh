#!/bin/sh

# This git hook runs optipng on any staged PNG (and DMI, obviously) before committing, and
# updates the staged one with its optimized version automatically. optipng preserves PNG comments
# by default, avoiding breaking DMI files.
#
# The script should be POSIX standard enough that you shouldn't encounter any problem using it,
# provided your shell can find optipng.
#
# To install, just use the install-hooks.sh file provided in this directory, or copy this
# file manually to .git/hooks. Remember that it needs execution permissions in order to work.
#
# If something breaks, bark at wwjnc.

mkdir testdir
exit 0
