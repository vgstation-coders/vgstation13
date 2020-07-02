/datum/organ
	var/name = "organ"
	var/mob/living/carbon/human/owner = null
	var/status = 0
	var/vital //Lose a vital limb, die immediately.

	var/list/datum/autopsy_data/autopsy_data = list()
	var/list/trace_chemicals = list() //Traces of chemicals in the organ,
									  //Links chemical IDs to number of ticks for which they'll stay in the blood

	var/germ_level = 0 //INTERNAL germs inside the organ, this is BAD if it's greater than INFECTION_LEVEL_ONE
	var/cancer_stage = 0 //Cancer growth inside the organ, anything above 0 is very bad. See handle_cancer() below

/datum/organ/proc/CanInsert(var/mob/living/carbon/human/H, var/mob/surgeon=null, var/quiet=0)
	return 1
/datum/organ/proc/Insert(var/mob/living/carbon/human/H, var/mob/surgeon=null)
	return 1
/datum/organ/proc/CanRemove(var/mob/living/carbon/human/H, var/mob/surgeon=null, var/quiet=0)
	return 1
/datum/organ/proc/Remove(var/mob/living/carbon/human/H, var/mob/surgeon=null)
	return 1

/datum/organ/Destroy()
	owner = null
	..()

/datum/organ/proc/process()
	return 0

/datum/organ/proc/receive_chem(chemical as obj)
	return 0

/datum/organ/proc/Copy()
	var/datum/organ/I = new type
	I.vital = vital
	I.name = name
	I.owner = owner
	I.status = status
	I.autopsy_data = autopsy_data
	I.trace_chemicals = trace_chemicals
	I.germ_level = germ_level
	return I

/datum/organ/proc/get_icon(var/icon/race_icon, var/icon/deform_icon)
	return icon('icons/mob/human.dmi', "blank")

//Germs
/datum/organ/proc/handle_antibiotics()
	var/antibiotics = owner.reagents.get_reagent_amount(SPACEACILLIN)

	if(!germ_level || antibiotics < 5)
		return

	if(germ_level < INFECTION_LEVEL_ONE)
		germ_level = 0	//Cure instantly
	else if (germ_level < INFECTION_LEVEL_TWO)
		germ_level -= 6	//At germ_level == 500, this should cure the infection in a minute
	else
		germ_level -= 2 //At germ_level == 1000, this will cure the infection in 5 minutes

//Handles chem traces
/mob/living/carbon/human/proc/handle_trace_chems()
	//New are added for reagents to random organs.
	for(var/datum/reagent/A in reagents.reagent_list)
		var/datum/organ/O = pick(organs)
		O.trace_chemicals[A.name] = 100

//Adds autopsy data for used_weapon.
/datum/organ/proc/add_autopsy_data(var/used_weapon, var/damage)
	var/datum/autopsy_data/W = autopsy_data[used_weapon]
	if(!W)
		W = new()
		W.weapon = used_weapon
		autopsy_data[used_weapon] = W

	W.hits += 1
	W.damage += damage
	W.time_inflicted = world.time

/mob/living/carbon/human/var/list/organs = list()
/mob/living/carbon/human/var/list/organs_by_name = list() //Map organ names to organs
/mob/living/carbon/human/var/list/internal_organs_by_name = list() //So internal organs have less ickiness too
/mob/living/carbon/human/var/list/grasp_organs = list()

/mob/living/carbon/human/proc/can_use_hand(var/this_hand = active_hand)
	if(restrained()) // TODO: make a proper system for this ffs
		return FALSE
	if(hasorgans(src))
		var/datum/organ/external/temp = src.find_organ_by_grasp_index(this_hand)
		if(temp && !temp.is_usable())
			return FALSE
		else if (!temp)
			return FALSE
	return TRUE

/mob/living/carbon/human/proc/can_use_hand_or_stump(var/this_hand = active_hand)
	if(restrained()) // handcuffed stump is retarded but let's do that in another PR ok?
		return FALSE
	if(hasorgans(src))
		var/datum/organ/external/hand = src.find_organ_by_grasp_index(this_hand)
		if(hand && hand.can_grasp())
			return TRUE
	return FALSE

