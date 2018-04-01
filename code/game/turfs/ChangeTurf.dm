// This is a list of turf types we dont want to assign to baseturfs unless through initialization or explicitly
GLOBAL_LIST_INIT(blacklisted_automated_baseturfs, typecacheof(list(
	/turf/open/space,
	)))

/turf/proc/empty(turf_type=/turf/open/space, baseturf_type, list/ignore_typecache, flags)
	// Remove all atoms except observers, landmarks, docking ports
	var/static/list/ignored_atoms = typecacheof(list(/mob/dead, /obj/effect/landmark, /obj/docking_port, /atom/movable/lighting_object))
	var/list/allowed_contents = typecache_filter_list_reverse(GetAllContentsIgnoring(ignore_typecache), ignored_atoms)
	allowed_contents -= src
	for(var/i in 1 to allowed_contents.len)
		var/thing = allowed_contents[i]
		qdel(thing, force=TRUE)

	var/turf/newT = ChangeTurf(turf_type, baseturf_type, flags)

	SSair.remove_from_active(newT)
	newT.CalculateAdjacentTurfs()
	SSair.add_to_active(newT,1)

/turf/proc/copyTurf(turf/T)
	if(T.type != type)
		var/obj/O
		if(underlays.len)	//we have underlays, which implies some sort of transparency, so we want to a snapshot of the previous turf as an underlay
			O = new()
			O.underlays.Add(T)
		T.ChangeTurf(type)
		for(var/group in decals)
			T.add_decal(decals[group],group)
		if(underlays.len)
			T.underlays = O.underlays
	if(T.icon_state != icon_state)
		T.icon_state = icon_state
	if(T.icon != icon)
		T.icon = icon
	if(color)
		T.atom_colours = atom_colours.Copy()
		T.update_atom_colour()
	if(T.dir != dir)
		T.setDir(dir)
	return T

//wrapper for ChangeTurf()s that you want to prevent/affect without overriding ChangeTurf() itself
/turf/proc/TerraformTurf(path, new_baseturf, flags)
	return ChangeTurf(path, new_baseturf, flags)

// Creates a new turf
// new_baseturfs can be either a single type or list of types, formated the same as baseturfs. see turf.dm
/turf/proc/ChangeTurf(path, list/new_baseturfs, flags)
	if(!path)
		return
	if(path == /turf/open/space/basic)
		// basic doesn't initialize and this will cause issues
		// no warning though because this can happen naturaly as a result of it being built on top of
		path = /turf/open/space
	if(!GLOB.use_preloader && path == type && !(flags & CHANGETURF_FORCEOP)) // Don't no-op if the map loader requires it to be reconstructed
		return src
	if(flags & CHANGETURF_SKIP)
		return new path(src)

	var/old_opacity = opacity
	var/old_dynamic_lighting = dynamic_lighting
	var/old_affecting_lights = affecting_lights
	var/old_lighting_object = lighting_object
	var/old_corners = corners

	var/old_exl = explosion_level
	var/old_exi = explosion_id
	var/old_bp = blueprint_data
	blueprint_data = null

	var/list/old_baseturfs = baseturfs
	changing_turf = TRUE

	qdel(src)	//Just get the side effects and call Destroy
	var/turf/W = new path(src)

	if(new_baseturfs)
		W.baseturfs = new_baseturfs
	else
		W.baseturfs = old_baseturfs

	W.explosion_id = old_exi
	W.explosion_level = old_exl

	if(!(flags & CHANGETURF_DEFER_CHANGE))
		W.AfterChange(flags)

	W.blueprint_data = old_bp

	if(SSlighting.initialized)
		recalc_atom_opacity()
		lighting_object = old_lighting_object
		affecting_lights = old_affecting_lights
		corners = old_corners
		if (old_opacity != opacity || dynamic_lighting != old_dynamic_lighting)
			reconsider_lights()

		if (dynamic_lighting != old_dynamic_lighting)
			if (IS_DYNAMIC_LIGHTING(src))
				lighting_build_overlay()
			else
				lighting_clear_overlay()

		for(var/turf/open/space/S in RANGE_TURFS(1, src)) //RANGE_TURFS is in code\__HELPERS\game.dm
			S.update_starlight()

	return W

// Take off the top layer turf and replace it with the next baseturf down
/turf/proc/ScrapeAway()
	if(length(baseturfs))
		var/list/new_baseturfs = baseturfs
		var/turf_type = new_baseturfs[new_baseturfs.len]
		new_baseturfs.len--
		switch(new_baseturfs.len)
			if(1)
				new_baseturfs = new_baseturfs[1]
			if(0)
				new_baseturfs = turf_type
				// We must never end up with a situation where there is no baseturf
				WARNING("turf of type [type] had a baseturfs length 1 still in list form.")
		return ChangeTurf(turf_type, new_baseturfs)
	
	if(baseturfs == type)
		return src

	return ChangeTurf(baseturfs, baseturfs) // The bottom baseturf will never go away

