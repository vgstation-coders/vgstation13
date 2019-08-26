/obj/item/clothing/head/helmet/space/unathi/breacher
	name = "unathi breacher helmet"
	desc = "Some sort of ancient Unathi power helmet with ridiculous armor plating."
	armor = list(melee = 75, bullet = 75, laser = 75,energy = 75, bomb = 75, bio = 100, rad = 90)
	species_restricted = list(UNATHI_SHAPED)
	species_fit = list(UNATHI_SHAPED)
	icon_state = "unathi_breacher"
	item_state = "rig_helm"
	_color = "unathi_breacher"
	clothing_flags = PLASMAGUARD
	
/obj/item/clothing/suit/space/unathi/breacher
	name = "unathi breacher armor"
	desc = "Some sort of ancient Unathi power suit with ridiculous armor plating."
	icon_state = "unathi_breacher"
	item_state = "rig_suit"
	slowdown = HARDSUIT_SLOWDOWN_BULKY
	armor = list(melee = 75, bullet = 75, laser = 75,energy = 75, bomb = 75, bio = 100, rad = 90)
	species_restricted = list(UNATHI_SHAPED)
	species_fit = list(UNATHI_SHAPED)
	allowed = list(
		/obj/item/weapon/gun,
		/obj/item/device/flashlight,
		/obj/item/weapon/tank,
		/obj/item/weapon/melee/baton,
		/obj/item/weapon/reagent_containers/spray/pepper,
		/obj/item/ammo_storage,
		/obj/item/ammo_casing,
		/obj/item/weapon/handcuffs,
		/obj/item/weapon/bikehorn/baton,
		/obj/item/weapon/blunderbuss,
		/obj/item/weapon/legcuffs/bolas,
	)
	clothing_flags = PLASMAGUARD

/obj/item/clothing/head/helmet/space/unathi/battle
	name = "unathi battle helmet"
	desc = "Typical gear for the modern Unathi soldier."
	armor = list(melee = 60, bullet = 10, laser = 30, energy = 5, bomb = 45, bio = 100, rad = 10)
	species_restricted = list(UNATHI_SHAPED)
	species_fit = list(UNATHI_SHAPED)
	icon_state = "unathi_battle"
	item_state = "syndicate-helm-black"
	_color = "unathi_battle"

/obj/item/clothing/suit/space/unathi/battle
	name = "unathi battle armor"
	desc = "Typical Unathi battle suit. Looks like a fish, moves like a fish, steers like a cow."
	icon_state = "unathi_battle"
	item_state = "syndicate-black"
	armor = list(melee = 40, bullet = 30, laser = 30,energy = 15, bomb = 35, bio = 100, rad = 50)
	species_restricted = list(UNATHI_SHAPED)
	species_fit = list(UNATHI_SHAPED)
	allowed = list(
		/obj/item/weapon/gun,
		/obj/item/device/flashlight,
		/obj/item/weapon/tank,
		/obj/item/weapon/melee/baton,
		/obj/item/weapon/reagent_containers/spray/pepper,
		/obj/item/ammo_storage,
		/obj/item/ammo_casing,
		/obj/item/weapon/handcuffs,
		/obj/item/weapon/bikehorn/baton,
		/obj/item/weapon/blunderbuss,
		/obj/item/weapon/legcuffs/bolas,
	)
	slowdown = HARDSUIT_SLOWDOWN_BULKY

/obj/item/clothing/suit/space/unathi/soghun
	name = "unathi soghun armor"
	desc = "A Unathi suit designed after ancient soghun outfits."
	icon_state = "unathi_soghun"
	item_state = "space_suit_syndicate"
	armor = list(melee = 40, bullet = 30, laser = 30,energy = 15, bomb = 35, bio = 100, rad = 50)
	species_restricted = list(UNATHI_SHAPED)
	species_fit = list(UNATHI_SHAPED)
	allowed = list(
		/obj/item/weapon/gun,
		/obj/item/device/flashlight,
		/obj/item/weapon/tank,
		/obj/item/weapon/melee/baton,
		/obj/item/weapon/reagent_containers/spray/pepper,
		/obj/item/ammo_storage,
		/obj/item/ammo_casing,
		/obj/item/weapon/handcuffs,
		/obj/item/weapon/bikehorn/baton,
		/obj/item/weapon/blunderbuss,
		/obj/item/weapon/legcuffs/bolas,
	)
	slowdown = HARDSUIT_SLOWDOWN_LOW

// Vox space gear (vaccuum suit, low pressure armor)
// Can't be equipped by any other species due to bone structure and vox cybernetics.


