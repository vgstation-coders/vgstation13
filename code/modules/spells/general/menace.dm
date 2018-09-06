/spell/menace
	name = "Shadowy Menace (toggle)"
	desc = "Terrify anyone who looks at you in the dark."
	abbreviation = "CK"

	school = "vampire"
	user_type = USER_TYPE_VAMPIRE

	charge_type = Sp_RECHARGE
	charge_max = 1 SECONDS
	invocation_type = SpI_NONE
	range = 0
	spell_flags = STATALLOWED | NEEDSHUMAN
	cooldown_min = 1 SECONDS

	override_base = "vamp"
	hud_state = "vamp_menace"

	var/blood_cost = 0

/spell/menace/cast_check(var/skipcharge = 0, var/mob/user = usr)
	. = ..()
	if (!.) // No need to go further.
		return FALSE
	if (!user.vampire_power(blood_cost, CONSCIOUS))
		return FALSE

/spell/menace/choose_targets(var/mob/user = usr)
	return list(user) // Self-cast

/spell/menace/cast(var/list/targets, var/mob/user)
	var/datum/role/vampire/V = isvampire(user) // Shouldn't ever be null, as cast_check checks if we're a vamp.
	if (!V)
		return FALSE
	V.remove_blood(blood_cost)
	V.ismenacing = !V.ismenacing
	to_chat(user, "<span class='notice'>You will [V.ismenacing ? "now" : "no longer"] terrify those who see you the in dark.</span>")