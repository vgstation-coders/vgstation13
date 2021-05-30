/spell/aoe_turf/hangman
	name = "Curse of the Hangman"
	desc = "This spell obscures the words of all beings in view. This can only be cured by others guessing the missing letters and filling the words out. Mistakes erase letters and even reset words!"
	user_type = USER_TYPE_WIZARD
	specialization = SSUTILITY
	abbreviation = "HM"

	charge_max = 150
	spell_flags = null
	invocation = "V_R'_ R_'UG_"
	invocation_type = SpI_SHOUT
	selection_type = "range"
	range = 3
	inner_radius = -1

	cooldown_min = 50

	hud_state = "blackout"

/spell/aoe_turf/hangman/choose_targets(var/mob/user = usr)

	var/list/targets = list()

	for(var/mob/living/carbon/human/H in hearers(user, range))
		if(H == user)
			continue
		targets += H

	if (!targets.len)
		to_chat(user, "<span class='warning'>There are no targets.</span>")
		return FALSE

	return targets

/spell/aoe_turf/hangman/cast(list/targets)

	for(var/T in targets)
		if(ishuman(T))
			var/mob/living/carbon/human/H = T
			H.set_muted_letters()
			H.visible_message("<span class='sinister'>[H]'s spoken words are now obscured. Others must shout letters to reveal them. Mistakes reverse the reveals!</span>","<span class='sinister'>Your spoken words are now obscured. Others must shout letters to reveal them. Mistakes reverse the reveals!</span>")