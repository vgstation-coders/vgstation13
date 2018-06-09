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
	var/list/obj/structure/window/windows = list()
	var/list/window_connections = list()

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
	T.set_graphic(air.graphics)
	if(SSair.init_done)
		var/list/tempwin_turf = list()
		var/list/tempwin_nextturf = list()

		for(var/obj/structure/window/w in T.contents)
			tempwin_turf |= w
		windows |= tempwin_turf
		for(var/D in cardinal)
			var/turf/simulated/floor/NT = get_step(T,D)
			if(istype(NT))
				if(NT.zone)
					if(NT.zone != src)
						var/zone/NZ = NT.zone
						var/found_border_zone = 0
						if(NZ.window_connections && NZ.window_connections.len)

							for(var/window_connection/wc in NZ.window_connections)
								if(src in wc.bordering_zones)
									found_border_zone = 1
									for(var/obj/structure/window/w in tempwin_turf)
										if((get_dir(w.loc, T) == w.dir )&& w.loc != T)
											wc.shared_windows |= w
											w.window_connections |= wc
									src.window_connections |= wc
									
							for(var/window_connection/wc in src.window_connections)
								if(NZ in wc.bordering_zones)
									found_border_zone = 1
									for(var/obj/structure/window/w in NT.contents)
										if((get_dir(w.loc, NT) == w.dir) && w.loc != NT )
											wc.shared_windows |= w
											w.window_connections |= wc
									NZ.window_connections |= wc
						if(!found_border_zone) //make a new window connection if there are windows
							for(var/obj/structure/window/w in NT.contents)
								if((get_dir(w.loc, T) == w.dir) && w.loc != T)
									tempwin_nextturf |= w
							if(tempwin_turf.len || tempwin_nextturf.len)
								var/window_connection/wc = new()
								for(var/obj/structure/window/w in tempwin_nextturf)
									if((get_dir(w.loc, T) == w.dir) && w.loc != T)
										wc.shared_windows |= w
										w.window_connections |= wc
								for(var/obj/structure/window/w in tempwin_turf)
									if((get_dir(w.loc, NT) == w.dir) && w.loc != T)
										wc.shared_windows |= w
										w.window_connections |= wc
								wc.bordering_zones.Add(src, NZ)
								src.window_connections += wc
								NZ.window_connections += wc
								SSair.global_window_connections += wc
						tempwin_nextturf.len = 0
				else
					var/list/obj/structure/window/nozonewindows = list()
					for(var/obj/structure/window/w in NT.contents)
						nozonewindows += w
					//now lets walk and find all of our connected full windows!
					if(nozonewindows.len)
						var/found_or_made = 0
						for(var/ND in cardinal)
							var/turf/WT = get_step(NT, ND)
							if(WT == T)
								continue
							if(istype(WT, /turf/simulated/floor))
								var/turf/simulated/floor/ST = WT
								if(ST.zone && ST.zone != T.zone)
									var/foundbz = 0
									for(var/window_connection/wc in src.window_connections)
										if(ST.zone in wc.bordering_zones)
											//ok add the windows to it
											foundbz = 1
											wc.shared_windows |= nozonewindows
											wc.directions = list( get_dir(NT,ST),reverse_direction(get_dir(NT,ST)))
											wc.bordering_zones.len = 0
											wc.bordering_zones += list(ST.zone, T.zone)
											found_or_made = 1
									for(var/window_connection/wc in ST.zone.window_connections)
										if(foundbz) break //dont bother
										if(src in wc.bordering_zones)
											foundbz = 1
											wc.shared_windows |= nozonewindows
											wc.directions = list( get_dir(NT,ST),reverse_direction(get_dir(NT,ST)))
											wc.bordering_zones.len = 0
											wc.bordering_zones += list(ST.zone, T.zone)
											found_or_made = 1
									if(!foundbz)
										var/window_connection/wc = new()
										wc.shared_windows |= nozonewindows
										wc.bordering_zones += list(ST.zone, src)
										ST.zone.window_connections += wc
										src.window_connections += wc
										SSair.global_window_connections += wc
										wc.directions = list( get_dir(NT,ST),reverse_direction(get_dir(NT,ST)))
										found_or_made = 1
								else
									continue
						if(!found_or_made)
							src.windows |= nozonewindows
			else
				continue

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
	T.set_graphic(0)
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
	if(SSair.init_done)
		for(var/window_connection/wc in window_connections)
			if(into in wc.bordering_zones)
				into.windows |= wc.shared_windows
				into.windows |= windows
				wc.shared_windows.len = 0
				windows.len = 0
				for(var/zone/Z in wc.bordering_zones)
					Z.window_connections -= wc
				wc.bordering_zones.len = 0
				qdel(wc)
			//move the window connections to the new zone thats taken over
			else
				wc.bordering_zones -= src
				wc.bordering_zones += into

	for(var/turf/simulated/T in contents)
		into.add(T)
		#ifdef ZASDBG
		T.dbg(merged)
		#endif

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
	if(air.check_tile_graphic())
		for(var/turf/simulated/T in contents)
			T.set_graphic(air.graphics)

	for(var/connection_edge/E in edges)
		if(E.sleeping)
			E.recheck()
	
	for(var/obj/structure/window/w in windows)
		w.pressure_act(air.return_pressure(), ignore_dir = 1)
		if(w && (w.gcDestroyed || get_turf(w) == null))
			windows -= w

/zone/proc/dbg_data(mob/M)
	to_chat(M, name)
	to_chat(M, "O2: [air.oxygen] N2: [air.nitrogen] CO2: [air.carbon_dioxide] P: [air.toxins]")
	to_chat(M, "P: [air.return_pressure()] kPa V: [air.volume]L T: [air.temperature]�K ([air.temperature - T0C]�C)")
	to_chat(M, "O2 per N2: [(air.nitrogen ? air.oxygen/air.nitrogen : "N/A")] Moles: [air.total_moles]")
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
