
/proc/power_failure(var/announce = 1)
	suspend_alert = 1
	if(announce)
		command_alert("Abnormal activity detected in [station_name()]'s powernet. As a precautionary measure, the station's power will be shut off for an indeterminate duration.", "Critical Power Failure",alert ='sound/AI/poweroff.ogg')
	for(var/obj/machinery/power/battery/smes/S in power_machines)
		if(istype(get_area(S), /area/turret_protected) || S.z != 1)
			continue
		S.charge = 0
		S.output = 0
		S.online = 0
		S.update_icon()
		S.power_change()

	var/list/skipped_areas = list(/area/engineering/engine, /area/turret_protected/ai)

	for(var/area/A in areas)
		if( !A.requires_power || A.always_unpowered )
			continue

		var/skip = 0
		for(var/area_type in skipped_areas)
			if(istype(A,area_type))
				skip = 1
				break
		if(A.contents)
			for(var/atom/AT in A.contents)
				if(AT.z != 1) //Only check one, it's enough.
					skip = 1
				break
		if(skip) continue
		A.power_light = 0
		A.power_equip = 0
		A.power_environ = 0

	for(var/obj/machinery/power/apc/C in power_machines)
		if(C.cell && C.z == 1)
			var/area/A = get_area(C)
			var/skip = 0
			for(var/area_type in skipped_areas)
				if(istype(A,area_type))
					skip = 1
					break
			if(skip) continue
			C.chargemode = 0
			C.cell.charge = 0

/proc/power_restore(var/announce = 1)


	if(announce)
		command_alert("Power has been restored to [station_name()]. We apologize for the inconvenience.", "Power Systems Nominal",alert='sound/AI/poweron.ogg')
	for(var/obj/machinery/power/apc/C in power_machines)
		if(C.cell && C.z == 1)
			C.cell.charge = C.cell.maxcharge
			C.chargemode = 1
	for(var/obj/machinery/power/battery/smes/S in power_machines)
		if(S.z != 1)
			continue
		S.charge = S.capacity
		S.output = 200000
		S.online = 1
		S.update_icon()
		S.power_change()
	for(var/area/A in areas)
		if(A.name != "Space" && A.name != "Engine Walls" && A.name != "Chemical Lab Test Chamber" && A.name != "space" && A.name != "Escape Shuttle" && A.name != "Arrival Area" && A.name != "Arrival Shuttle" && A.name != "start area" && A.name != "Engine Combustion Chamber")
			A.power_light = 1
			A.power_equip = 1
			A.power_environ = 1
	suspend_alert = 0

/proc/power_restore_quick(var/announce = 1)
	if(announce)
		command_alert("All SMESs on [station_name()] have been recharged. We apologize for the inconvenience.", "Power Systems Nominal",alert='sound/AI/poweron.ogg')
	for(var/obj/machinery/power/battery/smes/S in power_machines)
		if(S.z != 1)
			continue
		S.charge = S.capacity
		S.output = 200000
		S.online = 1
		S.update_icon()
		S.power_change()
	suspend_alert = 0
