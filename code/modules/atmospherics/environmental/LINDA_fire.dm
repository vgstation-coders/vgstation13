

/atom/proc/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	return null



/turf/proc/hotspot_expose(exposed_temperature, exposed_volume, soh = 0)
	return


/turf/open/hotspot_expose(exposed_temperature, exposed_volume, soh)
	var/datum/gas_mixture/air_contents = return_air()
	if(!air_contents)
		return 0

	var/oxy = air_contents.gases[/datum/gas/oxygen] ? air_contents.gases[/datum/gas/oxygen][MOLES] : 0
	var/tox = air_contents.gases[/datum/gas/plasma] ? air_contents.gases[/datum/gas/plasma][MOLES] : 0
	var/trit = air_contents.gases[/datum/gas/tritium] ? air_contents.gases[/datum/gas/tritium][MOLES] : 0
	if(active_hotspot)
		if(soh)
			if((tox > 0.5 || trit > 0.5) && oxy > 0.5)
				if(active_hotspot.temperature < exposed_temperature)
					active_hotspot.temperature = exposed_temperature
				if(active_hotspot.volume < exposed_volume)
					active_hotspot.volume = exposed_volume
		return 1

	var/igniting = 0

	if((exposed_temperature > PLASMA_MINIMUM_BURN_TEMPERATURE) && (tox > 0.5 || trit > 0.5))
		igniting = 1

	if(igniting)
		if(oxy < 0.5)
			return 0

		active_hotspot = new /obj/effect/hotspot(src)
		active_hotspot.temperature = exposed_temperature
		active_hotspot.volume = exposed_volume

		active_hotspot.just_spawned = (current_cycle < SSair.times_fired)
			//remove just_spawned protection if no longer processing this cell
		SSair.add_to_active(src, 0)
	return igniting

//This is the icon for fire on turfs, also helps for nurturing small fires until they are full tile
/obj/effect/hotspot
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	icon = 'icons/effects/fire.dmi'
	icon_state = "1"
	layer = GASFIRE_LAYER
	light_range = LIGHT_RANGE_FIRE
	light_color = LIGHT_COLOR_FIRE
	blend_mode = BLEND_ADD

	var/volume = 125
	var/temperature = FIRE_MINIMUM_TEMPERATURE_TO_EXIST
	var/just_spawned = TRUE
	var/bypassing = FALSE
	var/visual_update_tick = 0

/obj/effect/hotspot/Initialize()
	. = ..()
	SSair.hotspots += src
	perform_exposure()
	setDir(pick(GLOB.cardinals))
	air_update_turf()

/obj/effect/hotspot/proc/perform_exposure()
	var/turf/open/location = loc
	if(!istype(location) || !(location.air))
		return

	location.active_hotspot = src

	if(volume > CELL_VOLUME*0.95)
		bypassing = TRUE
	else
		bypassing = FALSE

	if(bypassing)
		if(!just_spawned)
			volume = location.air.reaction_results["fire"]*FIRE_GROWTH_RATE
			temperature = location.air.temperature
	else
		var/datum/gas_mixture/affected = location.air.remove_ratio(volume/location.air.volume)
		affected.temperature = temperature
		affected.react()
		temperature = affected.temperature
		volume = affected.reaction_results["fire"]*FIRE_GROWTH_RATE
		location.assume_air(affected)

	for(var/A in location)
		var/atom/AT = A
		if(AT && AT != src) // It's possible that the item is deleted in temperature_expose
			AT.fire_act(temperature, volume)
	return

/obj/effect/hotspot/proc/gauss_lerp(x, x1, x2)
	var/b = (x1 + x2) * 0.5
	var/c = (x2 - x1) / 6
	return NUM_E ** -((x - b) ** 2 / (2 * c) ** 2)

