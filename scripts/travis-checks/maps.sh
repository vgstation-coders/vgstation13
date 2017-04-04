#!/usr/bin/sh

# Quick explanation if you're not familiar with these commands
#
# find searches a filesystem using specific filters, in this case anything that ends with .dmm
# in the maps folder - so, any map files
# the -exec option causes it to execute a command for every filename or set of filenames found
# 
# awk is small scripting language - the format for this script is /regex condition/ { code }
# the code prints a line to output with the name of the input file and the bad assignment
# then returns an error code
find maps/ -name '*.dmm' -exec awk '/(step_[xy]|layer) ?=/ { printf "%s contains an assignment to %s\n", FILENAME, $1; exit 1  }' {} +