//Takes care of organ related updates, such as broken and missing limbs
/mob/living/carbon/human/proc/handle_organs(var/force_process = 0)

	number_wounds = 0
	var/stand_broken = 0 //We cannot stand because one of our legs or foot is completely broken and unsplinted, or missing
	var/damage_this_tick = getBruteLoss() + getFireLoss() + getToxLoss()
	if(damage_this_tick > last_dam)
		force_process = 1
	last_dam = damage_this_tick

	//Processing internal organs is pretty cheap, do that first.
	for(var/datum/organ/internal/I in internal_organs)
		I.process()

	if(force_process) //Force all limbs to be updated, period
		bad_external_organs.len = 0
		for(var/datum/organ/external/Ex in organs)
			bad_external_organs += Ex

	//Cancer check
	for(var/datum/organ/external/Ec in organs)
		if(Ec.cancer_stage)
			Ec.handle_cancer()

	//Also handles some internal organ processing when the organs are missing completely.
	//Only handles missing liver and kidneys for now.
    //This is a bit harsh, but really if you're missing an entire bodily organ you're in deep shit.
	if(species.has_organ["liver"])
		var/datum/organ/internal/liver = internal_organs_by_name["liver"]
		if(!liver || liver.status & ORGAN_CUT_AWAY)
			reagents.add_reagent(TOXIN, rand(1, 3))
		else
			liver.process()

	if(species.has_organ["kidneys"])
		var/datum/organ/internal/kidney = internal_organs_by_name["kidneys"]
		if(!kidney || kidney.status & ORGAN_CUT_AWAY)
			reagents.add_reagent(TOXIN, rand(1, 3))


	var/datum/organ/internal/eyes/eyes = internal_organs_by_name["eyes"]
	if(eyes)
		eyes.process()


	for(var/datum/organ/internal/I in internal_organs)
		if(!(I.status & ORGAN_CUT_AWAY))
			I.Life()

	if(!force_process && !bad_external_organs.len) //Nothing to update, just drop it
		return

	for(var/datum/organ/external/E in bad_external_organs)
		if(!E)
			continue

		if(!E.need_process())
			bad_external_organs -= E
			continue
		else
			E.process()
			number_wounds += E.number_wounds

			//Moving around with fractured ribs won't do you any good
			if(E.is_broken() && E.internal_organs && prob(15))
				if(!lying && world.timeofday - l_move_time < 15)
					var/datum/organ/internal/I = pick(E.internal_organs)
					custom_pain("You feel broken bones moving in your [E.display_name]!", 1)
					I.take_damage(rand(3, 5))

			//Special effects for arms and hands
			//is_usable() is here for sanity, in case we somehow get an item in an unusable hand
			if(E.grasp_id && (E.is_broken() || E.is_malfunctioning()))
				E.process_grasp(held_items[E.grasp_id], get_index_limb_name(E.grasp_id))

			//Special effects for legs and foot
			else if(E.name in list(LIMB_LEFT_LEG, LIMB_LEFT_FOOT, LIMB_RIGHT_LEG, LIMB_RIGHT_FOOT) && !lying)
				if(E.is_malfunctioning() || E.is_broken())
					stand_broken = 1 //We can't stand like this

	//We risk falling because stuff is broken bad
	if(stand_broken && !paralysis && !(lying || resting) && prob(5))
		if(feels_pain())
			audible_scream()
		emote("collapse")
		Paralyse(10)

	can_stand = check_stand_ability()
	has_limbs = check_crawl_ability()

/mob/living/carbon/human/proc/check_stand_ability()
	//All legs must be usable in order for a human to stand
	for(var/datum/organ/external/leg in get_organs(LIMB_LEFT_LEG, LIMB_RIGHT_LEG))
		if(!leg.can_stand())
			return FALSE

	return TRUE

/mob/living/carbon/human/proc/check_crawl_ability()
	//At least one limb has to be usable for a human to crawl
	for(var/datum/organ/external/limb in get_organs(LIMB_LEFT_LEG, LIMB_RIGHT_LEG, LIMB_LEFT_ARM, LIMB_RIGHT_ARM))
		if(limb.is_usable())
			return TRUE

	return FALSE

//Cancer, right now adminbus only
//When triggered, cancer starts growing inside the affected organ. Once it grows worse enough, you start having really serious effects
//When it grows REALLY bad, it just metastates, and then you die really hard. Takes 30 minutes, 25 from firs visible symptoms, so no way you can't anticipate
//For limb-specific effects, check each limb for sub-procs

/datum/organ/proc/handle_cancer()

	if(!cancer_stage) //This limb isn't cancerous, nothing to do in here
		return 1

	if(cancer_stage < CANCER_STAGE_BENIGN) //Abort immediately if the cancer has been suppresed
		return 1

	//List of reagents which will affect cancerous growth
	//Phalanximine and Medical Nanobots are the only reagent which can reverse cancerous growth in high doses, the others can stall it, some can even accelerate it
	//Every "unit" here corresponds to a tick of cancer growth, so for example 20 units of Phalanximine counters one unit of cancer growth
	var/phalanximine = owner.reagents.get_reagent_amount(PHALANXIMINE) / 5 //Phalanximine only works in large doses, but can actually cure cancer past the threshold unlike all other reagents below
	var/medbots = owner.reagents.get_reagent_amount(MEDNANOBOTS) * 2 //Medical nanobots for a cancer-free future tomorrow. Try not to overdose them, powerful enough to not risk going above 5u
	var/hardcores = owner.reagents.get_reagent_amount(BUSTANUT) //Bustanuts contain the very essence of Bustatime, stalling even the most robust ailments with a small dose
	var/ryetalyn = owner.reagents.get_reagent_amount(RYETALYN) //Ryetalin will very easily suppress the rogue DNA in cancer cells, but cannot actually cure it, you need to destroy the cells
	var/holywater = owner.reagents.get_reagent_amount(HOLYWATER) / 10 //Holy water has very potent effects with stalling cancer
	var/mutagen = owner.reagents.get_reagent_amount(MUTAGEN) / 5 //Mutagen will cause disastrous cancer growth if there already is one. It's the virus food of tumors

	var/cancerous_growth = 1 //Every tick, cancer grows by one tick, without any external factors

	cancerous_growth -= min(1, hardcores + holywater + ryetalyn - mutagen) + phalanximine + medbots //Simple enough, mut helps cancer growth, hardcores and holywater stall it, phalanx and medbots cure it
	cancer_stage += cancerous_growth

	if(cancerous_growth <= 0) //No cancerous growth this tick, no effects
		return 1

/datum/organ/send_to_past(var/duration)
	var/static/list/resettable_vars = list(
		"owner",
		"status",
		"autopsy_data",
		"trace_chemicals",
		"germ_level",
		"cancer_stage")

	reset_vars_after_duration(resettable_vars, duration, TRUE)
