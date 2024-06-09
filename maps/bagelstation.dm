#ifndef MAP_OVERRIDE
//**************************************************************
// Map Datum -- Bagel
//**************************************************************

/datum/map/active
	nameShort = "bagel"
	nameLong = "Bagelstation"
	map_dir = "bagelstation"
	zLevels = list(
		/datum/zLevel/station,
		/datum/zLevel/centcomm,
		/datum/zLevel/space{
			name = "spaceOldSat" ;
			},
		/datum/zLevel/space{
			name = "derelict" ;
			},
		/datum/zLevel/mining,
		/datum/zLevel/space{
			name = "spaceEmpty" ;
			},
		)

	enabled_jobs = list(/datum/job/trader)

	load_map_elements = list(
	/datum/map_element/dungeon/holodeck
	)

	center_x = 260
	center_y = 236

//All security airlocks have randomized wires
/obj/machinery/door/airlock/glass_security/New()
	.=..()
	wires = new /datum/wires/airlock/secure(src)

/obj/machinery/door/airlock/security/New()
	.=..()
	wires = new /datum/wires/airlock/secure(src)

/datum/shuttle/bagel
	name = "bagel ferry"
	can_link_to_computer = LINK_FREE
	destroy_everything = TRUE // So that it can replace part of maintenance. Possibly a terrible idea?
	linked_area = /area/shuttle/bagel

/datum/shuttle/bagel/initialize()
	. = ..()
	add_dock(/obj/docking_port/destination/bagel_aftstarboard)
	add_dock(/obj/docking_port/destination/bagel_foreport)

/obj/machinery/computer/shuttle_control/bagel
	shuttle = /area/shuttle/bagel

/obj/docking_port/destination/bagel_aftstarboard
	areaname = "aft starboard"
	base_turf_override = TRUE
	base_turf_type = /turf/simulated/floor/plating
	refill_area = /area/maintenance/asmaint

/obj/docking_port/destination/bagel_foreport
	areaname = "fore port"
	base_turf_override = TRUE
	base_turf_type = /turf/simulated/floor/plating
	refill_area = /area/maintenance/fpmaint

#include "bagelstation.dmm"
#endif