//Raider Gear
/obj/item/clothing/suit/space/vox
	w_class = W_CLASS_MEDIUM
	allowed = list(/obj/item/weapon/gun,/obj/item/ammo_storage,/obj/item/ammo_casing,/obj/item/weapon/melee/baton,/obj/item/weapon/melee/energy/sword,/obj/item/weapon/handcuffs,/obj/item/weapon/tank)
	slowdown = HARDSUIT_SLOWDOWN_HIGH
	armor = list(melee = 60, bullet = 50, laser = 30,energy = 15, bomb = 30, bio = 30, rad = 30)
	max_heat_protection_temperature = SPACE_SUIT_MAX_HEAT_PROTECTION_TEMPERATURE
	species_restricted = list(VOX_SHAPED)
	species_fit = list(VOX_SHAPED)

/obj/item/clothing/head/helmet/space/vox
	armor = list(melee = 60, bullet = 50, laser = 30, energy = 15, bomb = 30, bio = 30, rad = 30)
	species_restricted = list(VOX_SHAPED)
	species_fit = list(VOX_SHAPED)

/obj/item/clothing/head/helmet/space/vox/pressure
	name = "alien helmet"
	icon_state = "vox-pressure"
	item_state = "vox-pressure"
	desc = "Hey, wasn't this a prop in \'The Abyss\'?"

/obj/item/clothing/suit/space/vox/pressure
	name = "alien pressure suit"
	icon_state = "vox-pressure"
	item_state = "vox-pressure"
	desc = "A huge, armored, pressurized suit, designed for distinctly nonhuman proportions."

/obj/item/clothing/head/helmet/space/vox/carapace
	name = "alien visor"
	icon_state = "vox-carapace"
	item_state = "vox-carapace"
	desc = "A glowing visor, perhaps stolen from a depressed Cylon."
	eyeprot = 3

/obj/item/clothing/suit/space/vox/carapace
	name = "alien carapace armor"
	icon_state = "vox-carapace"
	item_state = "vox-carapace"
	desc = "An armored, segmented carapace with glowing purple lights. It looks pretty run-down."

/obj/item/clothing/head/helmet/space/vox/stealth
	name = "alien stealth helmet"
	icon_state = "vox-stealth"
	item_state = "vox-stealth"
	desc = "A smoothly contoured, matte-black alien helmet."
	eyeprot = 3

/obj/item/clothing/suit/space/vox/stealth
	name = "alien stealth suit"
	icon_state = "vox-stealth"
	item_state = "vox-stealth"
	desc = "A sleek black suit. It seems to have a tail, and is very heavy."

/obj/item/clothing/head/helmet/space/vox/medic
	name = "alien goggled helmet"
	icon_state = "vox-medic"
	item_state = "vox-medic"
	desc = "An alien helmet with enormous goggled lenses."

/obj/item/clothing/suit/space/vox/medic
	name = "alien armor"
	icon_state = "vox-medic"
	item_state = "vox-medic"
	desc = "An almost organic looking nonhuman pressure suit."

/obj/item/clothing/under/vox
	has_sensor = 0
	species_restricted = list(VOX_SHAPED)

/obj/item/clothing/under/vox/vox_casual
	name = "alien clothing"
	desc = "This doesn't look very comfortable."
	icon_state = "vox-casual-1"
	_color = "vox-casual-1"
	item_state = "vox-casual-1"

/obj/item/clothing/under/vox/vox_robes
	name = "alien robes"
	desc = "Weird and flowing!"
	icon_state = "vox-casual-2"
	_color = "vox-casual-2"
	item_state = "vox-casual-2"

/obj/item/clothing/gloves/yellow/vox
	desc = "These bizarre gauntlets seem to be fitted for... bird claws?"
	name = "insulated gauntlets"
	icon_state = "gloves-vox"
	item_state = "gloves-vox"
	siemens_coefficient = 0
	permeability_coefficient = 0.05
	_color="gloves-vox"
	species_restricted = list(VOX_SHAPED)

/obj/item/clothing/shoes/magboots/vox

	desc = "A pair of heavy, jagged armored foot pieces. They seem suitable for a velociraptor."
	name = "vox boots"
	item_state = "boots-vox"
	icon_state = "boots-vox"
	species_restricted = list(VOX_SHAPED)

	mag_slow = MAGBOOTS_SLOWDOWN_MED

	stomp_attack_power = 30
	stomp_delay = 2 SECONDS
	stomp_boot = "clawed boot"
	stomp_hit = "gouges"

	footprint_type = /obj/effect/decal/cleanable/blood/tracks/footprints/vox //They're like those five-toed shoes except for vox and with only three toes

