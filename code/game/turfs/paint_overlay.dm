
/*

/turf/proc/get_paint_state()
/turf/proc/get_paint_icon()
/turf/proc/apply_paint_overlay()
/turf/proc/apply_paint_stroke()
/turf/proc/remove_paint_overlay()
/turf/proc/update_paint_overlay()

/datum/paint_overlay

/obj/abstract/map/paint_coat
/obj/abstract/map/paint_coat/paint_stroke

*/

//returns the icon_state that corresponds to the paint overlay for that given turf.
/turf/proc/get_paint_state()
	var/paint_icon_state = icon_state
	switch (icon)
		if ('icons/turf/nfloors.dmi')
			paint_icon_state = "floor"
		if ('icons/turf/snow.dmi')
			if (icon_state == "plating")
				paint_icon_state = "plating-snow"
		else
			if (paint_icon_state in paint_overlay_override_floors)
				paint_icon_state = paint_overlay_override_floors[paint_icon_state]
	return paint_icon_state

/turf/simulated/floor/shuttle/get_paint_state()
	if (icon_state == "floor3")
		return "floor-shuttle1"
	return "floor-shuttle2"

/turf/simulated/floor/glass/get_paint_state()
	return "floor"

/turf/simulated/wall/get_paint_state()
	var/paint_icon_state = icon_state
	if (paint_icon_state in paint_overlay_override_walls)
		paint_icon_state = paint_overlay_override_walls[paint_icon_state]
	return paint_icon_state

/turf/simulated/wall/mineral/gold/get_paint_state()
	return replacetext(icon_state,mineral,"silver")

/turf/simulated/wall/mineral/silver/silver_old/get_paint_state()
	return replacetext(icon_state,mineral,"diamond")

/turf/simulated/wall/mineral/gold/gold_old/get_paint_state()
	return replacetext(icon_state,mineral,"diamond")

/turf/simulated/wall/mineral/iron/get_paint_state()
	return replacetext(icon_state,mineral,"diamond")

/turf/simulated/wall/mineral/sandstone/get_paint_state()
	return replacetext(icon_state,mineral,"diamond")

/turf/simulated/wall/mineral/clown/get_paint_state()
	return replacetext(icon_state,mineral,"diamond")

/turf/simulated/wall/mineral/clockwork/get_paint_state()
	return "clock"

/turf/unsimulated/wall/get_paint_state()
	var/paint_icon_state = icon_state
	if (paint_icon_state in paint_overlay_override_walls)
		paint_icon_state = paint_overlay_override_walls[paint_icon_state]
	return paint_icon_state

/turf/simulated/wall/shuttle/get_paint_state()
	var/paint_icon_state = icon_state
	if (findtext(icon_state,"bswall"))
		return copytext(icon_state,2)
	else if (paint_icon_state in paint_overlay_override_shuttle_walls)
		paint_icon_state = paint_overlay_override_shuttle_walls[paint_icon_state]
	return paint_icon_state


//------------------------------------------------------

//returns the dmi that corresponds to the paint overlay for that given turf.
/turf/proc/get_paint_icon()
	return 'icons/turf/paint_overlays_floors.dmi'

/turf/simulated/wall/get_paint_icon()
	return 'icons/turf/paint_overlays_walls.dmi'

/turf/unsimulated/wall/get_paint_icon()
	return 'icons/turf/paint_overlays_walls.dmi'

//------------------------------------------------------

//covers the whole turf with a new coat of paint, removing all paint decals in the process.
/turf/proc/apply_paint_overlay(var/_color=COLOR_WHITE,var/_alpha=255,var/_DNA = list(),var/_nano_paint=FALSE)
	if (!paint_overlay)
		paint_overlay=new(src)
	paint_overlay.apply(_color,_alpha, null, SOUTH, _DNA, _nano_paint)

//applies a paint decal
/turf/proc/apply_paint_stroke(var/_color=COLOR_WHITE,var/_alpha=255,var/_dir=SOUTH,var/_stroke_icon = "border_splatter",var/_DNA = list(),var/_nano_paint=FALSE)
	if (!paint_overlay)
		paint_overlay=new(src)
	paint_overlay.add_border_stroke(_color,_alpha,_dir, _stroke_icon, _DNA, _nano_paint)

