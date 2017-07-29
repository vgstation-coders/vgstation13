#define VERM_MICE    0
#define VERM_SPIDERS 1
#define VERM_SLIMES  2
#define VERM_BATS    3
#define VERM_MIMICS  4
#define VERM_ROACHES 5
#define VERM_GREMLINS 6

/datum/event/infestation
	announceWhen = 15
	endWhen = 20
	var/locstring
	var/vermstring
	var/vermin = VERM_MICE

	//TODO:  These locations should be specified by the map datum or by the area. //Area datums, any day now
	//Something like area.is_quiet=1 or map.quiet_areas=list()
	var/list/valid_areas = list(
	/area/crew_quarters/kitchen,
	/area/engineering/atmos,
	/area/maintenance/incinerator,
	/area/chapel/main,
	/area/library,
	/area/hydroponics,
	/area/storage/tech, //tech storage
	/area/lawoffice,
	/area/security/perma, //permabrig
	/area/bridge/meeting_room,
	/area/crew_quarters/toilet, //dorms toilet

	//maintenance
	/area/maintenance/aft,
	/area/maintenance/asmaint,
	/area/maintenance/fore,
	/area/maintenance/fpmaint,
	)

/datum/event/infestation/start()

	//Area where the vermin should spawn
	var/area/area_loc

	/* Some maps might not include some areas, so try to avoid spawning them in areas that don't exist
	   by picking another area if the currently picked area is empty */
	while(!area_loc && valid_areas.len)
		area_loc = locate(pick_n_take(valid_areas))

		if(!istype(area_loc) || !area_loc.contents.len)
			area_loc = null

	//Throw a runtime if every area in the valid_areas list is empty
	ASSERT(istype(area_loc) && area_loc.contents.len)

	locstring = "in \the [area_loc.name]"

	var/list/spawn_types = list()
	var/max_number = 4
	var/min_number = 2

	vermin = pick(VERM_MICE, VERM_SPIDERS, VERM_SLIMES, VERM_BATS, VERM_MIMICS, VERM_ROACHES, VERM_GREMLINS)

	switch(vermin)
		if(VERM_MICE)
			spawn_types = list(/mob/living/simple_animal/mouse, /mob/living/simple_animal/mouse/wire_biter, /mob/living/simple_animal/mouse/plague/random_virus)
			min_number = 4
			max_number = 10
			vermstring = "rats"
		if(VERM_SPIDERS)
			spawn_types = list(/mob/living/simple_animal/hostile/giant_spider/spiderling)
			vermstring = "spiderlings"
		if(VERM_SLIMES)
			spawn_types = typesof(/mob/living/carbon/slime) - /mob/living/carbon/slime - typesof(/mob/living/carbon/slime/adult)
			vermstring = "slimes"
		if(VERM_BATS)
			spawn_types = /mob/living/simple_animal/hostile/scarybat
			vermstring = "space bats"
		if(VERM_MIMICS)
			spawn_types = /mob/living/simple_animal/hostile/mimic/crate/item
			vermstring = "mimics"
			min_number = 3
			max_number = 5
			locstring = "on the station" //Don't reveal the mimics' location for fun times
		if(VERM_ROACHES)
			spawn_types = /mob/living/simple_animal/cockroach
			vermstring = "roaches"
			max_number = 30
		if(VERM_GREMLINS)
			spawn_types = /mob/living/simple_animal/hostile/gremlin
			vermstring = "gremlins"
			max_number = 4 //2 to 4

	var/number = rand(min_number, max_number)

	for(var/i = 0, i <= number, i++)
		var/list/turf/simulated/floor/valid = list()
		//Loop through each floor in the supply drop area
		for(var/turf/simulated/floor/F in area_loc)
			if(!F.has_dense_content())
				valid.Add(F)

		var/picked = pick(valid)
		if(vermin == VERM_SPIDERS)
			var/mob/living/simple_animal/hostile/giant_spider/spiderling/S = new(picked)
			S.amount_grown = 0
		else
			var/spawn_type = pick(spawn_types)
			new spawn_type(picked)

/datum/event/infestation/announce()
	var/warning = "Clear them out, before this starts to affect productivity."
	if(vermin == VERM_GREMLINS)
		warning = "Drive them away!" //DF reference

	command_alert(new /datum/command_alert/vermin(vermstring, locstring, warning))

//Command alert

/datum/command_alert/vermin
	name = "Vermin Alert"
	alert_title = "Vermin infestation"

/datum/command_alert/vermin/New(vermstring = "various vermin", locstring = "in the station's maintenance tunnels", warning = "Clear them out, before this starts to affect productivity.")
	..()

	message = "Bioscans indicate that [vermstring] have been breeding [locstring]. [warning]"

#undef LOC_KITCHEN
#undef LOC_ATMOS
#undef LOC_INCIN
#undef LOC_CHAPEL
#undef LOC_LIBRARY
#undef LOC_HYDRO
#undef LOC_VAULT
#undef LOC_TECH

#undef VERM_MICE
#undef VERM_LIZARDS
#undef VERM_SPIDERS
#undef VERM_SLIMES
#undef VERM_BATS
#undef VERM_MIMICS
#undef VERM_GREMLINS
