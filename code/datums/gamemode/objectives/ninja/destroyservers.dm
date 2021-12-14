/datum/objective/servers
	name = "\[Ninja\] Destroy Servers"
	explanation_text = "Assert our dominance of artificial intelligence. Steal a functional AI or kill all AIs on the station."

/datum/objective/servers/IsFulfilled()
	if (..())
		return TRUE
	for(var/obj/machinery/r_n_d/server/S in machines)
		var/turf/T = get_turf(S)
		if(T.z == STATION_Z)
			return FALSE
	return TRUE