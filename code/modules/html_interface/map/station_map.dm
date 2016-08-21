
/proc/generateHoloMinimaps()
	var/list/filters = list(
		"deathsquad",
		"ert",
		"nukeops",
		"elitesyndicate",
		"vox",
		)

	for (var/f in filters)
		centcommminimaps |= f
		generateCentcommMinimap(f)

	for (var/z = 1 to world.maxz)
		holominimaps |= z
		generateHoloMinimap(z)

/proc/generateHoloMinimap(var/zLevel=1)
	var/icon/canvas = icon('icons/480x480.dmi', "blank")

	if(zLevel != map.zCentcomm)//The Centcomm Zlevel's minimap will remain blank for immersion purposes. Until we add a way to only draw certain areas depending on the suit's faction
		for(var/i = 1 to 480)
			for(var/r = 1 to 480)
				var/turf/tile = locate(i, r, zLevel)
				if(tile && !istype(tile.loc, /area/shuttle) && !istype(tile.loc, /area/vault) && !istype(tile.loc, /area/derelict/ship))
					if((!istype(tile, /turf/space) && istype(tile.loc, /area/mine/unexplored)) || istype(tile, /turf/simulated/wall) || istype(tile, /turf/unsimulated/mineral) || istype(tile, /turf/unsimulated/wall) || (locate(/obj/structure/grille) in tile) || (locate(/obj/structure/window/full) in tile))
						canvas.DrawBox("#FFFFFFDD", i, r)
					else if (istype(tile, /turf/simulated/floor) || istype(tile, /turf/unsimulated/floor) || (locate(/obj/structure/catwalk) in tile))
						canvas.DrawBox("#66666699", i, r)

	holominimaps[zLevel] = canvas

/proc/generateCentcommMinimap(var/filter="all")
	var/icon/canvas = icon('icons/480x480.dmi', "blank")

	var/list/allowed_areas = list()
	var/list/restricted_areas = list()

	switch(filter)
		if("deathsquad")
			allowed_areas = list(
				/area/centcom/specops,
				/area/centcom/control,
				/area/centcom/creed,
				/area/centcom/test,
				/area/centcom/ferry,
				/area/centcom/holding,
				/area/centcom/evac,
				)
		if("ert")
			allowed_areas = list(
				/area/centcom/specops,
				/area/centcom/control,
				/area/centcom/creed,
				/area/centcom/test,
				/area/centcom/ferry,
				/area/centcom/holding,
				/area/centcom/evac,
				)
		if("nukeops")
			allowed_areas = list(
				/area/syndicate_mothership,
				)
			restricted_areas = list(
				/area/syndicate_mothership/elite_squad,
				)
		if("elitesyndicate")
			allowed_areas = list(
				/area/syndicate_mothership,
				)

	for(var/i = 1 to 480)
		for(var/r = 1 to 480)
			var/turf/tile = locate(i, r, map.zCentcomm)
			if(tile && is_type_in_list(tile.loc, allowed_areas) && !is_type_in_list(tile.loc, restricted_areas) && !istype(tile.loc, /area/shuttle) && !istype(tile.loc, /area/vault) && !istype(tile.loc, /area/derelict/ship))
				if((!istype(tile, /turf/space) && istype(tile.loc, /area/mine/unexplored)) || istype(tile, /turf/simulated/wall) || istype(tile, /turf/unsimulated/mineral) || istype(tile, /turf/unsimulated/wall) || (locate(/obj/structure/grille) in tile) || (locate(/obj/structure/window/full) in tile) || istype(tile, /turf/simulated/shuttle/wall))
					canvas.DrawBox("#FFFFFFDD", i, r)
				else if (istype(tile, /turf/simulated/floor) || istype(tile, /turf/unsimulated/floor) || (locate(/obj/structure/catwalk) in tile) || istype(tile, /turf/simulated/shuttle/floor))
					canvas.DrawBox("#66666699", i, r)

	centcommminimaps[filter] = canvas
