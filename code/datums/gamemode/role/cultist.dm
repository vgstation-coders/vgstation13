/datum/role/cultist
	id = CULTIST
	name = "Cultist"
	protected_jobs = list("Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Chaplain", "Head of Personnel", "Internal Affairs Agent")
	logo_state = "cult-logo"
	greets = list(GREET_DEFAULT,GREET_CUSTOM,GREET_ROUNDSTART,GREET_ADMINTOGGLE)
	var/list/tattoos = list()
	var/holywarning_cooldown = 0

/datum/role/cultist/New(var/datum/mind/M, var/datum/faction/fac=null, var/new_id)
	..()
	wikiroute = role_wiki[ROLE_CULTIST]

/datum/role/cultist/OnPostSetup()
	. = ..()
	if(!.)
		return

	update_cult_hud()
	antag.current.add_language(LANGUAGE_CULT)

	if(ishuman(antag.current) && !(locate(/spell/cult) in antag.current.spell_list))
		antag.current.add_spell(new /spell/cult/trace_rune, "cult_spell_ready", /obj/abstract/screen/movable/spell_master/bloodcult)
		antag.current.add_spell(new /spell/cult/erase_rune, "cult_spell_ready", /obj/abstract/screen/movable/spell_master/bloodcult)

/datum/role/cultist/RemoveFromRole(var/datum/mind/M)
	antag.current.remove_language(LANGUAGE_CULT)
	for(var/spell/cult/spell_to_remove in antag.current.spell_list)
		antag.current.remove_spell(spell_to_remove)
	if (src in blood_communion)
		blood_communion.Remove(src)
	..()

/datum/role/cultist/process()
	if (holywarning_cooldown > 0)
		holywarning_cooldown--

