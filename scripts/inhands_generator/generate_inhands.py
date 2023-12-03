#!/bin/python3
from PIL import Image
from PIL import ImageChops
import argparse
import os
from collections import namedtuple

class Offsets:
    def __init__(self, xs=0, ys=0, xn=0, yn=0, xe=0, ye=0, xw=0, yw=0):
        self.south = (xs, ys)
        self.north = (xn, yn)
        self.east = (xe, ye)
        self.west = (xw, yw)

zero_offsets = Offsets()

class SpriteDirs:
    def __init__(self, s=None, n=None, e=None, w=None):
        self.south = s
        self.north = n
        self.east = e
        self.west = w
    
    def __iter__(self):
        yield ('south', self.south)
        yield ('north', self.north)
        yield ('east', self.east)
        yield ('west', self.west)

Hands = namedtuple('Hands', ['right', 'left'])

# Scales the sprite down using nearest neighbour downsampling
def resize_sprite(sprite, scale=0.5, resampler=Image.Resampling.NEAREST):
    width, height = sprite.size
    new_width = int(width * scale)
    new_height = int(height * scale)
    
    resized = sprite.resize((new_width, new_height), resampler)
    return resized

# Mirrors a sprite and then translates it left by 1 pixel if it's an odd number of pixels in width
def mirror_and_translate(sprite, force_translate=False):
    flipped = sprite.transpose(method=Image.Transpose.FLIP_LEFT_RIGHT)
    bbox = flipped.getbbox()
    width = bbox[2] - bbox[1]
    if (width % 2 == 1) or force_translate:
        shifted = ImageChops.offset(flipped, -1, 0)
        flipped.close()
        return shifted
    else:
        return flipped

# Creates an inhand image for the given sprite and mask
# scaled_sprite and mask are PIL images
# the sprite should already be downscaled to the desired size and then re-centered
# returns a PIL image containing the inhand
def create_inhand(scaled_sprite, mask, x_offset=0, y_offset=0):
    canvas = Image.new("RGBA", mask.size, (0, 0, 0, 0))
    canvas.paste(scaled_sprite, (x_offset, y_offset))
    combined = Image.new("RGBA", mask.size, (0, 0, 0, 0))
    combined.paste(canvas, (0, 0), mask)
    return combined

# Creates inhand images for all 4 directions for the given sprite
# sprite should be a PIL image, and masks should be a Hands namedtuple containing
# SpriteDirs objects for right and left hand
# returns a namedtuple with two SpriteDirs with 4 PIL images for each direction,
# contained in the 'right' and 'left' fields
def create_inhands(sprite, masks, scale=0.5, offsets=zero_offsets, mode="mirror", mirror_behind=False, resampler=Image.Resampling.NEAREST):
    righthand_dirs = SpriteDirs()
    lefthand_dirs = SpriteDirs()
    scaled_sprite = resize_sprite(sprite, scale, resampler)
    for facing, maskimg in masks.right:
        offset = getattr(offsets, facing)
        
        scaled_sprite_mirrored = None
        r_img = None
        if mirror_behind:
            scaled_sprite_mirrored = mirror_and_translate(scaled_sprite)
        
        if mirror_behind and facing == "west": #behind for right hand
            r_img = create_inhand(scaled_sprite_mirrored, maskimg, offset[0], offset[1])
        else:
            r_img = create_inhand(scaled_sprite, maskimg, offset[0], offset[1])
        setattr(righthand_dirs, facing, r_img)
        
        l_img = None
        m_facing = facing
        if facing == "west":
            m_facing = "east"
        elif facing == "east":
            m_facing = "west"
        if mode=="mirror":
            l_img = mirror_and_translate(r_img)
            setattr(lefthand_dirs, m_facing, l_img)
        else:
            t_offset = getattr(offsets, m_facing)
            t_x = 32 - scaled_sprite.width - t_offset[0] + 1
            t_y = offset[1]
            l_mask = getattr(masks.left, facing)
            if mirror_behind and facing == "east": #behind for left hand
                l_img = create_inhand(scaled_sprite_mirrored, l_mask, t_x, t_y)
            else:
                l_img = create_inhand(scaled_sprite, l_mask, t_x, t_y)
            setattr(lefthand_dirs, facing, l_img)
            
    return Hands(right=righthand_dirs, left=lefthand_dirs)

# Opens an image and converts it to mode if it's not already that mode
def open_and_convert(path, mode="RGBA"):
    img = Image.open(path)
    if img.mode != mode:
        img = img.convert(mode)
    return img

# south, north, east, west: file paths
# returns a Hands namedtuple with two SpriteDirs for right and left hand
def open_masks(south, north, east, west):
    r_southimg = open_and_convert(south, "L")
    r_northimg = open_and_convert(north, "L")
    r_eastimg = open_and_convert(east, "L")
    r_westimg = open_and_convert(west, "L")
    l_southimg = mirror_and_translate(r_southimg, True)
    l_northimg = mirror_and_translate(r_northimg, True)
    l_eastimg = mirror_and_translate(r_westimg, True) #note how this is actually the mirrored west
    l_westimg = mirror_and_translate(r_eastimg, True) #and vice versa
    
    right = SpriteDirs(r_southimg, r_northimg, r_eastimg, r_westimg)
    left = SpriteDirs(l_southimg, l_northimg, l_eastimg, l_westimg)
    return Hands(right=right, left=left)

