
/* *********************************************************************************
        _____      _     ______ _       _     _____                        _
       / ____|    | |   |  ____| |     | |   |_   _|                      | |
      | |  __  ___| |_  | |__  | | __ _| |_    | |  ___ ___  _ __       __| |_  __
      | | |_ |/ _ \ __| |  __| | |/ _` | __|   | | / __/ _ \| '_ \     / _` \ \/ /
      | |__| |  __/ |_  | |    | | (_| | |_   _| || (_| (_) | | | |   | (_| |>  <
       \_____|\___|\__| |_|    |_|\__,_|\__| |_____\___\___/|_| |_|    \__,_/_/\_\

       Created by Deity, loosely based on David "DarkCampainger" Braun's own proc

                  It's open source, so use it how you want I guess

                            Version 2.0 - June 18, 2021

	  	 See camera_get_icon_deluxe() in photography.dm for an example usage

*///////////////////////////////////////////////////////////////////////////////////
/***************
pros:
* handles better the capture of multiple overlapping atoms as overlays with custom planes will appear properly relatively to other atoms
* fixes a bunch of byond bugs that occur when trying to render an icon using a dir that it doesn't have without resorting to big lists full of snowflakey exceptions
* added exceptions for human icons so that they appear with the direction that they are actually facing

cons:
* no cache, which would otherwise become expontentially inefficient as more and more atoms are captured at once. shouldn't be much of an issue anyway given how the proc is used
* no exact arg, if you want a reference picture of a single mob, use the old Get Flat Icon instead. It'd probably be more efficient too for a single atom.


****************/
proc/getFlatIconDeluxe(list/image_datas, var/turf/center, var/radius = 0)

	/*
	data[1]  = atom or parent atom if it's an overlay
	data[2]  = icon
	data[3]  = icon_state
	data[4]  = dir
	data[5]  = plane
	data[6]  = layer
	data[7]  = color
	data[8]  = alpha
	data[9]  = pixel_x
	data[10] = pixel_y
	data[11] = name if atom, otherwise ""
	data[12] = invisibility if atom, otherwise 0
	*/

	var/icon/flat = icon('icons/effects/224x224.dmi',"empty") // Final flattened icon
	var/icon/add // Icon of overlay being added

	for(var/data in image_datas)
		if (!data[2] && !data[3]) // no icon nor icon_state? we're probably not meant to draw that. Possibly a blank icon while we're only interested in its overlays.
			continue
		CHECK_TICK

		if (!data[3] || data[3] == "body_m_s")//this fixes human bodies always facing south
			add = icon(data[2], dir = data[4], frame = 1, moving = 0)
		else
			//making sure that our icon can turn
			var/dir = data[4]
			if (dir != SOUTH) // south-facing atoms shouldn't pose any problem
				var/icon_directions = get_icon_dir_count(data[2],data[3])
				if (icon_directions == 1)
					data[4] = SOUTH // if the icon has only one direction we HAVE to face south
				else if (icon_directions == 4)
					if (dir != NORTH && dir != EAST && dir != WEST)
						data[4] = SOUTH

			add = icon(data[2]
			         , data[3]
			         , data[4]
			         , 1
			         , 0)

		if(data[11] == "damage layer")
			if(ishuman(data[1]))
				var/mob/living/carbon/human/H = data[1]
				for(var/datum/organ/external/O in H.organs)
					if(!(O.status & ORGAN_DESTROYED))
						if(O.damage_state == "00")
							continue
						var/icon/DI
						DI = H.get_damage_icon_part(O.damage_state, O.icon_name, (H.species.blood_color == DEFAULT_BLOOD ? "" : H.species.blood_color))
						add.Blend(DI,ICON_OVERLAY)

		if(iscarbon(data[1]))
			var/mob/living/carbon/C = data[1]
			if(C.lying && !isalienadult(C))//because adult aliens have their own resting sprite
				add.Turn(90)

		if(isobserver(data[1]))
			add.ChangeOpacity(0.5)

		// Apply any color or alpha settings
		if(data[7] || data[8] != 255)
			var/rgba = (data[7] || "#FFFFFF") + copytext(rgb(0,0,0,data[8]), 8)
			add.Blend(rgba, ICON_MULTIPLY)

		// Blend the overlay into the flattened icon
		var/atom/pos = data[1]
		flat.Blend(add,blendMode2iconMode(pos.blend_mode),1+data[9]+PIXEL_MULTIPLIER*32*(pos.x-center.x+radius),1+data[10]+PIXEL_MULTIPLIER*32*(pos.y-center.y+radius))

	return flat

///////////////////////////////////////////////////////////////////////////////////////

// to_sort might be either an atom or an image, returns its image data relative to its parent if there is one
/proc/get_image_data(var/to_sort,var/list/parent)

	var/data[12]
	data[1] = to_sort
	data[2] = to_sort:icon
	data[3] = to_sort:icon_state
	data[4] = to_sort:dir
	data[5] = to_sort:plane
	data[6] = to_sort:layer
	data[7] = to_sort:color
	data[8] = to_sort:alpha
	data[9] = to_sort:pixel_x
	data[10] = to_sort:pixel_y
	data[11] = ""
	data[12] = 0
	if (isatom(to_sort))
		data[11] = to_sort:name
	if (isatom(to_sort))
		data[11] = to_sort:invisibility
	if (parent?.len)
		data[1] = parent[1] // the first entry always has to be the top level atom so we can track things like mobs lying down or their position
		data[4] = parent[4]
		if (to_sort:plane == FLOAT_PLANE)
			data[5] = parent[5] + 0.1
		//child layer always overwrites
		data[7] = parent[7]
		if (parent[8] != 255)
			data[8] = parent[8]
		data[9] += parent[9]
		data[10] += parent[10]

	return data

// fetches the image data of to_sort, as well as those of its overlays and underlays
/proc/get_content_image_datas(var/to_sort,var/list/parent)
	var/content_data = list()
	var/list/my_data = get_image_data(to_sort,parent)
	if (!my_data)
		return
	content_data = list(my_data)
	var/list/underlays = to_sort:underlays
	var/list/overlays = to_sort:overlays
	for (var/underlay in underlays)
		var/list/L = get_content_image_datas(underlay,my_data)
		if (L)
			content_data += L
	for (var/overlay in overlays)
		var/list/L = get_content_image_datas(overlay,my_data)
		if (L)
			content_data += L

	return content_data

// fetches the image datas of all atoms in a turf, including itself
/proc/get_turf_image_datas(var/turf/T,var/obj/item/device/camera/camera)
	var/list/turf_image_datas = list()
	turf_image_datas = get_content_image_datas(T)
	for(var/atom/A in T.contents)
		if (istype(A, /atom/movable/lighting_overlay))
			continue
		A.photography_act(camera)
		if (A.invisibility)
			if (!isobserver(A) || !camera.see_ghosts)
				continue
		var/list/L = get_content_image_datas(A)
		if (L)
			turf_image_datas += L

	return turf_image_datas

// sort image datas according to their planes/layers
/proc/sort_image_datas(var/list/datas_to_sort)
	if (!datas_to_sort?.len)
		return
	var/list/sorted = list()
	for(var/list/current_data in datas_to_sort)
		var/compare_index
		for(compare_index = sorted.len, compare_index > 0, --compare_index)
			var/list/compare_data = sorted[compare_index]
			if(compare_data[5] < current_data[5])
				break
			else if((compare_data[5] == current_data[5]) && (compare_data[6] <= current_data[6]))
				break
		sorted.Insert(compare_index+1, list(current_data))
	return sorted
