/datum/role/cultist
	id = CULTIST
	name = "Cultist"
	protected_jobs = list("Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Chaplain", "Head of Personnel", "Internal Affairs Agent")
	logo_state = "cult-logo"
	greets = list("default","custom","roundstart","admintoggle")

/datum/role/cultist/New(var/datum/mind/M, var/datum/faction/fac=null, var/new_id)
	..()
	wikiroute = role_wiki[ROLE_CULTIST]

/datum/role/cultist/OnPostSetup()
	. = ..()
	if(!.)
		return

	antag.current.add_language(LANGUAGE_CULT)
	if(!(locate(/spell/cult) in antag.current.spell_list))
		antag.current.add_spell(new /spell/cult/trace_rune, "cult_spell_ready", /obj/abstract/screen/movable/spell_master/bloodcult)
		antag.current.add_spell(new /spell/cult/erase_rune, "cult_spell_ready", /obj/abstract/screen/movable/spell_master/bloodcult)

/datum/role/cultist/RemoveFromRole(var/datum/mind/M)
	antag.current.remove_language(LANGUAGE_CULT)
	for(var/spell/cult/spell_to_remove in antag.current.spell_list)
		antag.current.remove_spell(spell_to_remove)
	..()

/datum/role/cultist/Greet(var/greeting,var/custom)
	if(!greeting)
		return

	var/icon/logo = icon('icons/logos.dmi', logo_state)
	switch(greeting)
		if ("roundstart")
			to_chat(antag.current, {"<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <span class='sinister'><font size=3>You are a cultist of <span class='danger'><font size=3>Nar-Sie</font></span>!</font><br>
				I, the Geometer of Blood, want you to thin the veil between your reality and my realm<br>
				so I can pull this place onto my plane of existence.<br>
				You've managed to get a job here, and the time has come to put our plan into motion.<br>
				However, the veil is currently so thick that I can barely bestow any power to you.<br>
				Other cultists made their way into the crew. Talk to them. <span class='danger'>Self Other Technology</span>!<br>
				Meet up with them. Raise an altar in my name. <span class='danger'>Blood Technology Join</span>!<br>
				</span>"})
		if ("admintoggle")
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <span class='sinister'>You catch a glimpse of the Realm of Nar-Sie, The Geometer of Blood. You now see how flimsy the world is, you see that it should be open to the knowledge of Nar-Sie.</span>")
			to_chat(antag.current, "<span class='sinister'>Assist your new compatriots in their dark dealings. Their goal is yours, and yours is theirs. You serve the Dark One above all else. Bring It back.</span>")
		if ("custom")
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <span class='sinister'>[custom]</span>")
		else
			if (faction && faction.ID == BLOODCULT)
				to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <span class='sinister'>You are a lone cultist. You've spent years studying the language of Nar-Sie, but haven't associated with his followers.</span>")
			else
				to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <span class='sinister'>You are cultist, from the cult of Nar-Sie, the Geometer of Blood.</span>")


	to_chat(antag.current, "<span class='info'><a HREF='?src=\ref[antag.current];getwiki=[wikiroute]'>(Wiki Guide)</a></span>")
	to_chat(antag.current, "<span class='sinister'>You find yourself to be well-versed in the runic alphabet of the cult.</span>")




/mob/living/carbon/proc/muted()
	return (iscultist(src) && reagents && reagents.has_reagent(HOLYWATER))

/datum/role/cultist/AdminPanelEntry(var/show_logo = FALSE,var/datum/admins/A)
	var/dat = ..()
	dat += " - <a href='?src=\ref[A];cult_privatespeak=\ref[antag.current]'>(Nar-Sie whispers)</a>"
	return dat