def close_masks(masks):
    for _, v in masks._asdict().items():
        for _, mask in v:
            mask.close()

def save_inhands(inhands, orig_file, outdir):
    orig_name, orig_ext = os.path.splitext(os.path.basename(orig_file))
    for hand, dirs in inhands._asdict().items():
        for direction, sprite in dirs:
            subdir = os.path.join(outdir, orig_name, '')
            os.makedirs(subdir, exist_ok=True)
            outpath = subdir + hand + "_" + direction + orig_ext
            sprite.save(outpath)

class AddTrailingSlash(argparse.Action):
    def __call__(self, parser, namespace, values, option_string=None):
        setattr(namespace, self.dest, os.path.join(values, ''))

def main():
    parser = argparse.ArgumentParser(
        prog='generate-inhands',
        description='Generate inhand icons from a directory of sprites.')
    
    parser.add_argument('-q', '--quiet', help='Quiet output', action='store_true')
    parser.add_argument('-o', '--outdir', help='Output directory', required=True, action=AddTrailingSlash)
    
    parser.add_argument('--mode', help='Which mode to use for off-hand sprites. Default: "mirror".', choices=['translate', 'mirror'], default="mirror")
    parser.add_argument('--mirror', help='If set, mirrors the sprite before generating inhands for it. This may look better on sprites that are facing towards the left. Can be combined with mirror-behind.', action='store_true')
    parser.add_argument('--mirror-behind', help='If set, mirrors east/west inhands that are behind the character. This may look better on sprites that are facing towards the right.', action='store_true')
    
    parser.add_argument('--filter', help='Sets the resampling filter. Default: nearest', default='nearest', choices=['nearest', 'box', 'bilinear', 'hamming', 'bicubic', 'lanczos'])
    
    parser.add_argument('--mask-south', help='South transparency mask', default='mask_south.png')
    parser.add_argument('--mask-north', help='North transparency mask', default='mask_north.png')
    parser.add_argument('--mask-east', help='East transparency mask', default='mask_east.png')
    parser.add_argument('--mask-west', help='West transparency mask', default='mask_west.png')
    
    parser.add_argument('-xs', '--x-south-offset', help='South facing X coordinate offset', type=int, default=0)
    parser.add_argument('-ys', '--y-south-offset', help='South facing Y coordinate offset', type=int, default=0)
    parser.add_argument('-xn', '--x-north-offset', help='North facing X coordinate offset', type=int, default=0)
    parser.add_argument('-yn', '--y-north-offset', help='North facing Y coordinate offset', type=int, default=0)
    parser.add_argument('-xe', '--x-east-offset', help='East facing X coordinate offset', type=int, default=0)
    parser.add_argument('-ye', '--y-east-offset', help='East facing Y coordinate offset', type=int, default=0)
    parser.add_argument('-xw', '--x-west-offset', help='West facing X coordinate offset', type=int, default=0)
    parser.add_argument('-yw', '--y-west-offset', help='West facing Y coordinate offset', type=int, default=0)
    
    parser.add_argument('-s', '--scale', help='Inhand scaling multiplier. Default: 0.5', type=float, default=0.5)
    
    parser.add_argument('files', metavar='files', nargs='*', help='List of files to generate inhands for')
    
    args = parser.parse_args()
    quiet = args.quiet
    
    resampler = None
    match args.filter:
        case 'nearest':
            resampler = Image.Resampling.NEAREST
        case 'box':
            resampler = Image.Resampling.BOX
        case 'bilinear':
            resampler = Image.Resampling.BILINEAR
        case 'hamming':
            resampler = Image.Resampling.HAMMING
        case 'bicubic':
            resampler = Image.Resampling.BICUBIC
        case 'lanczos':
            resampler = Image.Resampling.LANCZOS
        case _:
            raise ValueError("invalid resampling filter specified")
    
    if not os.path.exists(args.outdir):
        os.makedirs(args.outdir)
        if not quiet:
            print(f"Created directory {args.outdir}")
    
    offsets = Offsets(
        args.x_south_offset,
        args.y_south_offset,
        args.x_north_offset,
        args.y_north_offset,
        args.x_east_offset,
        args.y_east_offset,
        args.x_west_offset,
        args.y_west_offset)
    
    #We close this manually later to avoid creating too much indentation
    masks = open_masks(args.mask_south, args.mask_north, args.mask_east, args.mask_west)
    
    for f in args.files:
        with open_and_convert(f) as sprite:
            if args.mirror:
                mirrored = mirror_and_translate(sprite)
                sprite.close()
                sprite = mirrored
            inhands = create_inhands(sprite, masks, args.scale, offsets, mode=args.mode, mirror_behind=args.mirror_behind, resampler=resampler)
            save_inhands(inhands, f, args.outdir)
            if not quiet:
                print(f"Created inhands for {f}")
    
    close_masks(masks)

if __name__ == '__main__':
    main()
