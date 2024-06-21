/datum/role/wizard
	name = WIZARD
	id = WIZARD
	special_role = WIZARD
	required_pref = WIZARD
	disallow_job = TRUE
	logo_state = "wizard-logo"
	greets = list(GREET_CUSTOM,GREET_ROUNDSTART,GREET_MIDROUND)
	default_admin_voice = "Wizard Federation"
	admin_voice_style = "notice"

	stat_datum_type = /datum/stat/role/wizard
	//Lists used so that the spells will still show up at round-end even if the apprentice has been destroyed.
	//Can get lost through absorbing
	var/list/spells_from_spellbook = list()
	var/list/spells_from_absorb = list()
//Does not show spells because the scoreboard code overrides it

	var/list/artifacts_bought = list()
	var/list/potions_bought = list()

/datum/role/wizard/ForgeObjectives()
	if(!antag.current.client.prefs.antag_objectives)
		AppendObjective(/datum/objective/freeform/wizard)
		return
	switch(rand(1,100))
		if(1 to 30)
			AppendObjective(/datum/objective/target/assassinate/delay_medium)// 10 minutes
			AppendObjective(/datum/objective/escape, 1)
		if(31 to 60)
			AppendObjective(/datum/objective/target/steal)
			AppendObjective(/datum/objective/escape, 1)
		if(61 to 100)
			AppendObjective(/datum/objective/target/assassinate/delay_medium)// 10 minutes
			AppendObjective(/datum/objective/target/steal)
			AppendObjective(/datum/objective/survive, 1)
		else
			AppendObjective(/datum/objective/hijack)
	return

/datum/role/wizard/OnPostSetup()
	. = ..()
	if(!.)
		return
	equip_wizard(antag.current)
	name_wizard(antag.current)
	antag.current.flavor_text = null
	antag.current.faction = "wizard"
	antag.mob_legacy_fac = "wizard"

/datum/role/wizard/Greet(var/greeting,var/custom)
	if(!greeting)
		return

	var/icon/logo = icon('icons/logos.dmi', logo_state)
	switch(greeting)
		if(GREET_CUSTOM)
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> [custom]")
		if(GREET_MIDROUND)
			switch(faction.name)
				if("The Wizardly Peoples' Front","The Peoples' Front for Wizards")
					to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <span class='info'>You are a Space Wizard!</br></span>")
					to_chat(antag.current, "<span class='danger'>The Wizard Federation is in civil war! Plan your strategy in the den and coordinate with your teammate! You are part of [faction]. Enemy wizards will not have a visible wizard icon, but friendly wizards will.</br></span>")
					to_chat(antag.current, "<span class='danger' style='font-size:14pt'>The den is neutral ground! Do NOT fight here!</br></span>")
					to_chat(antag.current, "<span class='info'>[faction.desc]</span>")
				else
					to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <span class='danger'>You are a Space Wizard!!</br></span>")
					to_chat(antag.current, "<span class='info'>Let no one tell you that you arrived late, or early for that matter. You arrived precisely when you meant to.</span>")
		else
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <span class='danger'>You are a Space Wizard!!</br></span>")
			to_chat(antag.current, "<span class='danger'>The Space Wizards Federation has given you some tasks.</br></span>")//todo: randomize funnier plots such as "you were bored so you decided to go mess with the crew"

	to_chat(antag.current, "<span class='info'><a HREF='?src=\ref[antag.current];getwiki=[wikiroute]'>(Wiki Guide)</a></span>")


/datum/role/wizard/PostMindTransfer(var/mob/living/new_character, var/mob/living/old_character)
	. = ..()
	for (var/spell/S in antag.wizard_spells) //Bring back all their wizard spells
		if (!(S.spell_flags & LOSE_IN_TRANSFER))
			//Transfer the spell without doing on_added() or on_removed(), instead doing on_transfer()
			transfer_spell(new_character, old_character, S)

/datum/role/wizard/GetScoreboard()
	. = ..()
	if(!disallow_job) //It's a survivor wizzie
		return
	var/mob/living/carbon/human/H = antag.current
	var/has_nothing = TRUE //No spells, no potions, no artifacts

	if(spells_from_spellbook.len)
		has_nothing = FALSE
		. += "<BR>[has_nothing ? "T" : "Additionally, t"]he wizard learned:<BR>"
		for(var/spell/S in spells_from_spellbook)
			var/icon/tempimage
			if(S.override_icon != "")
				tempimage = icon(S.override_icon, S.hud_state)
			else
				tempimage = icon('icons/mob/screen_spells.dmi', S.hud_state)
			. += "<img class='icon' src='data:image/png;base64,[iconsouth2base64(tempimage)]'> [S.name]<BR>"

	//Spells that are learned through absorbing them from other mages
	if(spells_from_absorb.len)
		. += "<BR>[has_nothing ? "T" : "Additionally, t"]he wizard absorbed:<BR>"
		has_nothing = FALSE
		for(var/spell/S in spells_from_absorb)
			var/icon/tempimage
			if(S.override_icon != "")
				tempimage = icon(S.override_icon, S.hud_state)
			else
				tempimage = icon('icons/mob/screen_spells.dmi', S.hud_state)
			. += "<img class='icon' src='data:image/png;base64,[iconsouth2base64(tempimage)]'> [S.name]<BR>"

	//Spells that the wizard somehow got their hands on. Must be wizard spells
	var/list/dummy_list = H.spell_list - (spells_from_spellbook + spells_from_absorb)
	if(dummy_list.len)
		var/has_an_uncategorized_wizard_spell = FALSE
		for(var/spell/S in H.spell_list)
			if(S.is_wizard_spell())
				has_an_uncategorized_wizard_spell = TRUE
				has_nothing = FALSE
				break
		if(has_an_uncategorized_wizard_spell)
			//This implies adminbus or other shenanigans that could grant wizard spells
			. += "<BR>[has_nothing ? "T" : "Additionally, t"]he wizard somehow knew, through divine help or other means:<BR>"
			for(var/spell/S in dummy_list)
				var/icon/tempimage
				if(S.override_icon != "")
					tempimage = icon(S.override_icon, S.hud_state)
				else
					tempimage = icon('icons/mob/screen_spells.dmi', S.hud_state)
				. += "<img class='icon' src='data:image/png;base64,[iconsouth2base64(tempimage)]'> [S.name]<BR>"

	//Artifacts and potions, if the wizard bought any
	if(artifacts_bought.len || potions_bought.len)
		has_nothing = FALSE
		. += "<BR>[has_nothing ? "T" : "Additionally, t"]he wizard brought:<BR>"
		for(var/entry in artifacts_bought)
			. += "[entry]<BR>"
		for(var/entry in potions_bought)
			. += "[entry]<BR>"
	if(has_nothing)
		. += "The wizard used only the magic of charisma this round."
