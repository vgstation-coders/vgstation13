
//**************************************************************
// Map Datum -- Bagel
//**************************************************************

/datum/map/active
	nameShort = "bagel"
	nameLong = "Bagelstation"
	map_dir = "bagelstation"
	tDomeX = 108
	tDomeY = 70
	tDomeZ = 2
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


//All security airlocks have randomized wires
/obj/machinery/door/airlock/glass_security/New()
	.=..()
	wires = new /datum/wires/airlock/secure(src)

/obj/machinery/door/airlock/security/New()
	.=..()
	wires = new /datum/wires/airlock/secure(src)

////////////////////////////////////////////////////////////////
#include "defficiency/pipes.dm" // Atmos layered pipes.

#include "bagelstation.dmm"