/obj/effect/hotspot/proc/update_color()
	cut_overlays()

	var/heat_r = heat2colour_r(temperature)
	var/heat_g = heat2colour_g(temperature)
	var/heat_b = heat2colour_b(temperature)
	var/heat_a = 255
	var/greyscale_fire = 1 //This determines how greyscaled the fire is.

	if(temperature < 5000) //This is where fire is very orange, we turn it into the normal fire texture here.
		var/normal_amt = gauss_lerp(temperature, 1000, 3000)
		heat_r = LERP(heat_r,255,normal_amt)
		heat_g = LERP(heat_g,255,normal_amt)
		heat_b = LERP(heat_b,255,normal_amt)
		heat_a -= gauss_lerp(temperature, -5000, 5000) * 128
		greyscale_fire -= normal_amt
	if(temperature > 40000) //Past this temperature the fire will gradually turn a bright purple
		var/purple_amt = temperature < LERP(40000,200000,0.5) ? gauss_lerp(temperature, 40000, 200000) : 1
		heat_r = LERP(heat_r,255,purple_amt)
	if(temperature > 200000 && temperature < 500000) //Somewhere at this temperature nitryl happens.
		var/sparkle_amt = gauss_lerp(temperature, 200000, 500000)
		var/mutable_appearance/sparkle_overlay = mutable_appearance('icons/effects/effects.dmi', "shieldsparkles")
		sparkle_overlay.blend_mode = BLEND_ADD
		sparkle_overlay.alpha = sparkle_amt * 255
		add_overlay(sparkle_overlay)
	if(temperature > 400000 && temperature < 1500000) //Lightning because very anime.
		var/mutable_appearance/lightning_overlay = mutable_appearance(icon, "overcharged")
		lightning_overlay.blend_mode = BLEND_ADD
		add_overlay(lightning_overlay)
	if(temperature > 4500000) //This is where noblium happens. Some fusion-y effects.
		var/fusion_amt = temperature < LERP(4500000,12000000,0.5) ? gauss_lerp(temperature, 4500000, 12000000) : 1
		var/mutable_appearance/fusion_overlay = mutable_appearance('icons/effects/tile_effects.dmi', "chem_gas")
		fusion_overlay.blend_mode = BLEND_ADD
		fusion_overlay.alpha = fusion_amt * 255
		var/mutable_appearance/rainbow_overlay = mutable_appearance('icons/mob/screen_gen.dmi', "druggy")
		rainbow_overlay.blend_mode = BLEND_ADD
		rainbow_overlay.alpha = fusion_amt * 255
		rainbow_overlay.appearance_flags = RESET_COLOR
		heat_r = LERP(heat_r,150,fusion_amt)
		heat_g = LERP(heat_g,150,fusion_amt)
		heat_b = LERP(heat_b,150,fusion_amt)
		add_overlay(fusion_overlay)
		add_overlay(rainbow_overlay)

	set_light(l_color = rgb(LERP(250,heat_r,greyscale_fire),LERP(160,heat_g,greyscale_fire),LERP(25,heat_b,greyscale_fire)))

	heat_r /= 255
	heat_g /= 255
	heat_b /= 255

	color = list(LERP(0.3, 1, 1-greyscale_fire) * heat_r,0.3 * heat_g * greyscale_fire,0.3 * heat_b * greyscale_fire, 0.59 * heat_r * greyscale_fire,LERP(0.59, 1, 1-greyscale_fire) * heat_g,0.59 * heat_b * greyscale_fire, 0.11 * heat_r * greyscale_fire,0.11 * heat_g * greyscale_fire,LERP(0.11, 1, 1-greyscale_fire) * heat_b, 0,0,0)
	alpha = heat_a

#define INSUFFICIENT(path) (!location.air.gases[path] || location.air.gases[path][MOLES] < 0.5)
/obj/effect/hotspot/process()
	if(just_spawned)
		just_spawned = FALSE
		return

	var/turf/open/location = loc
	if(!istype(location))
		qdel(src)
		return

	if(location.excited_group)
		location.excited_group.reset_cooldowns()

	if((temperature < FIRE_MINIMUM_TEMPERATURE_TO_EXIST) || (volume <= 1))
		qdel(src)
		return
	if(!location.air || (INSUFFICIENT(/datum/gas/plasma) && INSUFFICIENT(/datum/gas/tritium)) || INSUFFICIENT(/datum/gas/oxygen))
		qdel(src)
		return

	//Not enough to burn
	if(((!location.air.gases[/datum/gas/plasma] || location.air.gases[/datum/gas/plasma][MOLES] < 0.5) && (!location.air.gases[/datum/gas/tritium] || location.air.gases[/datum/gas/tritium][MOLES] < 0.5)) || location.air.gases[/datum/gas/oxygen][MOLES] < 0.5)
		qdel(src)
		return

	perform_exposure()

	if(bypassing)
		icon_state = "3"
		location.burn_tile()

		//Possible spread due to radiated heat
		if(location.air.temperature > FIRE_MINIMUM_TEMPERATURE_TO_SPREAD)
			var/radiated_temperature = location.air.temperature*FIRE_SPREAD_RADIOSITY_SCALE
			for(var/t in location.atmos_adjacent_turfs)
				var/turf/open/T = t
				if(T.active_hotspot)
					T.hotspot_expose(radiated_temperature, CELL_VOLUME/4)

	else
		if(volume > CELL_VOLUME*0.4)
			icon_state = "2"
		else
			icon_state = "1"

	if((visual_update_tick++ % 7) == 0)
		update_color()

	if(temperature > location.max_fire_temperature_sustained)
		location.max_fire_temperature_sustained = temperature

	if(location.heat_capacity && temperature > location.heat_capacity)
		location.to_be_destroyed = TRUE
	return TRUE

/obj/effect/hotspot/Destroy()
	set_light(0)
	SSair.hotspots -= src
	var/turf/open/T = loc
	if(istype(T) && T.active_hotspot == src)
		T.active_hotspot = null
	DestroyTurf()
	return ..()

/obj/effect/hotspot/proc/DestroyTurf()
	if(isturf(loc))
		var/turf/T = loc
		if(T.to_be_destroyed)
			var/chance_of_deletion
			if (T.heat_capacity) //beware of division by zero
				chance_of_deletion = T.max_fire_temperature_sustained / T.heat_capacity * 8 //there is no problem with prob(23456), min() was redundant --rastaf0
			else
				chance_of_deletion = 100
			if(prob(chance_of_deletion))
				T.ScrapeAway()
			else
				T.to_be_destroyed = FALSE
				T.max_fire_temperature_sustained = 0

/obj/effect/hotspot/Crossed(atom/movable/AM, oldLoc)
	..()
	if(isliving(AM))
		var/mob/living/L = AM
		L.fire_act(temperature, volume)

/obj/effect/hotspot/singularity_pull()
	return

/obj/effect/dummy/fire
	name = "fire"
	desc = "OWWWWWW. IT BURNS. Tell a coder if you're seeing this."
	icon_state = "nothing"
	light_color = LIGHT_COLOR_FIRE
	light_range = LIGHT_RANGE_FIRE

/obj/effect/dummy/fire/Initialize()
	. = ..()
	if(!isliving(loc))
		return INITIALIZE_HINT_QDEL
#undef INSUFFICIENT