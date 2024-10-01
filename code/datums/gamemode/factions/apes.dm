/datum/faction/apes
	name = THE_APES
	ID = THE_APES
	logo_state = "monkey-logo"
	default_admin_voice = "Ape King"
	admin_voice_style = "rough"

/datum/faction/apes/OnLateArrival(mob/living/carbon/human/character, rank)
	if(ape_mode)
		character.apeify()