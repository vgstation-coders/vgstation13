#define PUDDLE_TRANSFER_THRESHOLD 0.05
#define MAX_PUDDLE_VOLUME 50
#define CIRCLE_PUDDLE_VOLUME 40 //39.26899 technically but this is close enough

var/list/obj/effect/overlay/puddle/puddles = list()
var/static/list/burnable_reagents = list(FUEL) //TODO: More types later

/turf
	var/obj/effect/overlay/puddle/current_puddle = null

/obj/effect/overlay/puddle
	icon = 'icons/effects/puddle.dmi'
	icon_state = "puddle0"
	name = "puddle"
	plane = ABOVE_TURF_PLANE
	layer = PUDDLE_LAYER
	anchored = TRUE
	mouse_opacity = FALSE
	var/turf/turf_on

/obj/effect/overlay/puddle/New()
	..()
	turf_on = get_turf(src)
	if(!turf_on)
		qdel(src)
		return

	if(turf_on.current_puddle)
		qdel(turf_on.current_puddle)
	turf_on.current_puddle = src
	processing_objects.Add(src)
	update_icon()

/obj/effect/overlay/puddle/process()
	if(!turf_on || (turf_on.reagents && turf_on.reagents.total_volume < PUDDLE_TRANSFER_THRESHOLD))
		qdel(src)
		return
	if(turf_on.reagents)
		for(var/datum/reagent/R in turf_on.reagents.reagent_list)
			if(R.evaporation_rate)
				turf_on.reagents.remove_reagent(R.id, R.evaporation_rate)
		if(config.puddle_spreading && turf_on.reagents.total_volume > MAX_PUDDLE_VOLUME)
			spread()

/obj/effect/overlay/puddle/proc/spread()
	var/excess_volume = turf_on.reagents.total_volume - MAX_PUDDLE_VOLUME
	var/list/spread_directions = cardinal.Copy()
	for(var/direction in spread_directions)
		var/turf/T = get_step(src,direction)
		if(!T)
			spread_directions.Remove(direction)
			log_debug("Puddle reached map edge.")
			continue
		if(!T.reagents && !T.clears_reagents)
			spread_directions.Remove(direction)
			continue
		if(!turf_on.can_leave_liquid(direction)) //Check if this liquid can leave the tile in the direction
			spread_directions.Remove(direction)
			continue
		if(!T.can_accept_liquid(turn(direction,180))) //Check if this liquid can enter the tile
			spread_directions.Remove(direction)
			continue

	if(!spread_directions.len)
		return

	var/average_volume = excess_volume / spread_directions.len //How much would be taken from our tile to fill each
	for(var/datum/reagent/R in turf_on.reagents.reagent_list)
		average_volume = min(R.viscosity, average_volume) //Capped by viscosity
	if(average_volume <= (spread_directions.len * PUDDLE_TRANSFER_THRESHOLD))
		return //If this is lower than the transfer threshold, break out

	for(var/direction in spread_directions)
		var/turf/T = get_step(src,direction)
		if(!T)
			log_debug("Puddle reached map edge.")
			continue
		if(T.clears_reagents)
			turf_on.reagents.remove_all(average_volume)
			return
		turf_on.reagents.trans_to(T, average_volume)
		T.reagents.reaction(T, volume_multiplier = 0) //Already transferred it here, don't go making it.
		if(T.current_puddle)
			T.current_puddle.update_icon()
	update_icon()

/obj/effect/overlay/puddle/getFireFuel() // Copied over from old fuel overlay system and adjusted
	var/total_fuel = 0
	if(turf_on && turf_on.reagents)
		for(var/id in burnable_reagents)
			total_fuel += turf_on.reagents.get_reagent_amount(id)
	return total_fuel

/obj/effect/overlay/puddle/burnFireFuel(var/used_fuel_ratio, var/used_reactants_ratio)
	if(turf_on && turf_on.reagents)
		for(var/id in burnable_reagents)
			// liquid fuel burns 5 times as quick
			turf_on.reagents.remove_reagent(id, turf_on.reagents.get_reagent_amount(id) * used_fuel_ratio * used_reactants_ratio * 5)

