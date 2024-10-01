
///////////////////////
// LUNG ORGAN
///////////////////////

/datum/organ/internal/lungs
	name = "lungs"
	parent_organ = LIMB_CHEST
	organ_type = "lungs"
	removed_type = /obj/item/organ/internal/lungs

	min_bruised_damage = 8
	min_broken_damage = 15

	// /vg/ now delegates breathing to the appropriate organ.

	// DEFAULTS FOR HUMAN LUNGS:
	var/list/datum/lung_gas/gasses = list(
		new /datum/lung_gas/metabolizable(GAS_OXYGEN,            min_pp=16, max_pp=140),
		new /datum/lung_gas/waste(GAS_CARBON,            max_pp=10),
		new /datum/lung_gas/toxic(GAS_PLASMA,                    max_pp=0.5, max_pp_mask=5, reagent_id=PLASMA, reagent_mult=0.1),
		new /datum/lung_gas/sleep_agent(GAS_SLEEPING, min_giggle_pp=0.15, min_para_pp=1, min_sleep_pp=5),
	)

	var/inhale_volume = BREATH_VOLUME
	var/exhale_moles = 0

/datum/organ/internal/lungs/Destroy()
	for(var/datum/lung_gas/G in gasses)
		qdel(G)
	..()

/datum/organ/internal/lungs/proc/gasp()
	owner.emote("gasp", null, null, TRUE)

/datum/organ/internal/lungs/proc/handle_breath(var/datum/gas_mixture/breath, var/mob/living/carbon/human/H)

	// NOW WITH MODULAR GAS HANDLING RATHER THAN A CLUSTERFUCK OF IF-TREES FOR EVERY SNOWFLAKE RACE
	//testing("Ticking lungs...")

	//Do this to make sure the pressure is correct.
	breath.volume = inhale_volume
	breath.update_values()

	// Instantiate a variable to determine if we should show the player a toxins_alert
	var/toxic_gas_detected = FALSE

	// First, we consume air.
	for(var/datum/lung_gas/G in gasses)
		G.set_context(src,breath,H)
		toxic_gas_detected |= G.handle_inhale()

	// Next, we exhale. At the moment, only /datum/lung_gas/waste uses this.
	for(var/datum/lung_gas/G in gasses)
		G.set_context(src,breath,H)
		G.handle_exhale()

	// If no toxic gas detected, ensure toxins_alert is disabled
	if(!toxic_gas_detected)
		H.toxins_alert = 0

	if( (abs(310.15 - breath.temperature) > 50) && !(M_RESIST_HEAT in H.mutations)) // Hot air hurts :(
		if(H.status_flags & GODMODE)
			return 1	//godmode
		if(breath.temperature < H.species.cold_level_1)
			if(prob(20))
				to_chat(H, "<span class='warning'>You feel your face freezing and an icicle forming in your lungs!</span>")
		else if(breath.temperature > H.species.heat_level_1)
			if(prob(20))
				if(isslimeperson(H))
					to_chat(H, "<span class='warning'>You feel supercharged by the extreme heat!</span>")
				else
					to_chat(H, "<span class='warning'>You feel your face burning and a searing heat in your lungs!</span>")

		if(isslimeperson(H))
			if(breath.temperature < H.species.cold_level_1)
				H.adjustToxLoss(round(H.species.cold_level_1 - breath.temperature))
				H.fire_alert = max(H.fire_alert, 1)
		else
			if(breath.temperature in H.species.cold_level_1 to H.species.heat_level_1)
				return

			else if(breath.temperature <= H.species.cold_level_3)
				H.apply_damage(COLD_GAS_DAMAGE_LEVEL_3, BURN, LIMB_HEAD, used_weapon = "Excessive Cold")
				H.fire_alert = max(H.fire_alert, 1)

			else if(breath.temperature <= H.species.cold_level_2)
				H.apply_damage(COLD_GAS_DAMAGE_LEVEL_2, BURN, LIMB_HEAD, used_weapon = "Excessive Cold")
				H.fire_alert = max(H.fire_alert, 1)

			else if(breath.temperature <= H.species.cold_level_1)
				H.apply_damage(COLD_GAS_DAMAGE_LEVEL_1, BURN, LIMB_HEAD, used_weapon = "Excessive Cold")
				H.fire_alert = max(H.fire_alert, 1)

			else if(breath.temperature >= H.species.heat_level_3)
				H.apply_damage(HEAT_GAS_DAMAGE_LEVEL_3, BURN, LIMB_HEAD, used_weapon = "Excessive Heat")
				H.fire_alert = max(H.fire_alert, 2)

			else if(breath.temperature >= H.species.heat_level_2)
				H.apply_damage(HEAT_GAS_DAMAGE_LEVEL_2, BURN, LIMB_HEAD, used_weapon = "Excessive Heat")
				H.fire_alert = max(H.fire_alert, 2)

			else if(breath.temperature >= H.species.heat_level_1)
				H.apply_damage(HEAT_GAS_DAMAGE_LEVEL_1, BURN, LIMB_HEAD, used_weapon = "Excessive Heat")
				H.fire_alert = max(H.fire_alert, 2)

