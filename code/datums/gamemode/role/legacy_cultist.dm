/datum/role/legacy_cultist
	id = LEGACY_CULTIST
	name = LEGACY_CULTIST
	special_role = LEGACY_CULTIST
	disallow_job = FALSE
	restricted_jobs = list("AI", "Cyborg", "Mobile MMI", "Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Chaplain", "Head of Personnel", "Internal Affairs Agent", "Merchant")
	logo_state = "cult-logo"
	greets = list("default","custom","admintoggle")
	required_pref = CULTIST

/datum/role/legacy_cultist/OnPostSetup(var/equip = FALSE)
	. = ..()
	antag.current.add_language(LANGUAGE_CULT)
	var/mob/living/carbon/human/cult_mob = antag.current
	var/datum/faction/cult/narsie/cult_fac = faction
	update_faction_icons()
	cult_fac.grant_runeword(antag.current)
	if(!istype(cult_mob))
		return

	if (!equip)
		return 1

	var/obj/item/weapon/paper/talisman/supply/T = new(cult_mob)
	var/list/slots = list (
		"backpack" = slot_in_backpack,
		"left pocket" = slot_l_store,
		"right pocket" = slot_r_store,
	)

	var/where = cult_mob.equip_in_one_of_slots(T, slots, EQUIP_FAILACTION_DROP, put_in_hand_if_fail = 1)

	if (!where)
		to_chat(cult_mob, "<span class='sinister'>Unfortunately, you weren't able to sneak in a talisman. Pray, and He most likely shall get you one.</span>")
	else
		to_chat(cult_mob, "<span class='sinister'>You have a talisman in your [where], one that will help you start the cult on this station. Use it well and remember - there are others.</span>")
		cult_mob.update_icons()
		return 1

/datum/role/legacy_cultist/Greet(var/greeting, var/custom)
	if(!greeting)
		return

	var/icon/logo = icon('icons/logos.dmi', logo_state)
	switch(greeting)
		if ("custom")
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> [custom]")
		if ("admintoggle")
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <span class='danger'>The Geometer of Blood calls your from beyond the veil. You are a Cultist!</span></B>")
		else
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <span class='danger'>You are a Cultist!</br></span>")
			to_chat(antag.current, "Your objective is to summon Nar-Sie, the Geometer of blood. To do so, you will have to complete several objectives to thin the veil between this world and his. <br/> \
				Discretion is key to your mission. Do not fail Nar-Sie. \
				Avoid the Chaplain, the chapel, Security and especially Holy Water.")

	to_chat(antag.current, "<span class='info'><a HREF='?src=\ref[antag.current];getwiki=[wikiroute]'>(Wiki Guide)</a></span>")
	antag.current << sound('sound/effects/vampire_intro.ogg')

/datum/role/legacy_cultist/Drop()
	. = ..()
	if (!antag)
		return .
	antag.current.remove_language(LANGUAGE_CULT)
	to_chat(antag.current, "<span class='danger'><FONT size = 3>An unfamiliar white light flashes through your mind, cleansing the taint of the dark-one and removing all of the memories of your time as his servant, except the one who converted you, with it.</FONT></span>")
	to_chat(antag.current, "<span class='danger'>You find yourself unable to mouth the words of the forgotten...</span>")
	antag.current.visible_message("<span class='big danger'>It looks like [antag.current] just reverted to their old faith!</span>")
	log_admin("[key_name(antag.current)] has been deconverted from the cult.")

/datum/role/legacy_cultist/AnnounceObjectives()
	if (!antag)
		return
	if (!istype(faction, /datum/faction/cult/narsie))
		WARNING("Wrong faction type for [src.antag.current], faction is [faction.type]")
		return FALSE
	var/datum/faction/cult/narsie/our_cult = faction
	to_chat(antag.current, "<span class = 'warning'>Our new objective is:</span>")
	to_chat(antag.current, "Objective #[faction.objective_holder.objectives.len]: <span class='danger'>[our_cult.current_objective.name]</span>")
	to_chat(antag.current, "<span class='warning'>[our_cult.current_objective.explanation_text]</span><br/>")

/datum/role/legacy_cultist/AdminPanelEntry()
	var/list/dat = ..()
	var/datum/faction/cult/narsie/C = faction
	dat += "<a href='?src=\ref[faction];cult_mindspeak=\ref[src]'>Voice of [C.deity_name]</a><br/>"
	return dat

/datum/role/legacy_cultist/handle_reagent(var/reagent_id)
	switch (reagent_id)
		if (HOLYWATER)
			var/mob/living/carbon/human/H = antag.current
			if (!istype(H))
				return
			if (prob(10))
				Drop()
			else
				to_chat(H, "<span class='danger'>A freezing liquid permeates your bloodstream. Your arcane knowledge is becoming obscure again.</span>")
