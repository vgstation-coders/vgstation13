#ifndef MAP_OVERRIDE
//**************************************************************
// Map Datum -- Snowbox Station
//**************************************************************

/datum/map/active
	nameShort = "snowbox"
	nameLong = "Snowbox Station"
	map_dir = "snowstation"
	zAsteroid = 1
	zMainStation = 2
	zCentcomm = 3
	zTCommSat = 5
	zLevels = list(
		/datum/zLevel/snowmine{
			z_above = 2
		},
		/datum/zLevel/snow{
			name = "station"
			movementChance = ZLEVEL_BASE_CHANCE * ZLEVEL_STATION_MODIFIER
			base_turf = /turf/simulated/open
			z_below = 1
		},
		/datum/zLevel/centcomm,
		/datum/zLevel/snow{
			name = "derelict" ;
			},
		)
	enabled_jobs = list(/datum/job/trader)

	load_map_elements = list(
	/datum/map_element/dungeon/holodeck
	)

	holomap_offset_x = list(0,0,0,86,4,0,0,)
	holomap_offset_y = list(0,0,0,94,10,0,0,)

	center_x = 150
	center_y = 150
	only_spawn_map_exclusive_vaults = TRUE

	event_blacklist = list(/datum/event/radiation_storm,/datum/event/carp_migration,/datum/event/rogue_drone,/datum/event/immovable_rod,
						/datum/event/meteor_wave,/datum/event/meteor_shower,/datum/event/thing_storm/meaty_gore,/datum/event/thing_storm/blob_shower,
						/datum/event/thing_storm/blob_storm,/datum/event/thing_storm/fireworks)
	load_map_elements = list(
	/datum/map_element/dungeon/holodeck
	)

	snow_theme = TRUE
	can_enlarge = FALSE

/datum/map/active/map_specific_init()
	climate = new /datum/climate/arctic()

/datum/subsystem/daynightcycle
	flags = SS_FIRE_IN_LOBBY

/datum/map/active/map_ruleset(var/datum/dynamic_ruleset/DR)
	if(ispath(DR.role_category,/datum/role/blob_overmind))
		return FALSE

	return ..()

/datum/map/active/map_equip(var/mob/living/carbon/human/H)
	if(!istype(H))
		return
	H.equip_or_collect(new /obj/item/weapon/book/manual/snow(H.back), slot_in_backpack)

////////////////////////////////////////////////////////////////
#include "tgstation-snow.dmm"
#endif
