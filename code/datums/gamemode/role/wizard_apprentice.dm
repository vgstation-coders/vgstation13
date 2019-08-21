/datum/role/wizard_master
	name = "master wizard"
	id = WIZAPP_MASTER
	disallow_job = TRUE
	logo_state = "wizard-logo"

/datum/role/wizard_apprentice
	name = "wizard's apprentice"
	id = WIZAPP
	disallow_job = TRUE
	logo_state = "apprentice-logo"

/datum/role/wizard_apprentice/OnPostSetup()
	. = ..()
	if(!.)
		return
	equip_wizard(antag.current, apprentice = TRUE)

/datum/role/wizard_apprentice/Greet(var/greeting,var/custom)
	if(!greeting)
		return

	var/icon/logo = icon('icons/logos.dmi', logo_state)
	switch(greeting)
		if(GREET_CUSTOM)
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> [custom]")
		if(GREET_DEFAULT)
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <span class='info'>You are a Wizard's Apprentice!</br></span>")


/datum/role/wizard_apprentice/PostMindTransfer(var/mob/living/new_character, var/mob/living/old_character)
	. = ..()
	for (var/spell/S in old_character.spell_list)
		if (S.user_type == USER_TYPE_WIZARD && !(S.spell_flags & LOSE_IN_TRANSFER))
			new_character.add_spell(S)

/datum/role/wizard_apprentice/GetScoreboard()
	. = ..()
	var/mob/living/carbon/human/H = antag.current

	if(!length(H.spell_list))
		. += "The apprentice somehow forgot everything he learned in magic school."
		return

	. += "<BR>The apprentice knew:<BR>"
	for(var/spell/S in H.spell_list)
		if(S.user_type != USER_TYPE_WIZARD)
			continue
		var/icon/tempimage = icon('icons/mob/screen_spells.dmi', S.hud_state)
		end_icons += tempimage
		var/tempstate = end_icons.len
		. += "<img src='logo_[tempstate].png'> [S.name]<BR>"
