/datum/component/wet_floor
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	var/highest_strength = TURF_DRY
	var/lube_flags = NONE			//why do we have this?
	var/list/time_left_list			//In deciseconds.
	var/static/mutable_appearance/permafrost_overlay = mutable_appearance('icons/effects/water.dmi', "ice_floor")
	var/static/mutable_appearance/ice_overlay = mutable_appearance('icons/turf/overlays.dmi', "snowfloor")
	var/static/mutable_appearance/water_overlay = mutable_appearance('icons/effects/water.dmi', "wet_floor_static")
	var/static/mutable_appearance/generic_turf_overlay = mutable_appearance('icons/effects/water.dmi', "wet_static")
	var/current_overlay
	var/permanent = FALSE
	var/last_process = 0

/datum/component/wet_floor/InheritComponent(datum/newcomp, orig, argslist)
	if(!newcomp)	//We are getting passed the arguments of a would-be new component, but not a new component
		add_wet(arglist(argslist))
	else			//We are being passed in a full blown component
		var/datum/component/wet_floor/WF = newcomp			//Lets make an assumption
		if(WF.gc())						//See if it's even valid, still. Also does LAZYLEN and stuff for us.
			CRASH("Wet floor component tried to inherit another, but the other was able to garbage collect while being inherited! What a waste of time!")
			return
		for(var/i in WF.time_left_list)
			add_wet(text2num(i), WF.time_left_list[i])

/datum/component/wet_floor/Initialize(strength, duration_minimum, duration_add, duration_maximum, _permanent = FALSE)
	if(!isopenturf(parent))
		. = COMPONENT_INCOMPATIBLE
		CRASH("Wet floor component attempted to be applied to a non open turf!")
	add_wet(strength, duration_minimum, duration_add, duration_maximum)
	RegisterSignal(COMSIG_TURF_IS_WET, .proc/is_wet)
	RegisterSignal(COMSIG_TURF_MAKE_DRY, .proc/dry)
	permanent = _permanent
	if(!permanent)
		START_PROCESSING(SSwet_floors, src)
	addtimer(CALLBACK(src, .proc/gc, TRUE), 1)		//GC after initialization.
	last_process = world.time

/datum/component/wet_floor/Destroy()
	STOP_PROCESSING(SSwet_floors, src)
	var/turf/T = parent
	qdel(T.GetComponent(/datum/component/slippery))
	if(istype(T))		//If this is false there is so many things wrong with it.
		T.cut_overlay(current_overlay)
	else
		stack_trace("Warning: Wet floor component wasn't on a turf when being destroyed! This is really bad!")
	return ..()

/datum/component/wet_floor/proc/update_overlay()
	var/intended
	if(!istype(parent, /turf/open/floor))
		intended = generic_turf_overlay
	else
		switch(highest_strength)
			if(TURF_WET_PERMAFROST)
				intended = permafrost_overlay
			if(TURF_WET_ICE)
				intended = ice_overlay
			else
				intended = water_overlay
	if(current_overlay != intended)
		var/turf/T = parent
		T.cut_overlay(current_overlay)
		T.add_overlay(intended)
		current_overlay = intended

/datum/component/wet_floor/proc/AfterSlip(mob/living/L)
	if(highest_strength == TURF_WET_LUBE)
		L.confused = max(L.confused, 8)

/datum/component/wet_floor/proc/update_flags()
	var/intensity
	lube_flags = NONE
	switch(highest_strength)
		if(TURF_WET_WATER)
			intensity = 60
			lube_flags = NO_SLIP_WHEN_WALKING
		if(TURF_WET_LUBE)
			intensity = 80
			lube_flags = SLIDE | GALOSHES_DONT_HELP
		if(TURF_WET_ICE)
			intensity = 120
			lube_flags = SLIDE | GALOSHES_DONT_HELP
		if(TURF_WET_PERMAFROST)
			intensity = 120
			lube_flags = SLIDE_ICE | GALOSHES_DONT_HELP
		else
			qdel(parent.GetComponent(/datum/component/slippery))
			return

	var/datum/component/slippery/S = parent.LoadComponent(/datum/component/slippery, NONE, CALLBACK(src, .proc/AfterSlip))
	S.intensity = intensity
	S.lube_flags = lube_flags

