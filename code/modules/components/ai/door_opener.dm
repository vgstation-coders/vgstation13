/datum/component/ai/door_opener
	var/pressure_check=TRUE
	var/max_pressure_diff=-1

/datum/component/ai/door_opener/RecieveSignal(var/message_type, var/list/args)
	switch(message_type)
		if(COMSIG_ATTACKING) // list("target"=A)
			OnAttackingTarget(args["target"])
		else
			..(message_type, args)

/datum/component/ai/door_opener/proc/OnAttackingTarget(var/atom/target)
	if(istype(target,/obj/machinery/door))
		var/obj/machinery/door/D = target
		if(CanOpenDoor(D))
			if(get_dist(src, target) > 1)
				return // keep movin'.
			controller.setBusy(TRUE)
			SendSignal(COMSIG_MOVE, "dir"=0) // Stop movement?
			D.visible_message("<span class='warning'>\The [D]'s motors whine as four arachnid claws begin trying to force it open!</span>")
			spawn(50)
				if(CanOpenDoor(D) && prob(25))
					D.open(1)
					D.visible_message("<span class='warning'>\The [src] forces \the [D] open!</span>")

					// Open firedoors, too.
					for(var/obj/machinery/door/firedoor/FD in D.loc)
						if(FD && FD.density)
							FD.open(1)

					// Reset targetting
					controller.setBusy(FALSE)
					controller.setTarget(null)
			return
		controller.setBusy(FALSE)
		return

/datum/component/ai/door_opener/proc/performPressureCheck(var/turf/loc)
	var/turf/simulated/lT=loc
	if(!istype(lT) || !lT.zone)
		return 0
	var/datum/gas_mixture/myenv=lT.return_air()
	var/pressure=myenv.return_pressure()

	for(var/dir in cardinal)
		var/turf/simulated/T=get_turf(get_step(loc,dir))
		if(T && istype(T) && T.zone)
			var/datum/gas_mixture/environment = T.return_air()
			var/pdiff = abs(pressure - environment.return_pressure())
			if(pdiff > max_pressure_diff)
				return pdiff
	return 0

/datum/component/ai/door_opener/proc/CanOpenDoor(var/obj/machinery/door/D)
	if(istype(D,/obj/machinery/door/poddoor) || istype(D, /obj/machinery/door/airlock/multi_tile/glass))
		return 0

	// Don't fuck with doors that are doing something
	if(D.operating>0)
		return 0

	// Don't open opened doors.
	if(!D.density)
		return 0

	// Can't open bolted/welded doors
	if(istype(D,/obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/A=D
		if(A.locked || A.welded || A.jammed)
			return 0

	var/turf/T = get_turf(D)

	// Don't kill ourselves
	if(max_pressure_diff > -1 && !performPressureCheck(T))
		return 0

	return 1
