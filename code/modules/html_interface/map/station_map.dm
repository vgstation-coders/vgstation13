#define HOLOMAP_OBSTACLE	"#FFFFFFDD"
#define HOLOMAP_PATH		"#66666699"


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

	//Station Holomaps display the map of the Z-Level they were built on.
	generateStationMinimap(map.zMainStation)
	generateStationMinimap(map.zAsteroid)
	generateStationMinimap(map.zDerelict)
	//If they were built on another Z-Level, they will display an error screen.

	holomaps_initialized = 1

	for (var/obj/machinery/station_map/S in station_holomaps)
		S.initialize()

/proc/generateHoloMinimap(var/zLevel=1)
	var/icon/canvas = icon('icons/480x480.dmi', "blank")

	if(zLevel != map.zCentcomm)
		for(var/i = 1 to ((2 * world.view + 1)*WORLD_ICON_SIZE))
			for(var/r = 1 to ((2 * world.view + 1)*WORLD_ICON_SIZE))
				var/turf/tile = locate(i, r, zLevel)
				if(tile && tile.loc.holomapAlwaysDraw())
					if((!istype(tile, /turf/space) && istype(tile.loc, /area/mine/unexplored)) || istype(tile, /turf/simulated/wall) || istype(tile, /turf/unsimulated/mineral) || istype(tile, /turf/unsimulated/wall) || (locate(/obj/structure/grille) in tile) || (locate(/obj/structure/window/full) in tile))
						if(map.holomap_offset_x.len >= zLevel)
							canvas.DrawBox(HOLOMAP_OBSTACLE, min(i+map.holomap_offset_x[zLevel],((2 * world.view + 1)*WORLD_ICON_SIZE)), min(r+map.holomap_offset_y[zLevel],((2 * world.view + 1)*WORLD_ICON_SIZE)))
						else
							canvas.DrawBox(HOLOMAP_OBSTACLE, i, r)
					else if (istype(tile, /turf/simulated/floor) || istype(tile, /turf/unsimulated/floor) || (locate(/obj/structure/catwalk) in tile))
						if(map.holomap_offset_x.len >= zLevel)
							canvas.DrawBox(HOLOMAP_PATH, min(i+map.holomap_offset_x[zLevel],((2 * world.view + 1)*WORLD_ICON_SIZE)), min(r+map.holomap_offset_y[zLevel],((2 * world.view + 1)*WORLD_ICON_SIZE)))
						else
							canvas.DrawBox(HOLOMAP_PATH, i, r)

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
					if(map.holomap_offset_x.len >= map.zCentcomm)
						canvas.DrawBox(HOLOMAP_OBSTACLE, min(i+map.holomap_offset_x[map.zCentcomm],((2 * world.view + 1)*WORLD_ICON_SIZE)), min(r+map.holomap_offset_y[map.zCentcomm],((2 * world.view + 1)*WORLD_ICON_SIZE)))
					else
						canvas.DrawBox(HOLOMAP_OBSTACLE, i, r)
				else if (istype(tile, /turf/simulated/floor) || istype(tile, /turf/unsimulated/floor) || (locate(/obj/structure/catwalk) in tile) || istype(tile, /turf/simulated/shuttle/floor))
					if(map.holomap_offset_x.len >= map.zCentcomm)
						canvas.DrawBox(HOLOMAP_PATH, min(i+map.holomap_offset_x[map.zCentcomm],((2 * world.view + 1)*WORLD_ICON_SIZE)), min(r+map.holomap_offset_y[map.zCentcomm],((2 * world.view + 1)*WORLD_ICON_SIZE)))
					else
						canvas.DrawBox(HOLOMAP_PATH, i, r)

	centcommMiniMaps[filter] = canvas