/datum/component/wet_floor/proc/dry(strength = TURF_WET_WATER, immediate = FALSE, duration_decrease = INFINITY)
	for(var/i in time_left_list)
		if(text2num(i) <= strength)
			time_left_list[i] = max(0, time_left_list[i] - duration_decrease)
	if(immediate)
		check()

/datum/component/wet_floor/proc/max_time_left()
	. = 0
	for(var/i in time_left_list)
		. = max(., time_left_list[i])

/datum/component/wet_floor/process()
	var/turf/open/T = parent
	var/diff = world.time - last_process
	var/decrease = 0
	var/t = T.GetTemperature()
	switch(t)
		if(-INFINITY to T0C)
			add_wet(TURF_WET_ICE, max_time_left())			//Water freezes into ice!
		if(T0C to T0C + 100)
			decrease = ((T.air.temperature - T0C) / SSwet_floors.temperature_coeff) * (diff / SSwet_floors.time_ratio)
		if(T0C + 100 to INFINITY)
			decrease = INFINITY
	decrease = max(0, decrease)
	if((is_wet() & TURF_WET_ICE) && t > T0C)		//Ice melts into water!
		for(var/obj/O in T.contents)
			if(O.flags_2 & FROZEN_2)
				O.make_unfrozen()
		add_wet(TURF_WET_WATER, max_time_left())
		dry(TURF_WET_ICE)
	dry(ALL, FALSE, decrease)
	check()
	last_process = world.time

/datum/component/wet_floor/proc/update_strength()
	highest_strength = 0			//Not bitflag.
	for(var/i in time_left_list)
		highest_strength = max(highest_strength, text2num(i))

/datum/component/wet_floor/proc/is_wet()
	. = 0
	for(var/i in time_left_list)
		. |= text2num(i)

/datum/component/wet_floor/OnTransfer(datum/to_datum)
	if(!isopenturf(to_datum))
		. = COMPONENT_INCOMPATIBLE
		CRASH("Wet floor component attempted to be transferred to a non open turf!")
	var/turf/O = parent
	O.cut_overlay(current_overlay)
	var/turf/T = to_datum
	T.add_overlay(current_overlay)

/datum/component/wet_floor/proc/add_wet(type, duration_minimum = 0, duration_add = 0, duration_maximum = MAXIMUM_WET_TIME, _permanent = FALSE)
	var/static/list/allowed_types = list(TURF_WET_WATER, TURF_WET_LUBE, TURF_WET_ICE, TURF_WET_PERMAFROST)
	if(duration_minimum <= 0 || !type)
		return FALSE
	if(type in allowed_types)
		return _do_add_wet(type, duration_minimum, duration_add, duration_maximum)
	else
		. = NONE
		for(var/i in allowed_types)
			if(!(type & i))
				continue
			. |= _do_add_wet(i, duration_minimum, duration_add, duration_maximum)
	if(_permanent)
		permanent = TRUE
		STOP_PROCESSING(SSwet_floors, src)

/datum/component/wet_floor/proc/_do_add_wet(type, duration_minimum, duration_add, duration_maximum)
	var/time = 0
	if(LAZYACCESS(time_left_list, "[type]"))
		time = CLAMP(LAZYACCESS(time_left_list, "[type]") + duration_add, duration_minimum, duration_maximum)
	else
		time = min(duration_minimum, duration_maximum)
	LAZYSET(time_left_list, "[type]", time)
	check(TRUE)
	return TRUE

/datum/component/wet_floor/proc/gc(on_init = FALSE)
	if(!LAZYLEN(time_left_list))
		if(on_init)
			var/turf/T = parent
			stack_trace("Warning: Wet floor component gc'd right initializatoin! What a waste of time and CPU! Type = [T? T.type : "ERROR - NO PARENT"], Coords = [istype(T)? COORD(T) : "ERROR - INVALID PARENT"].")
		qdel(src)
		return TRUE
	return FALSE

/datum/component/wet_floor/proc/check(force_update = FALSE)
	var/changed = FALSE
	for(var/i in time_left_list)
		if(time_left_list[i] <= 0)
			time_left_list -= i
			changed = TRUE
	if(changed || force_update)
		update_strength()
		update_overlay()
		update_flags()
		gc()
