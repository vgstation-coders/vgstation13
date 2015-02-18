
/datum/chemical_reaction/thermite
	name = "Thermite"
	id = "thermite"
	required_reagents = list("aluminum" = 1, "iron" = 1, "oxygen" = 1)
	results = list("thermite" = 3)

/datum/chemical_reaction/napalm
	name = "Napalm"
	id = "napalm"
	results = null
	required_reagents = list("aluminum" = 1, "plasma" = 1, "sacid" = 1 )
	reaction_description = "Ignites immediately."

/datum/chemical_reaction/napalm/on_reaction(var/datum/reagents/holder, var/created_volume)
	var/turf/location = get_turf(holder.my_atom.loc)
	for(var/turf/simulated/floor/target_tile in range(0,location))

		var/datum/gas_mixture/napalm = new
		var/datum/gas/volatile_fuel/fuel = new
		fuel.moles = created_volume
		napalm.trace_gases += fuel

		napalm.temperature = 400+T0C
		napalm.update_values()

		target_tile.assume_air(napalm)
		spawn (0) target_tile.hotspot_expose(700, 400,surfaces=1)
	holder.del_reagent("napalm")
	return