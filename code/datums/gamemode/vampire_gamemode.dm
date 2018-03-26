/datum/gamemode/vampire
	minimum_player_count = 10
	name = "Vampire"
	factions_allowed = list(/datum/faction/vampire)

// -- Vampire powers

/datum/power/vampire
	name = "Power"
	desc = "Placeholder"
	helptext = "No help text for vamps."
	isVerb = 0 	// Is it an active power, or passive?
	verbpath = null // Vampires have no verbs

	var/blood_threeshold = 0
	var/spell_path
	var/id

/datum/power/vampire/proc/Give(var/datum/role/vampire/V)
	if (!istype(V))
		message_admins("Error: trying to give a vampire power to a non-vampire.")

	if (spell_path)
		var/spell/S = new spell_path
		V.antag.current.add_spell(S)

	V.powers |= id

// -- List of all vampire spells

/* Tier 0 : roundstart */
/datum/power/vampire/rejuvenate
	blood_threeshold = 0
	id = VAMP_REJUV
	spell_path = /spell/rejuvenate

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

/datum/power/vampire/vision
	blood_threeshold = 100
	id = VAMP_VISION
	spell_path = null // No spell for night vision.

/* Tier 2 */
/datum/power/vampire/disease
	blood_threeshold = 150
	id = VAMP_DISEASE
	spell_path = /spell/targeted/disease

/datum/power/vampire/cloak
	blood_threeshold = 150
	id = VAMP_CLOAK
	spell_path = null // TODO

/* Tier 3 */
/datum/power/vampire/bats
	blood_threeshold = 200
	id = VAMP_BATS
	spell_path = null // TODO

/datum/power/vampire/scream
	blood_threeshold = 200
	id = VAMP_SCREAM
	spell_path = null // TODO

/datum/power/vampire/heal
	blood_threeshold = 200
	id = VAMP_HEAL

/* Tier 3.5 (/vg/) */
/datum/power/vampire/jaunt
	blood_threeshold = 250
	id = VAMP_JAUNT
	spell_path = null // TODO

/* Tier 4 */
/datum/power/vampire/slave
	blood_threeshold = 300
	id = VAMP_SLAVE
	spell_path = null // TODO

/datum/power/vampire/blink
	blood_threeshold = 300
	id = VAMP_BLINK
	spell_path = null // TODO

/* Tier 5 (/vg/) */
/datum/power/vampire/mature
	blood_threeshold = 400
	id = VAMP_MATURE

/* Tier 6 (/vg/) */
/datum/power/vampire/shadow
	blood_threeshold = 450
	id = VAMP_SHADOW
	spell_path = null // TODO

/* Tier 66 (/vg/) */
/datum/power/vampire/charisma
	blood_threeshold = 500
	id = VAMP_CHARISMA
	spell_path = null // TODO

/* Tier 666 (/vg/) */
/datum/power/vampire/undying
	blood_threeshold = 666
	id = VAMP_UNDYING
	spell_path = null // TODO