/obj/effect/overlay/puddle/Crossed(atom/movable/AM)
	if(turf_on.reagents && (isobj(AM) || ismob(AM))) // Only for reaction_obj and reaction_mob, no misc types.
		//turf_on.reagents.remove_all(turf_on.reagents.total_volume/10)
		if(isliving(AM))
			var/mob/living/L = AM
			if(turf_on.reagents.has_reagent(LUBE))
				L.ApplySlip(TURF_WET_LUBE)
			else if(turf_on.reagents.has_any_reagents(MILDSLIPPABLES))
				L.ApplySlip(TURF_WET_WATER)
		/*	var/list/zones_to_use = list(LIMB_HEAD,LIMB_CHEST,LIMB_GROIN) //TODO: Uncomment in separate PR.
			if(L.lying)
				// Right side of body if lying on right and vice versa, all of body except mouth on eyes if on back and all if on stomach
				if(L.dir == WEST || L.dir == NORTH || L.dir == SOUTH)
					zones_to_use += list(LIMB_RIGHT_ARM,LIMB_RIGHT_HAND,LIMB_RIGHT_LEG,LIMB_RIGHT_FOOT)
				if(L.dir == EAST || L.dir == NORTH || L.dir == SOUTH)
					zones_to_use += list(LIMB_LEFT_ARM,LIMB_LEFT_HAND,LIMB_LEFT_LEG,LIMB_LEFT_FOOT)
				if(L.dir == NORTH)
					zones_to_use += list(TARGET_MOUTH,TARGET_EYES)
			else
				//Only targeting feet if standing,
				zones_to_use = list(LIMB_LEFT_FOOT,LIMB_RIGHT_FOOT)
			turf_on.reagents.reaction(AM, volume_multiplier = 0.1, zone_sels = zones_to_use)
		else
			turf_on.reagents.reaction(AM, volume_multiplier = 0.1)*/

	else
		return ..()

// Overly gimmicky proc for if we want player controlled puddles for whatever reason
/obj/effect/overlay/puddle/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0, glide_size_override = 0)
	if(turf_on && turf_on.reagents)
		var/lowest_viscosity = turf_on.reagents.total_volume
		for(var/datum/reagent/R in turf_on.reagents.reagent_list)
			lowest_viscosity = min(R.viscosity, lowest_viscosity) //Capped by viscosity
		turf_on.reagents.trans_to(NewLoc, lowest_viscosity)
		if(isturf(NewLoc))
			var/turf/T = NewLoc
			if(T.reagents && T.reagents.total_volume >= MAX_PUDDLE_VOLUME)
				qdel(T.current_puddle)
				T.current_puddle = src
				turf_on = NewLoc
				return ..()

/obj/effect/overlay/puddle/Destroy()
	if(turf_on && turf_on.reagents)
		turf_on.reagents.clear_reagents()
	processing_objects.Remove(src)
	turf_on.current_puddle = null
	..()

/obj/effect/overlay/puddle/update_icon()
	if(turf_on && turf_on.reagents && turf_on.reagents.reagent_list.len)
		color = mix_color_from_reagents(turf_on.reagents.reagent_list,TRUE)
		alpha = mix_alpha_from_reagents(turf_on.reagents.reagent_list,TRUE)
		// Absolute scaling with volume, Scale() would give relative.
		transform = matrix(min(1, turf_on.reagents.total_volume / CIRCLE_PUDDLE_VOLUME), 0, 0, 0, min(1, turf_on.reagents.total_volume / CIRCLE_PUDDLE_VOLUME), 0)
	else // Sanity
		qdel(src)

	relativewall()

/obj/effect/overlay/puddle/relativewall()
	// Circle value as to have some breathing room
	if(turf_on && turf_on.reagents && turf_on.reagents.total_volume >= CIRCLE_PUDDLE_VOLUME)
		var/junction=findSmoothingNeighbors()
		icon_state = "puddle[junction]"
	else
		icon_state = "puddle0"

/obj/effect/overlay/puddle/canSmoothWith()
	var/static/list/smoothables = list(
		/obj/effect/overlay/puddle,
	)
	return smoothables

/obj/effect/overlay/puddle/isSmoothableNeighbor(var/obj/effect/overlay/puddle/A)
	if(istype(A) && A.turf_on && A.turf_on.reagents && A.turf_on.reagents.total_volume < CIRCLE_PUDDLE_VOLUME)
		return

	return ..()

/turf/proc/can_accept_liquid(from_direction)
	return 0
/turf/proc/can_leave_liquid(from_direction)
	return 0

/turf/space/can_accept_liquid(from_direction)
	return 1
/turf/space/can_leave_liquid(from_direction)
	return 1

/turf/simulated/floor/can_accept_liquid(from_direction)
	for(var/obj/structure/window/W in src)
		if(W.is_fulltile)
			return 0
		if(W.dir & from_direction)
			return 0
	for(var/obj/O in src)
		if(!O.liquid_pass())
			return 0
	return 1

/turf/simulated/floor/can_leave_liquid(to_direction)
	for(var/obj/structure/window/W in src)
		if(W.is_fulltile)
			return 0
		if(W.dir & to_direction)
			return 0
	for(var/obj/O in src)
		if(!O.liquid_pass())
			return 0
	return 1

/turf/simulated/wall/can_accept_liquid(from_direction)
	return 0
/turf/simulated/wall/can_leave_liquid(from_direction)
	return 0

/obj/proc/liquid_pass()
	return 1

/obj/machinery/door/liquid_pass()
	return !density

/obj/effect/overlay/puddle/mapping
	var/reagent_type = ""
	var/volume = 50

/obj/effect/overlay/puddle/mapping/initialize()
	if(turf_on && turf_on.reagents)
		turf_on.reagents.add_reagent(reagent_type,volume)

/obj/effect/overlay/puddle/mapping/water
	reagent_type = WATER

/obj/effect/overlay/puddle/mapping/fuel
	reagent_type = FUEL
