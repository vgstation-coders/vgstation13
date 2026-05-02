


/*		/proc/assume_contact_diseases
*
* Mob will contract diseases that can spread through contact among those in the list, and more if applicable
*
* /disease_list	: The associative list of diseases to contract, entries are structured like so "disease_id = disease_datum"
* /source		: The source of the disease, for logging
* /blocked		: Contact diseases will only spread to the mob if blocked = 0
* /bleeding		: If bleeding = 1, non-contact diseases that can spread from blood will spread to the mob
*/

/mob/living/proc/assume_contact_diseases(var/list/disease_list,var/atom/source,var/blocked=0,var/bleeding=0)
	if (istype(disease_list) && disease_list.len > 0)
		for(var/ID in disease_list)
			var/datum/disease2/disease/V = disease_list[ID]
			if (!V)
				message_admins("[key_name(src)] is trying to assume contact diseases from touching \a [source], but the disease_list contains an ID ([ID]) that isn't associated to an actual disease datum! Ping Deity about it please.")
				return
			if(!blocked && V.spread & SPREAD_CONTACT)
				infect_disease2(V, notes="(Contact, from [source])")
			else if(suitable_colony() && V.spread & SPREAD_COLONY)
				infect_disease2(V, notes="(Colonized, from [source])")
			else if(!blocked && bleeding && (V.spread & SPREAD_BLOOD))
				infect_disease2(V, notes="(Blood, from [source])")




/*		/proc/find_nearby_disease
*
* Called in Life() by humans (in handle_virus_updates.dm), monkeys and mice.
* Checks for nearby sources of diseases that can be contracted through touch.
*
*/
/mob/living/proc/find_nearby_disease()
	if(locked_to)//Riding a vehicle?
		return
	if(flying)//Flying?
		return

	var/turf/T = get_turf(src)

	//Virus Dishes aren't toys, handle with care, especially when they're open.
	for(var/obj/effect/decal/cleanable/virusdish/dish in T)
		dish.infection_attempt(src)
	for(var/obj/item/weapon/virusdish/dish in T)
		if (dish.open && dish.contained_virus)
			dish.infection_attempt(src,dish.contained_virus)
	var/obj/item/weapon/virusdish/dish = locate() in held_items
	if (dish && dish.open && dish.contained_virus)
		dish.infection_attempt(src,dish.contained_virus)

	//Now to check for stuff that's on the floor
	var/block = 0
	var/bleeding = 0
	if (lying)
		block = check_contact_sterility(FULL_TORSO)
		bleeding = check_bodypart_bleeding(FULL_TORSO)
	else
		block = check_contact_sterility(FEET)
		bleeding = check_bodypart_bleeding(FEET)

	var/static/list/viral_cleanable_types = list(
		/obj/effect/decal/cleanable/blood,
		/obj/effect/decal/cleanable/mucus,
		/obj/effect/decal/cleanable/vomit,
		)

	for(var/obj/effect/decal/cleanable/C in T)
		if (is_type_in_list(C,viral_cleanable_types))
			assume_contact_diseases(C.virus2,C,block,bleeding)

	for(var/obj/effect/rune/R in T)
		assume_contact_diseases(R.virus2,R,block,bleeding)




/*		/proc/oneway_contact_diseases
*
* Acquire another mob's diseases that can spread through contact
* For instance, by getting splashed with someone's blood due to clobbering them to death
*
* /L		: the mob we're getting the diseases from
* /block	: whether the part in contact passed its sterility check
* /bleeding	: whether the part in contact is bleeding
*/
/mob/living/proc/oneway_contact_diseases(var/mob/living/L,var/block=0,var/bleeding=0)
	assume_contact_diseases(L.virus2,L,block,bleeding)




/*		/proc/share_contact_diseases
*
* Exchange two mobs' diseases that can spread through contact
* This one is used for two-ways infections, such as hand-shakes, hugs, punches, people bumping into each others, etc
*
* /L		: the mob we're exchanging diseases with
* /block	: whether the part in contact passed its sterility check
* /bleeding	: whether the part in contact is bleeding
*/
/mob/living/proc/share_contact_diseases(var/mob/living/L,var/block=0,var/bleeding=0)
	L.assume_contact_diseases(virus2,src,block,bleeding)
	assume_contact_diseases(L.virus2,L,block,bleeding)




