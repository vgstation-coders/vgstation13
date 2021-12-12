// PLASMEN SHIT
// CAN'T WEAR UNLESS YOU'RE A PINK SKELLINGTON
/obj/item/clothing/suit/space/plasmaman
	name = "plasmaman suit"
	desc = "A special containment suit designed to protect a plasmaman's volatile body from outside exposure and quickly extinguish it in emergencies."
	w_class = W_CLASS_MEDIUM
	allowed = list(/obj/item/weapon/gun,/obj/item/ammo_storage,/obj/item/ammo_casing,/obj/item/weapon/melee/baton,/obj/item/weapon/melee/energy/sword,/obj/item/weapon/handcuffs,/obj/item/weapon/tank)
	slowdown = HARDSUIT_SLOWDOWN_LOW
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 100, rad = 0)
	body_parts_covered = ARMS|LEGS|FULL_TORSO|FEET|HANDS
	max_heat_protection_temperature = SPACE_SUIT_MAX_HEAT_PROTECTION_TEMPERATURE
	species_restricted = list(PLASMAMAN_SHAPED)
	species_fit = list(PLASMAMAN_SHAPED)
	clothing_flags = PLASMAGUARD|CONTAINPLASMAMAN
	pressure_resistance = 40 * ONE_ATMOSPHERE //we can't change, so some resistance is needed

	icon_state = "plasmaman_suit"
	item_state = "plasmaman_suit"

	var/next_extinguish=0
	var/extinguish_cooldown=10 SECONDS

/obj/item/clothing/suit/space/plasmaman/proc/Extinguish(var/mob/living/carbon/human/H)
	if(next_extinguish > world.time)
		return

	next_extinguish = world.time + extinguish_cooldown
	to_chat(H, "<span class='warning'>Your suit automatically extinguishes the fire.</span>")
	H.ExtinguishMob()

/obj/item/clothing/suit/space/plasmaman/proc/regulate_temp_of_wearer(var/mob/living/carbon/human/H)
	if(H.bodytemperature < T0C+37)
		H.bodytemperature = min(H.bodytemperature+5,T0C+37)
	else
		H.bodytemperature = max(H.bodytemperature-5,T0C+37)

/obj/item/clothing/head/helmet/space/plasmaman
	name = "plasmaman helmet"
	desc = "A special containment helmet designed to protect a plasmaman's volatile body from outside exposure and quickly extinguish it in emergencies."
	clothing_flags = PLASMAGUARD|CONTAINPLASMAMAN
	pressure_resistance = 40 * ONE_ATMOSPHERE
	species_restricted = list(PLASMAMAN_SHAPED)
	species_fit = list(PLASMAMAN_SHAPED)
	eyeprot = 0

	icon_state = "plasmaman_helmet0"
	item_state = "plasmaman_helmet0"
	var/base_state = "plasmaman_helmet"
	light_range = 4
	var/on = 0
	var/no_light=0 // Disable the light on the atmos suit
	actions_types = list(/datum/action/item_action/toggle_light)
	body_parts_visible_override = 0//I mean technically the eyes are visible on the sprite, but they're manually drawn, the helmet itself not having any transparency, so w/e

/obj/item/clothing/head/helmet/space/plasmaman/attack_self(mob/user)
	if(no_light)
		return
	on = !on
	icon_state = "[base_state][on]"
	if(on)
		set_light()
	else
		kill_light()
	user.update_inv_head()

// Tc_ENGINEERING
/obj/item/clothing/suit/space/plasmaman/assistant
	name = "plasmaman assistant suit"
	icon_state = "plasmamanAssistant_suit"

/obj/item/clothing/head/helmet/space/plasmaman/assistant
	name = "plasmaman assistant helmet"
	icon_state = "plasmamanAssistant_helmet0"
	base_state = "plasmamanAssistant_helmet"

/obj/item/clothing/suit/space/plasmaman/atmostech
	name = "plasmaman atmospheric suit"
	icon_state = "plasmamanAtmos_suit"
	armor = list(melee = 20, bullet = 0, laser = 0,energy = 0, bomb = 25, bio = 100, rad = 0)
	allowed = list(/obj/item/device/flashlight, /obj/item/weapon/tank, /obj/item/device/t_scanner, /obj/item/device/rcd, /obj/item/tool/wrench/socket)
	max_heat_protection_temperature = FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE
	slowdown = HARDSUIT_SLOWDOWN_HIGH

