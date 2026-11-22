#!/usr/bin/env python3
import os
import shutil

import travis_utils

def main():
    if os.environ.get("DM_UNIT_TESTS") != "1":
        print("DM_UNIT_TESTS is not set, not running tests.")
        return

    dmb = "vgstation13.dmb"

    executable = "DreamDaemon"
    dreamdaemon = shutil.which(executable)
    if not dreamdaemon:
        print("Unable to find {}.".format(executable))
        exit(1)

    code = travis_utils.run_command([dreamdaemon, dmb, "-close", "-trusted"])
    exit(code)

if __name__ == "__main__":
    main()
