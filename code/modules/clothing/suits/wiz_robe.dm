/obj/item/clothing/head/wizard
	name = "wizard hat"
	desc = "Strange-looking hat-wear that most certainly belongs to a real magic user."
	icon_state = "wizard"
	//Not given any special protective value since the magic robes are full-body protection --NEO
	siemens_coefficient = 0.8

	wizard_garb = 1

/obj/item/clothing/head/wizard/red
	name = "red wizard hat"
	desc = "Strange-looking red hat-wear that most certainly belongs to a real magic user."
	icon_state = "redwizard"
	siemens_coefficient = 0.8

/obj/item/clothing/head/wizard/fake
	name = "wizard hat"
	desc = "It has WIZZARD written across it in sequins. Comes with a cool beard."
	icon_state = "wizard-fake"

/obj/item/clothing/head/wizard/marisa
	name = "Witch Hat"
	desc = "Strange-looking hat-wear, makes you want to cast fireballs."
	icon_state = "marisa"
	siemens_coefficient = 0.8

/obj/item/clothing/head/wizard/magus
	name = "Magus Helm"
	desc = "A mysterious helmet that hums with an unearthly power."
	icon_state = "magus"
	item_state = "magus"
	siemens_coefficient = 0.8

/obj/item/clothing/head/wizard/magus/fake
	desc = "A mysterious helmet."
	wizard_garb = 0

/obj/item/clothing/head/wizard/clown
	name = "purple wizard hat"
	desc = "Strange-looking purple hat-wear that most certainly belongs to a real magic user."
	icon_state = "wizhatclown"
	item_state = "wizhatclown" // cheating
	siemens_coefficient = 0.8

/obj/item/clothing/head/wizard/clown/fake
	desc = "Strange-looking purple hat-wear that most certainly doesn't belong to a real magic user."
	wizard_garb = 0

/obj/item/clothing/head/wizard/amp
	name = "psychic amplifier"
	desc = "A crown-of-thorns psychic amplifier. Kind of looks like a tiara having sex with an industrial robot."
	icon_state = "amp"
	siemens_coefficient = 0.8

/obj/item/clothing/head/wizard/necro
	name = "Hood of Necromancy"
	desc = "An elegant hood woven with the souls of the undying."
	icon_state = "necromancer"
	item_state = "necrohood"
	siemens_coefficient = 0.8

/obj/item/clothing/head/wizard/necro/fake
	desc = "An elegant hood woven with child labor somewhere in Space China."
	wizard_garb = 0

/obj/item/clothing/head/wizard/magician
	name = "Magical Tophat"
	desc = "A magical tophat perfect for any magical performance."
	icon_state = "tophat"
	item_state = "tophat"
	siemens_coefficient = 0.8

/obj/item/clothing/head/wizard/lich
	name = "crown of the Lich"
	desc = "Get the Lich a crown, Liches love crowns."
	icon_state = "lichcrown_fancy"
	item_state = "lichcrown_fancy"
	siemens_coefficient = 0.8

/obj/item/clothing/head/wizard/skelelich
	name = "tarnished crown of the Lich"
	desc = "Turns out you CAN take it with you."
	icon_state = "lichcrown"
	item_state = "lichcrown"
	siemens_coefficient = 0.8

/obj/item/clothing/suit/wizrobe
	name = "wizard robe"
	desc = "A magnificant, gem-lined robe that seems to radiate power."
	icon_state = "wizard"
	item_state = "wizrobe"
	gas_transfer_coefficient = 0.01 // IT'S MAGICAL OKAY JEEZ +1 TO NOT DIE
	permeability_coefficient = 0.01
	armor = list(melee = 30, bullet = 20, laser = 20,energy = 20, bomb = 20, bio = 20, rad = 20)
	allowed = list(/obj/item/weapon/teleportation_scroll,/obj/item/weapon/gun/energy/staff)
	siemens_coefficient = 0.8

	wizard_garb = 1

/obj/item/clothing/suit/wizrobe/red
	name = "red wizard robe"
	desc = "A magnificant, red, gem-lined robe that seems to radiate power."
	icon_state = "redwizard"
	item_state = "redwizrobe"

/obj/item/clothing/suit/wizrobe/marisa
	name = "Witch Robe"
	desc = "Magic is all about the spell power, ZE!"
	icon_state = "marisa"
	item_state = "marisarobe"

/obj/item/clothing/suit/wizrobe/magusblue
	name = "Magus Robe"
	desc = "A set of armoured robes that seem to radiate a dark power."
	icon_state = "magusblue"
	item_state = "magusblue"

/obj/item/clothing/suit/wizrobe/magusred
	name = "Magus Robe"
	desc = "A set of armoured robes that seem to radiate a dark power."
	icon_state = "magusred"
	item_state = "magusred"

/obj/item/clothing/suit/wizrobe/clown
	name = "Clown Robe"
	desc = "A set of armoured robes that seem to radiate a dark power. That, and bad fashion decisions."
	icon_state = "wizzclown"
	item_state = "clownwizrobe"

/obj/item/clothing/suit/wizrobe/psypurple
	name = "purple robes"
	desc = "Heavy, royal purple robes threaded with psychic amplifiers and weird, bulbous lenses. Do not machine wash."
	icon_state = "psyamp"
	item_state = "psyamp"

/obj/item/clothing/suit/wizrobe/fake
	name = "wizard robe"
	desc = "A rather dull, blue robe meant to mimick real wizard robes."
	icon_state = "wizard-fake"
	item_state = "wizrobe"
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	siemens_coefficient = 1.0

/obj/item/clothing/suit/wizrobe/necro
	name = "Robe of Necromancy"
	desc = "An elegant robe woven with the souls of the undying."
	icon_state = "necromancer"
	item_state = "necrorobe"

/obj/item/clothing/head/wizard/marisa/fake
	name = "Witch Hat"
	desc = "Strange-looking hat-wear, makes you want to cast fireballs."
	icon_state = "marisa"
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	siemens_coefficient = 1.0

/obj/item/clothing/suit/wizrobe/marisa/fake
	name = "Witch Robe"
	desc = "Magic is all about the spell power, ZE!"
	icon_state = "marisa"
	item_state = "marisarobe"
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	siemens_coefficient = 1.0


/obj/item/clothing/suit/wizrobe/magician
	name = "Magical Suit"
	desc = "A magical stage outfit, perfect attire for sawwing assistants in half."
	icon_state = "magiciansuit"
	item_state = "magiciansuit"
	species_restricted = list("exclude",VOX_SHAPED) //this outfit won't work very well for Vox


/obj/item/clothing/suit/wizrobe/magician/fake
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	siemens_coefficient = 1.0


/obj/item/clothing/suit/wizrobe/lich
	name = "Lich robe"
	desc = "A set of fancy purple robes. They smell slightly of formaldehyde."
	icon_state = "lichrobe_fancy"
	item_state = "lichrobe_fancy"

/obj/item/clothing/suit/wizrobe/skelelich
	name = "tattered Lich robe"
	desc = "A threadbare grey robe. Even masters of the dead have laundry day."
	icon_state = "lichrobe"
	item_state = "lichrobe"

