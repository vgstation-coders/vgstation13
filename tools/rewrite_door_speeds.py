import glob, sys, os, traceback, fnmatch, argparse

import re

from byond.DMI import DMI
from byond.DMI.utils import *

reg = re.compile(r'state = "(.+?)"\n\tdirs = ([0-9]+)\n\tframes = ([0-9]+)\n\tdelay = ([0-9,]+)\n')

for file in glob.glob("*.dmi"):
    dmi = DMI(file)
    new_header = dmi.getHeader()

    matches = reg.finditer(new_header)

    for match in matches:
        name = match.group(1)
        frames = match.group(4)
        numframes = match.group(3)

        start = match.start()
        print "{} at: {}".format(name, start)

        if "door_opening" in name or "door_closing" in name:
            begining = new_header[0:start]
            string = new_header[start:len(new_header)]
            new_frame = frames.replace("2", "1")
            string = string.replace(frames, new_frame, 1) # maxreplace=

            new_header = begining + string

    dmi.setHeader(new_header, file)



    #print new_header

    #dmi.setHeader("new_header", "new/{}".format(file))