/obj/item/clothing/shoes/magboots/vox/togglemagpulse()
	//set name = "Toggle Floor Grip"
	if(usr.isUnconscious())
		return
	if(clothing_flags & MAGPULSE)
		clothing_flags &= ~(NOSLIP | MAGPULSE)
		slowdown = NO_SLOWDOWN
		to_chat(usr, "You retract the razor-sharp talons of your boots.")
		return 0
	else
		clothing_flags |= (NOSLIP | MAGPULSE)
		slowdown = mag_slow
		to_chat(usr, "You extend the razor-sharp talons of your boots.")
		return 1


// Vox Trader -- Same stats as civ gear, but looks like raiders. ///////////////////////////////
/obj/item/clothing/suit/space/vox/civ/trader // brownsuit
	name = "alien pressure suit"
	icon_state = "vox-pressure"
	item_state = "vox-pressure"
	desc = "A huge, pressurized suit, designed for distinctly nonhuman proportions. It looks unusually cheap, even for Vox."
	clothing_flags = GOLIATHREINFORCE

/obj/item/clothing/head/helmet/space/vox/civ/trader //brownhelmet
	name = "alien helmet"
	icon_state = "vox-pressure"
	item_state = "vox-pressure"
	desc = "Hey, wasn't this a prop in \'The Abyss\'?"
	clothing_flags = GOLIATHREINFORCE

/obj/item/clothing/suit/space/vox/civ/trader/carapace //carapace
	name = "alien carapace armor"
	icon_state = "vox-carapace"
	item_state = "vox-carapace"
	desc = "An armored, segmented carapace with glowing purple lights. It looks like someone stripped most of the armor off."

/obj/item/clothing/head/helmet/space/vox/civ/trader/carapace //carapace helmet
	name = "alien visor"
	icon_state = "vox-carapace"
	item_state = "vox-carapace"
	desc = "A glowing visor, perhaps stolen from a depressed Cylon."
	eyeprot = 3

/obj/item/clothing/suit/space/vox/civ/trader/medic // aquasuit
	name = "alien armor"
	icon_state = "vox-medic"
	item_state = "vox-medic"
	desc = "An almost organic looking nonhuman pressure suit."

/obj/item/clothing/head/helmet/space/vox/civ/trader/medic //aquahelmet
	name = "alien goggled helmet"
	icon_state = "vox-medic"
	item_state = "vox-medic"
	desc = "An alien helmet with enormous goggled lenses."

/obj/item/clothing/suit/space/vox/civ/trader/stealth // blacksuit
	name = "alien stealth suit"
	icon_state = "vox-stealth"
	item_state = "vox-stealth"
	desc = "A sleek black suit. It seems to have a tail, and is very heavy."

/obj/item/clothing/head/helmet/space/vox/civ/trader/stealth //blackhelmet
	name = "alien stealth helmet"
	icon_state = "vox-stealth"
	item_state = "vox-stealth"
	desc = "A smoothly contoured, matte-black alien helmet.?"

// -- Mushroom,traders --

/obj/item/clothing/suit/space/vox/civ/mushmen
	name = "mushmen pressure suit"
	icon_state = "mushroom-pressure"
	item_state = "mushroom-pressure"
	desc = "It looks like a deformed vox pressure suit, fit for mushroom people."
	species_restricted = list(MUSHROOM_SHAPED)

/obj/item/clothing/head/helmet/space/vox/civ/mushmen
	actions_types = list(/datum/action/item_action/dim_lighting)
	name = "mushmen helmet"
	icon_state = "mushroom-pressure"
	item_state = "mushroom-pressure"
	desc = "It looks like a deformed vox pressure helmet, fit for mushroom people."
	species_restricted = list(MUSHROOM_SHAPED)
	var/up = 0

/obj/item/clothing/head/helmet/space/vox/civ/mushmen/attack_self(var/mob/user)
	toggle(user)

/obj/item/clothing/head/helmet/space/vox/civ/mushmen/proc/toggle(var/mob/user)
	if(!user.incapacitated())
		if(src.up)
			to_chat(user, "<span class='notice'>You use \the [src]'s visor to protect your face from incoming light.</span>")
		else
			to_chat(user, "<span class='notice'>You disengage \the [src]'s light protection visor.</span>")
		src.up = !src.up

/obj/item/clothing/head/helmet/space/vox/civ/mushmen/islightshielded()
	return !up


/datum/action/item_action/dim_lighting
	name = "Dim lighting"

// Vox Casual//////////////////////////////////////////////
// Civvie
/obj/item/clothing/suit/space/vox/civ
	name = "vox assistant pressure suit"
	desc = "A cheap and oddly-shaped pressure suit made for vox crewmembers."
	icon_state = "vox-civ-assistant"
	item_state = "vox-pressure-normal"
	allowed = list(/obj/item/weapon/tank,/obj/item/weapon/pen,/obj/item/device/flashlight/pen)
	armor = list(melee = 5, bullet = 5, laser = 5, energy = 5, bomb = 0, bio = 100, rad = 25)
	pressure_resistance = 5 * ONE_ATMOSPHERE

