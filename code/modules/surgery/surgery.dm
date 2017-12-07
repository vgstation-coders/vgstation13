/* SURGERY STEPS */

/datum/surgery_step
	var/priority = 0	//steps with higher priority would be attempted first

	// type path referencing tools that can be used for this step, and how well are they suited for it
	var/list/allowed_tools = null
	// type paths referencing mutantraces that this step applies to.
	var/list/allowed_species = null
	var/list/disallowed_species = null

	// duration of the step
	var/min_duration = 0
	var/max_duration = 0

	var/list/mob/doing_surgery = list() //who's doing this RIGHT NOW

	// evil infection stuff that will make everyone hate me
	var/can_infect = 0
	//How much blood this step can get on surgeon. 1 - hands, 2 - full body.
	var/blood_level = 0


	//returns how well tool is suited for this step
/datum/surgery_step/proc/tool_quality(obj/item/tool)
	for (var/T in allowed_tools)
		if (istype(tool,T))
			return allowed_tools[T]
	return 0

/datum/surgery_step/proc/check_anesthesia(var/mob/living/carbon/human/target)
	if(target.sleeping > 0 || target.stat)
		return 1
	if(!target.feels_pain())
		return 1
	if(target.pain_numb || prob(target.pain_tolerance + UNMEDICATED_PAIN_TOLERANCE)) // Pain is tolerable?  Pomf wanted this. - N3X | How about painkillers? - Carlen
		return 1

	return 0

	// Checks if this step applies to the mutantrace of the user.
/datum/surgery_step/proc/is_valid_mutantrace(mob/living/carbon/human/target)
	if(!hasorgans(target))
		return 0

	if(allowed_species)
		for(var/species in allowed_species)
			if(target.dna.mutantrace == species)
				return 1

	if(disallowed_species)
		for(var/species in disallowed_species)
			if (target.dna.mutantrace == species)
				return 0

	return 1

	// checks whether this step can be applied with the given user and target
/datum/surgery_step/proc/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return 0

	// does stuff to begin the step, usually just printing messages. Moved germs transfering and bloodying here too
/datum/surgery_step/proc/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	if(!affected)
		return 0
	if (can_infect && affected)
		spread_germs_to_organ(affected, user)
	if (ishuman(user) && prob(60))
		var/mob/living/carbon/human/H = user
		if (blood_level)
			H.bloody_hands(target,0)
		if (blood_level > 1)
			H.bloody_body(target,0)
	if(istype(tool,/obj/item/weapon/scalpel/laser) || istype(tool,/obj/item/weapon/retractor/manager))
		tool.icon_state = "[initial(tool.icon_state)]_on"
		spawn(max_duration * tool.surgery_speed)//in case the player doesn't go all the way through the step (if he moves away, puts the tool away,...)
			tool.icon_state = "[initial(tool.icon_state)]_off"
	return

	// does stuff to end the step, which is normally print a message + do whatever this step changes
/datum/surgery_step/proc/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(istype(tool,/obj/item/weapon/scalpel/laser) || istype(tool,/obj/item/weapon/retractor/manager))
		tool.icon_state = "[initial(tool.icon_state)]_off"
	return

	// stuff that happens when the step fails
/datum/surgery_step/proc/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return null

proc/spread_germs_to_organ(datum/organ/external/E, mob/living/carbon/human/user)
	if(!istype(user) || !istype(E))
		return

	var/germ_level = user.germ_level
	if(user.gloves)
		germ_level = user.gloves.germ_level
	if(!(E.status & (ORGAN_ROBOT|ORGAN_PEG))) //Germs on robotic limbs bad
		E.germ_level = max(germ_level,E.germ_level) //as funny as scrubbing microbes out with clean gloves is - no.

// Cancel/clear a pre-flight
proc/unready_surgery(obj/item/tool)
	tool._surgery_preflight = FALSE
	tool._surgery_preflight_M = null
	tool._surgery_preflight_user = null
	tool._surgery_preflight_surface_stability = null
	return TRUE

// Check if the mob is ready for surgery and pre-flight if it is while returning the chance
proc/ready_for_surgery(mob/living/M, mob/living/user, obj/item/tool)
	var/surface_stability = check_if_ready_for_surgery(M, user, tool)
	if(surface_stability)
		tool._surgery_preflight = TRUE
		tool._surgery_preflight_M = M
		tool._surgery_preflight_user = user
		tool._surgery_preflight_surface_stability = surface_stability
		return TRUE
	return FALSE

// Tentively check if the mob is ready for surgery and return the chance
proc/check_if_ready_for_surgery(mob/living/M, mob/living/user, obj/item/tool)
	if(user == M) // Can't do surgery on yourself (yet)
		return FALSE
	if(!istype(M,/mob/living/carbon/human))
		return FALSE
	if(!(ishuman(M) && M.lying))
		return FALSE
	if(CAN_DO_SURGERY_ON_DISARM_GRAB_INTENT)
		if(user.a_intent == I_HURT)
			return FALSE
	else
		if(user.a_intent != I_HELP)
			return FALSE
	return find_working_surface_at_mob(M, ALLOWED_MEDICAL_WORK_SURFACES)

