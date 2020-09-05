/spell/passive/nogunallowed
	name = "No Gun Allowed"
	abbreviation = "NG"
	desc = "Forgo the use of guns in exchange for magical power. Some within the Wizard Federation have lobbied to make this spell a legal obligation."
	hud_state = "wiz_noclothes"
	spell_flags = NO_BUTTON

/spell/passive/nogunallowed/on_added(mob/user)
	user.flags |= HONORABLE_NOGUNALLOWED
