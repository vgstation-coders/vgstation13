/datum/objective/target/assassinate/orexile
	name = "Assassinate or exile <target>"

/datum/objective/target/assassinate/orexile/format_explanation()
	return "Assassinate or exile [target.current.real_name], the [target.assigned_role=="MODE" ? (target.special_role) : (target.assigned_role)]."

/datum/objective/target/assassinate/orexile/IsFulfilled()
	if(..())
		return TRUE //Covers dead, cyborgified, MMI'd, on away mission, no target, manual toggle
	var/turf/T = get_turf(target.current)
	if(!T)
		return TRUE
	if(T.z != STATION_Z)
		if(istype(T.loc, /area/shuttle/escape/centcom))
			return FALSE
		else if(istype(T.loc, /area/shuttle/escape_pod1/centcom) || istype(T.loc, /area/shuttle/escape_pod2/centcom) || istype(T.loc, /area/shuttle/escape_pod3/centcom) || istype(T.loc, /area/shuttle/escape_pod5/centcom))
			return FALSE
		else
			return TRUE
	return FALSE
