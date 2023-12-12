from PIL import Image
from byond.DMI import DMI
from byond.DMI.State import State

NB_IMAGES = 10;

# https://stackoverflow.com/questions/765736/how-to-use-pil-to-make-all-white-pixels-transparent

for i in range(1,NB_IMAGES):
    im = Image.open(str(i) + ".png")
    im = im.convert("RGBA")
    pixels = im.getdata()
    new_pixels = []
    for pixel in pixels:
        whiteness = pixel[1]
        new_pixels.append((whiteness,whiteness,whiteness,255-whiteness))

    im.putdata(new_pixels)
    im.save(str(i) + "_trans.png", "PNG")
    name = "light_range_"+str(i);
    dmifile = DMI(name + ".dmi")
    sprite_size = 32 + i*64;
    dmifile.icon_height = sprite_size;
    dmifile.icon_width = sprite_size;
    state = State("white");
    state.icons.append(im);
    dmifile.states[state.name] = state;
    dmifile.save(name + ".dmi");