//removes the paint overlay. Keeping erase at 0 let's us re-add it later, useful when we want to preserves things paint on plating hidden by floor tiles.
/turf/proc/remove_paint_overlay(var/erase)
	if (paint_overlay)
		paint_overlay.remove(erase)

//refreshes the paint overlay, ensuring that it matches any changes to the turf (such as its icon changing from damage).
/turf/proc/update_paint_overlay()
	if (paint_overlay)
		paint_overlay.update()
		lighting_overlay.update_overlay()

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/datum/paint_overlay
	var/turf/my_turf
	var/image/overlay
	var/list/sub_overlays = list()
	var/wet_color = COLOR_WHITE
	var/wet_time = 0//world.time of the last time paint was applied that covers the whole tile AND is opaque enough (200+ alpha)
	var/wet_duration = 10 SECONDS//relatively fast-drying
	var/wet_amount = 3//how many steps with wet shoes
	var/list/blood_DNA = list()
	var/arbitrary_overlay_limit = 32//figured not having a limit might be silly.
	var/nano_paint = FALSE//if true, main_color is added to the turf's light, enabling turfs to be lit up even without a proper light source (Might have to rework that when Europa Lights come back)
	var/main_color = "#000000"

	var/list/paintlights = list()//for paint masks made of nano paint


/datum/paint_overlay/New(var/turf/_turf)
	..()
	my_turf = _turf

//We'll need to make copies of a paint overlay when moving them to crowbar'd floor tiles.
/datum/paint_overlay/proc/Copy()
	var/datum/paint_overlay/copy = new()
	copy.overlay = image('icons/turf/paint_overlays_floors.dmi',my_turf,"no_paint")
	for (var/image/lay in sub_overlays)
		var/image/I = image(lay)
		copy.sub_overlays += I
	copy.wet_color = wet_color
	copy.wet_time = wet_time
	copy.wet_duration = wet_duration
	copy.wet_amount = wet_amount
	copy.blood_DNA = blood_DNA.Copy()

	copy.nano_paint = nano_paint
	copy.main_color = main_color

	copy.paintlights = paintlights.Copy()

	return copy

#define PAINT_OPACITY_THRESHOLD_FOR_FOOTPRINTS_REMOVAL	200

//the main proc that deals with actually adding paint on the floor
/datum/paint_overlay/proc/apply(var/_color=COLOR_WHITE,var/_alpha=255,var/_mask=null,var/_mask_dir=SOUTH,var/list/_blood_DNA=list(),var/_nano_paint=FALSE)
	my_turf.overlays -= overlay
	if (!overlay)
		overlay = image('icons/turf/paint_overlays_floors.dmi',my_turf,"no_paint")
		overlay.layer = PAINT_LAYER
	if (sub_overlays.len >= arbitrary_overlay_limit)
		_mask = null
		_alpha = 255
	if (!_mask && _alpha == 255)
		overlay.overlays.len = 0//we're applying a full opaque coat of paint so let's get rid of the other overlays
		for (var/obj/abstract/paint_light/PL in paintlights)
			PL.kill_paintlight()
		remove_sub_overlays()
		blood_DNA = list()
	if (!_mask)
		if (_nano_paint || (nano_paint && !_nano_paint))
			main_color = _color
			nano_paint = _nano_paint
			my_turf.lighting_overlay.update_overlay()
		var/image/new_paint_layer = image(my_turf.get_paint_icon(),my_turf,my_turf.get_paint_state(), dir = my_turf.dir)
		new_paint_layer.color = _color
		new_paint_layer.alpha = _alpha
		overlay.overlays += new_paint_layer
		sub_overlays += new_paint_layer
		if (_alpha >= PAINT_OPACITY_THRESHOLD_FOR_FOOTPRINTS_REMOVAL)
			wet(_color, 10 SECONDS, 3)
			for(var/obj/effect/decal/cleanable/blood/tracks/T in my_turf)
				qdel(T)//and let's remove footprints too
	else
		if (_nano_paint)
			add_paintlight(_color, _mask, _mask_dir)
		var/image/terrain = image(my_turf.get_paint_icon(),my_turf,my_turf.get_paint_state(), dir = my_turf.dir)
		terrain.blend_mode = BLEND_INSET_OVERLAY
		var/image/mask = image('icons/turf/paint_masks.dmi',my_turf, _mask, dir = _mask_dir)
		mask.appearance_flags = KEEP_TOGETHER
		mask.alpha = _alpha
		mask.color = _color
		mask.overlays += terrain
		overlay.overlays += mask
		sub_overlays += mask
	blood_DNA |= _blood_DNA
	if (blood_DNA.len <= 0)
		blood_DNA["wet paint"] = "paint"
	my_turf.overlays += overlay

