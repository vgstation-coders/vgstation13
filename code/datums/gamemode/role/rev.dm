/datum/role/revolutionary
	name = REV
	id = REV
	restricted_jobs = list("Security Officer", "Warden", "Detective", "AI", "Cyborg","Mobile MMI","Captain", "Head of Personnel", "Head of Security", "Chief Engineer", "Research Director", "Chief Medical Officer", "Internal Affairs Agent")
	logo_state = "rev-logo"
	greets = list(GREET_DEFAULT,GREET_CUSTOM,GREET_ROUNDSTART,GREET_ADMINTOGGLE)

// The ticker current state check is because revs are created, at roundstart, in the cuck cube.
// Which is outside the z-level of the main station.

/datum/role/revolutionary/AssignToRole(var/datum/mind/M, var/override = 0, var/roundstart = 0)
	if (!(M.current) || (M.current.z != map.zMainStation && !roundstart))
		message_admins("Error: cannot create a revolutionary off the main z-level.")
		return FALSE
	return ..()

/datum/role/revolutionary/Greet(var/greeting, var/custom)
	if(!greeting)
		return

	var/icon/logo = icon('icons/logos.dmi', logo_state)
	switch(greeting)
		if (GREET_ROUNDSTART, GREET_DEFAULT)
			to_chat(antag.current, {"<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/><span class = 'notice'>You are a member of the revolutionaries' leadership!</span>"})
		if (GREET_ADMINTOGGLE)
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <span class='warning'>You suddenly feel rather annoyed with this stations leadership!</span>")
		if (GREET_CUSTOM)
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <span class='warning'>[custom]</span>")

	to_chat(antag.current, "<span class='info'><a HREF='?src=\ref[antag.current];getwiki=[wikiroute]'>(Wiki Guide)</a></span>")

/datum/role/revolutionary/OnPostSetup()
	. = ..()
	to_chat(antag.current, "<span class='warning'><FONT size = 3> You are now a revolutionary! Help your cause. Do not harm your fellow freedom fighters. You can identify your comrades by the red \"R\" icons, and your leaders by the blue \"R\" icons. Help them kill the heads to win the revolution!</FONT></span>")
	AnnounceObjectives()

/datum/role/revolutionary/New()
	..()
	wikiroute = role_wiki[ROLE_REV]

/datum/role/revolutionary/leader
	name = HEADREV
	id = HEADREV
	logo_state = "rev_head-logo"

/datum/role/revolutionary/leader/OnPostSetup()
	.=..()
	if(!.)
		return
	var/mob/living/carbon/human/mob = antag.current
	var/obj/item/device/flash/rev/T = new(mob)
	if(istype(mob))
		var/list/slots = list (
			"backpack" = slot_in_backpack,
			"left pocket" = slot_l_store,
			"right pocket" = slot_r_store,
		)
		var/where = mob.equip_in_one_of_slots(T, slots, put_in_hand_if_fail = 1)

		if (!where)
			to_chat(mob, "\The [faction.name] were unfortunately unable to get you \a [T].")
		else
			to_chat(mob, "\The [T] in your [where] will help you to persuade the crew to join your cause.")
	else
		T.forceMove(get_turf(mob))
		to_chat(mob, "\The [faction.name] were able to get you \a [T], but could not find anywhere to slip it onto you, so it is now on the floor.")

/datum/role/revolutionary/Drop(var/borged = FALSE)
	if (!antag)
		return ..()
	if (borged)
		antag.current.visible_message("<span class='big danger'>The frame beeps contentedly, purging the hostile memory engram from the MMI before initalizing it.</span>",
				"<span class='big danger'>The frame's firmware detects and deletes your neural reprogramming! You remember nothing from the moment you were flashed until now.</span>")
	else
		antag.current.visible_message("<span class='big danger'>It looks like [antag.current] just remembered their real allegiance!</span>",
			"<span class='big danger'>You have been brainwashed! You are no longer a revolutionary! Your memory is hazy from the time you were a rebel...the only thing you remember is the name of the one who brainwashed you...</span>")
	update_faction_icons()
	return ..()
