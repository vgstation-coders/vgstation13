/*
Targeted spells (with the exception of dumbfire) select from all the mobs in the defined range
Targeted spells have two useful flags: INCLUDEUSER and SELECTABLE. These are explained in setup.dm
*/


/atom/movable/spell/targeted //can mean aoe for mobs (limited/unlimited number) or one target mob
	var/max_targets = 1 //leave 0 for unlimited targets in range, more for limited number of casts (can all target one guy, depends on target_ignore_prev) in range
	var/target_ignore_prev = 1 //only important if max_targets > 1, affects if the spell can be cast multiple times at one person from one cast


	var/amt_weakened = 0
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

	var/amt_eye_blind = 0
	var/amt_eye_blurry = 0

	var/list/compatible_mobs = list()

/atom/movable/spell/targeted/choose_targets(mob/user = usr)
	var/list/targets = list()

	if(max_targets == 0) //unlimited
		for(var/mob/living/target in view_or_range(range, user, selection_type))
			targets += target
		if(1) //single target can be picked
			if(range < 0 && spell_flags & INCLUDEUSER)
				targets += user
			else
				var/possible_targets = list()

				for(var/mob/living/M in view_or_range(range, user, selection_type))
					if(!(spell_flags & INCLUDEUSER) && user == M)
						continue
					possible_targets += M

				//targets += input("Choose the target for the spell.", "Targeting") as mob in possible_targets
				//Adds a safety check post-input to make sure those targets are actually in range.


	else
		var/list/possible_targets = list()

		for(var/mob/living/target in view_or_range(range, user, selection_type))
			possible_targets += target

		if(spell_flags & SELECTABLE)
			for(var/i = 1; i<=max_targets, i++)
				var/mob/M = input("Choose the target for the spell.", "Targeting") as mob in possible_targets
				if(M in view_or_range(range, user, selection_type))
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

	if(compatible_mobs.len)
		for(var/mob/living/target in targets) //filters out all the non-compatible mobs
			var/found = 0
			for(var/mob_type in compatible_mobs)
				if(istype(target, mob_type))
					found = 1
			if(!found)
				targets -= target

	return targets

/atom/movable/spell/targeted/cast(var/list/targets, mob/user)
	for(var/mob/living/target in targets)
		if(!(target in view_or_range(range, user, selection_type))) //filter at time of casting
			targets -= target
			continue
		target.adjustBruteLoss(amt_dam_brute)
		target.adjustFireLoss(amt_dam_fire)
		target.adjustToxLoss(amt_dam_tox)
		target.adjustOxyLoss(amt_dam_oxy)
		//disabling
		target.Weaken(amt_weakened)
		target.Paralyse(amt_paralysis)
		target.Stun(amt_stunned)
		if(amt_weakened || amt_paralysis || amt_stunned)
			if(target.buckled)
				target.buckled.unbuckle()
		target.eye_blind += amt_eye_blind
		target.eye_blurry += amt_eye_blurry
		target.dizziness += amt_dizziness
		target.confused += amt_confused
		target.stuttering += amt_stuttering