
/* *********************************************************************
        _____      _     ______ _       _     _____
       / ____|    | |   |  ____| |     | |   |_   _|
      | |  __  ___| |_  | |__  | | __ _| |_    | |  ___ ___  _ __
      | | |_ |/ _ \ __| |  __| | |/ _` | __|   | | / __/ _ \| '_ \
      | |__| |  __/ |_  | |    | | (_| | |_   _| || (_| (_) | | | |
       \_____|\___|\__| |_|    |_|\__,_|\__| |_____\___\___/|_| |_|

                Created by David "DarkCampainger" Braun

            Released under the Unlicense (see Unlicense.txt)

                   Version 1.2 - August 27, 2013

            Please see 'demo/demo.dm' for the example usage
             Please see 'Documentation.html' for reference

*///////////////////////////////////////////////////////////////////////


// Associative list of [md5 values = Icon] for determining if the icon already exists
var/list/_flatIcons = list()

var/list/directional = list(
	/obj/machinery/door/window,
	/obj/machinery/power/emitter,
	/obj/structure/disposalpipe,
	/obj/machinery/atmospherics,
	/obj/structure/window,
	/obj/structure/window/full,
	/obj/structure/bed/chair,
	/obj/structure/table,
	/obj/machinery/light,
	/obj/machinery/door/airlock/multi_tile,
	/obj/machinery/camera,
	/obj/structure/bomberflame,
	/obj/machinery/door/firedoor/border_only,
	/obj/item/projectile,
	/obj/effect/beam/emitter,
	/obj/machinery/conveyor,
	/obj/machinery/gateway,
	/obj/structure/shuttle/engine,
	/obj/machinery/power/terminal,
	/obj/machinery/power/generator,
	/obj/structure/particle_accelerator,
	/obj/structure/hanging_lantern,
	/turf/simulated/wall/shuttle
	)

var/list/exception = list(
	/obj/structure/window/full,
	/obj/machinery/atmospherics/unary/tank
	)

// returns a list with of the atom's own icon as well as its overlays, sorted by plane and layers, with the lowest being the first in the list and the highest objects being last
/proc/plane_layer_sort(var/list/to_sort)
	var/list/sorted = list()
	for(var/current_atom in to_sort)
		var/compare_index
		for(compare_index = sorted.len, compare_index > 0, --compare_index) // count down from the length of the list to zero.
			var/atom/compare_atom = sorted[compare_index] // compare to the next object down the list.
			if (compare_atom:plane != FLOAT_PLANE && current_atom:plane == FLOAT_PLANE) // it's an overlay, always place it above
				break
			if(compare_atom.plane < current_atom:plane) // is this object below our current atom?
				break
			else if((compare_atom.plane == current_atom:plane) && (compare_atom.layer <= current_atom:layer))	// is this object below our current atom?
				break
		sorted.Insert(compare_index+1, current_atom) // insert it just above the atom it was higher than - or at the bottom if it was higher than nothing.
	return sorted // return the sorted list.

