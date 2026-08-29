//Refer to life.dm for caller
/mob/living/carbon/human/get_breath_from_internal(volume_needed)
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
		update_internals()
		if(internal)
			return internal.remove_air_volume(volume_needed)
	return null

/mob/living/carbon/human/needs_to_breathe()
	if(undergoing_hypothermia() == PROFOUND_HYPOTHERMIA) // we're not breathing. see handle_hypothermia.dm for details.
		return FALSE
	if (species && (species.flags & NO_BREATHE))
		return FALSE
	return ..()

/mob/living/carbon/human/handle_species_environment(var/datum/gas_mixture/environment)
	if(species)
		species.handle_environment(environment, src)

/mob/living/carbon/human/check_breath_block(var/flag_check = BLOCK_BREATHING)
	var/list/blockers = list(wear_mask,glasses,head)
	for (var/item in blockers)
		var/obj/item/I = item
		if (!istype(I))
			continue
		if (I.clothing_flags & flag_check)
			return TRUE
	return FALSE

/mob/living/carbon/human/breathe_lungs()
	var/datum/organ/internal/lungs/L = get_lungs()
	if(L)
		L.process() //Ideally lungs would handle breathing, but right now we're just sanitizing
		return TRUE
	return FALSE

/mob/living/carbon/human/handle_breath(var/datum/gas_mixture/breath)
	if((status_flags & GODMODE) || (flags & INVULNERABLE))
		return FALSE
	var/datum/organ/internal/lungs/L = get_lungs()
	if(!L)
		if(reagents?.has_any_reagents(list(INAPROVALINE,PRESLOMITE)))
			return FALSE
		if(mind?.suiciding)
			adjustOxyLoss(2) //If you are suiciding, you should die a little bit faster
			failed_last_breath = 1
			oxygen_alert = 1
			return FALSE
		if(health > config.health_threshold_crit)
			adjustOxyLoss(HUMAN_MAX_OXYLOSS)
		else
			adjustOxyLoss(HUMAN_CRIT_MAX_OXYLOSS)
		failed_last_breath = 1
		oxygen_alert = 1

		return FALSE
	// Lungs now handle processing atmos shit.
	else
		L.handle_breath(breath)

	return TRUE
