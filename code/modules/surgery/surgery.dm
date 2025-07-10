/* SURGERY STEPS */

/datum/surgery_step
	var/priority = 0	//steps with higher priority would be attempted first

	// type path referencing tools that can be used for this step, and how well are they suited for it
	var/list/allowed_tools = null
	// type paths referencing mutantraces that this step applies to.
	var/list/allowed_species = null
	var/list/disallowed_species = null

	var/duration = 0
	var/list/mob/doing_surgery = list() //who's doing this RIGHT NOW

	// evil infection stuff that will make everyone hate me
	var/can_infect = 0
	//How much blood this step can get on surgeon. 1 - hands, 2 - full body.
	var/blood_level = 0
	//Whether or not the sound played will be a digging sound or the surgery sound designated by the tools used.
	var/digging = FALSE

	//returns how well tool is suited for this step
/datum/surgery_step/proc/tool_quality(obj/item/tool, mob/living/user)
	for (var/T in allowed_tools)
		if (!istext(T) && istype(tool,T))
			return allowed_tools[T]
		if (!istype(tool,/obj/item))
			continue
		if (T == "screwdriver" && tool.is_screwdriver(user))
			return allowed_tools[T]
		if (T == "wrench" && tool.is_wrench(user))
			return allowed_tools[T]
		if (T == "wirecutter" && tool.is_wirecutter(user))
			return allowed_tools[T]
	return 0

/datum/surgery_step/proc/check_anesthesia(var/mob/living/carbon/human/target)
	if(target.sleeping > 0 || target.stat)
		return 1
	if(!target.feels_pain())
		return 1
	if(prob(25)) // Pain is tolerable?  Pomf wanted this. - N3X
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

	if((!(affected.status & (ORGAN_ROBOT|ORGAN_PEG))) && !affected.cosmetic_only)//robot organs and pegs can't spread diseases or splatter blood
		var/block = user.check_contact_sterility(HANDS)
		var/bleeding = user.check_bodypart_bleeding(HANDS)
		target.oneway_contact_diseases(user,block,bleeding)//potentially spreads diseases from us to them, wear latex gloves!

		if (ishuman(user) && prob(60))
			var/mob/living/carbon/human/H = user
			if (blood_level)
				H.bloody_hands(target, 2)//potentially spreads diseases from them to us, wear latex gloves!
			if (blood_level > 1)
				H.bloody_body(target, 0)//potentially spreads diseases from them to us, wear a bio suit, or at least a labcoat!

	if(istype(tool,/obj/item/tool/scalpel/laser) || istype(tool,/obj/item/tool/retractor/manager))
		tool.icon_state = "[initial(tool.icon_state)]_on"
		spawn(duration * tool.toolspeed)//in case the player doesn't go all the way through the step (if he moves away, puts the tool away,...)
			tool.icon_state = "[initial(tool.icon_state)]_off"

	if((M_CLUMSY in user.mutations) && prob(20))
		if ((istype(tool, /obj/item/tool/circular_saw)) || (istype(tool, /obj/item/tool/surgicaldrill)))
			return
		else
			var/clownsound = null
			clownsound = pick("toysqueak","partyhorn","bikehorn","quack")
			playsound(target, "sound/items/[clownsound].ogg", 75, 2)
	else
		if(digging)
			playsound(target, 'sound/items/hemostatdig.ogg', 75, 1)
		else
			tool.playsurgerysound(target, 75, 1)

	return

	// does stuff to end the step, which is normally print a message + do whatever this step changes
/datum/surgery_step/proc/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(istype(tool,/obj/item/tool/scalpel/laser) || istype(tool,/obj/item/tool/retractor/manager))
		tool.icon_state = "[initial(tool.icon_state)]_off"
	return

	// stuff that happens when the step fails
/datum/surgery_step/proc/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return null

