#ifndef MAP_OVERRIDE
//**************************************************************
// Map Datum -- Dorfstation
//**************************************************************

/datum/map/active
	nameShort = "dorf"
	nameLong = "DorfStation"
	map_dir = "dorfstation"
	zLevels = list(
		/datum/zLevel/station,
		/datum/zLevel/centcomm,
		/datum/zLevel/space{
			name = "derelict" ;
			},
		/datum/zLevel/space{
			name = "spaceEmpty" ;
			}
		)
	enabled_jobs = list(/datum/job/trader)

	load_map_elements = list(
	/datum/map_element/dungeon/holodeck
	)

	holomap_offset_x = list(0,0,0,86,4,0,0,)
	holomap_offset_y = list(0,0,0,94,10,0,0,)

	center_x = 222
	center_y = 262

//All security airlocks have randomized wires
/obj/machinery/door/airlock/glass_security/New()
	.=..()
	wires = new /datum/wires/airlock/secure(src)

/obj/machinery/door/airlock/security/New()
	.=..()
	wires = new /datum/wires/airlock/secure(src)

/datum/map/active/map_equip(var/mob/living/carbon/human/H)
	if(!istype(H))
		return
	H.equip_or_collect(new /obj/item/weapon/storage/box/dorf(H.back), slot_in_backpack)

////////////////////////////////////////////////////////////////
#include "dorfstation.dmm"
#endif
