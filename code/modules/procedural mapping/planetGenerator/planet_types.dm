/datum/planet_type
	///The planet datum type
	var/name = "planet"
	//The procgen name players see
	var/planet_name = "Planet"
	///The description we show on examine
	var/desc = "A planet."
	///The mapgen we set when we are used
	var/mapgen = null
	///The fallback turf if mapgen fails.
	var/default_baseturf = null
	// The type of loot this planet can spawn
	var/loot_type
	//Value that gets added to loot rolls on this planet.
	var/loot_modifier = 0
	//Climate datum
	var/datum/climate/climate
	var/climate_type = null
	//Allocation occupied by this planet.
	var/allocation = null
	//Icon shown in the planet scanner.
	var/icon_state = "moon"
	var/icon/ico
	// Day/night cycle variables
	var/current_timeOfDay = TOD_DAYTIME
	var/next_firetime = 0
	var/list/daynight_turfs = list()
	var/weather_mod = 1 // Planet-specific weather light modifier
	// Player tracking for mob processing optimization
	var/list/planet_mobs = list() // All mobs on this planet
	var/list/players = list() // All living player mobs currently on this planet
	var/process_mobs = FALSE // Whether to process mobs on this planet
	// Faction for mobs spawned on this planet
	var/mob_faction

/**
 * Builds the list of turfs affected by day/night cycle for this planet
 *
 * Scans through all turfs in the allocation and identifies those in open surface areas
 * that should receive day/night lighting changes.
 */
/datum/planet_type/proc/build_daynight_turflist()
	daynight_turfs = list()
	if(!allocation)
		return

	var/datum/allocation/A = allocation
	if(!A.turfs || !A.turfs.len)
		return

	for(var/turf/T in A.turfs)
		if(IsEven(T.x) && IsEven(T.y))
			var/area/area_check = get_area(T)
			if(isopensurface(area_check))
				daynight_turfs += T
			else
				for(var/cdir in cardinal)
					var/turf/T1 = get_step(T, cdir)
					var/area/A1 = get_area(T1)
					if(istype(A1, /area/surface))
						daynight_turfs += T
						break

/datum/planet_type/New()
	..()
	planet_name = generate_planet_name()
	// Generate unique faction name for this planet instance
	mob_faction = planet_name
	ico = icon('icons/ui/planet_scanner/128x128.dmi', "bg")
	var/icon/fg = icon('icons/ui/planet_scanner/64x64.dmi', icon_state)
	ico.Blend(fg,ICON_OVERLAY,32,32)

/datum/planet_type/proc/add_player(var/mob/living/add_mob)
	if(!add_mob?.client)
		return
	if(!(add_mob in players))
		players += add_mob
	process_mobs = players.len ? TRUE : FALSE

/datum/planet_type/proc/remove_player(var/mob/living/rem_mob)
	if(!rem_mob?.client)
		return
	if(rem_mob in players)
		players -= rem_mob
	process_mobs = players.len ? TRUE : FALSE

/datum/planet_type/proc/on_mob_entered(mob/living/M, datum/planet_type/planet)
	if(!M || planet != src)
		return

	if(M.client)
		add_player(M)
	else
		planet_mobs |= M

/datum/planet_type/proc/on_mob_exited(mob/living/M, datum/planet_type/planet)
	if(!M || planet != src)
		return

	if(M.client)
		remove_player(M)
	else
		planet_mobs -= M

