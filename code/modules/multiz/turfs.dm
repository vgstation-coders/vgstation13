/turf/proc/CanZPass(atom/A, direction)
	if(z == A.z) //moving FROM this turf
		return direction == UP //can't go below
	else
		if(direction == UP) //on a turf below, trying to enter
			return 0
		if(direction == DOWN) //on a turf above, trying to enter
			return !density

/turf/simulated/open/CanZPass(atom, direction)
	return 1

/turf/space/CanZPass(atom, direction)
	return 1

//
// Open Space - "empty" turf that lets stuff fall thru it to the layer below
//

/turf/simulated/open
	name = "open space"
	icon = 'icons/turf/space.dmi'
	icon_state = ""
	desc = "\..."
	density = 0
	intact = 0 //No seriously, that's not a joke. Allows cable to be laid properLY on catwalks
	plane = OPENSPACE_PLANE_START
	//pathweight = 100000 //For lack of pathweights, mobdropping meta inc
	dynamic_lighting = 0 // Someday lets do proper lighting z-transfer.  Until then we are leaving this off so it looks nicer.
	var/turf/below

/turf/simulated/open/post_change()
	..()
	update()

/turf/simulated/open/initialize()
	..()
	ASSERT(HasBelow(z))
	update()

/turf/simulated/open/Entered(var/atom/movable/mover)
	..()
	mover.fall()

// Static list so it isn't slow in the check below
var/static/list/no_spacemove_turfs = list(/turf/simulated/wall,/turf/unsimulated/wall,/turf/unsimulated/mineral)

/turf/simulated/open/has_gravity()
	var/turf/below = GetBelow(src)
	if(!below)
		return 0
	// Turf checks for not spacemoving
	if(is_type_in_list(below, no_spacemove_turfs))
		return get_gravity()
	// Dense stuff below checks
	for(var/atom/A in below)
		if(A.density)
			return get_gravity()
	// Structure checks (these really should be turfs)
	if(locate(/obj/structure/catwalk) in src || locate(/obj/structure/lattice) in src)
		return get_gravity()
	return 0

/turf/simulated/open/can_place_cables()
	return TRUE

/turf/simulated/open/proc/update()
	plane = OPENSPACE_PLANE + src.z
	below = GetBelow(src)
	//turf_changed_event.register(below, src, /turf/simulated/open/update_icon)
	universe.OnTurfChange(below) //I think this is equivalent??
	levelupdate()
	for(var/atom/movable/A in src)
		A.fall()
	update_icon()

// override to make sure nothing is hidden
/turf/simulated/open/levelupdate()
	for(var/obj/O in src)
		O.hide(0)

/turf/simulated/open/examine(mob/user, distance, infix, suffix)
	if(..(user, 2))
		var/depth = 1
		var/list/checked_belows = list()
		for(var/turf/T = GetBelow(src); isopenspace(T); T = GetBelow(T))
			if(T.z in checked_belows) // To stop getting caught on this in infinite loops
				to_chat(user, "It looks bottomless.")
				return
			depth += 1
		to_chat(user, "It is about [depth] levels deep.")

/obj/effect/open_overlay
	name = "open overlay"
	desc = "The darkness of the abyss below"
	icon = 'icons/effects/32x32.dmi'
	icon_state = "white"
	layer = ABOVE_LIGHTING_LAYER
	plane = OPEN_OVERLAY_PLANE

/turf/simulated/open/update_icon()
	make_openspace_view()

/turf/simulated/proc/make_openspace_view()
	var/alpha_to_subtract = 127
	overlays.Cut()
	vis_contents.Cut()
	var/turf/bottom
	var/list/checked_belows = list()
	for(bottom = GetBelow(src); isopenspace(bottom); bottom = GetBelow(bottom))
		alpha_to_subtract /= 2
		if(bottom.z in checked_belows) // To stop getting caught on this in infinite loops
			return // Don't even render anything
		checked_belows.Add(bottom.z)

	if(!bottom || bottom == src)
		return
	var/obj/effect/open_overlay/overimage = new /obj/effect/open_overlay
	overimage.alpha = 255 - alpha_to_subtract
	overimage.color = rgb(0,0,0,overimage.alpha)
	vis_contents += bottom
	if(!istype(bottom,/turf/space)) // Space below us
		vis_contents.Add(overimage)
		return 1
	return 0

/turf/simulated/open/ChangeTurf(var/turf/N, var/tell_universe=1, var/force_lighting_update = 0, var/allow = 1)
	overlays.Cut()
	vis_contents.Cut()
	..()

/turf/simulated/floor/ChangeTurf(var/turf/N, var/tell_universe=1, var/force_lighting_update = 0, var/allow = 1)
	var/turf/simulated/open/BS = GetBelow(src)
	if(BS && (istype(BS,/turf/simulated/wall) || istype(BS,/turf/unsimulated/wall)) && isopenspace(N))
		return
	return ..()

