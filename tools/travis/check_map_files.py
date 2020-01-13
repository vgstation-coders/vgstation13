#!/usr/bin/env python3
# Checks the map files for bad strings like step_x, step_y and layer.
# Isn't smart enough to ignore string contents, however.
from __future__ import print_function
import sys
import os
import re

# Try using colorama for colored output, otherwise fall back to uncolored.
try:
    from colorama import init, Fore, Style
    init()

except ImportError:
    # Just give an empty string for everything, no colored output.
    class ColorDummy(object):
        def __getattr__(self, name):
            return ""

    Fore = ColorDummy()
    Style = ColorDummy()

BAD_STRINGS = {
    "step_x": re.compile(r"\bstep_x\b"),
    "step_y": re.compile(r"\bstep_y\b"),
    "layer": re.compile(r"\blayer\b"),
    "pixel_w" : re.compile(r"\bpixel_w\b") # This causes the map to require 511/512 to play on.
}

def main():
    if len(sys.argv) != 2:
        print(Fore.RED + "ERROR: Incorrect amount of arguments supplied: one needed." + Style.RESET_ALL)
        exit(1)

    passed = True
    rootpath = sys.argv[1]
    for root, _, files in os.walk(rootpath):
        for filename in files:
            if not checkfile(os.path.join(root, filename)):
                passed = False

    if not passed:
        exit(1)


def checkfile(filename):
    if not filename.endswith(".dmm"):
        return True

    retval = True
    print(Fore.CYAN + Style.DIM + "Checking file: {}".format(filename) + Style.RESET_ALL)
    with open(filename, "r") as f:
        for linenumber, line in enumerate(f.readlines()):
            for string, regex in BAD_STRINGS.items():
                if regex.search(line) != None:
                    print(Fore.RED + ("ERROR: '{}' found on line {}. Remove it, please."
                          .format(string, linenumber+1)) + Style.RESET_ALL)
                    retval = False

    return retval

if __name__ == '__main__':
    main()
