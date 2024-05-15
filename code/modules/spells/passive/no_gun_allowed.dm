/spell/passive/nogunallowed
	name = "No Gun Allowed"
	abbreviation = "NG"
	desc = "Forgo the use of guns in exchange for magical power. Some within the Wizard Federation have lobbied to make this spell a legal obligation."
	hud_state = "wiz_noclothes"
	user_type = USER_TYPE_WIZARD
	spell_flags = NO_BUTTON|NO_SPELLBOOK //Already exists in the artifact section
	range = SELFCAST

/spell/passive/nogunallowed/on_added(mob/user)
	user.flags |= HONORABLE_NOGUNALLOWED

/spell/passive/nogunallowed/on_transfer(mob/user)
	user.flags |= HONORABLE_NOGUNALLOWED
