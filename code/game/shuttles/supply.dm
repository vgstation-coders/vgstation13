var/global/datum/shuttle/cargo/cargo_shuttle = new

/datum/shuttle/cargo
	var/area/area_station
	var/area/area_centcomm

/datum/shuttle/cargo/New()
	.=..()
	setup_everything(starting_area = /area/supply/dock, \
		all_areas=list(/area/supply/dock,
			/area/supply/station), \
		name = "cargo shuttle", cooldown = 0, delay = 0)

/datum/shuttle/cargo/has_defined_areas()
	return 1

/datum/shuttle/cargo/initialize()
	if(!areas || !areas.len)
		return

	area_centcomm = locate(/area/shuttle/supply/centcom) in areas
	area_station = locate(/area/shuttle/supply/station) in areas

//Most of the code regarding this baby is in code\game\supplyshuttle.dm