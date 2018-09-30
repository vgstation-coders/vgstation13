// Lung upgrade
/datum/organ/internal/lungs/filter
	name = "advanced lungs"
	removed_type = /obj/item/organ/internal/lungs/filter

	min_bruised_damage = 15
	min_broken_damage = 30

	gasses = list()
	var/list/intake_settings=list(
		GAS_OXYGEN = list(
			new /datum/lung_gas/metabolizable(GAS_OXYGEN,            min_pp=16, max_pp=280),
			new /datum/lung_gas/waste(GAS_CARBON,            max_pp=10),
			new /datum/lung_gas/toxic(GAS_PLASMA,                    max_pp=5, max_pp_mask=0, reagent_id="plasma", reagent_mult=0.1),
			new /datum/lung_gas/sleep_agent(GAS_SLEEPING, min_giggle_pp=1, min_para_pp=5, min_sleep_pp=10),
		),
		GAS_NITROGEN = list(
			new /datum/lung_gas/metabolizable(GAS_NITROGEN,          min_pp=16, max_pp=280),
			new /datum/lung_gas/waste(GAS_CARBON,            	max_pp=10), // I guess? Ideally it'd be some sort of nitrogen compound.  Maybe N2O?
			new /datum/lung_gas/toxic(GAS_OXYGEN,                    max_pp=0.5, max_pp_mask=0, reagent_id=GAS_OXYGEN, reagent_mult=0.1),
			new /datum/lung_gas/sleep_agent(GAS_SLEEPING, min_giggle_pp=1, min_para_pp=5, min_sleep_pp=10),
		),
		GAS_PLASMA = list(
			new /datum/lung_gas/metabolizable(GAS_PLASMA, min_pp=16, max_pp=280),
			new /datum/lung_gas/waste(GAS_OXYGEN,         max_pp=10),
			new /datum/lung_gas/sleep_agent(GAS_SLEEPING, min_giggle_pp=1, min_para_pp=5, min_sleep_pp=10),
		)
	)

/datum/organ/internal/lungs/filter/CanInsert(var/mob/living/carbon/human/H, var/mob/surgeon=null, var/quiet=0)
	if(!(H.species.breath_type in intake_settings))
		if(surgeon)
			to_chat(surgeon, "<span class='warning'>You read the compatibility list on the back of the lung and find that it won't work on this species.</span>")
		return 0
	return 1

/datum/organ/internal/lungs/filter/Insert(var/mob/living/carbon/human/H, var/mob/surgeon=null, var/quiet=0)
	if(!quiet)
		H.visible_message("<span class='info'>\The [name] clicks as it adjusts to their body's metabolism.</span>", "<span class='info'>You feel something click in your chest.</span>", "<span class='warning'>You hear a click.</span>")
	gasses=intake_settings[H.species.breath_type]
	return 1
