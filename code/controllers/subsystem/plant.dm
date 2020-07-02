var/datum/subsystem/plant/SSplant

// Processes vines/spreading plants.
/datum/subsystem/plant
	name          = "Plants"
	init_order    = SS_INIT_PLANT
	display_order = SS_DISPLAY_PLANT
	priority      = SS_PRIORITY_PLANT
	wait          = 3 SECONDS

	var/list/processing_plants = list()
	var/list/currentrun
	var/list/datum/seed/seeds = list() // All seed data stored here.

/datum/subsystem/plant/New()
	NEW_SS_GLOBAL(SSplant)

// Predefined/roundstart varieties use a string key to make it
// easier to grab the new variety when mutating. Post-roundstart
// and mutant varieties use their uid converted to a string instead.
// Looks like shit but it's sort of necessary.
/datum/subsystem/plant/Initialize()
	// Populate the global seed datum list.
	for(var/type in subtypesof(/datum/seed))
		var/datum/seed/S = new type
		seeds[S.name] = S
		S.uid = "[seeds.len]"
		S.roundstart = TRUE
	..()

/datum/subsystem/plant/proc/create_random_seed(var/survive_on_station)
	var/datum/seed/seed = new()
	seed.randomize()
	seed.uid = seeds.len + 1
	seed.name = "[seed.uid]"
	seeds[seed.name] = seed

	if(survive_on_station)
		if(seed.consume_gasses)
			seed.consume_gasses[GAS_PLASMA] = null //PHORON DOES NOT EXIST
			seed.consume_gasses[GAS_CARBON] = null
		if(seed.chems)
			seed.chems.Remove(PHENOL) // Eating through the hull will make these plants completely inviable, albeit very dangerous.
		seed.ideal_heat = initial(seed.ideal_heat)
		seed.heat_tolerance = initial(seed.heat_tolerance)
		seed.ideal_light = initial(seed.ideal_light)
		seed.light_tolerance = initial(seed.light_tolerance)
		seed.lowkpa_tolerance = initial(seed.lowkpa_tolerance)
		seed.highkpa_tolerance = initial(seed.highkpa_tolerance)
	return seed

/datum/subsystem/plant/stat_entry()
	..("P:[processing_plants.len]")


/datum/subsystem/plant/fire(var/resumed = FALSE)
	if (!resumed)
		currentrun = processing_plants.Copy()

	while (currentrun.len)
		var/obj/effect/plantsegment/plant = currentrun[currentrun.len]
		currentrun.len--

		if (!plant || plant.gcDestroyed || plant.disposed)
			remove_plant(plant)
			continue
		if(plant.timestopped)
			continue

		plant.process()
		if (MC_TICK_CHECK)
			return

/datum/subsystem/plant/proc/add_plant(var/obj/effect/plantsegment/plant)
	if(!istype(plant) || plant.gcDestroyed || plant.disposed)
		return
	processing_plants |= plant

/datum/subsystem/plant/proc/remove_plant(var/obj/effect/plantsegment/plant)
	processing_plants -= plant
