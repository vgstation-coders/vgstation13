/datum/gamemode/vampire
	minimum_player_count = 10
	name = "Vampire"
	factions_allowed = list(/datum/faction/vampire = 4) // Up to 4 vampires.

// -- Vampire powers

/datum/power/vampire
	name = "Power"
	desc = "Placeholder"
	helptext = "" // Displays the helptext if needed
	isVerb = 0 	// Is it an active power, or passive?
	verbpath = null // Vampires have no verbs

	var/blood_threeshold = 0
	var/spell_path
	var/id
	var/store_in_memory = FALSE

/datum/power/vampire/proc/Give(var/datum/role/vampire/V)
	if (!istype(V))
		message_admins("Error: trying to give a vampire power to a non-vampire.")
		return FALSE

	if (spell_path && !(locate(spell_path) in V.antag.current.spell_list))
		var/spell/S = new spell_path
		V.antag.current.add_spell(S)

	V.powers |= id

	if (helptext)
		to_chat(V.antag.current, "<span class = 'notice'>[helptext]</span>")

	if (store_in_memory)
		V.antag.store_memory("<font size = '1'>[helptext]</font>")

// -- List of all vampire spells

/* Tier 0 : roundstart */
/datum/power/vampire/rejuvenate
	blood_threeshold = 0
	id = VAMP_REJUV
	spell_path = /spell/rejuvenate
	helptext = "You have gained the ability to rejuvnate your body and clean yourself of all incapacitating effects."

/datum/power/vampire/glare
	blood_threeshold = 0
	id = VAMP_GLARE
	spell_path = /spell/aoe_turf/glare

/datum/power/vampire/hypnotise
	blood_threeshold = 0
	id = VAMP_HYPNO
	spell_path = /spell/targeted/hypnotise

/* Tier 1 */
/datum/power/vampire/shape
	blood_threeshold = 100
	id = VAMP_SHAPE
	spell_path = /spell/shapeshift
	helptext = "You have gained the shapeshifting ability, at the cost of stored blood you can change your form permanently."

/datum/power/vampire/vision
	blood_threeshold = 100
	id = VAMP_VISION
	spell_path = null // No spell for night vision.
	helptext = "Your vampiric vision has improved."
	store_in_memory = TRUE

/* Tier 2 */
/datum/power/vampire/disease
	blood_threeshold = 150
	id = VAMP_DISEASE
	spell_path = /spell/targeted/disease
	helptext = "You have gained the Diseased Touch ability which causes those you touch to die shortly after unless treated medically."

/datum/power/vampire/cloak
	blood_threeshold = 150
	id = VAMP_CLOAK
	spell_path = /spell/cloak
	helptext = "You have gained the Cloak of Darkness ability which when toggled makes you near invisible in the shroud of darkness."

/* Tier 3 */
/datum/power/vampire/bats
	blood_threeshold = 200
	id = VAMP_BATS
	spell_path = /spell/aoe_turf/conjure/bats
	helptext = "You have gained the Summon Bats ability which allows you to summon a trio of angry space bats."

/datum/power/vampire/scream
	blood_threeshold = 200
	id = VAMP_SCREAM
	spell_path = /spell/aoe_turf/screech
	helptext = "You have gained the Chiroptean Screech ability which stuns anything with ears in a large radius and shatters glass in the process."

/datum/power/vampire/heal
	blood_threeshold = 200
	id = VAMP_HEAL
	helptext = "Your rejuvination abilities have improved and will now heal you over time when used."
	store_in_memory = TRUE

/* Tier 3.5 (/vg/) */
/datum/power/vampire/jaunt
	blood_threeshold = 250
	id = VAMP_JAUNT
	spell_path = /spell/targeted/ethereal_jaunt/vamp
	helptext = "You have gained the Mist Form ability which allows you to take on the form of mist for a short period and pass over any obstacle in your path."

/* Tier 4 */
/datum/power/vampire/slave
	blood_threeshold = 300
	id = VAMP_SLAVE
	spell_path = /spell/targeted/enthrall
	helptext = "You have gained the Enthrall ability which at a heavy blood cost allows you to enslave a human that is not loyal to any other, forever."

/datum/power/vampire/blink
	blood_threeshold = 300
	id = VAMP_BLINK
	spell_path = /spell/aoe_turf/blink/vamp
	helptext = "You have gained the ability to shadowstep, which makes you disappear into nearby shadows at the cost of blood."

/* Tier 5 (/vg/) */
/datum/power/vampire/mature
	blood_threeshold = 400
	id = VAMP_MATURE
	helptext = "You have reached physical maturity. You are more vulnerable to holy things, and your vision has been improved greatly."
	store_in_memory = TRUE

/* Tier 6 (/vg/) */
/datum/power/vampire/shadow
	blood_threeshold = 450
	id = VAMP_SHADOW
	spell_path = /spell/menace
	helptext = "You have gained mastery over the shadows. In the dark, you can mask your identity, instantly terrify non-vampires who approach you, and enter the chapel for a longer period of time."

/* Tier 66 (/vg/) */
/datum/power/vampire/charisma // Passive
	blood_threeshold = 500
	id = VAMP_CHARISMA
	helptext = "You develop an uncanny charismatic aura that makes you difficult to disobey. Hypnotise and Enthrall take less time to perform, and Enthrall works on implanted targets."
	store_in_memory = TRUE

/* Tier 666 (/vg/) */
/datum/power/vampire/undying
	blood_threeshold = 666
	id = VAMP_UNDYING
	spell_path = /spell/undeath
	helptext = "You have reached the absolute peak of your power. Your abilities cannot be nullified very easily, and you may return from the grave so long as your body is not burned, destroyed or sanctified."
	store_in_memory = TRUE

/datum/power/vampire/cape
	blood_threeshold = 666
	id = VAMP_CAPE
	spell_path = /spell/targeted/equip_item/cape
	helptext = "You can also spawn a rather nice cape."
	store_in_memory = TRUE
