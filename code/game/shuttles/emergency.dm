var/global/datum/shuttle/emergency/escape_shuttle = new

/datum/shuttle/emergency
	var/area/area_centcomm
	var/area/area_station

	cant_leave_zlevel = list()

/datum/shuttle/emergency/New()
	.=..()
	setup_everything(starting_area = /area/shuttle/escape/centcom, \
		all_areas=list(/area/shuttle/escape/centcom,
			/area/shuttle/escape/station), \
		name = "emergency shuttle", transit_area = /area/shuttle/escape/transit)

/datum/shuttle/emergency/has_defined_areas()
	return 1

/datum/shuttle/emergency/initialize()
	if(!areas || !areas.len)
		return

	area_centcomm = locate(/area/shuttle/escape/centcom) in areas
	area_station = locate(/area/shuttle/escape/station) in areas