/obj/item/clothing/head/helmet/space/vox/civ
	name = "vox assistant pressure helmet"
	icon_state = "vox-civ-assistant"
	item_state = "vox-pressure-normal"
	desc = "A very alien-looking helmet for vox crewmembers."
	flags = FPRINT|HIDEHAIRCOMPLETELY //Flags need updating from inheritance above
	armor = list(melee = 5, bullet = 5, laser = 5, energy = 5, bomb = 0, bio = 100, rad = 25)
	pressure_resistance = 5 * ONE_ATMOSPHERE
	eyeprot = 0

/obj/item/clothing/suit/space/vox/civ/bartender
	name = "vox bartender pressure suit"
	icon_state = "vox-civ-bartender"

/obj/item/clothing/head/helmet/space/vox/civ/bartender
	name = "vox bartender pressure helmet"
	icon_state = "vox-civ-bartender"

/obj/item/clothing/suit/space/vox/civ/chef
	name = "vox chef pressure suit"
	icon_state = "vox-civ-chef"

/obj/item/clothing/head/helmet/space/vox/civ/chef
	name = "vox chef pressure helmet"
	icon_state = "vox-civ-chef"

/obj/item/clothing/suit/space/vox/civ/botanist
	name = "vox botanist pressure suit"
	icon_state = "vox-civ-botanist"

/obj/item/clothing/head/helmet/space/vox/civ/botanist
	name = "vox botanist pressure helmet"
	icon_state = "vox-civ-botanist"

/obj/item/clothing/suit/space/vox/civ/janitor
	name = "vox janitor pressure suit"
	icon_state = "vox-civ-janitor"

/obj/item/clothing/head/helmet/space/vox/civ/janitor
	name = "vox janitor pressure helmet"
	icon_state = "vox-civ-janitor"

/obj/item/clothing/suit/space/vox/civ/cargo
	name = "vox cargo pressure suit"
	icon_state = "vox-civ-cargo"

/obj/item/clothing/head/helmet/space/vox/civ/cargo
	name = "vox cargo pressure helmet"
	icon_state = "vox-civ-cargo"

/obj/item/clothing/suit/space/vox/civ/mechanic
	name = "vox mechanic pressure suit"
	icon_state = "vox-civ-mechanic"

/obj/item/clothing/head/helmet/space/vox/civ/mechanic
	name = "vox mechanic pressure helmet"
	icon_state = "vox-civ-mechanic"

/obj/item/clothing/suit/space/vox/civ/librarian
	name = "vox librarian pressure suit"
	icon_state = "vox-civ-librarian"

/obj/item/clothing/head/helmet/space/vox/civ/librarian
	name = "vox librarian pressure helmet"
	icon_state = "vox-civ-librarian"

/obj/item/clothing/suit/space/vox/civ/chaplain
	name = "vox chaplain pressure suit"
	icon_state = "vox-civ-chaplain"

/obj/item/clothing/head/helmet/space/vox/civ/chaplain
	name = "vox chaplain pressure helmet"
	icon_state = "vox-civ-chaplain"

/obj/item/clothing/suit/space/vox/civ/mining
	name = "vox mining pressure suit"
	icon_state = "vox-civ-mining"
	clothing_flags = GOLIATHREINFORCE

/obj/item/clothing/head/helmet/space/vox/civ/mining
	name = "vox mining pressure helmet"
	icon_state = "vox-civ-mining"
	clothing_flags = GOLIATHREINFORCE

//Engineering
/obj/item/clothing/suit/space/vox/civ/engineer
	name = "vox engineer pressure suit"
	desc = "A cheap and oddly-shaped pressure suit made for vox crewmembers. This one comes with more radiation protection."
	icon_state = "vox-civ-engineer"
	item_state = "vox-pressure-engineer"
	armor = list(melee = 5, bullet = 5, laser = 5, energy = 5, bomb = 0, bio = 100, rad = 50)
	allowed = list(/obj/item/device/flashlight, /obj/item/weapon/tank, /obj/item/device/t_scanner, /obj/item/device/rcd, /obj/item/weapon/wrench/socket)
	max_heat_protection_temperature = SPACE_SUIT_MAX_HEAT_PROTECTION_TEMPERATURE
	pressure_resistance = 200 * ONE_ATMOSPHERE

/obj/item/clothing/head/helmet/space/vox/civ/engineer
	name = "vox engineer pressure helmet"
	icon_state = "vox-civ-engineer"
	item_state = "vox-pressure-engineer"
	desc = "A very alien-looking helmet for vox crewmembers. This one comes with more radiation protection."
	armor = list(melee = 5, bullet = 5, laser = 5, energy = 5, bomb = 0, bio = 100, rad = 50)
	max_heat_protection_temperature = SPACE_SUIT_MAX_HEAT_PROTECTION_TEMPERATURE
	pressure_resistance = 200 * ONE_ATMOSPHERE
	eyeprot = 3

