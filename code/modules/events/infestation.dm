/datum/event/infestation
	announceWhen = 15
	endWhen = 20
	var/locstring
	var/vermstring
	var/vermin = VERM_MICE
	var/override_location = null
	var/override_vermin = null

/datum/event/infestation/can_start()
	return 50

/datum/event/infestation/start()

	var/location = pick(LOC_KITCHEN, LOC_ATMOS, LOC_INCIN, LOC_CHAPEL, LOC_LIBRARY, LOC_HYDRO, LOC_VAULT, LOC_TECH)
	if (override_location)
		location = override_location

	var/spawn_area_type

	//TODO:  These locations should be specified by the map datum or by the area. //Area datums, any day now
	//Something like area.is_quiet=1 or map.quiet_areas=list()
	switch(location)
		if(LOC_KITCHEN)
			spawn_area_type = /area/crew_quarters/kitchen
			locstring = "the Kitchen"
		if(LOC_ATMOS)
			spawn_area_type = /area/engineering/atmos
			locstring = "Atmospherics"
		if(LOC_INCIN)
			spawn_area_type = /area/maintenance/incinerator
			locstring = "the Incinerator"
		if(LOC_CHAPEL)
			spawn_area_type = /area/chapel/main
			locstring = "the Chapel"
		if(LOC_LIBRARY)
			spawn_area_type = /area/library
			locstring = "the Library"
		if(LOC_HYDRO)
			spawn_area_type = /area/hydroponics
			locstring = "Hydroponics"
		if(LOC_VAULT)
			spawn_area_type = /area/storage/nuke_storage
			locstring = "the Vault"
		if(LOC_TECH)
			spawn_area_type = /area/storage/tech
			locstring = "Technical Storage"

	var/list/spawn_types = list()
	var/max_number = 4

	vermin = pick(VERM_MICE, VERM_LIZARDS, VERM_SPIDERS, VERM_SLIMES, VERM_BATS, VERM_BORERS, VERM_MIMICS, VERM_ROACHES, VERM_GREMLINS, VERM_BEES, VERM_HORNETS,
	VERM_SYPHONER, VERM_GREMTIDE, VERM_CRABS)

	if (override_vermin)
		vermin = override_vermin

	switch(vermin)
		if(VERM_MICE)
			spawn_types = list(/mob/living/simple_animal/mouse/common/gray, /mob/living/simple_animal/mouse/common/brown, /mob/living/simple_animal/mouse/common/white)
			max_number = 12
			vermstring = "mice"
		if(VERM_LIZARDS)
			spawn_types = list(/mob/living/simple_animal/hostile/lizard)
			max_number = 6
			vermstring = "lizards"
		if(VERM_SPIDERS)
			spawn_types = list(/mob/living/simple_animal/hostile/giant_spider/spiderling)
			vermstring = "spiderlings"
		if(VERM_SLIMES)
			spawn_types = typesof(/mob/living/carbon/slime) - /mob/living/carbon/slime - typesof(/mob/living/carbon/slime/adult)
			vermstring = "slimes"
		if(VERM_BATS)
			spawn_types = /mob/living/simple_animal/hostile/scarybat
			vermstring = "space bats"
		if(VERM_BORERS)
			spawn_types = /mob/living/simple_animal/borer
			vermstring = "borers"
			max_number = 5
		if(VERM_MIMICS)
			spawn_types = /mob/living/simple_animal/hostile/mimic/crate/item
			vermstring = "mimics"
			max_number = 1 //1 to 2
		if(VERM_ROACHES)
			spawn_types = /mob/living/simple_animal/cockroach
			vermstring = "roaches"
			max_number = 30 //Thanks obama
		if(VERM_GREMLINS)
			spawn_types = /mob/living/simple_animal/hostile/gremlin
			vermstring = "gremlins"
			max_number = 4 //2 to 4
		if(VERM_BEES)
			spawn_types = /obj/machinery/apiary/wild/angry
			vermstring = "angry bees"
			max_number = 2
		if(VERM_HORNETS)
			spawn_types = /obj/machinery/apiary/wild/angry/hornet
			vermstring = "deadly hornets"
			max_number = 2
		if(VERM_SYPHONER)
			spawn_types = /mob/living/simple_animal/hostile/syphoner
			vermstring = "rogue cell chargers"
			max_number = 2
		if(VERM_GREMTIDE)
			spawn_types = /mob/living/simple_animal/hostile/gremlin/greytide
			vermstring = "gremlin assistants"
			max_number = 3
		if(VERM_CRABS)
			spawn_types = list(/mob/living/simple_animal/crab, /mob/living/simple_animal/crab/kickstool, /mob/living/simple_animal/crab/snowy)
			vermstring = "crabs"
			max_number = 5

	var/number = rand(2, max_number)

	var/area/A = locate(spawn_area_type)
	var/list/turf/simulated/floor/valid = list()
	//Loop through each floor in the supply drop area
	for(var/turf/simulated/floor/F in A)
		if(!F.has_dense_content())
			valid.Add(F)
	if(!valid.len)
		message_admins("Infestation event failed! Could not find any viable turfs in [spawn_area_type] at which to spawn [number + 1] [vermstring].")
		announceWhen = -1
		endWhen = 0
		return

	for(var/i = 0, i <= number, i++)
		var/picked = pick(valid)
		if(vermin == VERM_SPIDERS)
			var/mob/living/simple_animal/hostile/giant_spider/spiderling/S = new(picked)
			S.amount_grown = 0
		else
			var/spawn_type = pick(spawn_types)
			var/mob/M = new spawn_type(picked)
			if(M.density)
				valid -= picked
		if(!valid.len)
			message_admins("Infestation event could not find enough viable turfs in [spawn_area_type] to spawn all vermin. [number - i] [vermstring] were unable to spawn!")
			break

/datum/event/infestation/announce()
	var/warning = "Clear them out, before this starts to affect productivity."
	if(vermin == VERM_GREMLINS)
		warning = "Drive them away!" //DF reference

	command_alert(new /datum/command_alert/vermin(vermstring, locstring, warning))
