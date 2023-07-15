#define HOLOMAP_OBSTACLE	"#FFFFFFDD"
#define HOLOMAP_PATH		"#66666699"

/datum/holomap_marker
	var/x
	var/y
	var/z
	var/offset_x = -8
	var/offset_y = -8
	var/filter
	var/id
	var/icon = 'icons/holomap_markers.dmi'
	var/color//used by path rune markers

/proc/generateHoloMinimaps()
	var/list/filters = list(
		HOLOMAP_FILTER_DEATHSQUAD,
		HOLOMAP_FILTER_ERT,
		HOLOMAP_FILTER_NUKEOPS,
		HOLOMAP_FILTER_ELITESYNDICATE,
		HOLOMAP_FILTER_VOX,
		)

	for (var/f in filters)
		generateCentcommMinimap(f)

	for (var/z = 1 to world.maxz)
		holoMiniMaps |= z
		generateMarkers(z)
		generateHoloMinimap(z)

	//------------Cult Map start--------
	var/icon/canvas = icon('icons/480x480.dmi', "cultmap")
	var/icon/map_base = icon(holoMiniMaps[map.zMainStation])
	map_base.Blend("#E30000",ICON_MULTIPLY)
	canvas.Blend(map_base,ICON_OVERLAY)
	extraMiniMaps |= HOLOMAP_EXTRA_CULTMAP
	extraMiniMaps[HOLOMAP_EXTRA_CULTMAP] = canvas
	//-------------Bhangmap--------
	var/list/allowed_bhang_zlevels = list(
		map.zMainStation,
		map.zAsteroid,
		map.zDerelict
		)
	for (var/z = 1 to world.maxz)
		var/icon/blank = icon('icons/480x480.dmi', "blank")
		extraMiniMaps["[HOLOMAP_EXTRA_BHANGMAP]_[z]"] = blank

		var/icon/bhangcanvas = icon('icons/480x480.dmi', "bhangmap")
		if (z in allowed_bhang_zlevels)
			var/icon/bhangmap_base = icon(holoMiniMaps[z])
			bhangmap_base.Blend("#FFBD00",ICON_MULTIPLY)
			bhangcanvas.Blend(bhangmap_base,ICON_OVERLAY)
		extraMiniMaps["[HOLOMAP_EXTRA_BHANGBASEMAP]_[z]"] = bhangcanvas
		sensed_explosions["z[z]"] = list()
	//----------------------------------

	//Station Holomaps display the map of the Z-Level they were built on.
	generateStationMinimap(map.zMainStation)
	if(world.maxz >= map.zAsteroid)
		generateStationMinimap(map.zAsteroid)
	if(world.maxz >= map.zDerelict)
		generateStationMinimap(map.zDerelict)
	//If they were built on another Z-Level, they will display an error screen.

	holomaps_initialized = 1

	for (var/obj/machinery/station_map/S in station_holomaps)
		S.initialize()

	for (var/obj/machinery/computer/bhangmeter/B in bhangmeters)
		B.initialize()

	for (var/obj/structure/deathsquad_gravpult/G in station_holomaps)
		G.initialize_holomaps()

