/mob/living/death(gibbed)
	if(!gibbed && can_butcher)
		verbs += /mob/living/proc/butcher

	//Check the global list of butchering drops for our species.
	//See code/datums/helper_datums/butchering.dm
	init_butchering_list()

	clear_fullscreens(TRUE)
	handle_symptom_on_death()
	..()
	standard_damage_overlay_updates()

/mob/living/gib(animation = FALSE, meat = TRUE)
	if(status_flags & BUDDHAMODE)
		adjustBruteLoss(200)
		return
	if(!isUnconscious())
		forcesay("-")
	death(1)
	monkeyizing = 1
	canmove = 0
	icon = null
	invisibility = 101

	gibs(loc, virus2, dna, flesh_color2, blood_color2)

	dead_mob_list -= src

	qdel(src)

/mob/living/proc/init_butchering_list()
	if(butchering_drops && butchering_drops.len) //Already initialized
		return

	var/list/animal_butchering_products = get_butchering_products()
	if(species_type && animal_butchering_products.len > 0)
		if(!butchering_drops)
			butchering_drops = list()

		for(var/butchering_type in animal_butchering_products)
			src.butchering_drops += new butchering_type
