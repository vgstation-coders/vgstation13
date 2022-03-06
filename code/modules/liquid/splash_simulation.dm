#define PUDDLE_TRANSFER_THRESHOLD 0.05
#define MAX_PUDDLE_VOLUME 50

var/liquid_delay = 4

var/list/datum/puddle/puddles = list()

/datum/puddle
	var/list/obj/effect/overlay/puddle/puddle_objects = list()

/datum/puddle/New(var/obj/effect/overlay/puddle/P)
	..()
	puddles += src
	if(P)
		puddle_objects.Add(P)

/datum/puddle/Del()
	puddles -= src
	for(var/obj/O in puddle_objects)
		qdel(O)
		O = null
	..()



/obj/effect/overlay/puddle
	icon = 'icons/effects/puddle.dmi'
	icon_state = "puddle0"
	name = "puddle"
	var/datum/puddle/controller
	var/turf/turf_on

/obj/effect/overlay/puddle/New()
	..()
	turf_on = get_turf(src)
	if(!turf_on)
		qdel(src)
		return

	for( var/obj/effect/overlay/puddle/L in loc )
		if(L != src)
			qdel(L)
			L = null

	controller = new/datum/puddle(src)
	processing_objects.Add(src)
	update_icon()

/obj/effect/overlay/puddle/process()
	turf_on = get_turf(src)
	if(!turf_on || (turf_on.reagents && turf_on.reagents.total_volume < PUDDLE_TRANSFER_THRESHOLD))
		qdel(src)
		return
	if(turf_on.reagents)
		for(var/datum/reagent/R in turf_on.reagents.reagent_list)
			turf_on.reagents.remove_reagent(R.id, R.evaporation_rate)
		if(turf_on.reagents.total_volume > MAX_PUDDLE_VOLUME)
			spread()

/obj/effect/overlay/puddle/proc/spread()
	var/excess_volume = turf_on.reagents.total_volume - MAX_PUDDLE_VOLUME
	var/list/spread_directions = cardinal
	for(var/direction in spread_directions)
		var/turf/T = get_step(src,direction)
		if(!T)
			spread_directions.Remove(direction)
			log_debug("Puddle reached map edge.")
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

		turf_on.reagents.trans_to(T, average_volume)
		T.reagents.reaction(T, none_splashed = TRUE) //Already transferred it here, don't go making it.
		var/obj/effect/overlay/puddle/L = locate(/obj/effect/overlay/puddle) in T
		if(L)
			L.update_icon()
			if(L.controller != src.controller)
				L.controller.puddle_objects.Remove(L)
				if(L.controller.puddle_objects.len <= 0)
					qdel(L.controller)
				L.controller = src.controller
	update_icon()

/obj/effect/overlay/puddle/getFireFuel() // Copied over from old fuel overlay system and adjusted
	if(on_turf && on_turf.reagents)
		return on_turf.reagents.get_reagent_amount(FUEL) + on_turf.reagents.get_reagent_amount(PLASMA)

/obj/effect/overlay/puddle/burnFireFuel(var/used_fuel_ratio, var/used_reactants_ratio)
	if(on_turf && on_turf.reagents)
		on_turf.reagents.remove_reagents(list(PLASMA,FUEL), used_fuel_ratio * used_reactants_ratio * 5) // liquid fuel burns 5 times as quick

/obj/effect/overlay/puddle/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0, glide_size_override = 0)
	return 0

/obj/effect/overlay/puddle/Destroy()
	src.controller.puddle_objects.Remove(src)
	if(turf_on && turf_on.reagents)
		turf_on.reagents.clear_reagents()
	processing_objects.Remove(src)
	..()

/obj/effect/overlay/puddle/update_icon()
	if(turf_on && turf_on.reagents)
		color = mix_color_from_reagents(turf_on.reagents.reagent_list)
		alpha = mix_alpha_from_reagents(turf_on.reagents.reagent_list)
		// Absolute scaling with volume, Scale() would give relative.
		transform = matrix(min(1, turf_on.reagents.total_volume / MAX_PUDDLE_VOLUME),0,0,0,min(1, turf_on.reagents.total_volume / MAX_PUDDLE_VOLUME),0)

	relativewall()
	relativewall_neighbours()

/obj/effect/overlay/puddle/relativewall()
	if(turf_on && turf_on.reagents && turf_on.reagents.total_volume >= MAX_PUDDLE_VOLUME)
		var/junction=findSmoothingNeighbors()
		icon_state = "puddle[junction]"
	else
		icon_state = "puddle0"

/obj/effect/overlay/puddle/canSmoothWith()
	var/static/list/smoothables = list(
		/obj/effect/overlay/puddle,
	)
	return smoothables

/obj/effect/overlay/puddle/isSmoothableNeighbor(atom/A)
	var/turf/T = get_turf(A)
	if(T && T.reagents && T.reagents.total_volume < MAX_PUDDLE_VOLUME)
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
	var/datum/reagent/R = chemical_reagents_list[reagent_type]
	if(R)
		R.reaction_turf(get_turf(src), volume)

/obj/effect/overlay/puddle/mapping/water
	reagent_type = WATER

/obj/effect/overlay/puddle/mapping/fuel
	reagent_type = FUEL
