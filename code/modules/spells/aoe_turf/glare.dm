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
	if (!user.vampire_power(blood_cost, CONSCIOUS))
		return FALSE

/spell/aoe_turf/glare/choose_targets(var/mob/user = usr)
	var/list/targets = list()
	for(var/mob/living/carbon/C in oview(inner_radius))
		var/success = C.vampire_affected(user.mind)
		switch (success)
			if (TRUE)
				targets += C
			if (FALSE)
				continue
			if (VAMP_FAILURE)
				return critfail(targets, user)

	if (!targets.len)
		to_chat(user, "<span class='warning'>There are no targets.</span>")
		return FALSE

	return targets

/spell/aoe_turf/glare/cast(var/list/targets, var/mob/user)
	var/datum/role/vampire/V = isvampire(user) // Shouldn't ever be null, as cast_check checks if we're a vamp.
	if (!V)
		return FALSE
	user.visible_message("<span class='danger'>\The [user]'s eyes emit a blinding flash!</span>")
	for (var/T in targets)
		var/mob/living/carbon/C = T
		var/dist = get_dist(user, C)
		if (C.is_blind())
			continue
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
				C.stuttering += 5+distance_value * ((VAMP_CHARISMA in V.powers) ? 2 : 1) //double stutter time with Charisma
				if(!C.blinded)
					C.blinded = 1
				C.blinded += max(1, distance_value)
		to_chat(C, "<span class='warning'>You are blinded by [user]'s glare.</span>")
	V.remove_blood(blood_cost)

/spell/aoe_turf/glare/critfail(var/list/targets, var/mob/user)
	user.visible_message("<span class='danger'>\The [user]'s eyes glow weakly, and they fall over...</span>", "<span class='danger'>A burning white light knocks you over!</span>")
	user.Stun(4)
	user.Knockdown(4)
	user.stuttering += 15
	var/datum/role/vampire/V = isvampire(user)
	if (V)
		V.remove_blood(3*blood_cost)