/*		/proc/breath_airborne_diseases
*
* Called in Life() by humans (in handle_breath.dm), monkeys and mice.
* Checks for nearby sources of diseases that can be contracted through breathing, such as pathogen clouds,
* but also by standing over splatters such as vomit that contains diseases that can spread airborne
*
*/
/mob/living/proc/breath_airborne_diseases()//only tries to find Airborne spread diseases. Blood and Contact ones are handled by find_nearby_disease()
	if (!check_airborne_sterility() && isturf(loc))//checking for sterile mouth protections
		breath_airborne_diseases_from_clouds()

		var/turf/T = get_turf(src)
		var/list/breathable_cleanable_types = list(
			/obj/effect/decal/cleanable/blood,
			/obj/effect/decal/cleanable/mucus,
			/obj/effect/decal/cleanable/vomit,
			)

		for(var/obj/effect/decal/cleanable/C in T)
			if (is_type_in_list(C,breathable_cleanable_types))
				if(istype(C.virus2,/list) && C.virus2.len > 0)
					for(var/ID in C.virus2)
						var/datum/disease2/disease/V = C.virus2[ID]
						if(V.spread & SPREAD_AIRBORNE)
							infect_disease2(V, notes="(Airborne, from [C])")

		for(var/obj/effect/rune/R in T)
			if(istype(R.virus2,/list) && R.virus2.len > 0)
				for(var/ID in R.virus2)
					var/datum/disease2/disease/V = R.virus2[ID]
					if(V.spread & SPREAD_AIRBORNE)
						infect_disease2(V, notes="(Airborne, from [R])")

		spawn (1)
			//we don't want the rest of the mobs to start breathing clouds before they've settled down
			//otherwise it can produce exponential amounts of lag if many mobs are in an enclosed space
			spread_airborne_diseases()




/*		/proc/breath_airborne_diseases_from_clouds
*
* The detailed check for nearby pathogen clouds, called by breath_airborne_diseases()
*
*/
/mob/living/proc/breath_airborne_diseases_from_clouds()
	for(var/turf/T in range(1, src))
		for(var/obj/effect/pathogen_cloud/cloud in T.contents)
			if (!cloud.sourceIsCarrier || cloud.source != src || cloud.modified)
				if (Adjacent(cloud))
					for (var/ID in cloud.viruses)
						var/datum/disease2/disease/V = cloud.viruses[ID]
						//if (V.spread & SPREAD_AIRBORNE)	//Anima Syndrome allows for clouds of non-airborne viruses
						infect_disease2(V, notes="(Airborne, from a pathogenic cloud[cloud.source ? " created by [key_name(cloud.source)]" : ""])")




/*		/proc/spread_airborne_diseases
*
* This proc creates new pathogen clouds if the holder is carrying airborne diseases, called by breath_airborne_diseases()
*
*/
/mob/living/proc/spread_airborne_diseases()
	//spreading our own airborne viruses
	if (virus2 && virus2.len > 0)
		var/list/airborne_viruses = filter_disease_by_spread(virus2,required = SPREAD_AIRBORNE)
		if (airborne_viruses && airborne_viruses.len > 0)
			var/strength = 0
			for (var/ID in airborne_viruses)
				var/datum/disease2/disease/V = airborne_viruses[ID]
				strength += V.infectionchance
			strength = round(strength/airborne_viruses.len)
			while (strength > 0)//stronger viruses create more clouds at once
				new /obj/effect/pathogen_cloud/core(get_turf(src), src, virus_copylist(airborne_viruses))
				strength -= 40




/*		/proc/handle_virus_updates
*
* This proc checks for nearby disease sources, then updates the diseases currently being carried
*
*/
/mob/living/proc/handle_virus_updates()
	if(status_flags & GODMODE)
		return 0

	src.find_nearby_disease()//getting diseases from blood/mucus/vomit splatters and open dishes

	activate_diseases()




/*		/proc/activate_diseases
*
* Updates the diseases currently being carried. if the mob is getting irradiated, the disease may also incubate,
* although it won't mutate unless the mob has also ingested the required reagents.
*
*/
/mob/living/proc/activate_diseases()
	if (virus2.len)
		var/active_disease = pick(virus2)//only one disease will activate its effects at a time.
		for (var/ID in virus2)
			var/datum/disease2/disease/V = virus2[ID]
			if(istype(V))
				V.activate(src,active_disease!=ID)

				if (prob(radiation))//radiation turns your body into an inefficient pathogenic incubator.
					V.incubate(src,rad_tick/10)
					//effect mutations won't occur unless the mob also has ingested mutagen
					//and even if they occur, the new effect will have a badness similar to the old one, so helpful pathogen won't instantly become deadly ones.




/*		/proc/handle_symptom_on_death
*
* Called upon the mob's death, allow disease symptoms to trigger their "on_death()" effect
*
*/
/mob/living/proc/handle_symptom_on_death()
	if(islist(virus2) && virus2.len > 0)
		for(var/I in virus2)
			var/datum/disease2/disease/D = virus2[I]
			if(D.effects.len)
				for(var/datum/disease2/effect/E in D.effects)
					E.on_death(src)
