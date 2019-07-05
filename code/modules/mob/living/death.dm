/mob/living/death(gibbed)
	if(!gibbed && can_butcher)
		verbs += /mob/living/proc/butcher

	//Check the global list of butchering drops for our species.
	//See code/datums/helper_datums/butchering.dm
	init_butchering_list()

	clear_fullscreens()

	handle_symptom_on_death()
	..()

/mob/living/gib()
	death(1)
	monkeyizing = 1
	canmove = 0
	icon = null
	invisibility = 101

	gibs(loc, virus2, dna)

	dead_mob_list -= src

	qdel(src)

/mob/living/proc/init_butchering_list()
	if(butchering_drops && butchering_drops.len) //Already initialized
		return
	if(species_type && animal_butchering_products[species_type])
		if(!butchering_drops)
			butchering_drops = list()
		var/list/L = animal_butchering_products[species_type]

		for(var/butchering_type in L)
			src.butchering_drops += new butchering_type
