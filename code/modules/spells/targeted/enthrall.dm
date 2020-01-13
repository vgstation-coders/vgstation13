/spell/targeted/enthrall
	name = "Enthrall (150)"
	desc = "You use a large portion of your power to sway those loyal to none to be loyal to you only."
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
	hud_state = "vampire_enthrall"

	var/blood_cost = 150

/spell/targeted/enthrall/cast_check(skipcharge = 0,mob/user = usr)
	. = ..()
	if (!user.vampire_power(blood_cost, CONSCIOUS))
		return FALSE

/spell/targeted/enthrall/is_valid_target(var/target, var/mob/user, var/list/options)
	if (!ismob(target)) // Can only enthrall humans
		return FALSE

	var/mob/M = target

	var/success = M.vampire_affected(user.mind)
	switch (success)
		if (TRUE)
			if (!user.can_enthrall(target))
				return FALSE
			return ..()
		if (FALSE)
			return FALSE
		if (VAMP_FAILURE)
			critfail(target, user)
			return FALSE


/spell/targeted/enthrall/cast(var/list/targets, var/mob/user)
	if (targets.len > 1)
		return FALSE
		
	var/mob/living/target = targets[1]

	var/datum/role/vampire/V = isvampire(user)

	if (!V)
		return FALSE
	
	user.visible_message("<span class='warning'>[user] bites \the [target]'s neck!</span>", "<span class='warning'>You bite \the [target]'s neck and begin the flow of power.</span>")
	to_chat(target, "<span class='sinister'>You feel the tendrils of evil [(VAMP_CHARISMA in V.powers) ? "aggressively" : "slowly"] invade your mind.</span>")

	if(do_mob(user, target, (VAMP_CHARISMA in V.powers) ? 150 : 300))
		if(user.vampire_power(blood_cost, 0)) // recheck
			V.handle_enthrall(target.mind)
	else
		to_chat(user, "<span class='warning'>Either you or your target moved, and you couldn't finish enthralling them!</span>")
		return FALSE

	V.remove_blood(blood_cost)

/spell/targeted/enthrall/critfail(var/list/targets, var/mob/user)
	to_chat(user, "<span class='sinister'>You won't command this one.</span>")
	if (ishuman(user))
		var/mob/living/carbon/human/H = user
		H.confused = max(10, H.confused)
	var/datum/role/vampire/V = isvampire(user)
	if (V)
		V.remove_blood(blood_cost)