/obj/item/clothing/head/helmet/space/plasmaman/atmostech
	name = "plasmaman atmospheric helmet"
	icon_state = "plasmamanAtmos_helmet0"
	base_state = "plasmamanAtmos_helmet"
	armor = list(melee = 20, bullet = 0, laser = 0,energy = 0, bomb = 25, bio = 100, rad = 0)
	max_heat_protection_temperature = FIRE_HELMET_MAX_HEAT_PROTECTION_TEMPERATURE

/obj/item/clothing/head/helmet/space/plasmaman/atmostech/New()
	actions_types += /datum/action/item_action/toggle_helmet_mask
	..()

/obj/item/clothing/suit/space/plasmaman/engineer
	name = "plasmaman engineer suit"
	icon_state = "plasmamanEngineer_suit"
	armor = list(melee = 40, bullet = 5, laser = 20,energy = 5, bomb = 35, bio = 100, rad = 80)
	allowed = list(/obj/item/device/flashlight, /obj/item/weapon/tank, /obj/item/device/t_scanner, /obj/item/device/rcd, /obj/item/tool/wrench/socket)
	pressure_resistance = 200 * ONE_ATMOSPHERE
	slowdown = HARDSUIT_SLOWDOWN_HIGH

/obj/item/clothing/head/helmet/space/plasmaman/engineer
	name = "plasmaman engineer helmet"
	icon_state = "plasmamanEngineer_helmet0"
	base_state = "plasmamanEngineer_helmet"
	armor = list(melee = 40, bullet = 5, laser = 20,energy = 5, bomb = 35, bio = 100, rad = 80)
	pressure_resistance = 200 * ONE_ATMOSPHERE
	eyeprot = 1

/obj/item/clothing/head/helmet/space/plasmaman/engineer/New()
	actions_types += /datum/action/item_action/toggle_helmet_mask
	..()

/obj/item/clothing/suit/space/plasmaman/engineer/ce
	name = "plasmaman chief engineer suit"
	icon_state = "plasmaman_CE"
	max_heat_protection_temperature = FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE

/obj/item/clothing/head/helmet/space/plasmaman/engineer/ce
	name = "plasmaman chief engineer helmet"
	icon_state = "plasmaman_CE_helmet0"
	base_state = "plasmaman_CE_helmet"
	max_heat_protection_temperature = FIRE_HELMET_MAX_HEAT_PROTECTION_TEMPERATURE


//SERVICE

/obj/item/clothing/suit/space/plasmaman/botanist
	name = "plasmaman botanist suit"
	icon_state = "plasmamanBotanist_suit"

/obj/item/clothing/head/helmet/space/plasmaman/botanist
	name = "plasmaman botanist helmet"
	icon_state = "plasmamanBotanist_helmet0"
	base_state = "plasmamanBotanist_helmet"

/obj/item/clothing/suit/space/plasmaman/librarian
	name = "plasmaman librarian suit"
	icon_state = "plasmamanLibrarian_suit"

/obj/item/clothing/head/helmet/space/plasmaman/librarian
	name = "plasmaman librarian helmet"
	icon_state = "plasmamanLibrarian_helmet0"
	base_state = "plasmamanLibrarian_helmet"

/obj/item/clothing/suit/space/plasmaman/chaplain
	name = "plasmaman chaplain suit"
	icon_state = "plasmamanChaplain_suit"

/obj/item/clothing/head/helmet/space/plasmaman/chaplain
	name = "plasmaman chaplain helmet"
	icon_state = "plasmamanChaplain_helmet0"
	base_state = "plasmamanChaplain_helmet"

/obj/item/clothing/suit/space/plasmaman/clown
	name = "plasmaman clown suit"
	icon_state = "plasmaman_Clown"

/obj/item/clothing/head/helmet/space/plasmaman/clown
	name = "plasmaman clown helmet"
	icon_state = "plasmaman_Clown_helmet0"
	base_state = "plasmaman_Clown_helmet"

/obj/item/clothing/suit/space/plasmaman/mime
	name = "plasmaman mime suit"
	icon_state = "plasmaman_Mime"

