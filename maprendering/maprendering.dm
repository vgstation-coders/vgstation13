#define MAPRENDER_IN_ROUND_CHECK_TICK ( !config.maprender_lags_game ? IN_ROUND_CHECK_TICK : 0 )

/client/proc/maprender()
	set category = "Mapping"
	set name = "Generate Map Render"

	if(!holder)
		to_chat(src, "Only administrators may use this command.")
		return
	if(config.maprender_lags_game)
		if(alert("Sure you want to do this? It should NEVER be done in an active round and cannot be cancelled", "generate maps", "Yes", "No") == "No")
			return

	var/allz = alert("Do you wish to generate a specific zlevel or all zlevels?", "Generate what levels?", "All", "Specific", "Cancel")

	var/zlevel = 1
	var/all_z = FALSE
	switch(allz)
		if("Cancel")
			return
		if("Specific")
			zlevel = input(usr,"Input zlevel you wish to render","Input zlevel",zlevel) as num
		if("All")
			all_z = TRUE

	var/area_rendered = alert("Do you wish to generate a specific area?", "Generate what area?", "All", "Specific", "Cancel")
	switch(area_rendered)
		if("Cancel")
			return
		if("Specific")
			area_rendered = input("Input area type") as text
			area_rendered = filter_list_input("Select an area type", "Area type", get_matching_types(area_rendered, /area))
			if(!area_rendered)
				area_rendered = null
		if("All")
			area_rendered = null

	var/invisibles = alert("Render invisible atoms?", "Render invisible", "Yes", "No", "Cancel")
	if(invisibles == "Cancel")
		return
	invisibles = invisibles == "Yes"

	var/lighted = /*alert("Render lighting?", "Render lighting", "Yes", "No", "Cancel")*/FALSE //doesn't work right, so kept like this
	/*if(lighted == "Cancel")
		return
	lighted = lighted == "Yes"*/

	var/strang = "[ckey]/[src] started rendering maps[area_rendered ? " for area [area_rendered]" : ""][all_z ? "" : " on z-level [zlevel]"],[invisibles ? "" : " not"] showing invisible atoms"/*,[lighted ? "" : " not"] showing lighting*/
	message_admins(strang)
	log_admin(strang)

	maprenders(zlevel, all_z, area_rendered, invisibles, lighted)