/obj/item/clothing/suit/space/vox/civ/engineer/atmos
	name = "vox atmos pressure suit"
	desc = "A cheap and oddly-shaped pressure suit made for vox crewmembers. Has some heat protection."
	icon_state = "vox-civ-atmos"
	armor = list(melee = 5, bullet = 5, laser = 5, energy = 5, bomb = 0, bio = 100, rad = 10)
	clothing_flags = PLASMAGUARD
	max_heat_protection_temperature = FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE

/obj/item/clothing/head/helmet/space/vox/civ/engineer/atmos
	name = "vox atmos pressure helmet"
	icon_state = "vox-civ-atmos"
	desc = "A very alien-looking helmet for vox crewmembers. Has some heat protection."
	armor = list(melee = 5, bullet = 5, laser = 5, energy = 5, bomb = 0, bio = 100, rad = 10)
	clothing_flags = PLASMAGUARD
	max_heat_protection_temperature = FIRE_HELMET_MAX_HEAT_PROTECTION_TEMPERATURE

/obj/item/clothing/suit/space/vox/civ/engineer/ce
	name = "vox chief engineer pressure suit"
	desc = "A more advanced pressure suit made for vox crewmembers. Has some radiation and heat protection."
	icon_state = "vox-civ-ce"
	armor = list(melee = 10, bullet = 5, laser = 10, energy = 5, bomb = 10, bio = 100, rad = 50)
	clothing_flags = PLASMAGUARD
	max_heat_protection_temperature = FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE

/obj/item/clothing/head/helmet/space/vox/civ/engineer/ce
	name = "vox chief engineer pressure helmet"
	icon_state = "vox-civ-ce"
	desc = "A very alien-looking helmet for vox crewmembers. Has some radiation and heat protection."
	clothing_flags = PLASMAGUARD
	max_heat_protection_temperature = FIRE_HELMET_MAX_HEAT_PROTECTION_TEMPERATURE

//Science
/obj/item/clothing/suit/space/vox/civ/science
	name = "vox science pressure suit"
	desc = "A cheap and oddly-shaped pressure suit made for vox crewmembers. This one is for SCIENCE!"
	icon_state = "vox-civ-science"
	item_state = "vox-pressure-science"
	armor = list(melee = 5, bullet = 5, laser = 5, energy = 5, bomb = 10, bio = 100, rad = 25)

/obj/item/clothing/head/helmet/space/vox/civ/science
	name = "vox science pressure helmet"
	icon_state = "vox-civ-science"
	item_state = "vox-pressure-science"
	desc = "A very alien-looking helmet for vox crewmembers. This one is for SCIENCE!"
	armor = list(melee = 5, bullet = 5, laser = 5, energy = 5, bomb = 10, bio = 100, rad = 25)
	eyeprot = 0

/obj/item/clothing/suit/space/vox/civ/science/rd
	name = "vox research director pressure suit"
	desc = "A cheap and oddly-shaped pressure suit made for vox crewmembers. This one is for the head of SCIENCE!"
	icon_state = "vox-civ-rd"

/obj/item/clothing/head/helmet/space/vox/civ/science/rd
	name = "vox research director pressure helmet"
	icon_state = "vox-civ-rd"
	desc = "A very alien-looking helmet for vox crewmembers. This one is for head of SCIENCE!"

/obj/item/clothing/suit/space/vox/civ/science/roboticist
	name = "vox roboticist pressure suit"
	desc = "A cheap and oddly-shaped pressure suit made for vox crewmembers. This one is for roboticists."
	icon_state = "vox-civ-roboticist"

/obj/item/clothing/head/helmet/space/vox/civ/science/roboticist
	name = "vox roboticist pressure helmet"
	icon_state = "vox-civ-roboticist"
	desc = "A very alien-looking helmet for vox crewmembers. This one is for roboticists."
	actions_types = list(/datum/action/item_action/toggle_helmet_mask)


//Med/Sci
/obj/item/clothing/suit/space/vox/civ/medical
	name = "vox medical pressure suit"
	desc = "A cheap and oddly-shaped pressure suit made for vox crewmembers. This one is for medical personnel."
	icon_state = "vox-civ-medical"
	item_state = "vox-pressure-medical"
	allowed = list(/obj/item/weapon/tank,/obj/item/device/flashlight,/obj/item/weapon/storage/firstaid,/obj/item/device/healthanalyzer,/obj/item/stack/medical)
	pressure_resistance = 40 * ONE_ATMOSPHERE

