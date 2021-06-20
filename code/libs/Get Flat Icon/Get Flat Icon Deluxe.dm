
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

#define GFI_DX_ATOM		1	// This is either the icon's source atom, or in the case of an overlay the atom this icon is an overlay of
#define GFI_DX_ICON		2	// Can be a dmi, or an icon object, depending on whether there is also a state. Can also be null in the case of overlays, so the parent's icon is used.
#define GFI_DX_STATE	3	// The icon_state.
#define GFI_DX_DIR		4	// The dir of the parent atom
#define GFI_DX_PLANE	5	// The plane of the atom, or the parent atom's +0.1 in the case of overlays
#define GFI_DX_LAYER	6
#define GFI_DX_COLOR	7	// The parent's color always overrides
#define GFI_DX_ALPHA	8	// The image's alpha, or that of its parent if said parent's alpha isn't 255
#define GFI_DX_PIXEL_X	9	// The combined offset of the overlay image and every datum it's part of, including parent images and the base atom
#define GFI_DX_PIXEL_Y	10	// The combined offset of the overlay image and every datum it's part of, including parent images and the base atom
#define GFI_DX_NAME		11	// Used to identify the human damage layer and apply the proper blood color

proc/getFlatIconDeluxe(list/image_datas, var/turf/center, var/radius = 0)

	var/icon/flat = icon('icons/effects/224x224.dmi',"empty") // Final flattened icon
	var/icon/add // Icon of overlay being added

	for(var/data in image_datas)
		if (!data[GFI_DX_ICON] && !data[GFI_DX_STATE]) // no icon nor icon_state? we're probably not meant to draw that. Possibly a blank icon while we're only interested in its overlays.
			continue
		CHECK_TICK

		if (!data[GFI_DX_STATE] || data[GFI_DX_STATE] == "body_m_s")//this fixes human bodies always facing south
			add = icon(data[GFI_DX_ICON], dir = data[GFI_DX_DIR], frame = 1, moving = 0)
		else
			if (!data[GFI_DX_ICON] && data[GFI_DX_ATOM])
				data[GFI_DX_ICON] = data[GFI_DX_ATOM]:icon
			//making sure that our icon can turn
			var/dir = data[GFI_DX_DIR]
			if (dir != SOUTH) // south-facing atoms shouldn't pose any problem
				var/icon_directions = get_icon_dir_count(data[GFI_DX_ICON],data[3])
				if (icon_directions == 1)
					data[GFI_DX_DIR] = SOUTH // if the icon has only one direction we HAVE to face south
				else if (icon_directions == 4)
					if (dir != NORTH && dir != EAST && dir != WEST)
						data[GFI_DX_DIR] = SOUTH

			add = icon(data[GFI_DX_ICON]
			         , data[GFI_DX_STATE]
			         , data[GFI_DX_DIR]
			         , 1
			         , 0)

		if(data[GFI_DX_NAME] == "damage layer")
			if(ishuman(data[GFI_DX_ATOM]))
				var/mob/living/carbon/human/H = data[GFI_DX_ATOM]
				for(var/datum/organ/external/O in H.organs)
					if(!(O.status & ORGAN_DESTROYED))
						if(O.damage_state == "00")
							continue
						var/icon/DI
						DI = H.get_damage_icon_part(O.damage_state, O.icon_name, (H.species.blood_color == DEFAULT_BLOOD ? "" : H.species.blood_color))
						add.Blend(DI,ICON_OVERLAY)

		if(iscarbon(data[GFI_DX_ATOM]))
			var/mob/living/carbon/C = data[1]
			if(C.lying && !isalienadult(C))//because adult aliens have their own resting sprite
				add.Turn(90)

		if(isobserver(data[GFI_DX_ATOM]))
			add.ChangeOpacity(0.5)

		// Apply any color or alpha settings
		if(data[GFI_DX_COLOR] || data[GFI_DX_ALPHA] != 255)
			var/rgba = (data[GFI_DX_COLOR] || "#FFFFFF") + copytext(rgb(0,0,0,data[GFI_DX_ALPHA]), 8)
			add.Blend(rgba, ICON_MULTIPLY)

		// Blend the overlay into the flattened icon
		var/atom/pos = data[GFI_DX_ATOM]
		flat.Blend(add,blendMode2iconMode(pos.blend_mode),1+data[GFI_DX_PIXEL_X]+PIXEL_MULTIPLIER*32*(pos.x-center.x+radius),1+data[GFI_DX_PIXEL_Y]+PIXEL_MULTIPLIER*32*(pos.y-center.y+radius))

	return flat

///////////////////////////////////////////////////////////////////////////////////////

// to_sort might be either an atom or an image, returns its image data relative to its parent if there is one
/proc/get_image_data(var/to_sort,var/list/parent)
	var/data[11]
	data[GFI_DX_ATOM] = to_sort
	data[GFI_DX_ICON] = to_sort:icon
	data[GFI_DX_STATE] = to_sort:icon_state
	data[GFI_DX_DIR] = to_sort:dir
	data[GFI_DX_PLANE] = to_sort:plane
	data[GFI_DX_LAYER] = to_sort:layer
	data[GFI_DX_COLOR] = to_sort:color
	data[GFI_DX_ALPHA] = to_sort:alpha
	data[GFI_DX_PIXEL_X] = to_sort:pixel_x
	data[GFI_DX_PIXEL_Y] = to_sort:pixel_y
	data[GFI_DX_NAME] = ""
	if (isatom(to_sort))
		data[GFI_DX_NAME] = to_sort:name
	if (parent?.len)
		data[GFI_DX_ATOM] = parent[GFI_DX_ATOM] // the first entry always has to be the top level atom so we can track things like mobs lying down or their position
		data[GFI_DX_DIR] = parent[GFI_DX_DIR]
		if (to_sort:plane == FLOAT_PLANE)
			data[GFI_DX_PLANE] = parent[GFI_DX_PLANE] + 0.1
		//child layer always overwrites
		data[GFI_DX_COLOR] = parent[GFI_DX_COLOR]
		if (parent[GFI_DX_ALPHA] != 255)
			data[GFI_DX_ALPHA] = parent[GFI_DX_ALPHA]
		data[GFI_DX_PIXEL_X] += parent[GFI_DX_PIXEL_X]
		data[GFI_DX_PIXEL_Y] += parent[GFI_DX_PIXEL_Y]
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
		if (istype(A, /atom/movable/light))
			continue
		if (camera)
			A.photography_act(camera)
		if (A.invisibility)
			if (!isobserver(A) || !camera || !camera.see_ghosts)
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
			if(compare_data[GFI_DX_PLANE] < current_data[GFI_DX_PLANE])
				break
			else if((compare_data[GFI_DX_PLANE] == current_data[GFI_DX_PLANE]) && (compare_data[GFI_DX_LAYER] <= current_data[GFI_DX_LAYER]))
				break
		sorted.Insert(compare_index+1, list(current_data))
	return sorted

#undef GFI_DX_ATOM
#undef GFI_DX_ICON
#undef GFI_DX_STATE
#undef GFI_DX_DIR
#undef GFI_DX_PLANE
#undef GFI_DX_LAYER
#undef GFI_DX_COLOR
#undef GFI_DX_ALPHA
#undef GFI_DX_PIXEL_X
#undef GFI_DX_PIXEL_Y
#undef GFI_DX_NAME
