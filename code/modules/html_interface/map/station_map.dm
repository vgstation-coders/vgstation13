
/proc/generateHoloMinimaps()
	var/list/filters = list(
		HOLOMAP_FILTER_DEATHSQUAD,
		HOLOMAP_FILTER_ERT,
		HOLOMAP_FILTER_NUKEOPS,
		HOLOMAP_FILTER_ELITESYNDICATE,
		HOLOMAP_FILTER_VOX,
		)

	for (var/f in filters)
		centcommMiniMaps |= f
		generateCentcommMinimap(f)

	for (var/z = 1 to world.maxz)
		holoMiniMaps |= z
		generateHoloMinimap(z)

	generateStationMinimap()

	holomaps_initialized = 1

	for (var/obj/machinery/station_map/S in station_holomaps)
		S.initialize()

/proc/generateHoloMinimap(var/zLevel=1)
	var/icon/canvas = icon('icons/480x480.dmi', "blank")

	if(zLevel != map.zCentcomm)//The Centcomm Zlevel's minimap will remain blank for immersion purposes. Until we add a way to only draw certain areas depending on the suit's faction
		for(var/i = 1 to ((2 * world.view + 1)*WORLD_ICON_SIZE))
			for(var/r = 1 to ((2 * world.view + 1)*WORLD_ICON_SIZE))
				var/turf/tile = locate(i, r, zLevel)
				if(tile && tile.loc.holomapAlwaysDraw())
					if((!istype(tile, /turf/space) && istype(tile.loc, /area/mine/unexplored)) || istype(tile, /turf/simulated/wall) || istype(tile, /turf/unsimulated/mineral) || istype(tile, /turf/unsimulated/wall) || (locate(/obj/structure/grille) in tile) || (locate(/obj/structure/window/full) in tile))
						canvas.DrawBox("#FFFFFFDD", i, r)
					else if (istype(tile, /turf/simulated/floor) || istype(tile, /turf/unsimulated/floor) || (locate(/obj/structure/catwalk) in tile))
						canvas.DrawBox("#66666699", i, r)

	holoMiniMaps[zLevel] = canvas

/proc/generateCentcommMinimap(var/filter="all")
	var/icon/canvas = icon('icons/480x480.dmi', "blank")

	var/list/allowed_areas = list()
	var/list/restricted_areas = list()

	switch(filter)
		if(HOLOMAP_FILTER_DEATHSQUAD)
			allowed_areas = list(
				/area/centcom/specops,
				/area/centcom/control,
				/area/centcom/creed,
				/area/centcom/test,
				/area/centcom/ferry,
				/area/centcom/holding,
				/area/centcom/evac,
				)
		if(HOLOMAP_FILTER_ERT)
			allowed_areas = list(
				/area/centcom/specops,
				/area/centcom/control,
				/area/centcom/creed,
				/area/centcom/test,
				/area/centcom/ferry,
				/area/centcom/holding,
				/area/centcom/evac,
				)
		if(HOLOMAP_FILTER_NUKEOPS)
			allowed_areas = list(
				/area/syndicate_mothership,
				)
			restricted_areas = list(
				/area/syndicate_mothership/elite_squad,
				)
		if(HOLOMAP_FILTER_ELITESYNDICATE)
			allowed_areas = list(
				/area/syndicate_mothership,
				)

	for(var/i = 1 to ((2 * world.view + 1)*WORLD_ICON_SIZE))
		for(var/r = 1 to ((2 * world.view + 1)*WORLD_ICON_SIZE))
			var/turf/tile = locate(i, r, map.zCentcomm)
			if(tile && (is_type_in_list(tile.loc, allowed_areas) && !is_type_in_list(tile.loc, restricted_areas)))
				if((!istype(tile, /turf/space) && istype(tile.loc, /area/mine/unexplored)) || istype(tile, /turf/simulated/wall) || istype(tile, /turf/unsimulated/mineral) || istype(tile, /turf/unsimulated/wall) || (locate(/obj/structure/grille) in tile) || (locate(/obj/structure/window/full) in tile) || istype(tile, /turf/simulated/shuttle/wall))
					canvas.DrawBox("#FFFFFFDD", i, r)
				else if (istype(tile, /turf/simulated/floor) || istype(tile, /turf/unsimulated/floor) || (locate(/obj/structure/catwalk) in tile) || istype(tile, /turf/simulated/shuttle/floor))
					canvas.DrawBox("#66666699", i, r)

	centcommMiniMaps[filter] = canvas

/proc/generateStationMinimap()
	var/icon/canvas = icon('icons/480x480.dmi', "blank")

	for(var/i = 1 to ((2 * world.view + 1)*WORLD_ICON_SIZE))
		for(var/r = 1 to ((2 * world.view + 1)*WORLD_ICON_SIZE))
			var/turf/tile = locate(i, r, map.zMainStation)
			if(tile && tile.loc)
				var/area/areaToPaint = tile.loc
				if(areaToPaint.holomap_color)
					canvas.DrawBox(areaToPaint.holomap_color, i, r)

	extraMiniMaps |= HOLOMAP_EXTRA_STATIONMAPAREAS
	extraMiniMaps[HOLOMAP_EXTRA_STATIONMAPAREAS] = canvas

	var/icon/big_map = icon('icons/480x480.dmi', "stationmap")
	var/icon/small_map = icon('icons/480x480.dmi', "blank")
	var/icon/map_base = icon(holoMiniMaps[map.zMainStation])

	small_map.Blend(map_base,ICON_OVERLAY)
	small_map.Blend(canvas,ICON_OVERLAY)
	small_map.Scale(32,32)

	map_base.Blend("#79ff79",ICON_MULTIPLY)

	big_map.Blend(map_base,ICON_OVERLAY)
	big_map.Blend(canvas,ICON_OVERLAY)

	for(var/area/A in areas)
		if(A.holomap_marker && (A.holomap_filter & HOLOMAP_EXTRA_STATIONMAP))
			var/turf/T = A.getAreaCenter(map.zMainStation)
			if(T)
				big_map.Blend(icon('icons/holomap_markers.dmi',A.holomap_marker), ICON_OVERLAY, T.x-8, T.y-8)

	extraMiniMaps |= HOLOMAP_EXTRA_STATIONMAP
	extraMiniMaps[HOLOMAP_EXTRA_STATIONMAP] = big_map

	extraMiniMaps |= HOLOMAP_EXTRA_STATIONMAPSMALL_NORTH
	extraMiniMaps[HOLOMAP_EXTRA_STATIONMAPSMALL_NORTH] = small_map

	var/icon/small_map_east = turn(icon(small_map), 90)
	extraMiniMaps |= HOLOMAP_EXTRA_STATIONMAPSMALL_EAST
	extraMiniMaps[HOLOMAP_EXTRA_STATIONMAPSMALL_EAST] = small_map_east

	var/icon/small_map_south = turn(icon(small_map_east), 90)
	extraMiniMaps |= HOLOMAP_EXTRA_STATIONMAPSMALL_SOUTH
	extraMiniMaps[HOLOMAP_EXTRA_STATIONMAPSMALL_SOUTH] = small_map_south

	var/icon/small_map_west = turn(icon(small_map_south), 90)
	extraMiniMaps |= HOLOMAP_EXTRA_STATIONMAPSMALL_WEST
	extraMiniMaps[HOLOMAP_EXTRA_STATIONMAPSMALL_WEST] = small_map_west