/proc/generateStationMinimap(var/StationZLevel)
	var/icon/canvas = icon('icons/480x480.dmi', "blank")

	for(var/i = 1 to ((2 * world.view + 1)*WORLD_ICON_SIZE))
		for(var/r = 1 to ((2 * world.view + 1)*WORLD_ICON_SIZE))
			var/turf/tile = locate(i, r, StationZLevel)
			if(tile && tile.loc)
				var/area/areaToPaint = tile.loc
				if(areaToPaint.holomap_color)
					if(map.holomap_offset_x.len >= StationZLevel)
						canvas.DrawBox(areaToPaint.holomap_color, min(i+map.holomap_offset_x[StationZLevel],((2 * world.view + 1)*WORLD_ICON_SIZE)), min(r+map.holomap_offset_y[StationZLevel],((2 * world.view + 1)*WORLD_ICON_SIZE)))
					else
						canvas.DrawBox(areaToPaint.holomap_color, i, r)

	extraMiniMaps |= HOLOMAP_EXTRA_STATIONMAPAREAS+"_[StationZLevel]"
	extraMiniMaps[HOLOMAP_EXTRA_STATIONMAPAREAS+"_[StationZLevel]"] = canvas

	var/icon/big_map = icon('icons/480x480.dmi', "stationmap")
	var/icon/small_map = icon('icons/480x480.dmi', "blank")
	var/icon/map_base = icon(holoMiniMaps[StationZLevel])

	map_base.Blend("#79ff79",ICON_MULTIPLY)

	small_map.Blend(map_base,ICON_OVERLAY)
	small_map.Blend(canvas,ICON_OVERLAY)
	small_map.Scale(32,32)

	big_map.Blend(map_base,ICON_OVERLAY)
	big_map.Blend(canvas,ICON_OVERLAY)

	for(var/area/A in areas)
		if(A.holomap_marker && (A.holomap_filter & HOLOMAP_EXTRA_STATIONMAP))
			var/turf/T = A.getAreaCenter(StationZLevel)
			if(T)
				if(map.holomap_offset_x.len >= StationZLevel)
					big_map.Blend(icon('icons/holomap_markers.dmi',A.holomap_marker), ICON_OVERLAY, T.x-8+map.holomap_offset_x[T.z]	, T.y-8+map.holomap_offset_y[T.z])
				else
					big_map.Blend(icon('icons/holomap_markers.dmi',A.holomap_marker), ICON_OVERLAY, T.x-8, T.y-8)


	extraMiniMaps |= HOLOMAP_EXTRA_STATIONMAP+"_[StationZLevel]"
	extraMiniMaps[HOLOMAP_EXTRA_STATIONMAP+"_[StationZLevel]"] = big_map

	extraMiniMaps |= HOLOMAP_EXTRA_STATIONMAPSMALL_NORTH+"_[StationZLevel]"
	extraMiniMaps[HOLOMAP_EXTRA_STATIONMAPSMALL_NORTH+"_[StationZLevel]"] = small_map

	var/icon/small_map_east = turn(icon(small_map), 90)
	extraMiniMaps |= HOLOMAP_EXTRA_STATIONMAPSMALL_EAST+"_[StationZLevel]"
	extraMiniMaps[HOLOMAP_EXTRA_STATIONMAPSMALL_EAST+"_[StationZLevel]"] = small_map_east

	var/icon/small_map_south = turn(icon(small_map_east), 90)
	extraMiniMaps |= HOLOMAP_EXTRA_STATIONMAPSMALL_SOUTH+"_[StationZLevel]"
	extraMiniMaps[HOLOMAP_EXTRA_STATIONMAPSMALL_SOUTH+"_[StationZLevel]"] = small_map_south

	var/icon/small_map_west = turn(icon(small_map_south), 90)
	extraMiniMaps |= HOLOMAP_EXTRA_STATIONMAPSMALL_WEST+"_[StationZLevel]"
	extraMiniMaps[HOLOMAP_EXTRA_STATIONMAPSMALL_WEST+"_[StationZLevel]"] = small_map_west

#undef HOLOMAP_OBSTACLE
#undef HOLOMAP_PATH
