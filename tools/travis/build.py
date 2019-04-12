#!/usr/bin/env python3
import asyncio
import distutils.spawn
import re
import sys
import os

import travis_utils

MAP_INCLUDE_RE = re.compile(r"#include \"maps\\[a-zA-Z0-9][a-zA-Z0-9_]*\.dm\"")
dme = "vgstation13.dme"

def append_unit_tests_macros_to_compile_options_file():
    with open("__DEFINES/__compile_options.dm", "a") as file:
        file.write("#define UNIT_TESTS_ENABLED 1\n")
        file.write("#define UNIT_TESTS_AUTORUN 1\n")
        file.write("#define UNIT_TESTS_STOP_SERVER_WHEN_DONE 1\n")
        file.write("#define MAP_OVERRIDE 6\n")
        file.write("#define GAMETICKER_LOBBY_DURATION 2 SECONDS\n")

def append_maps_to_dme(maps):
    with open(dme, "r+") as f:
        content = f.read()
        includes = ""
        for arg in maps:
            includes += "#include \"maps\\\\{}.dm\"\n".format(arg)
        content = MAP_INCLUDE_RE.sub(includes, content, count=1)
        f.seek(0, 0)
        f.write(content)

def main():
    mapfiles = os.environ.get("ALL_MAPS") # Extra map files to replace the regular map file in the DME with.
    build_tests = os.environ.get("DM_UNIT_TESTS") == "1" # Whether to build unit tests or not.

    if build_tests is True:
        append_unit_tests_macros_to_compile_options_file()

    elif mapfiles is not None:
        append_maps_to_dme(mapfiles.split())

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
