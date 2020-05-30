#!/usr/bin/env python2
# Requires Pillow (fork of PIL) and BYONDTools.
# For Pillow you can just run "$ pip instal pillow" (without quotes) in a terminal.
# If your PATH doesn't include Python just go to %Python directory%/scripts/, it's in there.
# As for BYONDTools: download a ZIP of https://gitlab.com/N3X15/ByondTools, then run setup.py install from a terminal.
from __future__ import print_function
from byond.DMI import DMI
from byond.DMI.State import State
import PIL.Image
import os
import os.path
import argparse

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("dmifile", help="The DMIs to scale.", nargs="*", type=str)
    parser.add_argument("-r", "--recurse", help="In conjunction with taking in DMI files, makes the script also recurse through the provided directory to find DMI files.")
    args = parser.parse_args()

    if args.recurse:
        for dirpath, dirnames, filenames in os.walk(args.recurse):
            for filename in filenames:
                if (filename[-3:] != "dmi"):
                    continue

                args.dmifile.append(os.path.join(dirpath, filename))

    if len(args.dmifile) < 1:
        print("Unable to find any mapfiles to upscale.")
        exit()

    for fullpath in args.dmifile:
        try:
            print("Upscaling %s" % (fullpath))
            upscale(fullpath)

        except Exception as e:
            print("Error upscaling %s: %s" % (fullpath, e))


def upscale(dmifile):
    dmi = DMI(dmifile)
    dmi.loadAll()
    upscaled = DMI(dmifile)
    upscaled.icon_height = dmi.icon_height * 2
    upscaled.icon_width = dmi.icon_width * 2

    for state in dmi.states.values():
        new_state = State(state.name)
        new_state.frames = state.frames
        new_state.dirs = state.dirs
        new_state.movement = state.movement
        new_state.loop = state.loop
        new_state.rewind = state.rewind
        new_state.delay = state.delay

        for icon in state.icons:
            new_icon = icon.resize((upscaled.icon_width, upscaled.icon_height), PIL.Image.NEAREST)
            new_state.icons.append(new_icon)
        
        upscaled.states[new_state.name] = new_state

    upscaled.save(dmifile)

if __name__ == "__main__":
    main()