/obj/item/clothing/head/helmet/space/plasmaman/mime
	name = "plasmaman mime helmet"
	icon_state = "plasmaman_Mime_helmet0"
	base_state = "plasmaman_Mime_helmet"

/obj/item/clothing/suit/space/plasmaman/service
	name = "plasmaman service suit"
	icon_state = "plasmamanService_suit"

/obj/item/clothing/head/helmet/space/plasmaman/service
	name = "plasmaman service helmet"
	icon_state = "plasmamanService_helmet0"
	base_state = "plasmamanService_helmet"

/obj/item/clothing/suit/space/plasmaman/janitor
	name = "plasmaman janitor suit"
	icon_state = "plasmamanJanitor_suit"

/obj/item/clothing/head/helmet/space/plasmaman/janitor
	name = "plasmaman janitor helmet"
	icon_state = "plasmamanJanitor_helmet0"
	base_state = "plasmamanJanitor_helmet"

/obj/item/clothing/suit/space/plasmaman/lawyer
	name = "plasmaman lawyer suit"
	icon_state = "plasmamanlawyer_suit"

/obj/item/clothing/head/helmet/space/plasmaman/lawyer
	name = "plasmaman lawyer helmet"
	icon_state = "plasmamanlawyer_helmet0"
	base_state = "plasmamanlawyer_helmet"

/obj/item/clothing/suit/space/plasmaman/bee
	name = "plasmaman bee suit"
	icon_state = "plasmamanbee_suit"

/obj/item/clothing/head/helmet/space/plasmaman/bee
	name = "plasmaman bee helmet"
	icon_state = "plasmamanbee_helmet0"
	base_state = "plasmamanbee_helmet"

//CARGO

/obj/item/clothing/suit/space/plasmaman/cargo
	name = "plasmaman cargo suit"
	icon_state = "plasmamanCargo_suit"

/obj/item/clothing/head/helmet/space/plasmaman/cargo
	name = "plasmaman cargo helmet"
	icon_state = "plasmamanCargo_helmet0"
	base_state = "plasmamanCargo_helmet"

/obj/item/clothing/suit/space/plasmaman/miner
	name = "plasmaman miner suit"
	icon_state = "plasmamanMiner_suit"
	armor = list(melee = 30, bullet = 5, laser = 15,energy = 5, bomb = 30, bio = 100, rad = 20)
	slowdown = HARDSUIT_SLOWDOWN_LOW
	clothing_flags = GOLIATHREINFORCE|CONTAINPLASMAMAN

/obj/item/clothing/head/helmet/space/plasmaman/miner
	name = "plasmaman miner helmet"
	icon_state = "plasmamanMiner_helmet0"
	base_state = "plasmamanMiner_helmet"
	armor = list(melee = 30, bullet = 5, laser = 15,energy = 5, bomb = 30, bio = 100, rad = 20)
	clothing_flags = GOLIATHREINFORCE|CONTAINPLASMAMAN


// MEDSCI

/obj/item/clothing/suit/space/plasmaman/medical
	name = "plasmaman medical suit"
	icon_state = "plasmamanMedical_suit"

/obj/item/clothing/head/helmet/space/plasmaman/medical
	name = "plasmaman medical helmet"
	icon_state = "plasmamanMedical_helmet0"
	base_state = "plasmamanMedical_helmet"

/obj/item/clothing/suit/space/plasmaman/medical/paramedic
	name = "plasmaman paramedic suit"
	icon_state = "plasmaman_Paramedic"
	allowed = list(/obj/item/weapon/gun,/obj/item/ammo_storage,/obj/item/ammo_casing,/obj/item/weapon/melee/baton,/obj/item/weapon/melee/energy/sword,/obj/item/weapon/handcuffs,/obj/item/weapon/tank,/obj/item/roller)

/obj/item/clothing/head/helmet/space/plasmaman/medical/paramedic
	name = "plasmaman paramedic helmet"
	icon_state = "plasmaman_Paramedic_helmet0"
	base_state = "plasmaman_Paramedic_helmet"

/obj/item/clothing/suit/space/plasmaman/medical/chemist
	name = "plasmaman chemist suit"
	icon_state = "plasmaman_Chemist"

/obj/item/clothing/head/helmet/space/plasmaman/medical/chemist
	name = "plasmaman chemist helmet"
	icon_state = "plasmaman_Chemist_helmet0"
	base_state = "plasmaman_Chemist_helmet"

