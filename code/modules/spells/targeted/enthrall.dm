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

/spell/targeted/enthrall/is_valid_target(atom/target, mob/user, options, bypass_range = 0)
	if (!ishuman(target)) // Can only enthrall humans
		return FALSE
	return ..()


/spell/targeted/enthrall/cast(var/list/targets, var/mob/user)
	if (targets.len > 1)
		return FALSE

	var/mob/living/target = targets[1]

	var/datum/role/vampire/V = isvampire(user)

	if (!V)
		return FALSE
	var/success = target.vampire_affected(user.mind)
	switch(success)
		if(FALSE)
			return TRUE
		if(VAMP_FAILURE)
			critfail(targets, user)
			return
	user.visible_message("<span class='warning'>[user] bites \the [target]'s neck!</span>", "<span class='warning'>You bite \the [target]'s neck and begin the flow of power.</span>")
	to_chat(target, "<span class='sinister'>You feel the tendrils of evil [(locate(/datum/power/vampire/charisma) in V.current_powers) ? "aggressively" : "slowly"] invade your mind.</span>")

	if(do_mob(user, target, (locate(/datum/power/vampire/charisma) in V.current_powers) ? 150 : 300))
		if(user.vampire_power(blood_cost, 0)) // recheck
			V.handle_enthrall(target.mind)
	else
		to_chat(user, "<span class='warning'>Either you or your target moved, and you couldn't finish enthralling them!</span>")
		return TRUE

	if(!target.client) //There is not a player "in control" of this corpse, so there is no one to inform.
		var/mob/dead/observer/ghost = mind_can_reenter(target.mind)
		if(ghost)
			var/mob/ghostmob = ghost.get_top_transmogrification()
			if(ghostmob) //A ghost has been found, and it still belongs to this corpse. There's nothing preventing them from being revived.
				to_chat(ghostmob, "<span class='interface big'><span class='bold'>The vampire has enthralled your corpse.  You will be their servant when you return to the living.  Blood and power to your Lord.  (Check your notes for the current identity of your master upon revival.)</span>")

	V.remove_blood(blood_cost)

/spell/targeted/enthrall/critfail(var/list/targets, var/mob/user)
	to_chat(user, "<span class='sinister'>You won't command this one.</span>")
	if (ishuman(user))
		var/mob/living/carbon/human/H = user
		H.confused = max(10, H.confused)
	var/datum/role/vampire/V = isvampire(user)
	if (V)
		V.remove_blood(blood_cost)
