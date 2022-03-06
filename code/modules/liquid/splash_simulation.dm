#define LIQUID_TRANSFER_THRESHOLD 0.05

var/liquid_delay = 4

var/list/datum/puddle/puddles = list()

/datum/puddle
	var/list/obj/effect/decal/cleanable/puddle/puddle_objects = list()

/datum/puddle/proc/process()
//	to_chat(world, "DEBUG: Puddle process!")
	for(var/obj/effect/decal/cleanable/puddle/L in puddle_objects)
		L.spread()

	for(var/obj/effect/decal/cleanable/puddle/L in puddle_objects)
		L.apply_calculated_effect()

	if(puddle_objects.len == 0)
		qdel(src)

/datum/puddle/New()
	..()
	puddles += src

/datum/puddle/Del()
	puddles -= src
	for(var/obj/O in puddle_objects)
		qdel(O)
		O = null
	..()

/client/proc/splash()
	set category = "Debug"

	var/volume = input("Volume?","Volume?", 0 ) as num
	if(!isnum(volume))
		return
	if(volume <= LIQUID_TRANSFER_THRESHOLD)
		return
	var/turf/T = get_turf(src.mob)
	if(!isturf(T))
		return
	var/reagent = input("Reagent ID?","Reagent ID?", WATER) as num
	if(!reagent)
		return
	trigger_splash(T, reagent, volume)

/proc/trigger_splash(turf/epicenter as turf, reagent_id as text, volume as num)
	if(!epicenter || volume <= 0 || !reagent_id)
		return

	var/obj/effect/decal/cleanable/puddle/L = new/obj/effect/decal/cleanable/puddle(epicenter)
	epicenter.reagents.add_reagent(reagent_id, volume)
	L.update_icon()
	var/datum/puddle/P = new/datum/puddle()
	P.puddle_objects.Add(L)
	L.controller = P




/obj/effect/decal/cleanable/puddle
	icon = 'icons/effects/puddle.dmi'
	icon_state = "puddle0"
	name = "puddle"
	var/datum/puddle/controller

/obj/effect/decal/cleanable/puddle/New()
	..()
	if( !isturf(loc) )
		qdel(src)
		return

	for( var/obj/effect/decal/cleanable/puddle/L in loc )
		if(L != src)
			qdel(L)
			L = null

	update_icon()

/obj/effect/decal/cleanable/puddle/proc/spread()


//	to_chat(world, "DEBUG: liquid spread!")
	var/surrounding_volume = 0
	var/list/spread_directions = cardinal
	var/turf/loc_turf = loc
	var/turf/center = get_turf(src)
	if(!center)
		return
	for(var/direction in spread_directions)
		var/turf/T = get_step(src,direction)
		if(!T)
			spread_directions.Remove(direction)
//			to_chat(world, "ERROR: Map edge!")
			continue //Map edge
		if(!loc_turf.can_leave_liquid(direction)) //Check if this liquid can leave the tile in the direction
			spread_directions.Remove(direction)
			continue
		if(!T.can_accept_liquid(turn(direction,180))) //Check if this liquid can enter the tile
			spread_directions.Remove(direction)
			continue
		var/obj/effect/decal/cleanable/puddle/L = locate(/obj/effect/decal/cleanable/puddle) in T
		if(L)
			if(T.reagents.total_volume >= center.reagents.total_volume)
				spread_directions.Remove(direction)
				continue
			surrounding_volume += T.reagents.total_volume //If liquid already exists, add it's volume to our sum
		else
			var/obj/effect/decal/cleanable/puddle/NL = new(T) //Otherwise create a new object which we'll spread to.
			NL.controller = src.controller
			controller.puddle_objects.Add(NL)

	if(!spread_directions.len)
//		to_chat(world, "ERROR: No candidate to spread to.")
		return //No suitable candidate to spread to

	var/average_volume = (center.reagents.total_volume + surrounding_volume) / (spread_directions.len + 1) //Average amount of volume on this and the surrounding tiles.
	var/volume_difference = center.reagents.total_volume - average_volume //How much more/less volume this tile has than the surrounding tiles.
	if(volume_difference <= (spread_directions.len*LIQUID_TRANSFER_THRESHOLD)) //If we have less than the threshold excess liquid - then there is nothing to do as other tiles will be giving us volume.or the liquid is just still.
//		to_chat(world, "ERROR: transfer volume lower than THRESHOLD!")
		return

	var/volume_per_tile = volume_difference / spread_directions.len

	for(var/direction in spread_directions)
		var/turf/T = get_step(src,direction)
		if(!T)
//			to_chat(world, "ERROR: Map edge 2!")
			continue //Map edge
		if(!(locate(/obj/effect/decal/cleanable/puddle) in T))
			new /obj/effect/decal/cleanable/puddle(T)
		center.reagents.trans_to(T,volume_per_tile)
		update_icon()

/obj/effect/decal/cleanable/puddle/proc/apply_calculated_effect()
	var/turf/T = get_turf(src)
	if(!T)
		return

	if(T.reagents && T.reagents.total_volume < LIQUID_TRANSFER_THRESHOLD)
		qdel(src)
		return

/obj/effect/decal/cleanable/puddle/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0, glide_size_override = 0)
	return 0

/obj/effect/decal/cleanable/puddle/Destroy()
	src.controller.puddle_objects.Remove(src)
	var/turf/T = get_turf(src)
	if(T && T.reagents)
		T.reagents.clear_reagents()
	..()

/obj/effect/decal/cleanable/puddle/update_icon()
	//icon_state = num2text( max(1,min(7,(floor(volume),10)/10)) )

	/*switch(volume)
		if(0 to 0.1)
			qdel(src)
		if(0.1 to 5)
			icon_state = "1"
		if(5 to 10)
			icon_state = "2"
		if(10 to 20)
			icon_state = "3"
		if(20 to 30)
			icon_state = "4"
		if(30 to 40)
			icon_state = "5"
		if(40 to 50)
			icon_state = "6"
		if(50 to INFINITY)
			icon_state = "7"*/

/obj/effect/decal/cleanable/puddle/relativewall()
	var/turf/T = get_turf(src)
	if(T && T.reagents && T.reagents.total_volume >= 50)
		var/junction=findSmoothingNeighbors()
		icon_state = "puddle[junction]"
	else
		icon_state = "puddle0"

/obj/effect/decal/cleanable/puddle/canSmoothWith()
	var/static/list/smoothables = list(
		/obj/effect/decal/cleanable/puddle,
	)
	return smoothables

/obj/effect/decal/cleanable/puddle/isSmoothableNeighbor(atom/A)
	var/turf/T = get_turf(A)
	if(T && T.reagents && T.reagents.total_volume < 50)
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

#undef LIQUID_TRANSFER_THRESHOLD