/proc/generateMarkers(var/ZLevel)
	//generating specific markers
	if(!map.disable_holominimap_generation)
		if(ZLevel == map.zMainStation)
			var/i = 1
			for(var/obj/machinery/power/battery/smes/S in smes_list)
				var/datum/holomap_marker/newMarker = new()
				newMarker.id = HOLOMAP_MARKER_SMES
				newMarker.filter = HOLOMAP_FILTER_STATIONMAP_STRATEGIC
				newMarker.x = S.x
				newMarker.y = S.y
				newMarker.z = S.z
				holomap_markers[HOLOMAP_MARKER_SMES+"_[i]"] = newMarker
				i++
			if(nukedisk)//Only gives the disk's original position on the map
				var/datum/holomap_marker/newMarker = new()
				newMarker.id = HOLOMAP_MARKER_DISK
				newMarker.filter = HOLOMAP_FILTER_STATIONMAP_STRATEGIC
				newMarker.x = nukedisk.x
				newMarker.y = nukedisk.y
				newMarker.z = nukedisk.z
				holomap_markers[HOLOMAP_MARKER_DISK] = newMarker
		//generating area markers
		for(var/area/A in areas)
			if(A.holomap_marker)
				var/turf/T = A.getAreaCenter(ZLevel)
				if(T)
					var/datum/holomap_marker/newMarker = new()
					newMarker.id = A.holomap_marker
					newMarker.filter = A.holomap_filter
					newMarker.x = T.x
					newMarker.y = T.y
					newMarker.z = ZLevel
					holomap_markers[newMarker.id+"_\ref[A]"] = newMarker
			if (A.destroy_after_marker)
				spawn(10)//necessary to give some margin for the marker to be created before removing that temp area.
					var/area/fill_area
					for(var/turf/T in A)
						if(!fill_area)
							fill_area = get_base_area(T.z)
						T.set_area(fill_area)
		//workplace markers
		var/list/landmarks = list()
		for (var/obj/effect/landmark/start/landmark in landmarks_list)
			if (!("[landmark.name]_[landmark.z]" in landmarks))
				landmarks["[landmark.name]_[landmark.z]"] = list(landmark)
			else
				landmarks["[landmark.name]_[landmark.z]"] += landmark
		for (var/landmark_id in landmarks)
			var/total_x = 0
			var/total_y = 0
			var/first_x = 0
			var/first_y = 0
			var/only_one = TRUE//we try to generate just one marker that averages the spawn locations
			var/list/landmark_starts = landmarks[landmark_id]
			if (!landmark_starts.len)
				continue
			for (var/obj/effect/landmark/start in landmark_starts)
				if (!first_x)
					first_x = start.x
					first_y = start.y
				var/diff = abs(first_x - start.x) + abs(first_y - start.y)
				if(diff > 50)
					only_one = FALSE//but if some of them are too far appart, we'll list them all.
					break

			if (only_one)
				var/datum/holomap_marker/newMarker = new()
				newMarker.id = landmark_id
				for (var/obj/effect/landmark/start in landmark_starts)
					total_x += start.x
					total_y += start.y
					newMarker.z = start.z
				newMarker.x = round(total_x/landmark_starts.len)
				newMarker.y = round(total_y/landmark_starts.len)
				workplace_markers[newMarker.id] = list(newMarker)
			else
				workplace_markers[landmark_id] = list()
				for (var/obj/effect/landmark/start in landmark_starts)
					var/datum/holomap_marker/newMarker = new()
					newMarker.id = landmark_id
					newMarker.x = start.x
					newMarker.y = start.y
					newMarker.z = start.z
					workplace_markers[newMarker.id] += newMarker