#undef PAINT_OPACITY_THRESHOLD_FOR_FOOTPRINTS_REMOVAL

//Causes the floor to wet the feet of humans, causing them to leave paint footprints
/datum/paint_overlay/proc/wet(var/_color=COLOR_WHITE,var/_duration=10 SECONDS, var/_amount=3)//amount means how far footprints can go
	wet_time = world.time

	wet_color = _color
	wet_duration = _duration
	wet_amount = _amount

//Adding paint decals.
/datum/paint_overlay/proc/add_border_stroke(var/_color=COLOR_WHITE,var/_alpha=255,var/_dir=SOUTH,var/stroke_icon = "border_splatter",var/list/_blood_DNA=list(),var/_nano_paint=FALSE)
	if (!overlay)
		overlay = image('icons/turf/paint_overlays_floors.dmi',my_turf,"no_paint")
		overlay.layer = PAINT_LAYER
	if (stroke_icon == "border_roller")//progressively painting over the whole tile
		if (sub_overlays.len > 0)
			var/image/lay = sub_overlays[sub_overlays.len]//grabbing the most recent overlay
			if (lay.icon == 'icons/turf/paint_masks.dmi')
				if ((lay.color ? lay.color : "#ffffff") == copytext(_color,1,8) && lay.alpha == round(_alpha))//same paint
					if (lay.dir == _dir)
						switch(lay.icon_state)
							if ("border_roller")
								apply(_color,_alpha,"border_roller_progress",_dir,_blood_DNA,_nano_paint)
								return
							if ("border_roller_progress")
								apply(_color,_alpha,null,_dir,_blood_DNA,_nano_paint)//On the third click we just apply a coat over the whole tile
								return
	if (stroke_icon == "wall_side")//painting around a wall
		if (sub_overlays.len > 0)
			var/image/lay = sub_overlays[sub_overlays.len]//grabbing the most recent overlay
			if (lay.icon == 'icons/turf/paint_masks.dmi')
				if ((lay.color ? lay.color : "#ffffff") == copytext(_color,1,8) && lay.alpha == round(_alpha))//painting the same side twice in a row with the same paint covers the whole wall
					if (lay.dir == _dir)
						apply(_color,_alpha,null,_dir,_blood_DNA,_nano_paint)
						return
	apply(_color,_alpha,stroke_icon,_dir,_blood_DNA,_nano_paint)

/datum/paint_overlay/proc/update()//updates the paint layers when floors get damaged and such
	if (!overlay)
		return
	my_turf.overlays -= overlay
	overlay.overlays.len = 0
	var/turf_icon = my_turf.get_paint_icon()
	var/turf_state = my_turf.get_paint_state()
	for (var/image/lay in sub_overlays)
		if (lay.icon == 'icons/turf/paint_masks.dmi')
			lay.overlays.len = 0
			var/image/I = image(turf_icon,my_turf,turf_state, dir = my_turf.dir)
			I.blend_mode = BLEND_INSET_OVERLAY
			lay.overlays += I
		else
			lay.icon = turf_icon
			lay.icon_state = turf_state
		overlay.overlays += lay
	my_turf.overlays += overlay

	refresh_paintlights()

/datum/paint_overlay/proc/remove(var/erase=0)
	my_turf.overlays -= overlay
	for (var/obj/abstract/paint_light/PL in paintlights)
		PL.kill_paintlight(erase)
	if (nano_paint)
		nano_paint = FALSE
		my_turf.lighting_overlay.update_overlay()
	if (erase)
		nano_paint = FALSE
		overlay.overlays.len = 0
		remove_sub_overlays()
		wet_time = 0
		blood_DNA = list()

/datum/paint_overlay/proc/refresh_paintlights()
	if (my_turf)
		my_turf.lighting_overlay.update_overlay()

	for (var/obj/abstract/paint_light/PL in paintlights)
		PL.refresh_paintlight(my_turf)