/obj/item/clothing/suit/space/plasmaman/medical/cmo
	name = "plasmaman chief medical officer suit"
	icon_state = "plasmaman_CMO"
	allowed = list(/obj/item/weapon/gun,/obj/item/ammo_storage,/obj/item/ammo_casing,/obj/item/weapon/melee/baton,/obj/item/weapon/melee/energy/sword,/obj/item/weapon/handcuffs,/obj/item/weapon/tank,/obj/item/roller)

/obj/item/clothing/head/helmet/space/plasmaman/medical/cmo
	name = "plasmaman chief medical officer helmet"
	icon_state = "plasmaman_CMO_helmet0"
	base_state = "plasmaman_CMO_helmet"

/obj/item/clothing/suit/space/plasmaman/science
	name = "plasmaman scientist suit"
	icon_state = "plasmamanScience_suit"

/obj/item/clothing/head/helmet/space/plasmaman/science
	name = "plasmaman scientist helmet"
	icon_state = "plasmamanScience_helmet0"
	base_state = "plasmamanScience_helmet"

/obj/item/clothing/head/helmet/space/plasmaman/science/New()
	actions_types += /datum/action/item_action/toggle_helmet_mask
	..()

/obj/item/clothing/suit/space/plasmaman/science/rd
	name = "plasmaman research director suit"
	icon_state = "plasmaman_RD"

/obj/item/clothing/head/helmet/space/plasmaman/science/rd
	name = "plasmaman research director helmet"
	icon_state = "plasmaman_RD_helmet0"
	base_state = "plasmaman_RD_helmet"


//SECURITY

/obj/item/clothing/suit/space/plasmaman/security
	name = "plasmaman security suit"
	icon_state = "plasmamanSecurity_suit"
	armor = list(melee = 40, bullet = 15, laser = 35,energy = 5, bomb = 35, bio = 100, rad = 20)

/obj/item/clothing/head/helmet/space/plasmaman/security
	name = "plasmaman security helmet"
	icon_state = "plasmamanSecurity_helmet0"
	base_state = "plasmamanSecurity_helmet"
	armor = list(melee = 40, bullet = 15, laser = 35,energy = 5, bomb = 35, bio = 100, rad = 20)
	eyeprot = 1

/obj/item/clothing/suit/space/plasmaman/security/detective
	name = "plasmaman detective suit"
	icon_state = "plasmamanDetective_suit"

/obj/item/clothing/head/helmet/space/plasmaman/security/detective
	name = "plasmaman detective helmet"
	icon_state = "plasmamanDetective_helmet0"
	base_state = "plasmamanDetective_helmet"

/obj/item/clothing/suit/space/plasmaman/security/hos
	name = "plasmaman head of security suit"
	icon_state = "plasmaman_HoS"

/obj/item/clothing/head/helmet/space/plasmaman/security/hos
	name = "plasmaman head of security helmet"
	icon_state = "plasmaman_HoS_helmet0"
	base_state = "plasmaman_HoS_helmet"

/obj/item/clothing/suit/space/plasmaman/security/hop
	name = "plasmaman head of personnel suit"
	icon_state = "plasmaman_HoP"

/obj/item/clothing/head/helmet/space/plasmaman/security/hop
	name = "plasmaman head of personnel helmet"
	icon_state = "plasmaman_HoP_helmet0"
	base_state = "plasmaman_HoP_helmet"

/obj/item/clothing/suit/space/plasmaman/security/captain
	name = "plasmaman captain suit"
	icon_state = "plasmaman_Captain"

/obj/item/clothing/head/helmet/space/plasmaman/security/captain
	name = "plasmaman captain helmet"
	icon_state = "plasmaman_Captain_helmet0"
	base_state = "plasmaman_Captain_helmet"


//MISC

/obj/item/clothing/suit/space/plasmaman/prisoner
	name = "plasmaman prisoner suit"
	icon_state = "plasmaman_prisoner_suit"
	max_heat_protection_temperature = null
	pressure_resistance = null
	allowed = list(/obj/item/weapon/tank)

/obj/item/clothing/head/helmet/space/plasmaman/prisoner
	name = "plasmaman prisoner helmet"
	icon_state = "plasmaman_prisoner_helmet0"
	base_state = "plasmaman_prisoner_helmet"
	pressure_resistance = null

