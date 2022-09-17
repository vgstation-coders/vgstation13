/spell/cloak
	name = "Cloak of Darkness (toggle)"
	desc = "Toggles whether you are currently cloaking yourself in darkness."
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

/spell/cloak/cast_check(var/skipcharge = 0, var/mob/user = usr)
	. = ..()
	if (!.) // No need to go further.
		return FALSE
	if (!user.vampire_power(blood_cost, CONSCIOUS))
		return FALSE
	if (!isvampire(user))
		return FALSE
/spell/cloak/choose_targets(var/mob/user = usr)
	return list(user) // Self-cast

/spell/cloak/cast(var/list/targets, var/mob/user)
	var/datum/role/vampire/V = user.mind.GetRole(VAMPIRE)
	V.iscloaking = !V.iscloaking
	to_chat(user, "<span class='notice'>You will now be [V.iscloaking ? "hidden" : "seen"] in darkness.</span>")
	V.handle_cloak(user)