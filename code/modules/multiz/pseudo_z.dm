// Out-of-bounds only.

/area/lowerlevel
	name = "lower level"
	icon_state = "yellow"
	var/darken_color = "#666666"
	var/initialized = FALSE


/area/lowerlevel/initialize()
	if(initialized)
		return
	initialized = TRUE
	for(var/turf/T in contents)
		T.color = darken_color
	for(var/obj/O in contents)
		O.color = darken_color
		O.filters += filter(type="drop_shadow", x=0, y=-2, size=4, color="#04080FAA")


/area/lowerlevel/two
	darken_color = "#444444"

/area/lowerlevel/three
	darken_color = "#272727"


/*

/*

What this is:

Fake-z mapping areas, used for creating  areas that appear as if they were on a different z-level.
This allows mappers to create zones with some "depth", without involving the whole multi-z system.
As a result, these "fake z levels" can't overlap with each other like a proper z level would.

*/


#define DARKENING_COLOR_1 "#777777"
#define DARKENING_COLOR_2 "#555555"
#define DARKENING_COLOR_3 "#333333"



/area/pseudo_z/
	var/darkening_color = "#FFFFFF"
	var/initialized
	var/pseudo_z_level = 0 	// 0 = base level. Max is 3.

	var/obj/effect/pseudo_z_overlay_holder/pseudo_holder = null

	icon_state = "yellow"

/area/pseudo_z/New()
	..()
	pseudo_holder = new(src)

/area/pseudo_z/level1
	darkening_color = DARKENING_COLOR_1
	pseudo_z_level = 1

/area/pseudo_z/level2
	darkening_color = DARKENING_COLOR_2
	pseudo_z_level = 2

/area/pseudo_z/level3
	darkening_color = DARKENING_COLOR_3
	pseudo_z_level = 3

/area/pseudo_z/initialize()
	..()
	if(initialized)
		return
	if(!pseudo_holder)
		pseudo_holder = new(src)
	initialized = TRUE
	for(var/turf/T in contents)
		pseudo_holder.add_turf(T)
		setup_border(T)

/area/pseudo_z/proc/setup_border(turf/T)
	for(var/dir in cardinal)
		var/turf/T2 = get_step(T, dir)
		if(pseudo_z_crossable(T, T2))
			var/obj/effect/pseudo_z_border_holder/holder = new /obj/effect/pseudo_z_border_holder(src)
			holder.dir = dir
			holder.setup_border_dummy()

/area/pseudo_z/proc/remove_border(turf/T)
	for(var/obj/effect/pseudo_z_border_holder/holder in T.contents)
		holder.remove_border_dummy()
		qdel(holder)



/area/proc/get_lighting_color_mult()
	return list(1,1,1)

/area/pseudo_z/get_lighting_color_mult()
	return list(0.5, 0.5, 0.5)


////

/obj/effect/pseudo_z_border_holder
	name = "border dummy holder"
	desc = "you shouldn't see this"
	density = 0
	anchored = 1
	invisibility = 101
	mouse_opacity = 0
	var/area/pseudo_z/parent_area = null
	var/turf/linked = null

/obj/effect/pseudo_z_border_holder/New(area/A)
	..()
	if(!isturf(loc))
		stack_trace("Pseudo-Z Border holder created with a non-turf loc.")
		qdel(src)
		return
	parent_area = A
	linked = loc
	linked.register_event(/event/destroyed, src, nameof(src::handle_crossed()))

/obj/effect/pseudo_z_border_holder/Destroy()
	linked.unregister_event(/event/destroyed, src, nameof(src::handle_crossed()))
	..()

// Crossed() isn't suitable here because we want to check which turf the atom is coming from, so the event is used instead.
/obj/effect/pseudo_z_border_holder/proc/handle_crossed(atom/movable/mover, location, oldloc)
	if(!pseudo_z_connected(location, oldloc))
		mover.visible_message("<span class='warning'>[mover] climbs down to [linked].</span>")		// temp

////

/obj/effect/pseudo_z_overlay_holder
	name = "open space"
	desc = "you shouldn't see this"
	density = 0
	anchored = 1
	plane = LIGHTING_PLANE
	layer = MAPPING_AREA_LAYER
	mouse_opacity = 0
	icon = 'icons/turf/areas.dmi'
	icon_state = "dark"
	var/area/pseudo_z/parent_area = null

/obj/effect/pseudo_z_overlay_holder/New(area/A)
	..()
	parent_area = A
	update()

/obj/effect/pseudo_z_overlay_holder/proc/update()
	if (!parent_area)
		return

	switch(parent_area.pseudo_z_level)
		if(-INFINITY to 0)
			icon_state = ""
		if(1)
			icon_state = "dark128"
		if(2)
			icon_state = "dark160"
		if(3 to INFINITY)
			icon_state = "dark"


/obj/effect/pseudo_z_overlay_holder/proc/add_turf(turf/T)
	T.vis_contents |= src


/obj/effect/pseudo_z_overlay_holder/proc/remove_turf(turf/T)
    T.vis_contents -= src

////

// Returns TRUE if both atom are on the same "pseudo-z" level, or if neither are pseudo z levels.
/proc/pseudo_z_connected(var/atom/first, var/atom/second)
	var/area/pseudo_z/A1 = get_area(first)
	var/area/pseudo_z/A2 = get_area(second)
	if((istype(A1) && istype(A2)) && (A1.pseudo_z_level == A2.pseudo_z_level))
		return TRUE
	if(!istype(A1) && !istype(A2))
		return TRUE
	return FALSE

// Returns TRUE if the first atom is on an equal or higher "pseudo-z" level.
/proc/pseudo_z_crossable(var/atom/first, var/atom/second)
	var/area/pseudo_z/A1 = get_area(first)
	var/area/pseudo_z/A2 = get_area(second)
	if((istype(A1) && istype(A2)) && A1.pseudo_z_level < A2.pseudo_z_level)
		return TRUE
	if(!istype(A1) && istype(A2))
		return TRUE
	return FALSE


// This has given me the biggest headache. Someone smarter than me should do this better.

// Biggest limitations of this implementation:
// 		- Doesn't work with multiple light sources on one tile.
// 		- Doesn't work with multiple objects facing different directions on one tile.
// I'm sure there's ways to fix this, but this is all OOB shit anyway and I've spent way too much time on this.

// "Why not just use an overlay over the whole tile?" Because objs which extend beyond their tiles (think: railings) get darkened by the overlay when they shouldnt

/*

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
		if(O.pseudo_z_exclude)
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
*/
*/

