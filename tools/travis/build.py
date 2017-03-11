#!/usr/bin/env python
from __future__ import print_function, unicode_literals
import argparse
import re
import distutils.spawn
import os
import sys

try:    
    import subprocess32 as subprocess
except ImportError:
    import subprocess


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("dme", help="The DME file to compile.")
    parser.add_argument("-M", "--mapfile", nargs="*", help="Extra map files to replace the regular map file in the DME with.")
    args = parser.parse_args()

    dme = args.dme
    if args.mapfile is not None:
        # Handle map file replacement.
        with open(dme, "r") as f:
            content = f.read()
        
        # Make string to replace the map include with.
        includes = ""
        for arg in args.mapfile:
            includes += "#include \"maps\\\\{}.dm\"\n".format(arg)
        
        MAP_INCLUDE_RE = re.compile(r"#include \"maps\\[a-zA-Z0-9][a-zA-Z0-9_]*\.dm\"")
        content = MAP_INCLUDE_RE.sub(includes, content, count=1)
        dme = "{}.mdme".format(dme)
        with open(dme, "w") as f:
            f.write(content)
    
    compiler = "DreamMaker"
    if sys.platform == "win32" or sys.platform == "cygwin":
        compiler = "dm"

    compiler = distutils.spawn.find_executable(compiler)
    if not compiler:
        print("Unable to find DM compiler.")
        exit(1)

    code = subprocess.call([compiler, dme])
    exit(code)

if __name__ == "__main__":
    main()