/proc/getFlatIcon(atom/A, dir, cache=1, exact=0) // 1 = use cache, 2 = override cache, 0 = ignore cache	//exact = 1 means the atom won't be rotated if it's a lying mob/living/carbon

	var/hash = "" // Hash of overlay combination

	if(is_type_in_list(A, directional)&&!is_type_in_list(A, exception))
		dir = A.dir
	else
		if(istype(A,/turf))
			var/c = directional_turfs.len
			directional_turfs -= A.icon_state
			if(c != directional_turfs.len)
				dir = A.dir
				directional_turfs += A.icon_state
			else
				dir = 2
		else
			dir = 2//ugly fix for atoms showing invisible on pictures if they don't have a 4-directional icon_state sprite and their dir isn't south(2)


	var/list/initialimage = list()
	// Add the atom's icon itself
	if(A.icon)
		// Make a copy without pixel_x/y settings
		if(A.pixel_x || A.pixel_y) //Lets assume any pixel shifted icon is directional
			dir = A.dir
		var/image/copy = image(icon=A.icon,icon_state=A.icon_state,layer=A.layer,dir=dir)
		initialimage[copy] = A.layer

	var/list/layers = plane_layer_sort(A.underlays)
	layers += initialimage
	layers += plane_layer_sort(A.overlays)


	if(cache!=0) // If cache is NOT disabled
		// Create a hash value to represent this specific flattened icon
		for(var/I in layers)
			hash += "\ref[I:icon],[I:icon_state],[I:dir != SOUTH ? I:dir : dir],[I:pixel_x],[I:pixel_y];_;"
		hash=md5(hash)

		if(cache!=2) // If NOT overriding cache
			// Check if the icon has already been generated
			if((hash in _flatIcons) && _flatIcons[hash])
				// Icon already exists, just return that one
				return _flatIcons[hash]

	var/icon/flat = icon('_flat_Blank.dmi') // Final flattened icon
	var/icon/add // Icon of overlay being added

		// Set current dimensions of flattened icon
	var/flatX1=1
	var/flatX2=1
	var/flatY1=1
	var/flatY2=1

		// Dimensions of overlay being added
	var/addX1
	var/addX2
	var/addY1
	var/addY2


	for(var/I in layers)
		if (!I:icon && !I:icon_state) // no icon nor icon_state? we're probably not meant to draw that. Possibly a blank icon while we're only interested in its overlays.
			continue

		var/layerdir = I:dir //We want overlays/underlays to use their correct directional icon state
		if(I == A || !layerdir)
			layerdir = dir
		var/icon_file = I:icon
		if (!icon_file)
			icon_file = A.icon
		var/icon_state = I:icon_state
		if (!icon_state)
			if (A.icon_state && I:icon && (A.icon_state in icon_states(I:icon)))
				icon_state = A.icon_state

		add = icon(icon_file
		         , icon_state
		         , layerdir
		         , 1
		         , 0)

		if(I:name == "damage layer")
			var/mob/living/carbon/human/H = A
			if(istype(H))
				for(var/datum/organ/external/O in H.organs)
					if(!(O.status & ORGAN_DESTROYED))
						if(O.damage_state == "00")
							continue
						var/icon/DI
						DI = H.get_damage_icon_part(O.damage_state, O.icon_name, (H.species.blood_color == DEFAULT_BLOOD ? "" : H.species.blood_color))
						add.Blend(DI,ICON_OVERLAY)

		if(!exact && iscarbon(A))
			var/mob/living/carbon/C = A
			if(C.lying && !isalienadult(C))//because adult aliens have their own resting sprite
				add.Turn(90)

		if(isobserver(A))
			add.ChangeOpacity(0.5)

		// Apply any color or alpha settings
		if(I:color || I:alpha != 255)
			var/rgba = (I:color || "#FFFFFF") + copytext(rgb(0,0,0,I:alpha), 8)
			add.Blend(rgba, ICON_MULTIPLY)

		// Find the new dimensions of the flat icon to fit the added overlay
		addX1 = min(flatX1, I:pixel_x+1)
		addX2 = max(flatX2, I:pixel_x+add.Width())
		addY1 = min(flatY1, I:pixel_y+1)
		addY2 = max(flatY2, I:pixel_y+add.Height())

		if(addX1!=flatX1 || addX2!=flatX2 || addY1!=flatY1 || addY2!=flatY2)
			// Resize the flattened icon so the new icon fits
			flat.Crop(addX1-flatX1+1, addY1-flatY1+1, addX2-flatX1+1, addY2-flatY1+1)
			flatX1=addX1;flatX2=addX2
			flatY1=addY1;flatY2=addY2

		// Blend the overlay into the flattened icon
		flat.Blend(add,ICON_OVERLAY,I:pixel_x+2-flatX1,I:pixel_y+2-flatY1)

	if(A.color)
		flat.Blend(A.color,ICON_MULTIPLY)

	if(cache!=0) // If cache is NOT disabled
		// Cache the generated icon in our list so we don't have to regenerate it
		_flatIcons[hash] = flat

	return flat

var/list/directional_turfs = list(	//jesus christ what am I doing.
	"red",
	"redcorner",
	"whitered",
	"whiteredcorner",
	"blue",
	"bluecorner",
	"whiteblue",
	"whitebluecorner",
	"green",
	"greencorner",
	"whitegreen",
	"whitegreencorner",
	"yellowsiding",
	"yellowcornersiding",
	"yellow",
	"yellowcorner",
	"whiteyellow",
	"whiteyellowcorner",
	"chapel",
	"enginewarncorner",
	"engineloadingarea",
	"enginewarn",
	"neutral",
	"neutralcorner",
	"orange",
	"orangecorner",
	"whitehall",
	"whitecorner",
	"arrival",
	"arrivalcorner",
	"escape",
	"escapecorner",
	"purple",
	"purplecorner",
	"whitepurple",
	"whitepurplecorner",
	"black",
	"blackcorner",
	"caution",
	"cautioncorner",
	"warning",
	"warningcorner",
	"brownold",
	"browncornerold",
	"brown",
	"browncorner",
	"carpetside",
	"carpetcorner",
	"carpet",
	"carpetsymbol",
	"redyellow",
	"redblue",
	"bluered",
	"redgreen",
	"greenyellow",
	"greenblue",
	"blueyellow",
	"podhatch",
	"podhatchcorner",
	"warnplate",
	"warnplatecorner",
	"warnwhite",
	"warnwhitecorner",
	"dark vault corner",
	"dark vault stripe",
	"loadingareadirty1",
	"loadingareadirty2",
	"asteroidwarning",
	"dark blue corner",
	"dark blue stripe",
	"dark brown corner",
	"dark brown stripe",
	"dark floor corner",
	"dark floor stripe",
	"dark green corner",
	"dark green stripe",
	"dark neutral corner",
	"dark neutral stripe",
	"dark orange corner",
	"dark orange stripe",
	"dark purple corner",
	"dark purple stripe",
	"dark red corner",
	"dark red stripe",
	"dark yellow corner",
	"dark yellow stripe",
	"dark loading",
	"darkpurple",
	"darkpurplecorners",
	"darkred",
	"darkredcorners",
	"darkblue",
	"darkbluecorners",
	"darkgreen",
	"darkgreencorners",
	"darkyellow",
	"darkyellowcorners",
	"darkbrown",
	"darkbrowncorners",
	"vault",
	"platingdrift",
	"snowcorner",
	"snowsurround",
	)