/proc/spread_germs_to_organ(datum/organ/external/E, mob/living/carbon/human/user)
	if(!istype(user) || !istype(E) || E.cosmetic_only)
		return

	var/germ_level = user.germ_level
	if(user.gloves)
		germ_level = user.gloves.germ_level
	if(!(E.status & (ORGAN_ROBOT|ORGAN_PEG))) //Germs on robotic limbs bad
		E.germ_level = max(germ_level,E.germ_level) //as funny as scrubbing microbes out with clean gloves is - no.

/proc/do_surgery(mob/living/M, mob/living/user, obj/item/tool, var/success_override = SURGERY_SUCCESS_NORMAL)
	if(!ishuman(M) && !isslime(M))
		return 0
	if (user.a_intent == I_HURT)	//check for Hippocratic Oath
		return 0
	var/sleep_fail = 0
	var/clumsy = 0
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		clumsy = (tool.clumsy_check(H) && prob(50))
	if (!user.dexterity_check())
		clumsy = 1

	var/target_area = user.zone_sel ? user.zone_sel.selecting : get_random_zone_sel()
	for(var/datum/surgery_step/S in surgery_steps)
		//check if tool is right or close enough and if this step is possible
		sleep_fail = 0
		if(S.tool_quality(tool, user))
			var/canuse = S.can_use(user, M, target_area, tool)
			if(canuse == -1)
				sleep_fail = 1
			if(canuse && S.is_valid_mutantrace(M) && !(M in S.doing_surgery))
				if(!can_operate(M, user))//never give the tool as 3rd arg here or you might cause an infinite loop
					return 1
				M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had surgery [S.type] with \the [tool] started by [user.name] ([user.ckey])</font>")
				user.attack_log += text("\[[time_stamp()]\] <font color='red'>Started surgery [S.type] with \the [tool] on [M.name] ([M.ckey])</font>")
				log_attack("<font color='red'>[user.name] ([user.ckey]) used \the [tool] to perform surgery type [S.type] on [M.name] ([M.ckey])</font>")
				S.doing_surgery += M
				S.begin_step(user, M, target_area, tool)		//start on it

				var/selection = user.zone_sel ? user.zone_sel.selecting : null //Check if the zone selection hasn't changed
				//We had proper tools! (or RNG smiled.) and user did not move or change hands.
				if(do_mob(user, M, S.duration * tool.toolspeed) && (success_override == SURGERY_SUCCESS_ALWAYS || (success_override == SURGERY_SUCCESS_NORMAL && (prob(S.tool_quality(tool, user) / (sleep_fail + clumsy + 1))))) && (!user.zone_sel || selection == user.zone_sel.selecting)) //Last part checks whether the zone selection hasn't changed
					M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had surgery [S.type] with \the [tool] successfully completed by [user.name] ([user.ckey])</font>")
					user.attack_log += text("\[[time_stamp()]\] <font color='red'>Successfully completed surgery [S.type] with \the [tool] on [M.name] ([M.ckey])</font>")
					log_attack("<font color='red'>[user.name] ([user.ckey]) used \the [tool] to successfully complete surgery type [S.type] on [M.name] ([M.ckey])</font>")
					S.end_step(user, M, target_area, tool)		//finish successfully
				else
					if(sleep_fail)
						to_chat(user, "<span class='warning'>The patient is squirming around in pain!</span>")
						M.audible_scream()
					M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had surgery [S.type] with \the [tool] failed by [user.name] ([user.ckey])</font>")
					user.attack_log += text("\[[time_stamp()]\] <font color='red'>Failed surgery [S.type] with \the [tool] on [M.name] ([M.ckey])</font>")
					log_attack("<font color='red'>[user.name] ([user.ckey]) used \the [tool] to fail the surgery type [S.type] on [M.name] ([M.ckey])</font>")
					S.fail_step(user, M, target_area, tool)		//malpractice~
				if(M) //good, we still exist
					S.doing_surgery -= M
				else
					S.doing_surgery.Remove(null) //get rid of that now null reference
				return	1	  												//don't want to do weapony things after surgery
	if (user.a_intent == I_HELP)
		to_chat(user, "<span class='warning'>You can't see any useful way to use [tool] on [M].</span>")
		return 1
	return 0

/proc/sort_surgeries()
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

/datum/surgery_status
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
