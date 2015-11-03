/obj/machinery/tinkers_daemon
	name = "Tinker's Daemon"

	// icon = ''
	// icon_state = ""

	var/target_component
	var/next_component = CLOCKDAEMON_TICKS_UNTARGETED

/obj/machinery/tinkers_daemon/New()
	. = ..()

	global.clockcult_TC++
	processing_objects += src

/obj/machinery/tinkers_daemon/Destroy()
	. = ..()

	global.clockcult_TC--
	processing_objects -= src

/obj/machinery/tinkers_daemon/process()
	if(--next_component > 0)
		return // Nothing happening.

	var/component
	if(target_component)
		component = target_component
	else
		component = pick(global.CLOCK_COMP_IDS)

	var/inserted = FALSE
	for(var/obj/machinery/tinkers_cache/C in tinkcaches)
		if(C.add_component(component))
			inserted = TRUE
			break

	if(!inserted) // We couldn't put it in any cache, drop it on the floor.
		var/obj/item/clock_component/C = getFromPool(get_clockcult_comp_by_id(component, no_alpha = TRUE), get_turf(src))
		animate(C, alpha = initial(C.alpha), 5) // Muh fade in.

	next_component = target_component ? CLOCKDAEMON_TICKS_TARGETED : CLOCKDAEMON_TICKS_UNTARGETED