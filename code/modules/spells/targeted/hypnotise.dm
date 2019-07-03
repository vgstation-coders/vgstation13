/spell/targeted/hypnotize
	name = "Hypnotize (150)"
	desc = "A malevolent stare that brainwashes your victim to obey you."
	abbreviation = "HN"

	school = "vampire"
	user_type = USER_TYPE_VAMPIRE

	charge_type = Sp_RECHARGE
	charge_max = 3 MINUTES
	invocation_type = SpI_NONE
	range = 1
	max_targets = 1
	spell_flags = WAIT_FOR_CLICK | NEEDSHUMAN
	cooldown_min = 3 MINUTES
	selection_type = "range"

	override_base = "vamp"
	hud_state = "vampire_hypno"

	var/blood_cost = 150

/spell/targeted/hypnotize/cast_check(skipcharge = 0, mob/user = usr)
	. = ..()
	if (!.) // No need to go further.
		return FALSE
	if (istype(user.get_item_by_slot(slot_glasses), /obj/item/clothing/glasses/sunglasses/blindfold))
		to_chat(user, "<span class='warning'>You're blindfolded!</span>")
		return FALSE
	if (!user.vampire_power(blood_cost, CONSCIOUS))
		return FALSE

/spell/targeted/hypnotize/is_valid_target(var/target, var/mob/user, var/list/options)
	if (!ismob(target))
		return FALSE

	var/mob/M = target

	var/success = M.vampire_affected(user.mind)
	switch (success)
		if (TRUE)
			if(!user.can_enthrall(target))
				return FALSE
			return ..()
		if (FALSE)
			return FALSE
		if (VAMP_FAILURE)
			critfail(target, user)
			return FALSE

/spell/targeted/hypnotize/cast(var/list/targets, var/mob/user)
	var/mob/living/target = targets[1]
	var/datum/role/vampire/V = isvampire(user)
	if (!V)
		return FALSE
	if(target.is_blind())
		to_chat(user, "<span class='warning'>\the [target] is blind!</span>")
		return FALSE
	user.visible_message("<span class='warning'>[user] gazes into \the [target]'s eyes!</span>", "<span class='warning'>You gaze into \the [target]'s eyes, molding their mind like clay to serve you.</span>")
	to_chat(target, "<span class='sinister'>You feel the tendrils of evil [(VAMP_CHARISMA in V.powers) ? "aggressively" : "slowly"] invade your mind.</span>")

	if(do_mob(user, target, (VAMP_CHARISMA in V.powers) ? 150 : 300))
		if(user.vampire_power(blood_cost, 0)) // recheck
			V.handle_enthrall(target.mind)
		else
			to_chat(user, "<span class='warning'>You didn't have enough blood to finish the brainwashing!</span>")
			return FALSE
	else
		to_chat(user, "<span class='warning'>Either you or your target moved, and you couldn't finish enthralling them!</span>")
		return FALSE

	V.remove_blood(blood_cost)

/spell/targeted/hypnotize/critfail(var/list/targets, var/mob/user)
	to_chat(user, "<span class='sinister'>This one is protected by a holy aura, protecting against your brainwashing!</span>")
	if (ishuman(user))
		var/mob/living/carbon/human/H = user
		H.confused = max(10, H.confused)
	var/datum/role/vampire/V = isvampire(user)
	if (V)
		V.remove_blood(blood_cost)