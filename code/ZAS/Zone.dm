/*

Overview:
	Each zone is a self-contained area where gas values would be the same if tile-based equalization were run indefinitely.
	If you're unfamiliar with ZAS, FEA's air groups would have similar functionality if they didn't break in a stiff breeze.

Class Vars:
	name - A name of the format "Zone [#]", used for debugging.
	invalid - True if the zone has been erased and is no longer eligible for processing.
	needs_update - True if the zone has been added to the update list.
	edges - A list of edges that connect to this zone.
	air - The gas mixture that any turfs in this zone will return. Values are per-tile with a group multiplier.

Class Procs:
	add(turf/simulated/T)
		Adds a turf to the contents, sets its zone and merges its air.

	remove(turf/simulated/T)
		Removes a turf, sets its zone to null and erases any gas graphics.
		Invalidates the zone if it has no more tiles.

	c_merge(zone/into)
		Invalidates this zone and adds all its former contents to into.

	c_invalidate()
		Marks this zone as invalid and removes it from processing.

	rebuild()
		Invalidates the zone and marks all its former tiles for updates.

	tick()
		Called only when the gas content is changed. Changes gas graphics.

	dbg_data(mob/M)
		Sends M a printout of important figures for the zone.

*/


/zone
	var/name
	var/invalid = 0
	var/list/contents = list()
	var/needs_update = 0
	var/list/edges = list()
	var/datum/gas_mixture/air = new

	var/list/graphic_add = list()
	var/list/graphic_remove = list()

/zone/New()
	SSair.add_zone(src)
	air.temperature = TCMB
	air.volume = 0

/zone/proc/add(turf/simulated/T)
#ifdef ZASDBG
	ASSERT(!invalid)
	ASSERT(istype(T))
	ASSERT(!SSair.has_valid_zone(T))
#endif

	var/datum/gas_mixture/turf_air = T.return_air()
	air.volume += turf_air.volume
	air.merge(turf_air)
	T.zone = src
	contents.Add(T)
	T.update_graphic(air.graphic)

/zone/proc/remove(turf/simulated/T)
#ifdef ZASDBG
	ASSERT(!invalid)
	ASSERT(istype(T))
	ASSERT(T.zone == src)
	soft_assert(T in contents, "Lists are weird broseph")
#endif

	T.zone = null
	var/datum/gas_mixture/turf_air = T.return_air()
	air.multiply(1 - turf_air.volume / air.volume)
	air.volume -= turf_air.volume
	contents.Remove(T)
	T.update_graphic(graphic_remove = air.graphic)
	if(!contents.len)
		c_invalidate()

/zone/proc/c_merge(zone/into)
#ifdef ZASDBG
	ASSERT(!invalid)
	ASSERT(istype(into))
	ASSERT(into != src)
	ASSERT(!into.invalid)
#endif
	c_invalidate()
	for(var/turf/simulated/T in contents)
		T.update_graphic(graphic_remove = air.graphic)
		into.add(T)
		#ifdef ZASDBG
		T.dbg(merged)
		#endif

	//Rebuild the old zone's edges so that they will be possessed by the new zone
	for(var/connection_edge/E in edges)
		if(E.contains_zone(into))
			E.erase() //Don't need to connect the new zone to itself
		for(var/turf/T in E.connecting_turfs)
			SSair.mark_for_update(T)

/zone/proc/c_invalidate()
	invalid = 1
	SSair.remove_zone(src)
	#ifdef ZASDBG
	for(var/turf/simulated/T in contents)
		T.dbg(invalid_zone)
	#endif

/zone/proc/rebuild()
	if(invalid)
		return //Short circuit for explosions where rebuild is called many times over.
	c_invalidate()
	for(var/turf/simulated/T in contents)
		T.update_graphic(graphic_remove = air.graphic) //we need to remove the overlays so they're not doubled when the zone is rebuilt
		//T.dbg(invalid_zone)
		T.needs_air_update = 0 //Reset the marker so that it will be added to the list.
		SSair.mark_for_update(T)

//Gets a list of the gas_mixtures of all zones connected to this one through arbitrarily many sleeping edges.
//This is to cut down somewhat on differentials across open doors.
//Yes, recursion is slow, but this will generally not be called very often, and will rarely have to recurse more than a few levels deep.
//That said, feel free to optimize it if you want.
//
//At the top level, just call it with no arg. The arg generally is for internal use.
/zone/proc/get_equalized_zone_air(list/found = list())
	found += air
	. = found //I want to minimize the call stack left over after the recursive call. Honestly the implicit return is probably the same as an explicit one, but I'd rather play it safe.
	for(var/connection_edge/zone/E in edges)
		if(E.sleeping)
			var/zone/Z = E.get_connected_zone(src)
			if(!(Z.air in found))
				Z.get_equalized_zone_air(found)

/zone/proc/tick()
	if(air.check_tile_graphic(graphic_add, graphic_remove))
		for(var/turf/simulated/T in contents)
			T.update_graphic(graphic_add, graphic_remove)
		graphic_add.len = 0
		graphic_remove.len = 0

	for(var/connection_edge/E in edges)
		if(E.sleeping)
			E.recheck()

/zone/proc/dbg_data(mob/M)
	to_chat(M, name)
	to_chat(M, "O2: [air[GAS_OXYGEN]] N2: [air[GAS_NITROGEN]] CO2: [air[GAS_CARBON]] P: [air[GAS_PLASMA]]")
	to_chat(M, "P: [air.pressure] kPa V: [air.volume]L T: [air.temperature]�K ([air.temperature - T0C]�C)")
	to_chat(M, "O2 per N2: [(air[GAS_NITROGEN] ? air[GAS_OXYGEN]/air[GAS_NITROGEN] : "N/A")] Moles: [air.total_moles]")
	to_chat(M, "Simulated: [contents.len] ([air.volume / CELL_VOLUME])")
//	to_chat(M, "Unsimulated: [unsimulated_contents.len]")
//	to_chat(M, "Edges: [edges.len]")
	if(invalid)
		to_chat(M, "Invalid!")
	var/zone_edges = 0
	var/space_edges = 0
	var/space_coefficient = 0
	for(var/connection_edge/E in edges)
		if(E.type == /connection_edge/zone)
			zone_edges++
		else
			space_edges++
			space_coefficient += E.coefficient
			to_chat(M, "[E:air:return_pressure()]kPa")

	to_chat(M, "Zone Edges: [zone_edges]")
	to_chat(M, "Space Edges: [space_edges] ([space_coefficient] connections)")

	//for(var/turf/T in unsimulated_contents)
//		to_chat(M, "[T] at ([T.x],[T.y])")
