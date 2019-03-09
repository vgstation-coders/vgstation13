/*
 * Summon guns/swords/magic/bombs/emags/mechs
 */

/datum/role/survivor
	id = SURVIVOR
	name = SURVIVOR
	logo_state = "gun-logo"
	var/survivor_type = "survivor"
	var/summons_received

/datum/role/survivor/crusader
	id = CRUSADER
	name = CRUSADER
	survivor_type = "crusader"
	logo_state = "sword-logo"

/datum/role/survivor/Greet()
	to_chat(antag.current, "<B>You are a [survivor_type]!</B><BR>Your own safety matters above all else, trust no one and kill anyone who gets in your way. However, armed as you are, now would be the perfect time to settle that score or grab that pair of yellow gloves you've been eyeing...")

/datum/role/survivor/ForgeObjectives()
	var/datum/objective/survive/S = new
	AppendObjective(S)

/datum/role/survivor/GetScoreboard()
	. = ..()
	. += "The [name] received the following as a result of a summoning spell: [summons_received]<BR>"

/datum/role/survivor/bomber
	id = BOMBER
	name = BOMBER
	survivor_type = "mad bomber"

/datum/role/survivor/bomber/Greet()
	to_chat(antag.current, "<B>You are a [survivor_type]!</B><BR>You want to make your own mark on history by following in the footsteps of a legendary bomber! Detonate, bomb, explode! But most importantly, try to survive!")

/datum/role/survivor/bomber/ForgeObjectives()
	var/datum/objective/survive/bomber/B = new
	AppendObjective(B)

/datum/role/survivor/saboteur
	id = SABOTEUR
	name = SABOTEUR
	survivor_type = "saboteur"

/datum/role/survivor/saboteur/Greet()
	var/department = pick("Cargo", "Command", "Security", "Science", "Medbay", "Engineering")
	var/excuse = pick("for killing your dog", "just for fun", "because the captain called you a nerd", "because Centcomm did not respond to your messages", "for suffering xenos to live", "because the wizard just brainwashed you", "because someone got away with beating you", "because someone told you to", "for no real reason", "because you were declined access in [department]")
	to_chat(antag.current, "<B>You are a [survivor_type]!</B><BR>You've had enough with the station, and you want to sabotage Nanotrasen [excuse]. Sabotage the station and teach the megacorporation a lesson!")

/datum/role/survivor/saboteur/ForgeObjectives()
	var/datum/objective/survive/saboteur/S = new
	AppendObjective(S)

/datum/role/survivor/mech
	id = MECH_WARRIOR
	name = MECH_WARRIOR
	survivor_type = "mech warrior"

/datum/role/survivor/mech/Greet()
	to_chat(antag.current, "<B>You are a [survivor_type]!</B><BR>You are here to engage others in honorable (or dishonorable) exosuit combat! Seek other mech warriors (anyone riding a mech) and challenge them to battle! Or just kill people at random, it's your choice!")

/datum/role/survivor/mech/ForgeObjectives()
	var/datum/objective/survive/mech/M = new
	AppendObjective(M)

/datum/role/survivor/mech/GetScoreboard()
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
	to_chat(antag.current, "<B>You are a Magician!</B><BR>Your own safety matters above all else, trust no one and kill anyone who gets in your way. However, armed as you are, now would be the perfect time to settle that score or grab that pair of yellow gloves you've been eyeing...")

/datum/role/wizard/summon_magic/OnPostSetup()
	return TRUE

/datum/role/wizard/summon_magic/GetScoreboard()
	. = ..()
	. += "The [name] received the following as a result of a summoning spell: [summons_received]<BR>"