/client/proc/maprenders(var/currentz = 1, var/allz = 0, var/render_area = null, var/invisibles = TRUE, var/lighted = FALSE)

	to_chat(world, "Map Render: <B>GENERATE MAP FOR [allz? "ALL ZLEVELS" : "LEVEL [currentz]"]</B>")
	var/mapname = replacetext(map.nameLong, " ", "")

	var/startz = currentz
	var/endz = currentz
	if(allz)
		startz = 1
		endz = world.maxz

	var/const/icon_size = 2048/WORLD_ICON_SIZE //Depends on map render icon, in this case we're doing 2048x2048 pixels at 32x32 per tile

	for(var/z = startz to endz)
		for(var/x = 0 to world.maxx step icon_size)
			for(var/y = 0 to world.maxy step icon_size)
				var/list/pixel_shift_objects = list()
				var/icon/map_icon = new/icon('maprendering/maprender.png') //2048 pixels, thats 32 tiles of 32 pixels
				var/area_rendered = FALSE
				for(var/a = 1 to icon_size)
					for(var/b = 1 to icon_size)
						//Finding turf and all turf contents
						var/turf/currentturf = locate(x+a,y+b,z)
						if(!currentturf || (currentturf.turf_flags & NO_MINIMAP))
							continue
						if(render_area && !istype(get_area(currentturf),render_area))
							var/otherfinds = FALSE
							var/otherfound = FALSE
							if(currentturf.density)
								otherfinds = TRUE
							else
								for(var/atom/movable/A in currentturf.contents)
									if((A.pass_flags_self & PASSGRILLE) || (A.pass_flags_self & PASSDOOR))
										otherfinds = TRUE
										break
							if(otherfinds)
								for(var/direction in alldirs)
									var/turf/otherturf = get_step(currentturf,direction)
									if(!otherturf.density && istype(get_area(otherturf),render_area))
										otherfound = TRUE
										break
							if(!otherfound)
								continue
						area_rendered = TRUE
						var/list/allturfcontents = currentturf.contents.Copy()

						//Remove the following line if you want to add space to your renders, I think it is cheaper to merely use a pregenned image for this
						if(!istype(currentturf,/turf/space))
							var/icon/turficon = getFlatIcon(currentturf, currentturf.dir, cache = 0)
							map_icon.Blend(turficon, ICON_OVERLAY, ((a-1)*WORLD_ICON_SIZE)+1, ((b-1)*WORLD_ICON_SIZE)+1)

						for(var/atom/movable/A in allturfcontents)
							if((!lighted && A.type == /atom/movable/lighting_overlay) || (!invisibles && A.invisibility == 101))
								allturfcontents -= A
							else if(A.locs.len > 1) //Fix for multitile objects I wish I didn't have to do this its probably slow
								if(A.locs[1] != A.loc)
									allturfcontents -= A
									continue
						//Due to processing order, a pixelshifted object will be overriden in certain directions,
						//we'll apply it at the end, they're almost always at the top layer anyway
							if(A.pixel_x || A.pixel_y)
								allturfcontents -= A
								pixel_shift_objects += A
							MAPRENDER_IN_ROUND_CHECK_TICK

						if(!allturfcontents.len)
							continue

						allturfcontents = plane_layer_sort(allturfcontents)

						//Preparing to blend get flat icon of
						for(var/A in allturfcontents)
							var/blendtype = ICON_OVERLAY
							if(A:type == /atom/movable/lighting_overlay)
								blendtype = BLEND_MULTIPLY
							var/icon/icontoblend = getFlatIcon(A,A:dir, cache = 0)
							map_icon.Blend(icontoblend, blendtype, ((a-1)*WORLD_ICON_SIZE)+1, ((b-1)*WORLD_ICON_SIZE)+1)
							MAPRENDER_IN_ROUND_CHECK_TICK
						sleep(-1)
						MAPRENDER_IN_ROUND_CHECK_TICK
					MAPRENDER_IN_ROUND_CHECK_TICK
				if(!area_rendered)
					continue
				for(var/A in pixel_shift_objects)
					var/icon/icontoblend = getFlatIcon(A, A:dir, cache = 0)
					//This part is tricky since we've skipped a and b, since these are map objects they have valid x,y. a and b should be the modulo'd value of x,y with icon_size
					map_icon.Blend(icontoblend, ICON_OVERLAY, (((A:x % icon_size)-1)*WORLD_ICON_SIZE)+1+A:pixel_x, (((A:y % icon_size)-1)*WORLD_ICON_SIZE)+1+A:pixel_y)
					MAPRENDER_IN_ROUND_CHECK_TICK

				if(y >= world.maxy)
					map_icon.DrawBox(rgb(255,255,255,255), x1 = 1, y1 = 1, x2 = WORLD_ICON_SIZE*icon_size, y2 = WORLD_ICON_SIZE*(icon_size-world.maxy % icon_size))
				if(x >= world.maxx)
					map_icon.DrawBox(rgb(255,255,255,255), x1 = WORLD_ICON_SIZE*(icon_size - world.maxx % icon_size), y1 = 1, x2 = WORLD_ICON_SIZE*icon_size, y2 = WORLD_ICON_SIZE*icon_size)

				world.log << "Completed image z: [z], x: [x] to [x/icon_size], y: [round((world.maxy-y)/icon_size)]"
				var/resultpath = "maprendering/renderoutput/[mapname]/[z]/maprender[round((world.maxy-y)/icon_size)]-[x/icon_size].png"
				// BYOND BUG: map_icon now contains 4 directions? Create a new icon with only a single state.
				var/icon/result_icon = new/icon()

				result_icon.Insert(map_icon, "", SOUTH, 1, 0)
				if(fexists(resultpath))
					fdel(resultpath)
				fcopy(result_icon, resultpath)
				MAPRENDER_IN_ROUND_CHECK_TICK
			MAPRENDER_IN_ROUND_CHECK_TICK
		MAPRENDER_IN_ROUND_CHECK_TICK
	to_chat(world, "<b>The map has been rendered successfully<b>")
	src << sound('sound/effects/maprendercomplete.ogg')
