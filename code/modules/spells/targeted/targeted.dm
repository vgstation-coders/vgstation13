/*
Targeted spells (with the exception of dumbfire) select from all the mobs in the defined range
Targeted spells have two useful flags: INCLUDEUSER and SELECTABLE. These are explained in setup.dm
*/


/spell/targeted //can mean aoe for mobs (limited/unlimited number) or one target mob
	spell_flags = SELECTABLE
	user_type = USER_TYPE_NOUSER
	var/max_targets = 1 //leave 0 for unlimited targets in range, more for limited number of casts (can all target one guy, depends on target_ignore_prev) in range
	var/target_ignore_prev = 1 //only important if max_targets > 1, affects if the spell can be cast multiple times at one person from one cast


	var/amt_knockdown = 0
	var/amt_paralysis = 0
	var/amt_stunned = 0

	var/amt_dizziness = 0
	var/amt_confused = 0
	var/amt_stuttering = 0

		//set to negatives for healing
	var/amt_dam_fire = 0
	var/amt_dam_brute = 0
	var/amt_dam_oxy = 0
	var/amt_dam_tox = 0
	var/amt_dam_brain = 0

	var/amt_eye_blind = 0
	var/amt_eye_blurry = 0
	var/mind_affecting = 0 //Determines if it can be blocked by PSY_RESIST or tinfoil hat

	var/list/compatible_mobs = list()
	var/believed_name

/spell/targeted/is_valid_target(var/target, mob/user, list/options)
	if(!(spell_flags & INCLUDEUSER) && target == user)
		return 0
	if(!(range == GLOBALCAST) && !(range == SELFCAST && target == user) && (options && !(target in options))) //Shouldn't be necessary but a good check in case of overrides
		return 0
	if(mind_affecting && !user.can_mind_interact(target))
		return 0
	return !compatible_mobs.len || is_type_in_list(target, compatible_mobs)

/spell/targeted/choose_targets(mob/user = usr)
	if(mind_affecting && tinfoil_check(user))
		to_chat(user, "<span class='warning'>Something is interfering with your ability to target minds.</span>")
		return
	var/list/targets = list()
	if(max_targets == 0) //unlimited
		if(range == -2)
			targets = living_mob_list
		else
			for(var/mob/living/target in view_or_range(range, holder, selection_type))
				targets += target

	else if(max_targets == 1) //single target can be picked
		if(spell_flags & TALKED_BEFORE)
			if(!user || !user.mind || !user.mind.heard_before.len)
				return
			var/target_name = input(user, "Choose the target, from those whose voices you've heard before.", "Targeting") in user.mind.heard_before
			var/mob/temp_target = user.mind.heard_before[target_name]
			believed_name = target_name
			targets += temp_target
		else if((range == 0 || range == SELFCAST) && (spell_flags & INCLUDEUSER))
			targets += user
		else
			var/list/possible_targets = list()
			var/list/starting_targets
			if(range == GLOBALCAST)
				starting_targets = living_mob_list
			else
				starting_targets = view_or_range(range, holder, selection_type)

			for(var/mob/living/M in starting_targets)
				if(!(spell_flags & INCLUDEUSER) && M == user)
					continue
				if(compatible_mobs && compatible_mobs.len)
					if(!is_type_in_list(M, compatible_mobs))
						continue
				if(compatible_mobs && compatible_mobs.len && !is_type_in_list(M, compatible_mobs))
					continue
				if(mind_affecting)
					if(iscarbon(user))
						var/mob/living/carbon/C = user
						if(!C.can_mind_interact(M))
							continue
				possible_targets += M

			if(possible_targets.len)
				if(spell_flags & SELECTABLE) //if we are allowed to choose. see setup.dm for details
					var/mob/temp_target = input(user, "Choose the target for the spell.", "Targeting") as null|mob in possible_targets
					if(temp_target)
						targets += temp_target
				else
					targets += pick(possible_targets)
			//Adds a safety check post-input to make sure those targets are actually in range.


	else
		var/list/possible_targets = list()
		var/list/starting_targets

		if(range == -2)
			starting_targets = living_mob_list
		else
			starting_targets = view_or_range(range, holder, selection_type)

		for(var/mob/living/target in starting_targets)
			if(!(spell_flags & INCLUDEUSER) && target == user)
				continue
			if(compatible_mobs && !is_type_in_list(target, compatible_mobs))
				continue
			possible_targets += target

		if(spell_flags & SELECTABLE)
			for(var/i = 1; i<=max_targets, i++)
				if(!possible_targets.len)
					break
				var/mob/M = input(user, "Choose the target for the spell.", "Targeting") as null|mob in possible_targets
				if(!M)
					break
				if(range != -2)
					if(!(M in view_or_range(range, holder, selection_type)))
						continue
				targets += M
				possible_targets -= M
		else
			for(var/i=1,i<=max_targets,i++)
				if(!possible_targets.len)
					break
				if(target_ignore_prev)
					var/target = pick(possible_targets)
					possible_targets -= target
					targets += target
				else
					targets += pick(possible_targets)

	if(!(spell_flags & INCLUDEUSER) && (user in targets))
		targets -= user

	if(compatible_mobs && compatible_mobs.len)
		for(var/mob/living/target in targets) //filters out all the non-compatible mobs
			if(!is_type_in_list(target, compatible_mobs))
				targets -= target

	return targets

/spell/targeted/cast(var/list/targets, mob/user)
	for(var/mob/living/target in targets)
		if(range >= 0)
			if(!(target in view_or_range(range, holder, selection_type))) //filter at time of casting
				targets -= target
				continue
		apply_spell_damage(target)

/spell/targeted/proc/apply_spell_damage(mob/living/target)
	target.adjustBruteLoss(amt_dam_brute)
	target.adjustFireLoss(amt_dam_fire)
	target.adjustToxLoss(amt_dam_tox)
	target.adjustOxyLoss(amt_dam_oxy)
	target.adjustBrainLoss(amt_dam_brain)
	//disabling
	target.Knockdown(amt_knockdown)
	target.Paralyse(amt_paralysis)
	target.Stun(amt_stunned)
	if(amt_knockdown || amt_paralysis || amt_stunned)
		target.unlock_from()
	target.eye_blind += amt_eye_blind
	target.eye_blurry += amt_eye_blurry
	target.dizziness += amt_dizziness
	target.confused += amt_confused
	target.confused_intensity = CONFUSED_MAGIC
	target.stuttering += amt_stuttering

/spell/targeted/proc/tinfoil_check(mob/living/carbon/human/user)
	if(!istype(user))
		return 0

	if(user.head && istype(user.head,/obj/item/clothing/head/tinfoil))
		return 1

	return 0