/datum/planet_type/proc/generate_planet_name()
	// Complete planet names
	var/list/whole_names = list(
		"Aurelia",
		"Valeria",
		"Meridian",
		"Stellaris",
		"Novara",
		"Caldris",
		"Zephyria",
		"Astoria",
		"Lysander",
		"Celestine",
		"Umbria",
		"Solara",
		"Nexaria",
		"Verdania",
		"Crystallis",
		"Tempest",
		"Serenity",
		"Horizon",
		"Elysian",
		"Cascadia"
	)

	// Name prefixes
	var/list/prefixes = list(
		"Alpha",
		"Beta",
		"Gamma",
		"Delta",
		"Epsilon",
		"Zeta",
		"Eta",
		"Theta",
		"Iota",
		"Kappa",
		"Lambda",
		"Mu",
		"Nu",
		"Xi",
		"Omicron",
		"Pi",
		"Rho",
		"Sigma",
		"Tau",
		"Upsilon",
		"Phi",
		"Chi",
		"Psi",
		"Omega",
		"Neo",
		"Proto",
		"Meta",
		"Ultra",
		"Mega",
		"Hyper"
	)

	// Base names
	var/list/bases = list(
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

	// Name suffixes
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

	// 30% chance to use a complete name, 70% chance to build one
	if(prob(30))
		return pick(whole_names)

	// Build a name from components
	var/generated_name = ""
	var/name_type = rand(1, 3)

	switch(name_type)
		if(1) // Prefix + Base + Suffix
			generated_name = "[pick(prefixes)] [pick(bases)] [pick(suffixes)]"
		if(2) // Prefix + Base only
			generated_name = "[pick(prefixes)] [pick(bases)]"
		if(3) // Base + Suffix only
			generated_name = "[pick(bases)] [pick(suffixes)]"

	return generated_name

/datum/planet_type/beach
	name = "beach planet"
	desc = "The platonic ideal of vacation spots. Warm, comfortable temperatures, and a breathable atmosphere."
	mapgen = /datum/planetGenerator/beach
	default_baseturf = /turf/unsimulated/floor/planetary/grass
	loot_type = LOOT_TYPE_BEACH
	climate_type = /datum/climate/tropical
	icon_state = "beach2"

/datum/planet_type/desert
	name = "desert planet"
	desc = "A hot, arid world with vast deserts and scarce water sources."
	mapgen = /datum/planetGenerator/desert
	default_baseturf = /turf/unsimulated/floor/planetary/desert
	loot_type = LOOT_TYPE_DESERT
	climate_type = /datum/climate/desert
	loot_modifier = 5
	icon_state = "desert"

/datum/planet_type/grass
	name = "grass planet"
	desc = "A temperate planet with a breathable atmosphere and abundant flora and fauna."
	mapgen = /datum/planetGenerator/grass
	default_baseturf = /turf/unsimulated/floor/planetary/grass
	loot_type = LOOT_TYPE_GRASS
	climate_type = /datum/climate/temperate
	icon_state = "earth"

/datum/planet_type/jungle
	name = "jungle planet"
	desc = "A hot, humid planet teeming with exotic flora and fauna."
	mapgen = /datum/planetGenerator/jungle
	default_baseturf = /turf/unsimulated/floor/jungle/grass
	loot_type = LOOT_TYPE_JUNGLE
	climate_type = /datum/climate/tropical
	loot_modifier = 10
	icon_state = "jungle2"

/datum/planet_type/lava
	name = "lava planet"
	desc = "A planet rife with seismic and volcanic activity. High temperatures and dangerous xenofauna render it dangerous for the unprepared."
	mapgen = /datum/planetGenerator/lava
	default_baseturf = /turf/unsimulated/floor/planetary/basalt
	loot_type = LOOT_TYPE_LAVA
	climate_type = /datum/climate/lava
	loot_modifier = 15
	icon_state = "lava"

/datum/planet_type/snow
	name = "frozen planet"
	desc = "A frozen planet covered in thick snow, thicker ice, and dangerous predators."
	mapgen = /datum/planetGenerator/snow
	default_baseturf = /turf/unsimulated/floor/snow
	loot_type = LOOT_TYPE_SNOW
	climate_type = /datum/climate/arctic
	loot_modifier = 5
	icon_state = "snow"

/datum/planet_type/urban
	name = "wasteland planet"
	desc = "A desolate, toxic world littered with the remnants of a long-gone civilization and the conflict that ended it."
	mapgen = /datum/planetGenerator/urban
	default_baseturf = /turf/unsimulated/floor/planetary/wasteland
	loot_type = LOOT_TYPE_URBAN
	climate_type = /datum/climate/wasteland
	loot_modifier = 10
	icon_state = "barren"

/datum/planet_type/xeno
	name = "unknown planet"
	desc = "An alien world with an atmosphere and ecosystem that defies human understanding."
	mapgen = /datum/planetGenerator/xeno
	default_baseturf = /turf/unsimulated/floor/grey_sand
	loot_type = LOOT_TYPE_XENO
	climate_type = /datum/climate/xeno
	loot_modifier = 20
	icon_state = "xeno1"