// Take the input as baseturfs and put it underneath the current baseturfs
// If fake_turf_type is provided and new_baseturfs is not the baseturfs list will be created identical to the turf type's
// If both or just new_baseturfs is provided they will be inserted below the existing baseturfs
/turf/proc/PlaceOnBottom(list/new_baseturfs, turf/fake_turf_type)
	if(fake_turf_type)
		if(!new_baseturfs)
			if(!length(baseturfs))
				baseturfs = list(baseturfs)
			var/list/old_baseturfs = baseturfs.Copy()
			assemble_baseturfs(fake_turf_type)
			if(!length(baseturfs))
				baseturfs = list(baseturfs)
			baseturfs -= baseturfs & GLOB.blacklisted_automated_baseturfs
			baseturfs += old_baseturfs
			return
		else if(!length(new_baseturfs))
			new_baseturfs = list(new_baseturfs, fake_turf_type)
		else
			new_baseturfs += fake_turf_type
	if(!length(baseturfs))
		baseturfs = list(baseturfs)
	baseturfs.Insert(1, new_baseturfs)

// Make a new turf and put it on top
// The args behave identical to PlaceOnBottom except they go on top
// Things placed on top of closed turfs will ignore the topmost closed turf
// Returns the new turf
/turf/proc/PlaceOnTop(list/new_baseturfs, turf/fake_turf_type, flags)
	var/turf/newT
	if(flags & CHANGETURF_SKIP) // We haven't been initialized
		if(initialized)
			stack_trace("CHANGETURF_SKIP was used in a PlaceOnTop call for a turf that's initialized. This is a mistake. [src]([type])")
		assemble_baseturfs()
	if(fake_turf_type)
		if(!new_baseturfs) // If no baseturfs list then we want to create one from the turf type
			if(!length(baseturfs))
				baseturfs = list(baseturfs)
			var/list/old_baseturfs = baseturfs.Copy()
			if(!istype(src, /turf/closed))
				old_baseturfs += type
			newT = ChangeTurf(fake_turf_type, null, flags)
			newT.assemble_baseturfs(initial(fake_turf_type.baseturfs)) // The baseturfs list is created like roundstart
			if(!length(newT.baseturfs))
				newT.baseturfs = list(baseturfs)
			newT.baseturfs -= newT.baseturfs & GLOB.blacklisted_automated_baseturfs
			newT.baseturfs.Insert(1, old_baseturfs) // The old baseturfs are put underneath
			return newT
		if(!length(baseturfs))
			baseturfs = list(baseturfs)
		if(!istype(src, /turf/closed))
			baseturfs += type
		baseturfs += new_baseturfs
		return ChangeTurf(fake_turf_type, null, flags)
	if(!length(baseturfs))
		baseturfs = list(baseturfs)
	if(!istype(src, /turf/closed))
		baseturfs += type
	var/turf/change_type
	if(length(new_baseturfs))
		change_type = new_baseturfs[new_baseturfs.len]
		new_baseturfs.len--
		if(new_baseturfs.len)
			baseturfs += new_baseturfs
	else
		change_type = new_baseturfs
	return ChangeTurf(change_type, null, flags)

// Copy an existing turf and put it on top
// Returns the new turf
/turf/proc/CopyOnTop(turf/copytarget, ignore_bottom=1, depth=INFINITY)
	var/list/new_baseturfs = list()
	new_baseturfs += baseturfs
	new_baseturfs += type

	if(depth)
		var/list/target_baseturfs = copytarget.baseturfs
		target_baseturfs -= target_baseturfs & GLOB.blacklisted_automated_baseturfs
		var/base_len = length(target_baseturfs)
		if(!base_len)
			if(!ignore_bottom)
				new_baseturfs += target_baseturfs
		else if(base_len > ignore_bottom)
			if(base_len - ignore_bottom <= depth)
				new_baseturfs += target_baseturfs.Copy(ignore_bottom + 1)
			else
				new_baseturfs += target_baseturfs.Copy(base_len - depth)

	var/turf/newT = copytarget.copyTurf(src)
	newT.baseturfs = new_baseturfs
	return newT


//If you modify this function, ensure it works correctly with lateloaded map templates.
/turf/proc/AfterChange(flags) //called after a turf has been replaced in ChangeTurf()
	levelupdate()
	CalculateAdjacentTurfs()

	//update firedoor adjacency
	var/list/turfs_to_check = get_adjacent_open_turfs(src) | src
	for(var/I in turfs_to_check)
		var/turf/T = I
		for(var/obj/machinery/door/firedoor/FD in T)
			FD.CalculateAffectingAreas()

	queue_smooth_neighbors(src)

	HandleTurfChange(src)

/turf/open/AfterChange(flags)
	..()
	RemoveLattice()
	if(!(flags & CHANGETURF_IGNORE_AIR))
		Assimilate_Air()

//////Assimilate Air//////
/turf/open/proc/Assimilate_Air()
	var/turf_count = LAZYLEN(atmos_adjacent_turfs)
	if(blocks_air || !turf_count) //if there weren't any open turfs, no need to update.
		return

	var/datum/gas_mixture/total = new//Holders to assimilate air from nearby turfs
	var/list/total_gases = total.gases

	for(var/T in atmos_adjacent_turfs)
		var/turf/open/S = T
		if(!S.air)
			continue
		var/list/S_gases = S.air.gases
		for(var/id in S_gases)
			ASSERT_GAS(id, total)
			total_gases[id][MOLES] += S_gases[id][MOLES]
		total.temperature += S.air.temperature

	air.copy_from(total)

	var/list/air_gases = air.gases
	for(var/id in air_gases)
		air_gases[id][MOLES] /= turf_count //Averages contents of the turfs, ignoring walls and the like

	air.temperature /= turf_count
	SSair.add_to_active(src)

/turf/proc/ReplaceWithLattice()
	ScrapeAway()
	new /obj/structure/lattice(locate(x, y, z))