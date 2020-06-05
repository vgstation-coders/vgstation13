
// -- Vampire powers

/datum/power/vampire
	name = "Vampire Power"
	desc = "Vampire Power"
	granttext = "" // Displays the granttext if needed


// -- List of all vampire spells

/* Tier 0 : roundstart */
/datum/power/vampire/rejuvenate
	cost = 0
	spellpath = /spell/rejuvenate
	granttext = "You have gained the ability to rejuvnate your body and clean yourself of all incapacitating effects."

/datum/power/vampire/glare
	cost = 0
	spellpath = /spell/aoe_turf/glare

/datum/power/vampire/hypnotise
	cost = 0
	spellpath = /spell/targeted/hypnotise

/* Tier 1 */
/datum/power/vampire/shape
	cost = 100
	spellpath = /spell/shapeshift
	granttext = "You have gained the shapeshifting ability, at the cost of stored blood you can change your form permanently."

/datum/power/vampire/vision
	cost = 100
	spellpath = null // No spell for night vision.
	granttext = "Your vampiric vision has improved."
	store_in_memory = TRUE

/* Tier 2 */
/datum/power/vampire/disease
	cost = 150
	spellpath = /spell/targeted/disease
	granttext = "You have gained the Diseased Touch ability which causes those you touch to die shortly after unless treated medically."

/datum/power/vampire/cloak
	cost = 150
	spellpath = /spell/cloak
	granttext = "You have gained the Cloak of Darkness ability which when toggled makes you near invisible in the shroud of darkness."

/* Tier 3 */
/datum/power/vampire/bats
	cost = 200
	spellpath = /spell/aoe_turf/conjure/bats
	granttext = "You have gained the Summon Bats ability which allows you to summon a trio of angry space bats."

/datum/power/vampire/scream
	cost = 200
	spellpath = /spell/aoe_turf/screech
	granttext = "You have gained the Chiroptean Screech ability which stuns anything with ears in a large radius and shatters glass in the process."

/datum/power/vampire/heal
	cost = 200
	granttext = "Your rejuvination abilities have improved and will now heal you over time when used."
	store_in_memory = TRUE

/* Tier 3.5 (/vg/) */
/datum/power/vampire/jaunt
	cost = 250
	spellpath = /spell/targeted/ethereal_jaunt/vamp
	granttext = "You have gained the Mist Form ability which allows you to take on the form of mist for a short period and pass over any obstacle in your path."

/* Tier 4 */
/datum/power/vampire/slave
	cost = 300
	spellpath = /spell/targeted/enthrall
	granttext = "You have gained the Enthrall ability which at a heavy blood cost allows you to enslave a human that is not loyal to any other, forever."

/datum/power/vampire/blink
	cost = 300
	spellpath = /spell/aoe_turf/blink/vamp
	granttext = "You have gained the ability to shadowstep, which makes you disappear into nearby shadows at the cost of blood."

/* Tier 5 (/vg/) */
/datum/power/vampire/mature
	cost = 400
	granttext = "You have reached physical maturity. You are more vulnerable to holy things, and your vision has been improved greatly."
	store_in_memory = TRUE

/* Tier 6 (/vg/) */
/datum/power/vampire/shadow
	cost = 450
	spellpath = /spell/menace
	granttext = "You have gained mastery over the shadows. In the dark, you can mask your identity, instantly terrify non-vampires who approach you, and enter the chapel for a longer period of time."

/* Tier 66 (/vg/) */
/datum/power/vampire/charisma // Passive
	cost = 500
	granttext = "You develop an uncanny charismatic aura that makes you difficult to disobey. Hypnotise and Enthrall take less time to perform, and Enthrall works on implanted targets."
	store_in_memory = TRUE

/* Tier 666 (/vg/) */
/datum/power/vampire/undying
	cost = 666
	spellpath = /spell/undeath
	granttext = "You have reached the absolute peak of your power. Your abilities cannot be nullified very easily, and you may return from the grave so long as your body is not burned, destroyed or sanctified."
	store_in_memory = TRUE

/datum/power/vampire/cape
	cost = 666
	spellpath = /spell/targeted/equip_item/cape
	granttext = "You can also spawn a rather nice cape."
	store_in_memory = TRUE