/obj/item/clothing/suit/space/plasmaman/moltar
	name = "moltar's firesuit"
	icon_state = "plasmamanMoltar_suit"

/obj/item/clothing/head/helmet/space/plasmaman/moltar
	name = "moltar's mask"
	icon_state = "plasmamanMoltar_helmet"
	base_state = "plasmamanMoltar_helmet"
	no_light=1



//NUKEOPS

/obj/item/clothing/suit/space/plasmaman/nuclear //should just replace this with a ref to the normal suit
	name = "blood red plasmaman suit"
	icon_state = "plasmaman_Nukeops"
	armor = list(melee = 60, bullet = 50, laser = 30, energy = 15, bomb = 35, bio = 100, rad = 60)
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank,/obj/item/weapon/gun,/obj/item/ammo_storage,/obj/item/ammo_casing,/obj/item/weapon/melee/baton,/obj/item/weapon/melee/energy/sword,/obj/item/weapon/handcuffs)
	siemens_coefficient = 0.6

/obj/item/clothing/head/helmet/space/plasmaman/nuclear
	name = "blood red plasmaman helmet"
	icon_state = "plasmaman_Nukeops_helmet0"
	base_state = "plasmaman_Nukeops_helmet"
	armor = list(melee = 60, bullet = 50, laser = 30,energy = 15, bomb = 35, bio = 100, rad = 60)
	siemens_coefficient = 0.6
	var/obj/machinery/camera/camera

/obj/item/clothing/head/helmet/space/plasmaman/nuclear/attack_self(mob/user)
	if(camera)
		..(user)
	else
		camera = new /obj/machinery/camera(src)
		camera.network = list(CAMERANET_NUKE)
		cameranet.removeCamera(camera)
		camera.c_tag = user.name
		to_chat(user, "<span class='notice'>User scanned as [camera.c_tag]. Camera activated.</span>")

/obj/item/clothing/head/helmet/space/plasmaman/nuclear/examine(mob/user)
	..()
	if(get_dist(user,src) <= 1)
		to_chat(user, "<span class='info'>This helmet has a built-in camera. It's [camera ? "" : "in"]active.</span>")


//CULT

/obj/item/clothing/suit/space/plasmaman/cultist
	name = "plasmaman cultist armor"
	icon_state = "plasmaman_cult"
	item_state = "plasmaman_cult"
	desc = "A bulky suit of armour, menacing with red energy. It looks like it would fit a plasmaman."
	slowdown = 1
	armor = list(melee = 60, bullet = 50, laser = 30,energy = 15, bomb = 30, bio = 30, rad = 30)

/obj/item/clothing/head/helmet/space/plasmaman/cultist
	name = "plasmaman cultist helmet"
	icon_state = "plasmamanCult_helmet0"
	base_state = "plasmamanCult_helmet"
	desc = "A containment suit designed by the followers of Nar-Sie. It glows menacingly with unearthly flames."
	armor = list(melee = 60, bullet = 50, laser = 30,energy = 15, bomb = 30, bio = 30, rad = 30)

//Sith

/obj/item/clothing/suit/space/plasmaman/sith
	name = "plasmaman Sith suit"
	icon_state = "plasmaman_sith_suit"
	item_state = "plasmaman_sith_suit"
	desc = "A menacing armored suit that protects the wearer from harm, fit for a plasmaman. It appears to permanently seal itself once worn."
	armor = list(melee = 60, bullet = 50, laser = 50, energy = 50, bomb = 80, bio = 100, rad = 100)
	canremove = 0

/obj/item/clothing/suit/space/plasmaman/sith/acidable()
	return 0

//Unlike the suit, the helmet can be taken off
/obj/item/clothing/head/helmet/space/plasmaman/sith
	name = "plasmaman Sith helmet"
	icon_state = "plasmaman_sith_helmet0"
	item_state = "plasmaman_sith_helmet0"
	base_state = "plasmaman_sith_helmet"
	desc = "A menacing helmet that protects the wearer from harm, fit for a plasmaman."
	armor = list(melee = 60, bullet = 50, laser = 50, energy = 50, bomb = 80, bio = 100, rad = 100)

/obj/item/clothing/head/helmet/space/plasmaman/sith/acidable()
	return 0
