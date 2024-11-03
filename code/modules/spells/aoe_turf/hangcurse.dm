/*
CURSE OF THE HANGMAN
Removes letters in the afflicted's sentences like the virology symptom, others must guess them to clear it.
-kanef
*/

/spell/aoe_turf/hangman
	name = "Curse of the Hangman"
	desc = "This spell obscures the words of all beings in view. This can only be cured by others guessing the missing letters and filling the words out. Mistakes erase letters and even reset words!"
	user_type = USER_TYPE_WIZARD
	specialization = SSUTILITY
	abbreviation = "HM"

	charge_max = 500
	spell_flags = null
	invocation = "V_R'_ R_'UG_"
	invocation_type = SpI_SHOUT
	selection_type = "range"
	range = 3
	inner_radius = -1

	cooldown_min = 100
	var/letters_retained = 12
	level_max = list(Sp_TOTAL = 6, Sp_SPEED = 4, Sp_POWER = 2)

	hud_state = "wiz_hangman"

/spell/aoe_turf/hangman/get_upgrade_info(upgrade_type, level)
	if(upgrade_type == Sp_POWER)
		if(spell_levels[Sp_POWER] >= level_max[Sp_POWER])
			if(prob(10))
				return "Th__ _p_ll _lr__dy r_mov__ __ m_ny l_tt_r_ __ _t c_n!"
			return "This spell already removes as many letters as it can!"
		return "Remove more letters from the sentences of those who are affected."
	return ..()

/spell/aoe_turf/hangman/empower_spell()
	spell_levels[Sp_POWER]++

	letters_retained /= 1.5

	switch(spell_levels[Sp_POWER])
		if(0)
			name = "Curse of the Hangman"
			invocation = "VIR'O RO'UGE"
		if(1)
			name = "C__se _f th_ H_ng__n"
			invocation = "V_R'_ R_'UGE"
		if(2)
			name = "C__s_ __ _h_ H__g___"
			invocation = "V_R'_ R_'_G_"

	return "The curse will now retain less letters"

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
			H.set_muted_letters(letters_retained) // See Hear() for guessing and human level saycode for filtering
			H.visible_message("<span class='sinister'>[H]'s spoken words are now obscured. Others must shout letters to reveal them. Mistakes reverse the reveals!</span>","<span class='sinister'>Your spoken words are now obscured. Others must shout letters to reveal them. Mistakes reverse the reveals!</span>")