/obj/item/clothing/head/helmet/space/vox/civ/medical
	name = "vox medical pressure helmet"
	icon_state = "vox-civ-medical"
	item_state = "vox-pressure-medical"
	desc = "A very alien-looking helmet for Nanotrasen-hired Vox. This one is for medical personnel."
	pressure_resistance = 40 * ONE_ATMOSPHERE
	eyeprot = 0

/obj/item/clothing/suit/space/vox/civ/medical/virologist
	name = "vox virologist pressure suit"
	desc = "A cheap and oddly-shaped pressure suit made for vox crewmembers. This one is for virologists."
	icon_state = "vox-civ-virologist"

/obj/item/clothing/head/helmet/space/vox/civ/medical/virologist
	name = "vox virologist pressure helmet"
	icon_state = "vox-civ-virologist"
	desc = "A very alien-looking helmet for Nanotrasen-hired Vox. This one is for virologists."

/obj/item/clothing/suit/space/vox/civ/medical/chemist
	name = "vox chemist pressure suit"
	desc = "A cheap and oddly-shaped pressure suit made for vox crewmembers. This one is for chemists."
	icon_state = "vox-civ-chemist"

/obj/item/clothing/head/helmet/space/vox/civ/medical/chemist
	name = "vox chemist pressure helmet"
	icon_state = "vox-civ-chemist"
	desc = "A very alien-looking helmet for Nanotrasen-hired Vox. This one is for chemists."

/obj/item/clothing/suit/space/vox/civ/medical/geneticist
	name = "vox geneticist pressure suit"
	desc = "A cheap and oddly-shaped pressure suit made for vox crewmembers. This one is for geneticists."
	icon_state = "vox-civ-geneticist"

/obj/item/clothing/head/helmet/space/vox/civ/medical/geneticist
	name = "vox geneticist pressure helmet"
	icon_state = "vox-civ-geneticist"
	desc = "A very alien-looking helmet for Nanotrasen-hired Vox. This one is for geneticists."

/obj/item/clothing/suit/space/vox/civ/medical/paramedic
	name = "vox paramedic pressure suit"
	desc = "A cheap and oddly-shaped pressure suit made for vox crewmembers. This one is for paramedics."
	icon_state = "vox-civ-paramedic"
	allowed = list(/obj/item/weapon/tank,/obj/item/device/flashlight,/obj/item/weapon/storage/firstaid,/obj/item/device/healthanalyzer,/obj/item/stack/medical,/obj/item/roller)

/obj/item/clothing/head/helmet/space/vox/civ/medical/paramedic
	name = "vox paramedic pressure helmet"
	icon_state = "vox-civ-paramedic"
	desc = "A very alien-looking helmet for Nanotrasen-hired Vox. This one is for paramedics."

/obj/item/clothing/suit/space/vox/civ/medical/cmo
	name = "vox CMO pressure suit"
	desc = "A cheap and oddly-shaped pressure suit made for vox crewmembers. This one is for the CMO."
	icon_state = "vox-civ-cmo"
	allowed = list(/obj/item/weapon/tank,/obj/item/device/flashlight,/obj/item/weapon/storage/firstaid,/obj/item/device/healthanalyzer,/obj/item/stack/medical,/obj/item/roller)

/obj/item/clothing/head/helmet/space/vox/civ/medical/cmo
	name = "vox CMO pressure helmet"
	icon_state = "vox-civ-cmo"
	desc = "A very alien-looking helmet for Nanotrasen-hired Vox. This one is for the CMO."

//Security
/obj/item/clothing/suit/space/vox/civ/security
	name = "vox security pressure suit"
	desc = "A cheap and oddly-shaped pressure suit made for vox crewmembers. This one is for security aligned vox."
	icon_state = "vox-civ-security"
	item_state = "vox-pressure-security"
	armor = list(melee = 60, bullet = 10, laser = 30, energy = 5, bomb = 45, bio = 100, rad = 10)
	allowed = list(/obj/item/weapon/tank,/obj/item/weapon/gun,/obj/item/device/flashlight,/obj/item/weapon/tank,/obj/item/weapon/melee/baton)
	pressure_resistance = 40 * ONE_ATMOSPHERE

/obj/item/clothing/head/helmet/space/vox/civ/security
	name = "vox security pressure helmet"
	icon_state = "vox-civ-security"
	item_state = "vox-pressure-security"
	desc = "A very alien-looking helmet for Nanotrasen-hired Vox. This one is for security aligned vox."
	pressure_resistance = 40 * ONE_ATMOSPHERE
	eyeprot = 3

