/datum/organ
	var/name = "organ"
	var/mob/living/carbon/human/owner = null
	var/status = 0
	var/vital //Lose a vital limb, die immediately.

	var/list/datum/autopsy_data/autopsy_data = list()
	var/list/trace_chemicals = list() //Traces of chemicals in the organ,
									  //Links chemical IDs to number of ticks for which they'll stay in the blood

	var/germ_level = 0 //INTERNAL germs inside the organ, this is BAD if it's greater than INFECTION_LEVEL_ONE

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
	var/antibiotics = owner.reagents.get_reagent_amount("spaceacillin")

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

/mob/living/carbon/human/proc/can_use_hand(var/this_hand = hand)
	if(hasorgans(src))
		var/datum/organ/external/temp = src.organs_by_name[(this_hand ? "l_hand" : "r_hand")]
		if(temp && !temp.is_usable())
			return
		else if (!temp)
			return
	return 1

//Takes care of organ related updates, such as broken and missing limbs
/mob/living/carbon/human/proc/handle_organs()


	number_wounds = 0
	var/stand_broken = 0 //We cannot stand because one of our legs or foot is completely broken and unsplinted, or missing
	var/force_process = 0
	var/damage_this_tick = getBruteLoss() + getFireLoss() + getToxLoss()
	if(damage_this_tick > last_dam)
		force_process = 1
	last_dam = damage_this_tick
	if(force_process)
		bad_external_organs.len = 0
		for(var/datum/organ/external/Ex in organs)
			bad_external_organs += Ex

	//Processing internal organs is pretty cheap, do that first.
	for(var/datum/organ/internal/I in internal_organs)
		I.process()

	//Also handles some internal organ processing when the organs are missing completely.
	//Only handles missing liver and kidneys for now.
    //This is a bit harsh, but really if you're missing an entire bodily organ you're in deep shit.
	if(species.has_organ["liver"])
		var/datum/organ/internal/liver = internal_organs_by_name["liver"]
		if(!liver || liver.status & ORGAN_CUT_AWAY)
			reagents.add_reagent("toxin", rand(1, 3))

	if(species.has_organ["kidneys"])
		var/datum/organ/internal/kidney = internal_organs_by_name["kidneys"]
		if(!kidney || kidney.status & ORGAN_CUT_AWAY)
			reagents.add_reagent("toxin", rand(1, 3))

	if(!force_process && !bad_external_organs.len)
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
			if(E.name in list("l_hand","l_arm","r_hand", "r_arm") && (E.is_broken() || E.is_malfunctioning()))
				var/obj/item/c_hand	//Getting what's in this hand
				if(E.name == "l_hand" || E.name == "l_arm")
					c_hand = l_hand
				if(E.name == "r_hand" || E.name == "r_arm")
					c_hand = r_hand

				E.process_grasp(c_hand, E.name) //See organ_external.dm for helper proc

			//Special effects for legs and foot
			else if(E.name in list("l_leg", "l_foot", "r_leg", "r_foot") && !lying)
				if(E.is_malfunctioning() || E.is_broken())
					stand_broken = 1 //We can't stand like this

	//We risk falling because stuff is broken bad
	if(stand_broken && !paralysis && !(lying || resting) && prob(5))
		if(species && species.flags & NO_PAIN)
			emote("scream", , , 1)
		emote("collapse")
		Paralyse(10)

	//Check arms and legs for existence
	var/canstand_l = 1
	var/canstand_r = 1
	var/legispeg_l = 0
	var/legispeg_r = 0
	var/hasleg_l =   1 //Have left leg
	var/hasleg_r =   1 //Have right leg
	var/hasarm_l =   1 //Have left arm
	var/hasarm_r =   1 //Have right arm
	//var/datum/organ/external/E = organs_by_name["l_foot"]
	var/datum/organ/external/E
	E = organs_by_name["l_leg"]
	if(!E.is_usable()) //The leg is missing, that's going to throw a wrench into our plans
		canstand_l = 0
		hasleg_l = 0
	legispeg_l = E.is_peg() //Need to check this here for the feet

	E = organs_by_name["r_leg"]
	if(!E.is_usable())
		canstand_r = 0
		hasleg_r = 0
	legispeg_r = E.is_peg()

	//We can stand if we're on a peg leg, otherwise same logic.
	E = organs_by_name["l_foot"]
	if(!E.is_usable() && !legispeg_l)
		canstand_l = 0
	E = organs_by_name["r_foot"]
	if(!E.is_usable() && !legispeg_r)
		canstand_r = 0
	E = organs_by_name["l_arm"]
	if(!E.is_usable())
		hasarm_l = 0
	E = organs_by_name["r_arm"]
	if(!E.is_usable())
		hasarm_r = 0

	//Can stand if we have both of our legs (with leg and foot parts present, or an entire pegleg)
	//Has limbs to move around if at least one arm or leg is at least partially there
	can_stand = (canstand_l && canstand_r)
	has_limbs = hasleg_l || hasleg_r || hasarm_l || hasarm_r
