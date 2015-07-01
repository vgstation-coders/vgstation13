#define SPECOPS_MOVE_TIME 600	//Time to station is milliseconds. 60 seconds, enough time for everyone to be on the shuttle before it leaves.
#define SPECOPS_COOLDOWN 6000 //Time between the shuttle is capable of moving.

var/global/datum/shuttle/specops/specops_shuttle = new

/datum/shuttle/specops
	var/area/area_centcomm
	var/area/area_station

	cant_leave_zlevel = list()

/datum/shuttle/specops/New()
	.=..()
	setup_everything(starting_area = /area/shuttle/specops/centcom, \
		all_areas=list(/area/shuttle/specops/centcom,
			/area/shuttle/specops/station), \
		name = "elite syndicate squad shuttle", cooldown = SPECOPS_COOLDOWN, delay = SPECOPS_MOVE_TIME)

/datum/shuttle/specops/has_defined_areas()
	return 1

/datum/shuttle/specops/initialize()
	area_centcomm = locate(/area/shuttle/specops/centcom) in areas
	area_station = locate(/area/shuttle/specops/station) in areas

#undef SPECOPS_MOVE_TIME
#undef SPECOPS_COOLDOWN