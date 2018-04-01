#!/bin/sh

# post-rewrite is also invoked by amend, so we only want rebase commands
if [ $1 == "rebase" ]; then
	REPO_ROOT=`git rev-parse --show-toplevel`
	source "$REPO_ROOT/tools/git-hooks/install-hooks.sh"
fi;