/datum/role/cultist/Greet(var/greeting,var/custom)
	if(!greeting)
		return

	var/icon/logo = icon('icons/logos.dmi', logo_state)
	switch(greeting)
		if (GREET_ROUNDSTART)
			to_chat(antag.current, {"<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <span class='sinister'><font size=3>You are a cultist of <span class='danger'><font size=3>Nar-Sie</font></span>!</font><br>
				I, the Geometer of Blood, want you to thin the veil between your reality and my realm<br>
				so I can pull this place onto my plane of existence.<br>
				You've managed to get a job here, and the time has come to put our plan into motion.<br>
				However, the veil is currently so thick that I can barely bestow any power to you.<br>
				Other cultists made their way into the crew. Talk to them. <span class='danger'>Self Other Technology</span>!<br>
				Meet up with them. Raise an altar in my name. <span class='danger'>Blood Technology Join</span>!<br>
				</span>"})
		if (GREET_ADMINTOGGLE)
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <span class='sinister'>You catch a glimpse of the Realm of Nar-Sie, The Geometer of Blood. You now see how flimsy the world is, you see that it should be open to the knowledge of Nar-Sie.</span>")
			to_chat(antag.current, "<span class='sinister'>Assist your new compatriots in their dark dealings. Their goal is yours, and yours is theirs. You serve the Dark One above all else. Bring It back.</span>")
		if (GREET_CUSTOM)
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <span class='sinister'>[custom]</span>")
		if (GREET_CONVERTED)
			to_chat(antag.current, "<span class='sinister'>You feel like you've broken past the veil of reality, your mind has seen worlds from beyond this plane, you've listened to the words of the Geometer of Blood for what felt like both an instant and ages, and now share both his knowledge and his ambition.</span>")
			to_chat(antag.current, "<span class='sinister'>The Cult of Nar-Sie now counts you as its newest member. Your fellow cultists will guide you. You remember the last three words that Nar-Sie spoke to you: <span class='danger'>See Blood Hell</span></span>")
		if (GREET_PAMPHLET)
			to_chat(antag.current, "<span class='sinister'>Wow, that pamphlet was very convincing, in fact you're like totally a cultist now, hail Nar-Sie!</span>")//remember, debug item
		if (GREET_SOULSTONE)
			to_chat(antag.current, "<span class='sinister'>Dark energies corrupt your soul, as the blood stone grants you a window to peer through the veil, you have become a cultist!</span>")
		if (GREET_RESURRECT)
			to_chat(antag.current, "<span class='sinister'>You were resurrected from beyond the veil by the followers of Nar-Sie, and are already familiar with their rituals! You have now joined their ranks as a cultist.</span>")
		else
			if (faction && faction.ID == BLOODCULT)
				to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <span class='sinister'>You are cultist, from the cult of Nar-Sie, the Geometer of Blood.</span>")
			else
				to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <span class='sinister'>You are a lone cultist. You've spent years studying the language of Nar-Sie, but haven't associated with his followers.</span>")

	to_chat(antag.current, "<span class='info'><a HREF='?src=\ref[antag.current];getwiki=[wikiroute]'>(Wiki Guide)</a></span>")
	to_chat(antag.current, "<span class='sinister'>You find yourself to be well-versed in the runic alphabet of the cult.</span>")

/datum/role/cultist/update_antag_hud()
	update_cult_hud()

/datum/role/cultist/proc/update_cult_hud()
	var/mob/M = antag.current
	if(M && M.client && M.hud_used)
		if(!M.hud_used.cult_Act_display)
			M.hud_used.cult_hud()
		if (!(M.hud_used.cult_Act_display in M.client.screen))
			M.client.screen += list(M.hud_used.cult_Act_display,M.hud_used.cult_tattoo_display)
		M.hud_used.cult_Act_display.overlays.len = 0
		M.hud_used.cult_tattoo_display.overlays.len = 0
		var/current_act = max(-1,min(5,veil_thickness))
		var/image/I_act = image('icons/mob/screen1_cult.dmi',"act")
		I_act.appearance_flags |= RESET_COLOR
		M.hud_used.cult_Act_display.overlays += I_act
		var/image/I_tattoos = image('icons/mob/screen1_cult.dmi',"tattoos")
		I_tattoos.appearance_flags |= RESET_COLOR
		M.hud_used.cult_tattoo_display.overlays += I_tattoos

		var/image/I_act_indicator = image('icons/mob/screen1_cult.dmi',"[current_act]")
		if (current_act == CULT_MENDED)
			I_act_indicator.appearance_flags |= RESET_COLOR
		M.hud_used.cult_Act_display.overlays += I_act_indicator

		var/image/I_arrow = image('icons/mob/screen1_cult.dmi',"[current_act]a")
		I_arrow.appearance_flags |= RESET_COLOR
		M.hud_used.cult_Act_display.overlays += I_arrow
		switch (current_act)
			if (CULT_MENDED)
				M.hud_used.cult_Act_display.name = "..."
			if (CULT_PROLOGUE)
				M.hud_used.cult_Act_display.name = "Prologue: The Reunion"
			if (CULT_ACT_I)
				M.hud_used.cult_Act_display.name = "Act I: The Followers"
			if (CULT_ACT_II)
				M.hud_used.cult_Act_display.name = "Act II: The Sacrifice"
			if (CULT_ACT_III)
				M.hud_used.cult_Act_display.name = "Act III: The Blood Bath"
			if (CULT_ACT_IV)
				M.hud_used.cult_Act_display.name = "Act IV: The Tear in Reality"
			if (CULT_EPILOGUE)
				M.hud_used.cult_Act_display.name = "Epilogue: The Feast"
		var/tattoos_names = ""
		var/i = 0
		for (var/T in tattoos)
			var/datum/cult_tattoo/tattoo = tattoos[T]
			if (tattoo)
				M.hud_used.cult_tattoo_display.overlays += image('icons/mob/screen1_cult.dmi',"t_[tattoo.icon_state]")
				tattoos_names += "[i ? ", " : ""][tattoo.name]"
				i++
		if (!tattoos_names)
			tattoos_names = "none"
		M.hud_used.cult_tattoo_display.name = "Arcane Tattoos: [tattoos_names]"

		if (isshade(M) && M.gui_icons && istype(M.loc,/obj/item/weapon/melee/soulblade))
			M.client.screen += list(
				M.gui_icons.soulblade_bgLEFT,
				M.gui_icons.soulblade_coverLEFT,
				M.gui_icons.soulblade_bloodbar,
				M.fire,
				)

/mob/living/carbon/proc/muted()
	if (checkTattoo(TATTOO_HOLY))
		return 0
	return (iscultist(src) && reagents && reagents.has_reagent(HOLYWATER))

/datum/role/cultist/AdminPanelEntry(var/show_logo = FALSE,var/datum/admins/A)
	var/dat = ..()
	dat += " - <a href='?src=\ref[A];cult_privatespeak=\ref[antag.current]'>(Nar-Sie whispers)</a>"
	return dat
