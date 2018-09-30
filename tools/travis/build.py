#!/usr/bin/env python3
import asyncio
import distutils.spawn
import re
import sys
import os

import travis_utils

MAP_INCLUDE_RE = re.compile(r"#include \"maps\\[a-zA-Z0-9][a-zA-Z0-9_]*\.dm\"")

def main():
    dme = os.environ.get("PROJECT_NAME") # The DME file to compile.
    if not dme:
        print("No project name specified.")
        exit(1)
    dme += ".dme"
    mapfiles = os.environ.get("ALL_MAPS") # Extra map files to replace the regular map file in the DME with.
    build_tests = os.environ.get("DM_UNIT_TESTS") == "1" # Whether to build unit tests or not.

    if build_tests is True and mapfiles is not None:
        print("Cannot run tests AND change maps at the same time, overriding ALL_MAPS.") # Because BYOND will cry "corrupt map data in world file"
        mapfiles = "test_tiny"

    if build_tests is True:
        with open(dme, "r+") as f:
            content = f.read()
            f.seek(0, 0)
            f.write("#define UNIT_TESTS\n" + content)

    if mapfiles is not None:
        with open(dme, "r+") as f:
            content = f.read()
            includes = ""
            for arg in mapfiles.split():
                includes += "#include \"maps\\\\{}.dm\"\n".format(arg)
            content = MAP_INCLUDE_RE.sub(includes, content, count=1)
            f.seek(0, 0)
            f.write(content)

    compiler = "DreamMaker"
    if sys.platform == "win32" or sys.platform == "cygwin":
        compiler = "dm"

    compiler = distutils.spawn.find_executable(compiler)
    if not compiler:
        print("Unable to find DM compiler.")
        exit(1)

    loop = travis_utils.get_platform_event_loop()
    code = loop.run_until_complete(travis_utils.run_with_timeout_guards([compiler, dme]))
    exit(code)


if __name__ == "__main__":
    main()
