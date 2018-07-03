/datum/role/legacy_cultist
	id = LEGACY_CULTIST
	name = LEGACY_CULTIST
	special_role = ROLE_LEGACY_CULTIST
	disallow_job = FALSE
	restricted_jobs = list("AI", "Cyborg", "Mobile MMI", "Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Chaplain", "Head of Personnel", "Internal Affairs Agent")
	logo_state = "cult-logo"
	greets = list("default","custom","admintoggle")
	required_pref = ROLE_LEGACY_CULTIST

/datum/role/legacy_cultist/OnPostSetup()
	. = ..()
	antag.current.add_language(LANGUAGE_CULT)
	var/mob/living/carbon/human/cult_mob = antag.current

	if(!istype(cult_mob))
		return

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
	antag.current.remove_language(LANGUAGE_CULT)
	..()

/datum/role/legacy_cultist/MemorizeObjectives()
	var/datum/faction/cult/narsie/our_cult = faction
	var/text="<b>Our Cult's objectives:</b> <br/>"
	text += "[our_cult.current_objective.name]. [our_cult.current_objective.explanation_text]<br/>"
	to_chat(antag.current, "[text]")
	antag.memory += "[text]"

/datum/role/legacy_cultist/AnnounceObjectives()
	if (!istype(faction, /datum/faction/cult/narsie))
		WARNING("Wrong faction type for [src.antag.current], faction is [faction.type]")
		return FALSE
	var/datum/faction/cult/narsie/our_cult = faction
	var/text = "[our_cult.current_objective.name]. [our_cult.current_objective.explanation_text]<br/>"
	to_chat(antag.current, "Our new objective is: [text]")
	antag.memory += "[text]"