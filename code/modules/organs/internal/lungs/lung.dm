
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
		new /datum/lung_gas/radioactive(GAS_RADON,      max_pp=0.1, max_pp_mask=5, radspermole=3),

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

/datum/organ/internal/lungs/proc/is_ruptured()
	return is_bruised()

/datum/organ/internal/lungs/proc/rupture()
	if(!is_bruised())
		owner.custom_pain("You feel a stabbing pain in your chest!", 1)
		damage = min_bruised_damage

/datum/organ/internal/lungs/proc/handle_breath(var/datum/gas_mixture/breath)

	// NOW WITH MODULAR GAS HANDLING RATHER THAN A CLUSTERFUCK OF IF-TREES FOR EVERY SNOWFLAKE RACE
	//testing("Ticking lungs...")

	if(!breath || (breath.total_moles() == 0) || (owner.mind?.suiciding))
		if(owner.reagents?.has_any_reagents(list(INAPROVALINE,PRESLOMITE)))
			return
		if(owner.mind?.suiciding)
			owner.adjustOxyLoss(2) //If you are suiciding, you should die a little bit faster
			owner.failed_last_breath = 1
			owner.oxygen_alert = 1
			return
		if(owner.health > config.health_threshold_crit)
			owner.adjustOxyLoss(HUMAN_MAX_OXYLOSS)
		else
			owner.adjustOxyLoss(HUMAN_CRIT_MAX_OXYLOSS)
		owner.failed_last_breath = 1
		owner.oxygen_alert = 1
		if(!breath)
			return

	if(breath.total_moles < BREATH_MOLES / 5 || breath.total_moles > BREATH_MOLES * 5)
		if(prob(20))
			take_damage(1,1)
		if(!owner.is_lung_ruptured() && damage > 2)
			var/chance_break = (damage / min_broken_damage)*100
			if(prob(chance_break))
				rupture()

	//Do this to make sure the pressure is correct.
	breath.volume = inhale_volume
	breath.update_values()

	// Instantiate a variable to determine if we should show the player a toxins_alert
	var/toxic_gas_detected = FALSE

	// First, we consume air.
	for(var/datum/lung_gas/G in gasses)
		G.set_context(src,breath,owner)
		toxic_gas_detected |= G.handle_inhale()

	// Next, we exhale. At the moment, only /datum/lung_gas/waste uses this.
	for(var/datum/lung_gas/G in gasses)
		G.set_context(src,breath,owner)
		G.handle_exhale()

	// If no toxic gas detected, ensure toxins_alert is disabled
	if(!toxic_gas_detected)
		owner.toxins_alert = 0

	if( (abs(310.15 - breath.temperature) > 50) && !(M_RESIST_HEAT in owner.mutations)) // Hot air hurts :(
		if(owner.status_flags & GODMODE)
			return 1	//godmode
		if(breath.temperature < owner.species.cold_level_1)
			if(prob(20))
				to_chat(owner, "<span class='warning'>You feel your face freezing and an icicle forming in your lungs!</span>")
		else if(breath.temperature > owner.species.heat_level_1)
			if(prob(20))
				to_chat(owner, "<span class='warning'>You feel [isslimeperson(owner) ? "supercharged by the extreme heat" : "your face burning and a searing heat in your lungs"]!</span>")

		if(isslimeperson(owner))
			if(breath.temperature < owner.species.cold_level_1)
				owner.adjustToxLoss(round(owner.species.cold_level_1 - breath.temperature))
				owner.fire_alert = max(owner.fire_alert, 1)
		else
			if(breath.temperature in owner.species.cold_level_1 to owner.species.heat_level_1)
				return

			var/applied_damage = null
			var/used_damage_type = ""
			var/fire_alert_level = 0

			if(breath.temperature <= owner.species.cold_level_3)
				applied_damage = COLD_GAS_DAMAGE_LEVEL_3
			else if(breath.temperature <= owner.species.cold_level_2)
				applied_damage = COLD_GAS_DAMAGE_LEVEL_2
			else if(breath.temperature <= owner.species.cold_level_1)
				applied_damage = COLD_GAS_DAMAGE_LEVEL_1
			else if(breath.temperature >= owner.species.heat_level_3)
				applied_damage = HEAT_GAS_DAMAGE_LEVEL_3
			else if(breath.temperature >= owner.species.heat_level_2)
				applied_damage = HEAT_GAS_DAMAGE_LEVEL_2
			else if(breath.temperature >= owner.species.heat_level_1)
				applied_damage = HEAT_GAS_DAMAGE_LEVEL_1

			if(breath.temperature <= owner.species.cold_level_1)
				used_damage_type = "Cold"
				fire_alert_level = 1
			else if(breath.temperature >= owner.species.heat_level_1)
				used_damage_type = "Heat"
				fire_alert_level = 2

			owner.apply_damage(applied_damage, BURN, LIMB_HEAD, used_weapon = "Excessive [used_damage_type]")
			owner.fire_alert = max(owner.fire_alert, fire_alert_level)

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
		new /datum/lung_gas/radioactive(GAS_RADON,      max_pp=0.1, max_pp_mask=5, radspermole=3),
	)


/datum/organ/internal/lungs/plasmaman
	name = "\improper Plasmaman lungs"
	removed_type = /obj/item/organ/internal/lungs/plasmaman

	gasses = list(
		new /datum/lung_gas/metabolizable(GAS_PLASMA, min_pp=16, max_pp=140),
		new /datum/lung_gas/waste(GAS_CARBON,         max_pp=10),
		new /datum/lung_gas/sleep_agent(GAS_SLEEPING, min_giggle_pp=0.15, min_para_pp=1, min_sleep_pp=5),
		new /datum/lung_gas/radioactive(GAS_RADON,      max_pp=0.1, max_pp_mask=5, radspermole=3),
	)

/datum/organ/internal/lungs/insectoid
	name = "\improper Insectoid lungs"
	removed_type = /obj/item/organ/internal/lungs/insectoid

	gasses = list(
		new /datum/lung_gas/metabolizable(OXYGEN, min_pp=16, max_pp=140),
		new /datum/lung_gas/waste(GAS_CARBON,         max_pp=10),
		new /datum/lung_gas/sleep_agent(GAS_SLEEPING, min_giggle_pp=0.15, min_para_pp=1, min_sleep_pp=5),
		new /datum/lung_gas/radioactive(GAS_RADON,      max_pp=0.1, max_pp_mask=5, radspermole=3),
	)