/turf/unsimulated/floor/ChangeTurf(var/turf/N, var/tell_universe=1, var/force_lighting_update = 0, var/allow = 1)
	var/turf/simulated/open/BS = GetBelow(src)
	if(BS && (istype(BS,/turf/simulated/wall) || istype(BS,/turf/unsimulated/wall)) && isopenspace(N))
		return
	return ..()

//This segment of code copied directly from space.dm

/turf/simulated/open/canBuildCatwalk()
	if(locate(/obj/structure/catwalk) in contents)
		return BUILD_FAILURE
	return locate(/obj/structure/lattice) in contents


/turf/simulated/open/canBuildLattice(var/material)
	if(src.x >= (world.maxx - TRANSITIONEDGE) || src.x <= TRANSITIONEDGE)
		return BUILD_FAILURE
	else if (src.y >= (world.maxy - TRANSITIONEDGE || src.y <= TRANSITIONEDGE ))
		return BUILD_FAILURE
	else if(locate(/obj/structure/catwalk) in contents)
		return BUILD_FAILURE
	else if(!(locate(/obj/structure/lattice) in contents) && !(istype(material,/obj/item/stack/sheet/wood)))
		return BUILD_SUCCESS
	return BUILD_FAILURE

/turf/simulated/open/canBuildPlating(var/material)
	if(src.x >= (world.maxx - TRANSITIONEDGE) || src.x <= TRANSITIONEDGE)
		return BUILD_FAILURE
	else if (src.y >= (world.maxy - TRANSITIONEDGE || src.y <= TRANSITIONEDGE ))
		return BUILD_FAILURE
	else if((locate(/obj/structure/lattice) in contents) && !(istype(material,/obj/item/stack/tile/wood)))
		return 1
	return BUILD_FAILURE

// This previously contained handling lattices, catwalks, and platings, but we do that differently here
/turf/simulated/open/attackby(obj/item/C as obj, mob/user as mob)
	//To lay cable
	if(istype(C, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/coil = C
		coil.turf_place(src, user)
	return

//Most things use is_plating to test if there is a cover tile on top (like regular floors)
/turf/simulated/open/is_plating()
	return TRUE

/turf/simulated/open/is_space()
	var/turf/below = GetBelow(src)
	return !below || below.is_space()

/turf/simulated/open/suicide_act(var/mob/living/user)
	if(user.can_fall() && Cross(user) && CanZPass(user) && get_gravity() > 0.667)
		var/turf/below = GetBelow(src)
		if(!below || below.can_prevent_fall(user,src))
			return
		for(var/obj/O in src)
			if(!O.CanFallThru())
				return
		for(var/atom/A in below)
			if(A.can_prevent_fall(user,src))
				return
		user.forceMove(src)
		to_chat(viewers(user), "<span class='danger'>[user] is plunging to \his death! It looks like \he's trying to commit suicide.</span>")
		if(prob(1)) // Do a flip!
			user.emote("flip")
		return SUICIDE_ACT_CUSTOM

/turf/simulated/floor/glass/New(loc)
	..(loc)
	if(get_base_turf(src.z) == /turf/simulated/open)
		icon_state = ""
		plane = OPENSPACE_PLANE_START
		layer = 0
		update_icon()

/obj/effect/open_overlay/glass
	name = "glass open overlay"
	desc = "The window over the darkness of the abyss below"
	icon = 'icons/turf/overlays.dmi'
	icon_state = ""
	layer = 0
	plane = GLASSTILE_PLANE

/obj/effect/open_overlay/glass/damage
	name = "glass open overlay cracks"
	desc = "The dent in the window over the darkness of the abyss below"
	icon = 'icons/obj/structures.dmi'

/turf/simulated/floor/glass/update_icon()
	..()
	if(get_base_turf(src.z) == /turf/simulated/open)
		if(make_openspace_view()) // Space below us
			icon_state = "" // Remove any previous space stuff, if any
		else
			// We space background now, forget the vis contentsing of it
			icon_state = "[((x + y) ^ ~(x * y) + z) % 25]"
		var/obj/effect/open_overlay/glass/overglass = new /obj/effect/open_overlay/glass
		overglass.icon_state = glass_state
		vis_contents.Add(overglass)
		var/obj/effect/open_overlay/glass/damage/overdamage = new /obj/effect/open_overlay/glass/damage
		overdamage.icon_state = icon_state
		vis_contents.Add(overdamage)

/turf/simulated/floor/glass/ChangeTurf(var/turf/N, var/tell_universe=1, var/force_lighting_update = 0, var/allow = 1)
	vis_contents.Cut()
	overlays.Cut()
	..()

// Debug verbs.
/client/proc/update_all_open_spaces()
	set category = "Debug"
	set name = "Update open spaces"
	set desc = "On multi-z maps, force all open space turfs to update_icon and make their items fall"

	if (!holder)
		return

	for(var/turf/simulated/open/O in world)
		O.update_icon()
		for(var/atom/movable/A in O)
			A.fall()

	message_admins("Admin [key_name_admin(usr)] forced open spaces to update.")
