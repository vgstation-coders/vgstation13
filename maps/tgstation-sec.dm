#ifndef MAP_OVERRIDE
//**************************************************************
// Map Datum -- Castle station
// Literally just Box Station (as of 28/11/2018) without security elements
//**************************************************************

/datum/map/active
	nameShort = "castle"
	nameLong = "Castle Station"
	map_dir = "castlestation"
	tDomeX = 128
	tDomeY = 58
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
			name = "spacePirateShip" ;
			},
		)
	enabled_jobs = list(/datum/job/trader)
	disabled_jobs = list(
		/datum/job/hos,
		/datum/job/warden,
		/datum/job/detective,
		/datum/job/officer,
		/datum/job/ai,
		/datum/job/cyborg,
		/datum/job/mommi)

	default_tagger_locations = list(
		DISP_DISPOSALS,
		DISP_CARGO_BAY,
		DISP_QM_OFFICE,
		DISP_ENGINEERING,
		DISP_CE_OFFICE,
		DISP_ATMOSPHERICS,
		null,
		null,
		DISP_MEDBAY,
		DISP_CMO_OFFICE,
		DISP_CHEMISTRY,
		DISP_RESEARCH,
		DISP_RD_OFFICE,
		DISP_ROBOTICS,
		DISP_HOP_OFFICE,
		DISP_LIBRARY,
		DISP_CHAPEL,
		DISP_THEATRE,
		DISP_BAR,
		DISP_KITCHEN,
		DISP_HYDROPONICS,
		DISP_JANITOR_CLOSET,
		DISP_GENETICS,
		DISP_TELECOMMS,
		DISP_MECHANICS,
		DISP_TELESCIENCE
	)

	unavailable_items = list(/obj/item/clothing/under/rank/head_of_security)

	load_map_elements = list(
	/datum/map_element/dungeon/holodeck
	)

	holomap_offset_x = list(0,0,0,86,4,0,0,)
	holomap_offset_y = list(0,0,0,94,10,0,0,)

	center_x = 226
	center_y = 254

////////////////////////////////////////////////////////////////
#include "tgstation-sec.dmm"
#endif
