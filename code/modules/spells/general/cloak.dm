/spell/cloak
	name = "Cloak (toggle)"
	desc = "Allows you to hide in the darkness."
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
	hud_state = "vampire_cloack"

	var/blood_cost = 0

/spell/cloak/cast_check(var/skipcharge = 0, var/mob/user = usr)
	if (!user.vampire_power(blood_cost, 0))
		return FALSE
	return ..()

/spell/cloak/choose_targets(var/mob/user = usr)
	return list(user) // Self-cast

/spell/cloak/cast(var/list/targets, var/mob/user)
	var/mob/living/carbon/human/H = user
	var/datum/role/vampire/V = isvampire(user) // Shouldn't ever be null, as cast_check checks if we're a vamp.
	V.iscloaking = !V.iscloaking
	to_chat(H, "<span class='notice'>You will now be [V.iscloaking ? "hidden" : "seen"] in darkness.</span>")