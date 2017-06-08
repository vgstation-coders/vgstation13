#!/usr/bin/env python3

from PIL import Image
import os
import sys
import argparse
import itertools
import random
with open(os.devnull, "w") as f:
    old = sys.stdout
    sys.stdout = f
    from byond import DMI, directions
    sys.stdout = old


# WARNING: sprite details are highly hardcoded. Modify at own risk.
SECTIONS = [
    (0,  0, 6,  6), (7,  0, 25,  6), (26,  0, 32,  6),
    (0,  7, 6, 25), (7,  7, 25, 25), (26,  7, 32, 25),
    (0, 26, 6, 32), (7, 26, 25, 32), (26, 26, 32, 32)
]
# Rivet color to ignore blending on.
RIVET_COLOR = (57, 57, 57, 255)
DARK_COLOR = (71, 71, 71, 255)
TEMPLATE = "shuttle_gen_template.png"
# First tuple is light color, second is dark color.
COLORS = {
    "g":  (( 78,  78,  78), ( 71,  71,  71)),
    "dg": (( 73,  73,  73), ( 69,  69,  69)),
    "b":  (( 61,  78,  92), ( 54,  70,  84)),
    "w":  ((231, 231, 231), (207, 207, 207)),
    "y":  ((126, 121,  43), (114, 109,  30)),
    "r":  ((115,  48,  48), (105,  44,  44))
}

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("template", help="The template to use to build the state.")
    parser.add_argument("dmifile", help="The DMI file to write the state into. Created if it doesn't exist yet.")

    namespace = parser.parse_args()
    template_image = Image.open(TEMPLATE)
    template = None
    regen = False

    if namespace.template == "REGENERATE":
        regen = True

    else:
        template = namespace.template.split("-")
        template = list(map(lambda x: COLORS[x], template))

    if not regen and len(template) != len(SECTIONS):
        print("Invalid template.")
        exit(1)

    dmi = None
    if os.path.exists(namespace.dmifile):
        with open(namespace.dmifile, "rb") as f:
            dmi = DMI.DMI(f)
            dmi.loadAll()
        dmi.filename = namespace.dmifile

    elif regen:
        print("DMI does not exist, cannot regen.")
        exit(1)

    else:
        dmi = DMI.DMI(namespace.dmifile)

    if regen:
        for state in dmi.states.keys():
            subtmpl = state.split("-")
            if len(subtmpl) == len(SECTIONS):
                dmi.states[state] = generate_single_state(map(lambda x: COLORS[x], subtmpl), state, template_image)


    else:
        test_template_dupe(dmi, namespace.template.split("-"))
        state = generate_single_state(template, namespace.template, template_image)
        dmi.states[namespace.template] = state

    dmi.save(namespace.dmifile)

# Test the format strings to see if rotated versions already exist in the DMI, to prevent messes.
def test_template_dupe(dmi, template):
    tests = [
        # Yes I had paint open while writing these down.
        "{0}-{1}-{2}-{3}-{4}-{5}-{6}-{7}-{8}", # south-facing
        "{6}-{3}-{0}-{7}-{4}-{1}-{8}-{5}-{2}", # west-facing
        "{8}-{7}-{6}-{5}-{4}-{3}-{2}-{1}-{0}", # north-facing
        "{2}-{5}-{8}-{1}-{4}-{7}-{0}-{3}-{6}"  # east-facing
    ]

    for test in tests:
        formatted = test.format(*template)
        if formatted in dmi.states:
            print("conflicts with existing (possibly rotated) DMI state: {}".format(formatted))
            exit(1)

def generate_single_state(template, template_name, template_image):
    state = DMI.State(template_name)
    state.dirs = 4
    state.icons = [None] * 4
    state.frames = 1

    new = template_image.convert("RGBA")
    pixels = new.load()
    for (color, sections) in zip(template, SECTIONS):
        for x in range(sections[0], sections[2]):
            for y in range(sections[1], sections[3]):
                pixel = None
                if pixels[x, y] == DARK_COLOR:
                    pixel = color[1]

                elif pixels[x, y] == RIVET_COLOR:
                    continue

                else:
                    pixel = color[0]

                pixel = (random.randint(-1, 1) + pixel[0], random.randint(-1, 1) + pixel[1], random.randint(-1, 1) + pixel[2], 255)
                pixels[x, y] = pixel

    state.setFrame(directions.SOUTH, 0, new.copy())
    state.setFrame(directions.NORTH, 0, new.rotate(180))
    state.setFrame(directions.WEST, 0, new.rotate(270))
    state.setFrame(directions.EAST, 0, new.rotate(90))

    return state

if __name__ == '__main__':
    main()
