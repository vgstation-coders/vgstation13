/spell/passive/nogunallowed
	name = "No Gun Allowed"
	abbreviation = "NG"
	user_type = USER_TYPE_WIZARD
	desc = "Forgo the use of guns in exchange for magical power. Some within the Wizard Federation have lobbied to make this spell a legal obligation."
	hud_state = "wiz_noclothes"
	spell_flags = NO_BUTTON
	price = -0.5 * Sp_BASE_PRICE
	specialization = SSUTILITY

/spell/passive/nogunallowed/on_added(mob/user)
	user.flags += HONORABLE_NOGUNALLOWED
