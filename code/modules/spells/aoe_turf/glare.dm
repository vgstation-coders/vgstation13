/spell/aoe_turf/glare
	name = "Glare"
	desc = "A scary glare that incapacitates people for a short while around you."
	abbreviation = "GL"

	school = "vampire"
	user_type = USER_TYPE_VAMPIRE

	charge_type = Sp_RECHARGE
	charge_max = 3 MINUTES
	invocation_type = SpI_NONE
	range = 3
	spell_flags = NEEDSHUMAN
	cooldown_min = 3 MINUTES

	override_base = "vamp"
	hud_state = "vampire_glare"

	inner_radius = 3

	var/blood_cost = 0

/spell/aoe_turf/glare/cast_check(var/skipcharge = 0, var/mob/user = usr)
	. = ..()
	if (!.) // No need to go further.
		return FALSE
	if (istype(user.get_item_by_slot(slot_glasses), /obj/item/clothing/glasses/sunglasses/blindfold))
		to_chat(user, "<span class='warning'>You're blindfolded!</span>")
		return FALSE
	if (!user.vampire_power(blood_cost, CONSCIOUS))
		return FALSE

/spell/aoe_turf/glare/choose_targets(var/mob/user = usr)
	var/list/targets = list()
	for(var/mob/living/carbon/C in oview(inner_radius)) //Silicons are excluded
		if(istype(C))
			targets += C

	if (!targets.len)
		to_chat(user, "<span class='warning'>There are no targets.</span>")
		return FALSE

	return targets

/spell/aoe_turf/glare/cast(var/list/targets, var/mob/user)
	var/datum/role/vampire/V = isvampire(user) // Shouldn't ever be null, as cast_check checks if we're a vamp.
	if (!V)
		return FALSE
	var/critical_fail = FALSE
	var/list/immune_targets = list() //Helps keep things tidy by telling the vampire everyone who is divinely-shielded
	for(var/mob/living/carbon/affected in targets) //Check for whether the spell should fail, then proceed
		var/success = affected.vampire_affected(user.mind, FALSE) //We are just checking, don't send messages
		switch (success)
			if (FALSE)
				immune_targets += affected
			if (VAMP_FAILURE)
				affected.vampire_affected(user.mind)
				critical_fail = TRUE
				break
	if(critical_fail) //Cancel the spell because a null rod caused a backlash against the vampire
		critfail(targets, user)
		return
	user.visible_message("<span class='danger'>\The [user]'s eyes emit a blinding flash!</span>")
	for (var/mob/living/carbon/C in targets)
		if(C.is_blind())
			continue
		if(C in immune_targets)
			C.vampire_affected(user.mind) //Send the message related to whether they are resistant or being shielded by a null rod
			continue
		var/dist = get_dist(user, C)
		switch (dist)
			if (0 to 1) // Close mobs
				C.Stun(8)
				C.Knockdown(8)
				C.stuttering += 20
			else // Further away mobs
				var/distance_value = max(0, abs(dist-3) + 1)
				C.Stun(distance_value)
				if(distance_value > 1)
					C.Knockdown(distance_value)
				C.stuttering += 5+distance_value * ((locate(/datum/power/vampire/charisma) in V.current_powers) ? 2 : 1) //double stutter time with Charisma
				if(!C.blinded)
					C.blinded = 1
				C.blinded += max(1, distance_value)
		to_chat(C, "<span class='warning'>You are blinded by [user]'s glare.</span>")
		C.flash_eyes()
	V.remove_blood(blood_cost)

/spell/aoe_turf/glare/critfail(var/list/targets, var/mob/user)
	user.visible_message("<span class='danger'>\The [user]'s eyes glow weakly, and they fall over...</span>", "<span class='danger'>A burning white light knocks you over!</span>")
	user.Stun(4)
	user.Knockdown(4)
	user.stuttering += 15
