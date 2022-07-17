//Refer to life.dm for caller

/mob/living/carbon/human/proc/breathe()
	if(flags & INVULNERABLE)
		return
	if(reagents.has_any_reagents(LEXORINS))
		return
	if(undergoing_hypothermia() == PROFOUND_HYPOTHERMIA) // we're not breathing. see handle_hypothermia.dm for details.
		return
	if(M_NO_BREATH in mutations)
		return //No breath mutation means no breathing.
	if(istype(loc, /obj/machinery/atmospherics/unary/cryo_cell)) //This is an annoying hack given that cryo cells are supposed to be oxygenated, but fuck it
		return
	if(species && species.flags & NO_BREATHE)
		return
	if(nobreath)
		nobreath--
		return

	var/datum/organ/internal/lungs/L = internal_organs_by_name["lungs"]
	if(L)
		L.process() //Ideally lungs would handle breathing, but right now we're just sanitizing

	var/datum/gas_mixture/environment = loc.return_air()
	var/datum/gas_mixture/breath
	//HACK NEED CHANGING LATER
	if(health < config.health_threshold_crit || !L)
		losebreath++
	if(losebreath > 0) //Suffocating so do not take a breath
		losebreath--
		if(prob(10)) //Gasp per 10 ticks? Sounds about right.
			spawn()
				emote("gasp")
		if(istype(loc, /obj/))
			var/obj/location_as_object = loc
			location_as_object.handle_internal_lifeform(src, 0)
	else
		//First, check for air from internal atmosphere (using an air tank and mask generally)
		breath = get_breath_from_internal(BREATH_VOLUME) // Super hacky -- TLE
		//breath = get_breath_from_internal(0.5) // Manually setting to old BREATH_VOLUME amount -- TLE

		//No breath from internal atmosphere so get breath from location
		if(!breath)
			if(head && (head.clothing_flags & BLOCK_BREATHING)) //Worn items which block breathing are handled first
				//
			else if(wear_mask && (wear_mask.clothing_flags & BLOCK_BREATHING))
				//
			else if(isobj(loc))
				var/obj/location_as_object = loc
				breath = location_as_object.handle_internal_lifeform(src, BREATH_VOLUME)
			else if(isturf(loc))
				/*if(environment.return_pressure() > ONE_ATMOSPHERE)
					//Loads of air around (pressure effect will be handled elsewhere), so lets just take a enough to fill our lungs at normal atmos pressure (using n = Pv/RT)
					breath_moles = (ONE_ATMOSPHERE*BREATH_VOLUME/R_IDEAL_GAS_EQUATION*environment.temperature)
				else
					*/
					//Not enough air around, take a percentage of what's there to model this properly
				breath = environment.remove_volume(CELL_VOLUME * BREATH_PERCENTAGE)

				if(!breath || breath.total_moles < BREATH_MOLES / 5 || breath.total_moles > BREATH_MOLES * 5)
					if(prob(20))
						L.damage += 1
					if(!is_lung_ruptured() && L.damage > 2)
						var/chance_break = (L.damage / L.min_broken_damage)*100
						if(prob(chance_break))
							rupture_lung()

				//Handle filtering

				var/block = 0
				var/list/blockers = list(wear_mask,glasses,head)
				for (var/item in blockers)
					var/obj/item/I = item
					if (!istype(I))
						continue
					if (I.clothing_flags & BLOCK_GAS_SMOKE_EFFECT)
						block = 1
						break

				if(!block)
					for(var/obj/effect/smoke/chem/smoke in view(1, src)) //If there is smoke within one tile
						if(smoke.reagents.total_volume)
							smoke.reagents.reaction(src, INGEST, amount_override = min(smoke.reagents.total_volume,10)/(smoke.reagents.reagent_list.len))
							spawn(5)
								if(smoke)
									smoke.reagents.copy_to(src, 10) //I dunno, maybe the reagents enter the blood stream through the lungs?
							break //If they breathe in the nasty stuff once, no need to continue checking

					//airborne viral spread/breathing
					breath_airborne_diseases()

		else //Still give containing object the chance to interact
			if(istype(loc, /obj/))
				var/obj/location_as_object = loc
				location_as_object.handle_internal_lifeform(src, 0)

	handle_breath(breath)

	if(species)
		species.handle_environment(environment, src)



	if(breath)
		loc.assume_air(breath)
/*
		//Spread some viruses while we are at it
		if(virus2 && virus2.len > 0)
			//if(get_infection_chance(src))//checking our own infection protections, so we don't spread an airborne virus if we're wearing internals
			//	for(var/mob/living/M in range(1,src))
			//		if(can_be_infected(M))
			//			spread_disease_to(src,M)
*/
/mob/living/carbon/human/proc/get_breath_from_internal(volume_needed)
	if(internal)
		if(!contents.Find(internal))
			if(wear_suit && isrig(wear_suit)) //But what if he's wearing a rigsuit?
				var/obj/item/clothing/suit/space/rig/rig = wear_suit
				if(!rig.T) //But if the rig has no internal tank...
					internal = null
			else
				internal = null
		if(!wear_mask || !(wear_mask.clothing_flags & MASKINTERNALS))
			internal = null
		if(internal)
			return internal.remove_air_volume(volume_needed)
		else if(internals)
			internals.icon_state = "internal0"
	return null

/mob/living/carbon/human/proc/handle_breath(var/datum/gas_mixture/breath)
	if((status_flags & GODMODE) || (flags & INVULNERABLE))
		return 0
	var/datum/organ/internal/lungs/L = internal_organs_by_name["lungs"]
	if(!breath || (breath.total_moles() == 0) || (mind && mind.suiciding) || !L)
		if(reagents.has_any_reagents(list(INAPROVALINE,PRESLOMITE)))
			return 0
		if(mind && mind.suiciding)
			adjustOxyLoss(2) //If you are suiciding, you should die a little bit faster
			failed_last_breath = 1
			oxygen_alert = 1
			return 0
		if(health > config.health_threshold_crit)
			adjustOxyLoss(HUMAN_MAX_OXYLOSS)
			failed_last_breath = 1
		else
			adjustOxyLoss(HUMAN_CRIT_MAX_OXYLOSS)
			failed_last_breath = 1

		oxygen_alert = 1

		return 0

	// Lungs now handle processing atmos shit.
	if(L)
		L.handle_breath(breath,src)

	return 1
