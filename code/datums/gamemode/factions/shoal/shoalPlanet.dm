/datum/zLevel/shoal
	name = "vox shoal"
	movementJammed = 1 		// no drifting here
	teleJammed = 1			// no teleporting
	bluespace_jammed = 1	// BoHs make explosions.
//	base_turf = /turf/unsimulated/floor/vox/plating
//	base_area = /area/shoal
	planetside = TRUE

/datum/planet_type/shoal
	name = "shoal"
	planet_name = "Vox Shoal"

	desc = "A hulking ball of scrap metal, about as large as any planet. Nobody knows if there's a surface at the center."

	mapgen = null

	default_baseturf = /turf/unsimulated/wall/shoal

	loot_type = 0
	climate_type = null
	icon_state = "moon"
	hidden = FALSE

/datum/planet_type/shoal/build_daynight_turflist()
	return

/datum/planet_type/shoal/New()
	..()
	world.maxz += 1
	var/datum/zLevel/shoal/shoalZLevel = new
	map.addZLevel(shoalZLevel, world.maxz, TRUE, TRUE)
	message_admins("Generating unique planet '[planet_name]' at z-level [world.maxz]")
	SSmapping.planets += src
	var/datum/map_element/shoal/shoal = new
	var/result = shoal.load(1, 1, shoalZLevel.z, 0, TRUE)
	if(!result)
		message_admins("Failed to load the Vox Shoal")
		return FALSE
	return result

/datum/planet_type/shoal/generate_planet_name()
	var/list/sector_names = list(
		"Centauri",
		"Orionis",
		"Draconis",
		"Cygni",
		"Ursa",
		"Lyrae",
		"Aquila",
		"Cassiopeia",
		"Andromeda",
		"Perseus",
		"Hercules",
		"Gemini",
		"Virgo",
		"Scorpius",
		"Sagittarius",
		"Aquarius",
		"Taurus",
		"Aries",
		"Libra",
		"Pisces",
		"Cancer",
		"Leo",
		"Capricorn",
		"Terra",
		"Luna",
		"Sol",
		"Helios",
		"Titan",
		"Cosmos",
		"Nexus",
		"Void",
		"Prime",
		"Major",
		"Minor",
		"Central"
	)
	var/list/suffixes = list(
		"I",
		"II",
		"III",
		"IV",
		"V",
		"VI",
		"VII",
		"VIII",
		"IX",
		"X",
		"Prime",
		"Alpha",
		"Beta",
		"Gamma",
		"Delta",
		"One",
		"Two",
		"Three",
		"Four",
		"Five",
		"Six",
		"Seven",
		"Eight",
		"Nine",
		"Ten",
		"Major",
		"Minor",
		"Central",
		"Outer",
		"Inner",
		"North",
		"South",
		"East",
		"West"
	)

	return "Vox Shoal (Sector [pick(sector_names)]-[pick(suffixes)])"


/datum/map_element/shoal
	file_path = "maps/shoal.dmm"


// Raiders

/area/shoal
	name = "\improper Shoal"
	icon_state = "tradeden"
	requires_power = 0
	dynamic_lighting = 1
	holomap_draw_override = HOLOMAP_DRAW_EMPTY

/area/shoal/station
	name = "\improper Shoal"
	icon_state = "yellow"
	requires_power = 0
	dynamic_lighting = 1
	holomap_draw_override = HOLOMAP_DRAW_EMPTY