/datum/paint_overlay/proc/remove_sub_overlays()
	paintlights.len = 0
	sub_overlays.len = 0

/datum/paint_overlay/proc/add_paint_to_feet(var/mob/living/carbon/human/H)
	if (!overlay || !wet_time || ((world.time - wet_time) > wet_duration))
		return
	if(H.shoes)
		var/obj/item/clothing/shoes/S = H.shoes
		S.track_blood = max(0, wet_amount, S.track_blood)
		S.luminous_paint = FALSE
		if (nano_paint)
			S.luminous_paint = TRUE
		else
			for (var/obj/abstract/paint_light/PL in paintlights)
				if (PL.light_color == wet_color)
					S.luminous_paint = TRUE
		if(!blood_overlays["[S.type][S.icon_state]"])
			S.set_blood_overlay()

		if(S.blood_overlay != null)
			S.overlays.Remove(S.blood_overlay)
		else
			S.blood_overlay = blood_overlays["[S.type][S.icon_state]"]

		if(!S.blood_DNA)
			S.blood_DNA = list()
		S.blood_DNA |= blood_DNA.Copy()

		var/newcolor = (S.blood_color && S.blood_DNA.len) ? BlendRYB(S.blood_color, wet_color, 0.5) : wet_color
		S.blood_overlay.color = newcolor
		S.overlays += S.blood_overlay
		S.blood_color = newcolor

		H.update_inv_shoes(1)

	else
		H.track_blood = max(wet_amount, 0, H.track_blood)
		if(!H.feet_blood_DNA)
			H.feet_blood_DNA = list()
		H.feet_blood_DNA |= blood_DNA.Copy()
		H.feet_blood_lum = FALSE
		if (nano_paint)
			H.feet_blood_lum = TRUE
		else
			for (var/obj/abstract/paint_light/PL in paintlights)
				if (PL.light_color == wet_color)
					H.feet_blood_lum = TRUE
		H.feet_blood_color = (H.feet_blood_color && H.feet_blood_DNA.len) ? BlendRYB(H.feet_blood_color, wet_color, 0.5) : wet_color

		H.update_inv_shoes(1)

/datum/paint_overlay/proc/add_paintlight(var/_color, var/_state, var/_dir)
	var/obj/abstract/paint_light/PL = new(my_turf)
	PL.setup_paintlight(_color,_state,_dir)
	PL.refresh_paintlight(my_turf)
	paintlights += PL

///////////////////////////////////////////////////////////////////////////////////////////////////
/obj/abstract/paint_light
	icon = 'icons/effects/32x32.dmi'
	icon_state = "blank"
	mouse_opacity = 0

	var/paint_state
	dir = SOUTH

/obj/abstract/paint_light/proc/setup_paintlight(var/_color, var/_state, var/_dir)
	light_color = _color
	paint_state = _state
	dir = _dir

/obj/abstract/paint_light/proc/refresh_paintlight(var/turf/_my_turf)
	if (_my_turf)
		loc = _my_turf
		update_moody_light('icons/turf/paint_masks.dmi',paint_state,255,light_color)

/obj/abstract/paint_light/proc/kill_paintlight()
	kill_moody_light()

///////////////////////////////////////////////////////////////////////////////////////////////////
//Lets mappers have some turfs pre-painted

/obj/abstract/map/paint_coat
	plane = TURF_PLANE
	layer = PAINT_LAYER
	icon = 'icons/turf/paint_overlays_floors.dmi'
	icon_state = "fullblack"
	color = COLOR_WHITE
	alpha = 255
	var/coat_luminosity = FALSE

/obj/abstract/map/paint_coat/perform_spawn()
	var/turf/T = get_turf(loc)
	if (T)
		T.apply_paint_overlay(color,alpha,list(),coat_luminosity)
	qdel(src)

/obj/abstract/map/paint_coat/paint_stroke
	icon = 'icons/turf/paint_masks.dmi'
	icon_state = "border_roller"
	dir = SOUTH

/obj/abstract/map/paint_coat/paint_stroke/perform_spawn()
	var/turf/T = get_turf(loc)
	if (T)
		T.apply_paint_stroke(color,alpha,dir,icon_state,list(),coat_luminosity)
	qdel(src)