//Old Vox Suits
/*
/obj/item/clothing/suit/space/vox/civ/old
	name = "vox civilian pressure suit"
	desc = "A modernized pressure suit for Vox who've decided to work for the winning team."
	icon_state = "vox-pressure-normal"
	item_state = "vox-pressure-normal"
	allowed = list(/obj/item/weapon/tank,/obj/item/weapon/pen,/obj/item/device/flashlight/pen)
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 100, rad = 10)
	species_restricted = list(VOX_SHAPED)

/obj/item/clothing/head/helmet/space/vox/civ/old
	name = "vox civilian pressure helmet"
	icon_state = "vox-pressure-normal"
	item_state = "vox-pressure-normal"
	desc = "A very alien-looking helmet for Nanotrasen-hired Vox."
	species_restricted = list(VOX_SHAPED)

/obj/item/clothing/suit/space/vox/civ/old/engineer
	name = "vox engineering pressure suit"
	desc = "A modernized pressure suit for Vox who've decided to work for the winning team.  This one comes with more radiation protection."
	icon_state = "vox-pressure-engineer"
	item_state = "vox-pressure-engineer"
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 100, rad = 80)

/obj/item/clothing/head/helmet/space/vox/civ/old/engineer
	name = "vox engineering pressure helmet"
	icon_state = "vox-pressure-engineer"
	item_state = "vox-pressure-engineer"
	desc = "A very alien-looking helmet for Nanotrasen-hired Vox. This one is yellow."

/obj/item/clothing/suit/space/vox/civ/old/science
	name = "vox science pressure suit"
	desc = "A modernized pressure suit for Vox who've decided to work for the winning team.  This one's for SCIENCE."
	icon_state = "vox-pressure-science"
	item_state = "vox-pressure-science"

/obj/item/clothing/head/helmet/space/vox/civ/old/science
	name = "vox science pressure helmet"
	icon_state = "vox-pressure-science"
	item_state = "vox-pressure-science"
	desc = "A very alien-looking helmet for Nanotrasen-hired Vox. This one is white."

/obj/item/clothing/suit/space/vox/civ/old/medical
	name = "vox medical pressure suit"
	desc = "A modernized pressure suit for Vox who've decided to work for the winning team.  This one's for medical personnel."
	icon_state = "vox-pressure-medical"
	item_state = "vox-pressure-medical"
	allowed = list(/obj/item/weapon/tank,/obj/item/device/flashlight,/obj/item/weapon/storage/firstaid,/obj/item/device/healthanalyzer,/obj/item/stack/medical)

/obj/item/clothing/head/helmet/space/vox/civ/old/medical
	name = "vox medical pressure helmet"
	icon_state = "vox-pressure-medical"
	item_state = "vox-pressure-medical"
	desc = "A very alien-looking helmet for Nanotrasen-hired Vox. This one is white."

/obj/item/clothing/suit/space/vox/civ/old/security
	name = "vox medical pressure suit"
	desc = "A modernized pressure suit for Vox who've decided to work for shitcurity."
	icon_state = "vox-pressure-security"
	item_state = "vox-pressure-security"
	armor = list(melee = 60, bullet = 10, laser = 30, energy = 5, bomb = 45, bio = 100, rad = 10)
	allowed = list(/obj/item/weapon/tank,/obj/item/weapon/gun,/obj/item/device/flashlight,/obj/item/weapon/tank,/obj/item/weapon/melee/baton)

/obj/item/clothing/head/helmet/space/vox/civ/old/security
	name = "vox security pressure helmet"
	icon_state = "vox-pressure-security"
	item_state = "vox-pressure-security"
	desc = "A very alien-looking helmet for Nanotrasen-hired Vox. This one is for shitcurity."
*/

//Grey spacesuit

/obj/item/clothing/head/helmet/space/grey
	name = "grey pressure helmet"
	icon_state = "grey-fishbowl-helm"
	item_state = "grey-fishbowl-helm"
	desc = "A strange globe-like structure. Despite looking like a decent glare would break it, it is surprisingly durable. Enough thinking room for a Grey."
	armor = list(melee = 5, bullet = 5, laser = 5, energy = 5, bomb = 10, bio = 100, rad = 50)
	max_heat_protection_temperature = SPACE_SUIT_MAX_HEAT_PROTECTION_TEMPERATURE
	heat_conductivity = SPACESUIT_HEAT_CONDUCTIVITY
	body_parts_covered = FULL_HEAD|IGNORE_INV
	species_restricted = list(GREY_SHAPED)
	species_fit = list(GREY_SHAPED)

/obj/item/clothing/suit/space/grey
	name = "grey pressure suit"
	icon_state = "grey-pressure-suit"
	item_state = "grey-pressure-suit"
	desc = "A strange suit comprised of a series of tubes. Despite looking like a decent wind could tear it apart, it is surprisingly durable. Too thin for anything but a Grey to wear it."
	armor = list(melee = 5, bullet = 5, laser = 5, energy = 5, bomb = 10, bio = 100, rad = 50)
	species_restricted = list(GREY_SHAPED)
	species_fit = list(GREY_SHAPED)


