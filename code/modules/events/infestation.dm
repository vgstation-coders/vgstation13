#define LOC_KITCHEN 0
#define LOC_ATMOS 1
#define LOC_INCIN 2
#define LOC_CHAPEL 3
#define LOC_LIBRARY 4
#define LOC_HYDRO 5
#define LOC_VAULT 6
#define LOC_TECH 7

#define VERM_MICE    0
#define VERM_LIZARDS 1
#define VERM_SPIDERS 2
#define VERM_SLIMES  3
#define VERM_BATS    4
#define VERM_BORERS  5

/datum/event/infestation
	announceWhen = 15
	endWhen = 20
	var/location
	var/locstring
	var/vermin
	var/vermstring

/datum/event/infestation/start()

	location = rand(0,7)
	var/list/turf/simulated/floor/turfs = list()
	var/spawn_area_type

	// TODO:  These locations should be specified by the map datum or by the area.
	//  something like area.is_quiet=1 or map.quiet_areas=list()
	switch(location)
		if(LOC_KITCHEN)
			spawn_area_type = /area/crew_quarters/kitchen
			locstring = "the kitchen"
		if(LOC_ATMOS)
			spawn_area_type = /area/engineering/atmos
			locstring = "atmospherics"
		if(LOC_INCIN)
			spawn_area_type = /area/maintenance/incinerator
			locstring = "the incinerator"
		if(LOC_CHAPEL)
			spawn_area_type = /area/chapel/main
			locstring = "the chapel"
		if(LOC_LIBRARY)
			spawn_area_type = /area/library
			locstring = "the library"
		if(LOC_HYDRO)
			spawn_area_type = /area/hydroponics
			locstring = "hydroponics"
		if(LOC_VAULT)
			spawn_area_type = /area/storage/nuke_storage
			locstring = "the vault"
		if(LOC_TECH)
			spawn_area_type = /area/storage/tech
			locstring = "technical storage"

	//world << "looking for [spawn_area_type]"
	for(var/areapath in typesof(spawn_area_type))
		//world << "	checking [areapath]"
		var/area/A = locate(areapath)
		//world << "	A: [A], contents.len: [A.contents.len]"
			//world << "	B: [B], contents.len: [B.contents.len]"
		for(var/turf/simulated/floor/F in A)
			if(!F.contents.len)
				turfs += F

	var/list/spawn_types = list()
	var/max_number
	vermin = rand(0,4)
	switch(vermin)
		if(VERM_MICE)
			spawn_types = list(/mob/living/simple_animal/mouse/gray, /mob/living/simple_animal/mouse/brown, /mob/living/simple_animal/mouse/white)
			max_number = 12
			vermstring = "mice"
		if(VERM_LIZARDS)
			spawn_types = list(/mob/living/simple_animal/lizard)
			max_number = 6
			vermstring = "lizards"
		if(VERM_SPIDERS)
			spawn_types = list(/mob/living/simple_animal/hostile/giant_spider/spiderling)
			vermstring = "spiders"
		if(VERM_SLIMES)
			spawn_types = typesof(/mob/living/carbon/slime) - /mob/living/carbon/slime - typesof(/mob/living/carbon/slime/adult)
			vermstring = "slimes"
		if(VERM_BATS)
			spawn_types = /mob/living/simple_animal/hostile/scarybat
			vermstring = "bats"
		if(VERM_BORERS)
			spawn_types = /mob/living/simple_animal/borer
			vermstring = "borers"
			max_number = 5

	spawn(0)
		var/num = rand(2,max_number)
		while(turfs.len > 0 && num > 0)
			var/turf/simulated/floor/T = pick(turfs)
			turfs.Remove(T)
			num--


			if(vermin == VERM_SPIDERS)
				var/mob/living/simple_animal/hostile/giant_spider/spiderling/S = new(T)
				S.amount_grown = 0
			else
				var/spawn_type = pick(spawn_types)
				new spawn_type(T)


/datum/event/infestation/announce()
	command_alert("Bioscans indicate that [vermstring] have been breeding in [locstring]. Clear them out, before this starts to affect productivity.", "Vermin infestation")

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