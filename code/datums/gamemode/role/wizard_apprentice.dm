/datum/role/wizard_master
	name = "master wizard"
	id = WIZAPP_MASTER
	disallow_job = TRUE
	logo_state = "wizard-logo"
	default_admin_voice = "Wizard Federation"
	admin_voice_style = "notice"

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
	antag.current.flavor_text = null
	antag.current.faction = "wizard"
	antag.mob_legacy_fac = "wizard"

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
	for (var/spell/S in antag.wizard_spells)
		if (!(S.spell_flags & LOSE_IN_TRANSFER))
			transfer_spell(new_character, old_character, S)

/datum/role/wizard_apprentice/GetScoreboard()
	. = ..()
	var/mob/living/carbon/human/H = antag.current

	if(!length(H.spell_list))
		. += "The apprentice somehow forgot everything he learned in magic school."
		return

	. += "<BR>The apprentice knew:<BR>"
	for(var/spell/S in antag.wizard_spells)
		var/icon/tempimage = icon('icons/mob/screen_spells.dmi', S.hud_state)
		. += "<img class='icon' src='data:image/png;base64,[iconsouth2base64(tempimage)]'> [S.name]<BR>"
