/spell/shapeshift
	name = "Shapeshift"
	desc = "Changes your name and appearance and has a cooldown of 3 minutes."
	abbreviation = "SS"

	school = "vampire"
	user_type = USER_TYPE_VAMPIRE

	charge_type = Sp_RECHARGE
	charge_max = 3 MINUTES
	invocation_type = SpI_NONE
	range = 0
	spell_flags = STATALLOWED | NEEDSHUMAN
	cooldown_min = 3 MINUTES

	override_base = "vamp"
	hud_state = "vamp_shapeshift"

	var/blood_cost = 1

/spell/shapeshift/cast_check(var/skipcharge = 0, var/mob/user = usr)
	. = ..()
	if (!.) // No need to go further.
		return FALSE
	if (!user.vampire_power(blood_cost, CONSCIOUS))
		return FALSE

/spell/shapeshift/choose_targets(var/mob/user = usr)
	return list(user) // Self-cast

/spell/shapeshift/cast(var/list/targets, var/mob/user)
	if (!user.client)
		return FALSE
	user.visible_message("<span class='sinister'>\The [user] transforms!</span>")
	user.client.prefs.real_name = user.generate_name() //random_name(M.current.gender)
	user.client.prefs.randomize_appearance_for(user)
	user.regenerate_icons()
	var/datum/role/vampire/V = isvampire(user)
	if (V)
		V.remove_blood(blood_cost)