/proc/generateHoloMinimap(var/zLevel=1)
	set background=1

	var/icon/canvas = icon('icons/480x480.dmi', "blank")

	//These atoms will keep their tile empty on holomaps
	var/list/full_emptiness = list()

	//These atoms will appear as obstacles on holomaps
	var/list/full_obstacles = list(
		/obj/structure/grille,
		/obj/structure/fence,
		/obj/structure/window/full,
		)

	//These atoms will appear as floors on holomaps
	var/list/full_paths = list(
		/obj/structure/catwalk,
		/obj/structure/fence/door,
		)

	var/datum/zLevel/Z = map.zLevels[zLevel]

	if (istype(Z, /datum/zLevel/snowsurface))//we got a lot of turfs to check, so let's only check for those if we really need it
		full_emptiness += /obj/glacier
		full_obstacles += /obj/structure/flora/tree

	if(!map.disable_holominimap_generation)
		if (zLevel > map.zDeepSpace)
			return // No need to generate an holomap for something that didn't spawn.
		if(zLevel != map.zCentcomm)
			for(var/i = 1 to ((2 * world.view + 1)*WORLD_ICON_SIZE))
				for(var/r = 1 to ((2 * world.view + 1)*WORLD_ICON_SIZE))
					var/turf/tile = locate(i, r, zLevel)
					if (tile?.loc)
						var/area/aera = tile.loc
						var/override = FALSE
						for(var/emptiness in full_emptiness)
							var/atom/A = locate(emptiness) in tile
							if (A && !is_type_in_list(A,full_paths))
								override = TRUE
								break
						if (override)
							if (istype(aera, /area/surface/blizzard))
								if(map.holomap_offset_x.len >= zLevel)
									canvas.DrawBox(HOLOMAP_PATH, min(i+map.holomap_offset_x[zLevel],((2 * world.view + 1)*WORLD_ICON_SIZE)), min(r+map.holomap_offset_y[zLevel],((2 * world.view + 1)*WORLD_ICON_SIZE)))
								else
									canvas.DrawBox(HOLOMAP_PATH, i, r)
							continue

						if((tile.holomap_draw_override != HOLOMAP_DRAW_EMPTY) && (aera.holomap_draw_override != HOLOMAP_DRAW_EMPTY))
							override = FALSE
							for(var/obstacle in full_obstacles)
								if (locate(obstacle) in tile)
									override = TRUE
									break
							if (istype(Z, /datum/zLevel/snowsurface))//a few snowflake checks (pun intended) to keep some of snaxi's secrets a bit harder to find.
								if (istype(aera, /area/surface/blizzard))
									if(map.holomap_offset_x.len >= zLevel)
										canvas.DrawBox(HOLOMAP_PATH, min(i+map.holomap_offset_x[zLevel],((2 * world.view + 1)*WORLD_ICON_SIZE)), min(r+map.holomap_offset_y[zLevel],((2 * world.view + 1)*WORLD_ICON_SIZE)))
									else
										canvas.DrawBox(HOLOMAP_PATH, i, r)
									continue
								else if ((istype(tile, /turf/unsimulated/floor/snow/permafrost) && istype(aera, /area/surface/mine)) ||(istype(tile, /turf/unsimulated/floor/snow/cave) && istype(aera, /area/surface/outer/ne)))
									override = TRUE

								else if (istype(aera, /area/derelict/secret))
									override = TRUE
							if (Z.blur_holomap(aera,tile))
								override = TRUE
							var/exception = FALSE
							if (istype(tile, get_base_turf(zLevel)) && istype(aera, /area/mine/unexplored))//we could avoid such exceptions if this area wasn't ever painted over space.
								exception = TRUE
							if(override || (!exception && ((tile.holomap_draw_override == HOLOMAP_DRAW_FULL) || (aera.holomap_draw_override == HOLOMAP_DRAW_FULL))))
								if(map.holomap_offset_x.len >= zLevel)
									canvas.DrawBox(HOLOMAP_OBSTACLE, min(i+map.holomap_offset_x[zLevel],((2 * world.view + 1)*WORLD_ICON_SIZE)), min(r+map.holomap_offset_y[zLevel],((2 * world.view + 1)*WORLD_ICON_SIZE)))
								else
									canvas.DrawBox(HOLOMAP_OBSTACLE, i, r)
							else
								override = FALSE
								for(var/path in full_paths)
									if (locate(path) in tile)
										override = TRUE
										break
								if (override || (tile.holomap_draw_override == HOLOMAP_DRAW_PATH))
									if(map.holomap_offset_x.len >= zLevel)
										canvas.DrawBox(HOLOMAP_PATH, min(i+map.holomap_offset_x[zLevel],((2 * world.view + 1)*WORLD_ICON_SIZE)), min(r+map.holomap_offset_y[zLevel],((2 * world.view + 1)*WORLD_ICON_SIZE)))
									else
										canvas.DrawBox(HOLOMAP_PATH, i, r)
						else if (istype(Z, /datum/zLevel/snowsurface) && istype(aera, /area/vault))
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
				/area/centcom/test,
				/area/centcom/ferry,
				/area/centcom/holding,
				/area/centcom/evac,
				)
		if(HOLOMAP_FILTER_ERT)
			allowed_areas = list(
				/area/centcom/ert,
				/area/centcom/control,
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
				if((!istype(tile, get_base_turf(map.zCentcomm)) && istype(tile.loc, /area/mine/unexplored)) || istype(tile, /turf/simulated/wall) || istype(tile, /turf/unsimulated/mineral) || istype(tile, /turf/unsimulated/wall) || (locate(/obj/structure/grille) in tile) || (locate(/obj/structure/window/full) in tile) || istype(tile, /turf/simulated/wall/shuttle))
					if(map.holomap_offset_x.len >= map.zCentcomm)
						canvas.DrawBox(HOLOMAP_OBSTACLE, min(i+map.holomap_offset_x[map.zCentcomm],((2 * world.view + 1)*WORLD_ICON_SIZE)), min(r+map.holomap_offset_y[map.zCentcomm],((2 * world.view + 1)*WORLD_ICON_SIZE)))
					else
						canvas.DrawBox(HOLOMAP_OBSTACLE, i, r)
				else if (istype(tile, /turf/simulated/floor) || istype(tile, /turf/unsimulated/floor) || (locate(/obj/structure/catwalk) in tile) || istype(tile, /turf/simulated/floor/shuttle))
					if(map.holomap_offset_x.len >= map.zCentcomm)
						canvas.DrawBox(HOLOMAP_PATH, min(i+map.holomap_offset_x[map.zCentcomm],((2 * world.view + 1)*WORLD_ICON_SIZE)), min(r+map.holomap_offset_y[map.zCentcomm],((2 * world.view + 1)*WORLD_ICON_SIZE)))
					else
						canvas.DrawBox(HOLOMAP_PATH, i, r)

	centcommMiniMaps["[filter]"] = canvas

/proc/generateStationMinimap(var/StationZLevel)
	var/icon/canvas = icon('icons/480x480.dmi', "blank")

	if(!map.disable_holominimap_generation)
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
					else if ((tile.holomap_draw_override == HOLOMAP_DRAW_HALLWAY) && !istype(areaToPaint, /area/surface/blizzard))
						if(map.holomap_offset_x.len >= StationZLevel)
							canvas.DrawBox(HOLOMAP_AREACOLOR_HALLWAYS, min(i+map.holomap_offset_x[StationZLevel],((2 * world.view + 1)*WORLD_ICON_SIZE)), min(r+map.holomap_offset_y[StationZLevel],((2 * world.view + 1)*WORLD_ICON_SIZE)))
						else
							canvas.DrawBox(HOLOMAP_AREACOLOR_HALLWAYS, i, r)

	var/icon/big_map = icon('icons/480x480.dmi', "stationmap")
	var/icon/small_map = icon('icons/480x480.dmi', "blank")
	var/icon/map_base = icon(holoMiniMaps[StationZLevel])
/*
	var/icon/map_with_areas = icon(holoMiniMaps[StationZLevel])
	map_with_areas = icon(holoMiniMaps[StationZLevel])
	map_with_areas.Blend(canvas,ICON_OVERLAY)
*/
	extraMiniMaps |= HOLOMAP_EXTRA_STATIONMAPAREAS+"_[StationZLevel]"
	extraMiniMaps[HOLOMAP_EXTRA_STATIONMAPAREAS+"_[StationZLevel]"] = canvas

	map_base.Blend("#79ff79",ICON_MULTIPLY)

	small_map.Blend(map_base,ICON_OVERLAY)
	small_map.Blend(canvas,ICON_OVERLAY)
	small_map.Scale(32,32)

	big_map.Blend(map_base,ICON_OVERLAY)
	big_map.Blend(canvas,ICON_OVERLAY)

	if(StationZLevel == map.zMainStation)
		var/icon/strategic_map = icon(big_map)

		for(var/marker in holomap_markers)
			var/datum/holomap_marker/holomarker = holomap_markers[marker]
			if(holomarker.z == StationZLevel && holomarker.filter & HOLOMAP_FILTER_STATIONMAP_STRATEGIC)
				if(map.holomap_offset_x.len >= StationZLevel)
					strategic_map.Blend(icon(holomarker.icon,holomarker.id), ICON_OVERLAY, holomarker.x-8+map.holomap_offset_x[StationZLevel]	, holomarker.y-8+map.holomap_offset_y[StationZLevel])
				else
					strategic_map.Blend(icon(holomarker.icon,holomarker.id), ICON_OVERLAY, holomarker.x-8, holomarker.y-8)

		extraMiniMaps |= HOLOMAP_EXTRA_STATIONMAP_STRATEGIC
		extraMiniMaps[HOLOMAP_EXTRA_STATIONMAP_STRATEGIC] = strategic_map

	for(var/marker in holomap_markers)
		var/datum/holomap_marker/holomarker = holomap_markers[marker]
		if((holomarker.z == StationZLevel) && ((holomarker.filter & HOLOMAP_FILTER_STATIONMAP) || (map.snow_theme && (holomarker.filter & HOLOMAP_FILTER_TAXI))))
			if(map.holomap_offset_x.len >= StationZLevel)
				big_map.Blend(icon(holomarker.icon,holomarker.id), ICON_OVERLAY, holomarker.x-8+map.holomap_offset_x[StationZLevel]	, holomarker.y-8+map.holomap_offset_y[StationZLevel])
			else
				big_map.Blend(icon(holomarker.icon,holomarker.id), ICON_OVERLAY, holomarker.x-8, holomarker.y-8)

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
