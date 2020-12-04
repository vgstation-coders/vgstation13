#!/usr/bin/env python3
import sys
import os
from PIL import Image

"""
Find duplicate icon states in DMI files.
"""

__author__ = "Damian"
__version__ = "0.1.0"
__license__ = "WTFPL"


def file_contains_duplicate_icon_states(filename: str):
    try:
        image = Image.open(filename)
    except:
        print(f"{filename}: An error occurred opening this file.")
        return True # whatever, you get the point, something's wrong
    desc = image.info["Description"]
    states = set()
    output = False
    for line in desc.splitlines():
        if not line.startswith("state = \""):
            continue
        state_name = line[9:-1]
        if state_name in states:
            print(f"{filename}: duplicate icon state: {state_name}")
            output = True
        else:
            states.add(state_name)
    return output

def main():
    if(len(sys.argv) != 2):
        print("You must pass a file or directory as the first argument.")
        sys.exit(1)

    path = sys.argv[1]
    if os.path.isfile(path):
        sys.exit(file_contains_duplicate_icon_states(path))

    elif os.path.isdir(path):
        exit_code = 0
        for root, dirs, files in os.walk(path):
            for file in files:
                if not file.endswith(".dmi"):
                    continue
                if file_contains_duplicate_icon_states(os.path.join(root, file)):
                    exit_code += 1
        sys.exit(exit_code)
    else:
        print("Argument was not a file nor a directory. What are you doing?")
        sys.exit(-1)

if __name__ == "__main__":
    main()