proc/do_surgery(mob/living/M = null, mob/living/user = null, obj/item/tool)
	var/surface_stability = 0
	if(tool._surgery_preflight)
		M = tool._surgery_preflight_M
		user = tool._surgery_preflight_user
		surface_stability = tool._surgery_preflight_surface_stability
		unready_surgery(tool)
	else
		surface_stability = check_if_ready_for_surgery(M,user,tool)
		if(!surface_stability)
			return FALSE

	if(!M || !user || !tool)
		error("BUG? do_surgery was called without a mob, user, and/or tool. A tool isn't doing a pre-flight correctly? M = [M], user = [user], tool = [tool]")
		if(M)
			to_chat(M, "<span class='sinister'>You sense that something tried to hit you, but...something in the world feels like it has broken. You feel the urge to seek the gods.</span>")
		if(user)
			to_chat(user, "<span class='sinister'>You try to hit something, but...something in the world feels like it has broken. You feel the urge to seek the gods.</span>")
		return FALSE

	// VOTE! Should surgery even proceed if there's a suit in the way?
	var/cover = can_medicate_through_obstruction(user, M)
	if(cover)
		to_chat(user, "<span class='warning'>You can't use \the [tool] through \the [cover]!</span>")
		return TRUE

	var/clumsy = 0
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		clumsy = ((M_CLUMSY in H.mutations) && prob(50))
	for(var/datum/surgery_step/S in surgery_steps)
		//check if tool is right or close enough and if this step is possible
		if(S.tool_quality(tool))
			var/canuse = S.can_use(user, M, user.zone_sel.selecting, tool)
			if(canuse && S.is_valid_mutantrace(M) && !(M in S.doing_surgery))
				M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had surgery [S.type] with \the [tool] started by [user.name] ([user.ckey])</font>")
				user.attack_log += text("\[[time_stamp()]\] <font color='red'>Started surgery [S.type] with \the [tool] on [M.name] ([M.ckey])</font>")
				log_attack("<font color='red'>[user.name] ([user.ckey]) used \the [tool] to perform surgery type [S.type] on [M.name] ([M.ckey])</font>")
				S.doing_surgery += M
				S.begin_step(user, M, user.zone_sel.selecting, tool)		//start on it
				var/selection = user.zone_sel.selecting
				var/anesthesia_fail = !S.check_anesthesia(M) // Check if the patient is able to feel pain right now. You should not be able to operate safely when they're awake.
				var/success_chance = surface_stability * ( (S.tool_quality(tool)/100) / (anesthesia_fail + clumsy + 1) )
				//We had proper tools! (or RNG smiled.) and user did not move or change hands.
				if(do_mob(user, M, rand(S.min_duration, S.max_duration) * tool.surgery_speed) && prob(success_chance) && selection == user.zone_sel.selecting)
					M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had surgery [S.type] with \the [tool] successfully completed by [user.name] ([user.ckey])</font>")
					user.attack_log += text("\[[time_stamp()]\] <font color='red'>Successfully completed surgery [S.type] with \the [tool] on [M.name] ([M.ckey])</font>")
					log_attack("<font color='red'>[user.name] ([user.ckey]) used \the [tool] to successfully complete surgery type [S.type] on [M.name] ([M.ckey])</font>")
					S.end_step(user, M, user.zone_sel.selecting, tool)		//finish successfully
				else
					if ((tool in user.contents) && (user.Adjacent(M)))											//or
						M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had surgery [S.type] with \the [tool] failed by [user.name] ([user.ckey])</font>")
						user.attack_log += text("\[[time_stamp()]\] <font color='red'>Failed surgery [S.type] with \the [tool] on [M.name] ([M.ckey])</font>")
						log_attack("<font color='red'>[user.name] ([user.ckey]) used \the [tool] to fail the surgery type [S.type] on [M.name] ([M.ckey])</font>")
						S.fail_step(user, M, user.zone_sel.selecting, tool)		//malpractice~
						if(anesthesia_fail)
							to_chat(user, "<span class='warning'>The patient is squirming around in pain!</span>")
							M.emote("scream",,, 1)
						else if (surface_stability != PERCENT_SUITABLE_MEDICAL_WORKSPACE)
							to_chat(user, "<span class='warning'>This working surface isn't stable!</span>")

				if(M) //good, we still exist
					S.doing_surgery -= M
				else
					S.doing_surgery.Remove(null)	//get rid of that now null reference
				return	TRUE	  					//don't want to do weapony things after surgery
	if (CAN_DO_SURGERY_ON_DISARM_GRAB_INTENT)
		if (user.a_intent != I_HELP)
			to_chat(user, "<span class='orange italics'>You refrain yourself</span> <span class='warning'>before noticing you see no useful way to use \the [tool] on \the [M].</span>")
		else
			to_chat(user, "<span class='notice italics'>You want to help</span> <span class='warning'>but you can't see any useful way to use \the [tool] on \the [M].</span>")
	else
		to_chat(user, "<span class='warning'>You can't see any useful way to use \the [tool] on \the [M].</span>")
	return TRUE

proc/sort_surgeries()
	var/gap = surgery_steps.len
	var/swapped = 1
	while (gap > 1 || swapped)
		swapped = 0
		if(gap > 1)
			gap = round(gap / 1.247330950103979)
		if(gap < 1)
			gap = 1
		for(var/i = 1; gap + i <= surgery_steps.len; i++)
			var/datum/surgery_step/l = surgery_steps[i]		//Fucking hate
			var/datum/surgery_step/r = surgery_steps[gap+i]	//how lists work here
			if(l.priority < r.priority)
				surgery_steps.Swap(i, gap + i)
				swapped = 1

/datum/surgery_status/
	var/eyes	=	0
	var/face	=	0
	var/appendix =	0
	var/ribcage = 0
	var/butt = 0
	var/butt_replace = 0
	var/genitals = 0
	var/head_reattach = 0
	var/tooth_replace = 0
	var/tooth_extract = 0
	var/current_organ
