/*

What this is:

A fake-z mapping area, used for creating out-of-bounds areas that appear as if they were on a different z-level.__vox_sound_meta_init
This allows mappers to create OOB areas with some "depth", without involving the whole multi-z system.
Why is this in the multi-z folder then? Because I had nowhere else to put it.

If you are doing something involving /actual/ multi-z, don't use any of this.

*/


#define DARKENING_COLOR_1 "#777777"
#define DARKENING_COLOR_2 "#555555"
#define DARKENING_COLOR_3 "#333333"
#define DARKENING_COLOR_ABYSS "#111111"




/area/fake_z/
	var/darkening_color = "#FFFFFF"
	icon_state = "yellow"

/area/fake_z/level1
	darkening_color = DARKENING_COLOR_1

/area/fake_z/level2
	darkening_color = DARKENING_COLOR_2

/area/fake_z/level3
	darkening_color = DARKENING_COLOR_3

/area/fake_z/abyss
	name = "abyss"
	darkening_color = DARKENING_COLOR_ABYSS


/area/fake_z/initialize()
	..()
//	to_chat(world, "Setting up Fake-Z Area")
	for(var/turf/T in contents)
		new /atom/movable/fake_openspace(T, darkening_color)



/atom/movable/fake_openspace
	name = "open space"
	anchored = TRUE
	density = TRUE
	mouse_opacity = 0
	plane = ABOVE_TURF_PLANE

	var/obj_excludes = list(
		/obj/structure/shuttle/diag_wall
	)

// Sure, lets add the 15th million variable.
/obj/
	var/fake_z_exclude = FALSE


/proc/fake_z_connected(var/atom/first, var/atom/second)
	var/area/A1 = get_area(first)
	var/area/A2 = get_area(second)
	if((istype(A1, /area/fake_z) || istype(A2, /area/fake_z)) && (A1 != A2))
		return FALSE
	else
		return TRUE



// This has given me the biggest headache. Someone smarter than me should do this better.

// Biggest limitations of this implementation:
// 		- Doesn't work with multiple light sources on one tile.
// 		- Doesn't work with multiple objects facing different directions on one tile.
// I'm sure there's ways to fix this, but this is all OOB shit anyway and I've spent way too much time on this.

// "Why not just use an overlay over the whole tile?" Because objs which extend beyond their tiles (think: railings) get darkened by the overlay when they shouldnt

/atom/movable/fake_openspace/New(var/turf/loc, color)
	src.color = color

	var/image/I = image('icons/turf/open_space.dmi', loc, "lighting_transparent", layer)
	I.blend_mode = BLEND_MULTIPLY
	overlays += I

//	loc.filters += filter(type="drop_shadow", x=0, y=-2, size=4, color="#04080FAA")
	loc.density = TRUE

	for(var/mob/living/simple_animal/S in loc)
		S.color = color

	for(var/obj/O in loc)
		if(is_type_in_list(O.type, obj_excludes))
			continue
		if(O.fake_z_exclude)
			continue

/*
		//First we assume its form.
		underlays += O.appearance
*/

		O.filters += filter(type="drop_shadow", x=0, y=-2, size=4, color="#04080FAA")

		// This might not work with every object.
		O.color = color
		O.layer -= 1

/*
		// This works under the assumption that there is a maximum of one light source per turf.
		// Obviously, that's not always the case. But for an OOB area where we can control how many sources we map in, it should be OK.
		if(O.light)
			set_light(O.light_range, O.light_power, O.light_color)

		dir = O.dir // Yes, this is stupid too.


		//And then we kill the object.
		qdel(O)
*/

#undef DARKENING_COLOR_1
#undef DARKENING_COLOR_2
#undef DARKENING_COLOR_3
#undef DARKENING_COLOR_ABYSS
