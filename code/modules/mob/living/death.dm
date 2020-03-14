/mob/living/death(gibbed)
	if(!gibbed && can_butcher)
		verbs += /mob/living/proc/butcher

	//Check the global list of butchering drops for our species.
	//See code/datums/helper_datums/butchering.dm
	init_butchering_list()

	clear_fullscreens()
	..()

/mob/living/proc/init_butchering_list()
	if(butchering_drops && butchering_drops.len) //Already initialized
		return
	if(species_type && animal_butchering_products[species_type])
		if(!butchering_drops)
			butchering_drops = list()
		var/list/L = animal_butchering_products[species_type]

		for(var/butchering_type in L)
			src.butchering_drops += new butchering_type
