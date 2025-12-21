//See maps/ruins for dmm's and definitions

/area/ruin
	name = "ruin"
	icon = 'icons/turf/areas.dmi'
	icon_state = "ruin"
	base_turf_type = /turf/unsimulated/floor/planetary/grass

/area/exposed_ruin //allows daylight and weather
	name = "exposed ruin"
	icon_state = "ruin_exposed"

/datum/map_element/ruin
	var/ruin_type = RUIN_TYPE_GENERIC
	var/cost = RUIN_COST_MEDIUM

/datum/map_element/ruin/initialize(list/objects)
	..(objects)
	existing_vaults.Add(src)

	for(var/turf/new_turf in objects)
		new_turf.turf_flags |= NO_MINIMAP

/proc/get_ruin_list(var/whitelist = 0, var/blacklist = 0)
	var/list/ruin_list = list()
	var/list/added_types = list()
	if(!whitelist && !blacklist)
		ruin_list = subtypesof(/datum/map_element/ruin)
		for(var/R in ruin_list)
			ruin_list.Add(new R)
			ruin_list.Remove(R)
	else if(whitelist)
		for(var/type_flag in SSmapping.ruins_by_type)
			var/numeric_flag = text2num(type_flag)
			if(whitelist & numeric_flag)
				var/list/types = SSmapping.ruins_by_type[type_flag]
				for(var/R_type in types)
					if(!(R_type in added_types))
						added_types += R_type
						ruin_list.Add(new R_type)
		if(blacklist)
			for(var/datum/map_element/ruin/R in ruin_list)
				var/skip = FALSE
				for(var/type_flag in SSmapping.ruins_by_type)
					var/numeric_flag = text2num(type_flag)
					if(blacklist & numeric_flag)
						var/list/types = SSmapping.ruins_by_type[type_flag]
						if(types.Find(R.type))
							skip = TRUE
							break
				if(skip)
					ruin_list.Remove(R)
	else if(blacklist)
		ruin_list = subtypesof(/datum/map_element/ruin)
		for(var/R in ruin_list)
			var/skip = FALSE
			for(var/type_flag in SSmapping.ruins_by_type)
				var/numeric_flag = text2num(type_flag)
				if(blacklist & numeric_flag)
					var/list/types = SSmapping.ruins_by_type[type_flag]
					if(types.Find(R))
						skip = TRUE
						break
			if(!skip)
				ruin_list.Add(new R)
			ruin_list.Remove(R)
	return ruin_list

/proc/weighted_ruin_list(var/list/ruins,var/type_flag,var/factor = 3)
	var/list/weighted_list = list()
	for(var/datum/map_element/ruin/R in ruins)
		var/list/filtered_ruin_list = SSmapping.ruins_by_type["[type_flag]"]
		if(filtered_ruin_list.Find(R.type))
			for(var/i = 0; i < factor; i++)
				weighted_list.Add(R)
		else
			weighted_list.Add(R)
	return weighted_list