//Martian Fishbowl

/obj/item/clothing/head/helmet/space/martian
	name = "alien pressure helmet"
	icon_state = "bubblehelm"
	icon = 'icons/obj/clothing/martian.dmi'
	item_state = "bubblehelm"
	desc = "A very spacious container, with a slot on the back for pressurized tanks to sustain an internal atmosphere."
	max_heat_protection_temperature = SPACE_SUIT_MAX_HEAT_PROTECTION_TEMPERATURE
	heat_conductivity = SPACESUIT_HEAT_CONDUCTIVITY
	body_parts_covered = FULL_HEAD|IGNORE_INV
	species_restricted = list("Martian")
	var/obj/item/weapon/tank/tank

/obj/item/clothing/head/helmet/space/martian/attackby(obj/item/W,mob/user)
	if(istype(W, /obj/item/weapon/tank) && !tank)
		to_chat(user, "<span class = 'notice'>You start attaching \the [W] to \the [src].</span>")
		if(do_after(user,src, 50))
			if(user.drop_item(W, src))
				playsound(src,'sound/effects/refill.ogg',50,1)
				to_chat(user, "<span class = 'notice'>You attach \the [W] to \the [src]!</span>")
				tank = W
				item_state = "[initial(item_state)]_mask"
				return
	..()

/obj/item/clothing/head/helmet/space/martian/attack_self(mob/user)
	if(tank)
		to_chat(user, "<span class = 'notice'>You start detaching \the [tank] from \the [src].</span>")
		if(do_after(user,src, 50))
			playsound(src,'sound/effects/refill.ogg',50,1)
			to_chat(user, "<span class = 'notice'>You detach \the [tank] from \the [src]!</span>")
			user.put_in_hands(tank)
			item_state = initial(item_state)
			tank = null
	..()

/obj/item/clothing/head/helmet/space/martian/examine(mob/user)
	..()
	if(tank)
		to_chat(user, "<span class = 'notice'>It has a [bicon(tank)][tank] attached to the back.</span>")
		
		
/obj/item/clothing/head/helmet/space/skrell/black
	name = "skrell combat helmet"
	desc = "a military Skrell space helmet."
	armor = list(melee = 60, bullet = 10, laser = 30, energy = 5, bomb = 45, bio = 100, rad = 10)
	species_restricted = list(SKRELL_SHAPED)
	species_fit = list(SKRELL_SHAPED)
	icon_state = "skrell_black"
	item_state = "syndicate-helm-black"
	_color = "skrell_black"

/obj/item/clothing/suit/space/skrell/black
	name = "skrell combat suit"
	desc = "a military Skrell space suit."
	icon_state = "skrell_black"
	item_state = "syndicate-black"
	armor = list(melee = 60, bullet = 10, laser = 30, energy = 5, bomb = 45, bio = 100, rad = 10)
	species_restricted = list(SKRELL_SHAPED)
	species_fit = list(SKRELL_SHAPED)
	allowed = list(
		/obj/item/weapon/gun,
		/obj/item/device/flashlight,
		/obj/item/weapon/tank,
		/obj/item/weapon/melee/baton,
		/obj/item/weapon/reagent_containers/spray/pepper,
		/obj/item/ammo_storage,
		/obj/item/ammo_casing,
		/obj/item/weapon/handcuffs,
		/obj/item/weapon/bikehorn/baton,
		/obj/item/weapon/blunderbuss,
		/obj/item/weapon/legcuffs/bolas,
	)
	slowdown = HARDSUIT_SLOWDOWN_LOW
	
/obj/item/clothing/head/helmet/space/skrell/white
	name = "skrell space helmet"
	desc = "a civilian Skrell space helmet."
	armor = list(melee = 30, bullet = 5, laser = 20,energy = 10, bomb = 20, bio = 10, rad = 20)
	species_restricted = list(SKRELL_SHAPED)
	species_fit = list(SKRELL_SHAPED)
	icon_state = "skrell_white"
	item_state = "medical_helm"
	_color = "skrell_white"

/obj/item/clothing/suit/space/skrell/white
	name = "skrell space suit"
	desc = "a civilian Skrell space suit."
	icon_state = "skrell_white"
	item_state = "medical_hardsuit"
	armor = list(melee = 30, bullet = 5, laser = 20,energy = 10, bomb = 20, bio = 10, rad = 20)
	species_restricted = list(SKRELL_SHAPED)
	species_fit = list(SKRELL_SHAPED)
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank,/obj/item/weapon/storage/)
	slowdown = HARDSUIT_SLOWDOWN_LOW