/datum/organ/internal/lungs/process()
	..()
	if((owner.species && owner.species.flags & NO_BREATHE) || (M_NO_BREATH in owner.mutations))
		return

	if (germ_level > INFECTION_LEVEL_ONE)
		if(prob(5))
			owner.audible_cough()		//respitory tract infection

	if(is_bruised())
		var/chance = min(50, (damage-min_bruised_damage)/min_broken_damage*50)
		if(prob(chance))
			spawn owner.emote("me", 1, "gasps for air!")
			if (owner.losebreath <= 30)
				owner.losebreath += 5
		else if(prob(chance))
			if(owner.drip(10))
				spawn owner.emote("me", 1, "coughs up blood!")


/datum/organ/internal/lungs/vox
	name = "\improper Vox lungs"
	removed_type = /obj/item/organ/internal/lungs/vox

	gasses = list(
		new /datum/lung_gas/metabolizable(GAS_NITROGEN,          min_pp=16, max_pp=140),
		new /datum/lung_gas/waste(GAS_CARBON,            max_pp=10), // I guess? Ideally it'd be some sort of nitrogen compound.  Maybe N2O?
		new /datum/lung_gas/toxic(OXYGEN,                    max_pp=0.5, max_pp_mask=0, reagent_id=OXYGEN, reagent_mult=0.1),
		new /datum/lung_gas/toxic(GAS_PLASMA,                    max_pp=0.5, max_pp_mask=5, reagent_id=PLASMA, reagent_mult=0.1),
		new /datum/lung_gas/sleep_agent(GAS_SLEEPING, min_giggle_pp=0.15, min_para_pp=1, min_sleep_pp=5),
	)


/datum/organ/internal/lungs/plasmaman
	name = "\improper Plasmaman lungs"
	removed_type = /obj/item/organ/internal/lungs/plasmaman

	gasses = list(
		new /datum/lung_gas/metabolizable(GAS_PLASMA, min_pp=16, max_pp=140),
		new /datum/lung_gas/waste(GAS_CARBON,         max_pp=10),
		new /datum/lung_gas/sleep_agent(GAS_SLEEPING, min_giggle_pp=0.15, min_para_pp=1, min_sleep_pp=5),
	)

/datum/organ/internal/lungs/insectoid
	name = "\improper Insectoid lungs"
	removed_type = /obj/item/organ/internal/lungs/insectoid

	gasses = list(
		new /datum/lung_gas/metabolizable(OXYGEN, min_pp=16, max_pp=140),
		new /datum/lung_gas/waste(GAS_CARBON,         max_pp=10),
		new /datum/lung_gas/sleep_agent(GAS_SLEEPING, min_giggle_pp=0.15, min_para_pp=1, min_sleep_pp=5),
	)

