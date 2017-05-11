
//**************************************************************
// Map Datum -- Ministation
//**************************************************************

/datum/map/active
	nameShort = "mini"
	nameLong = "Ministation"
	tDomeX = 128
	tDomeY = 76
	tDomeZ = 2
	zLevels = list(
		/datum/zLevel/station,
		/datum/zLevel/centcomm,
		/datum/zLevel/space{
			name = "spaceOldSat" ;
			},
		/datum/zLevel/mining,
		)
	unavailable_items = list(
		/obj/item/clothing/shoes/magboots/elite,
		/obj/item/clothing/suit/space/nasavoid,
		/obj/item/clothing/under/rank/research_director,
		/obj/item/clothing/under/rank/chief_engineer,
		/obj/item/clothing/under/rank/chief_medical_officer,
		/obj/item/clothing/under/rank/head_of_security
		)

	holomap_offset_x = list(110,0,0,86,4,0,0,)
	holomap_offset_y = list(119,0,0,94,10,0,0,)

////////////////////////////////////////////////////////////////

#include "ministation.dmm"

#if !defined(MAP_OVERRIDE_FILES)
	#define MAP_OVERRIDE_FILES
	#include "ministation\misc.dm"
	#include "ministation\telecomms.dm"
	#include "ministation\uplink_item.dm"
	#include "ministation\job\jobs.dm"
	#include "ministation\job\removed.dm"

//#elif !defined(MAP_OVERRIDE)
	//#warn a map has already been included, ignoring ministation.
