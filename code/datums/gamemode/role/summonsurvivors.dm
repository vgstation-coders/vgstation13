/*
 * Summon guns/swords/magic traitors
 */

/datum/role/survivor
	id = SURVIVOR
	name = SURVIVOR
	logo_state = "survivor-logo"
	default_admin_voice = "Common Sense"
	admin_voice_style = "warning"
	var/survivor_type = "survivor"
	var/summons_received

/datum/role/survivor/crusader
	id = CRUSADER
	name = CRUSADER
	survivor_type = "crusader"
	logo_state = "sword-logo"

/datum/role/survivor/Greet(var/greeting,var/custom)
	if (greeting == GREET_RIGHTANDWRONG)
		logo_state = "gun-logo"

	var/icon/logo = icon('icons/logos.dmi', logo_state)
	switch(greeting)
		if (GREET_RIGHTANDWRONG)
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <B>You are a [survivor_type]!</B><BR>Your own safety matters above all else, trust no one and kill anyone who gets in your way. However, armed as you are, now would be the perfect time to settle that score or grab that pair of yellow gloves you've been eyeing...")
		if (GREET_MADNESSSURVIVOR)
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <B>You are a [survivor_type]!</B><BR>This place is bad news, and you are determined to make it out of here alive by any means necessary.")
		else
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <B>You are a [survivor_type]!</B>")

/datum/role/survivor/ForgeObjectives()
	var/datum/objective/survive/S = new
	AppendObjective(S)

/datum/role/survivor/GetScoreboard()
	. = ..()
	. += "The [name] received the following as a result of a summoning spell: [summons_received]<BR>"

//Note this is a wizard subtype

/datum/role/wizard/summon_magic
	disallow_job = FALSE
	name = MAGICIAN
	id = MAGICIAN
	logo_state = "magik-logo"
	var/summons_received

/datum/role/wizard/summon_magic/ForgeObjectives()
	var/datum/objective/survive/S = new
	AppendObjective(S)

/datum/role/wizard/summon_magic/Greet()
	var/icon/logo = icon('icons/logos.dmi', logo_state)
	to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <B>You are a Magician!</B><BR>Your own safety matters above all else, trust no one and kill anyone who gets in your way. However, armed as you are, now would be the perfect time to settle that score or grab that pair of yellow gloves you've been eyeing...")

/datum/role/wizard/summon_magic/OnPostSetup(var/laterole = FALSE)
	return TRUE

/datum/role/wizard/summon_magic/GetScoreboard()
	. = ..()
	. += "The [name] received the following as a result of a summoning spell: [summons_received]<BR>"

/datum/role/wizard/summon_magic/artifact
	name = MAGICIAN_ARTIFACT
	id = MAGICIAN_ARTIFACT

/datum/role/wizard/summon_magic/artifact/Greet()
	var/icon/logo = icon('icons/logos.dmi', logo_state)
	to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <B>You are a Magical Artificer!</B><BR>Your own safety matters above all else, trust no one and kill anyone who gets in your way. However, armed as you are, now would be the perfect time to settle that score or grab that pair of yellow gloves you've been eyeing...")

/datum/role/wizard/summon_potions
	disallow_job = FALSE
	name = POTION
	id = POTION
	logo_state = "magik-logo"
	var/summons_received

/datum/role/wizard/summon_potions/ForgeObjectives()
	var/datum/objective/survive/potions/S = new
	AppendObjective(S)

/datum/role/wizard/summon_potions/Greet()
	var/icon/logo = icon('icons/logos.dmi', logo_state)
	to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <B>You are a Potion Seller!</B><BR>Your own safety matters abov- Fuck that, GO SELL SOME POTIONS!")

/datum/role/wizard/summon_potions/OnPostSetup(var/laterole = FALSE)
	return TRUE

/datum/role/wizard/summon_potions/GetScoreboard()
	. = ..()
	. += "The [name] received the following as a result of a summoning spell: [summons_received]<BR>"

