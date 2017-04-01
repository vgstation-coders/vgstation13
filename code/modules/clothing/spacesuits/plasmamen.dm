// PLASMEN SHIT
// CAN'T WEAR UNLESS YOU'RE A PINK SKELLINGTON
/obj/item/clothing/suit/space/phoronman
	name = "phoronman suit"
	desc = "A special containment suit designed to protect a phoronman's volatile body from outside exposure and quickly extinguish it in emergencies."
	w_class = W_CLASS_MEDIUM
	allowed = list(/obj/item/weapon/gun,/obj/item/ammo_storage,/obj/item/ammo_casing,/obj/item/weapon/melee/baton,/obj/item/weapon/melee/energy/sword,/obj/item/weapon/handcuffs,/obj/item/weapon/tank)
	slowdown = 1
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 100, rad = 0)
	body_parts_covered = ARMS|LEGS|FULL_TORSO|FEET|HANDS
	max_heat_protection_temperature = SPACE_SUIT_MAX_HEAT_PROTECTION_TEMPERATURE
	species_restricted = list("Phoronman")
	clothing_flags = PHORONGUARD
	pressure_resistance = 40 * ONE_ATMOSPHERE //we can't change, so some resistance is needed

	icon_state = "phoronman_suit"
	item_state = "phoronman_suit"

	var/next_extinguish=0
	var/extinguish_cooldown=10 SECONDS

/obj/item/clothing/suit/space/phoronman/proc/Extinguish(var/mob/user)
	var/mob/living/carbon/human/H=user
	if(next_extinguish > world.time)
		return

	next_extinguish = world.time + extinguish_cooldown
	to_chat(H, "<span class='warning'>Your suit automatically extinguishes the fire.</span>")
	H.ExtinguishMob()

/obj/item/clothing/head/helmet/space/phoronman
	name = "phoronman helmet"
	desc = "A special containment helmet designed to protect a phoronman's volatile body from outside exposure and quickly extinguish it in emergencies."
	clothing_flags = PHORONGUARD
	pressure_resistance = 40 * ONE_ATMOSPHERE
	species_restricted = list("Phoronman")
	eyeprot = 0

	icon_state = "phoronman_helmet0"
	item_state = "phoronman_helmet0"
	var/base_state = "phoronman_helmet"
	var/brightness_on = 4 //luminosity when on
	var/on = 0
	var/no_light=0 // Disable the light on the atmos suit
	actions_types = list(/datum/action/item_action/toggle_light)

/obj/item/clothing/head/helmet/space/phoronman/attack_self(mob/user)
	if(no_light)
		return
	on = !on
	icon_state = "[base_state][on]"
	if(on)
		set_light(brightness_on)
	else
		set_light(0)
	user.update_inv_head()

// Tc_ENGINEERING
/obj/item/clothing/suit/space/phoronman/assistant
	name = "phoronman assistant suit"
	icon_state = "phoronmanAssistant_suit"

/obj/item/clothing/head/helmet/space/phoronman/assistant
	name = "phoronman assistant helmet"
	icon_state = "phoronmanAssistant_helmet0"
	base_state = "phoronmanAssistant_helmet"

/obj/item/clothing/suit/space/phoronman/atmostech
	name = "phoronman atmospheric suit"
	icon_state = "phoronmanAtmos_suit"
	armor = list(melee = 20, bullet = 0, laser = 0,energy = 0, bomb = 25, bio = 100, rad = 0)
	max_heat_protection_temperature = FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE
	slowdown = 2

/obj/item/clothing/head/helmet/space/phoronman/atmostech
	name = "phoronman atmospheric helmet"
	icon_state = "phoronmanAtmos_helmet0"
	base_state = "phoronmanAtmos_helmet"
	armor = list(melee = 20, bullet = 0, laser = 0,energy = 0, bomb = 25, bio = 100, rad = 0)
	max_heat_protection_temperature = FIRE_HELMET_MAX_HEAT_PROTECTION_TEMPERATURE

/obj/item/clothing/suit/space/phoronman/engineer
	name = "phoronman engineer suit"
	icon_state = "phoronmanEngineer_suit"
	armor = list(melee = 40, bullet = 5, laser = 20,energy = 5, bomb = 35, bio = 100, rad = 80)
	pressure_resistance = 200 * ONE_ATMOSPHERE
	slowdown = 2

/obj/item/clothing/head/helmet/space/phoronman/engineer
	name = "phoronman engineer helmet"
	icon_state = "phoronmanEngineer_helmet0"
	base_state = "phoronmanEngineer_helmet"
	armor = list(melee = 40, bullet = 5, laser = 20,energy = 5, bomb = 35, bio = 100, rad = 80)
	pressure_resistance = 200 * ONE_ATMOSPHERE
	eyeprot = 1

/obj/item/clothing/suit/space/phoronman/engineer/ce
	name = "phoronman chief engineer suit"
	icon_state = "phoronman_CE"
	max_heat_protection_temperature = FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE

/obj/item/clothing/head/helmet/space/phoronman/engineer/ce
	name = "phoronman chief engineer helmet"
	icon_state = "phoronman_CE_helmet0"
	base_state = "phoronman_CE_helmet"
	max_heat_protection_temperature = FIRE_HELMET_MAX_HEAT_PROTECTION_TEMPERATURE


//SERVICE

/obj/item/clothing/suit/space/phoronman/botanist
	name = "phoronman botanist suit"
	icon_state = "phoronmanBotanist_suit"

/obj/item/clothing/head/helmet/space/phoronman/botanist
	name = "phoronman botanist helmet"
	icon_state = "phoronmanBotanist_helmet0"
	base_state = "phoronmanBotanist_helmet"

/obj/item/clothing/suit/space/phoronman/chaplain
	name = "phoronman chaplain suit"
	icon_state = "phoronmanChaplain_suit"

/obj/item/clothing/head/helmet/space/phoronman/chaplain
	name = "phoronman chaplain helmet"
	icon_state = "phoronmanChaplain_helmet0"
	base_state = "phoronmanChaplain_helmet"

/obj/item/clothing/suit/space/phoronman/clown
	name = "phoronman clown suit"
	icon_state = "phoronman_Clown"

/obj/item/clothing/head/helmet/space/phoronman/clown
	name = "phoronman clown helmet"
	icon_state = "phoronman_Clown_helmet0"
	base_state = "phoronman_Clown_helmet"

/obj/item/clothing/suit/space/phoronman/mime
	name = "phoronman mime suit"
	icon_state = "phoronman_Mime"

/obj/item/clothing/head/helmet/space/phoronman/mime
	name = "phoronman mime helmet"
	icon_state = "phoronman_Mime_helmet0"
	base_state = "phoronman_Mime_helmet"

/obj/item/clothing/suit/space/phoronman/service
	name = "phoronman service suit"
	icon_state = "phoronmanService_suit"

/obj/item/clothing/head/helmet/space/phoronman/service
	name = "phoronman service helmet"
	icon_state = "phoronmanService_helmet0"
	base_state = "phoronmanService_helmet"

/obj/item/clothing/suit/space/phoronman/janitor
	name = "phoronman janitor suit"
	icon_state = "phoronmanJanitor_suit"

/obj/item/clothing/head/helmet/space/phoronman/janitor
	name = "phoronman janitor helmet"
	icon_state = "phoronmanJanitor_helmet0"
	base_state = "phoronmanJanitor_helmet"

/obj/item/clothing/suit/space/phoronman/lawyer
	name = "phoronman lawyer suit"
	icon_state = "phoronmanlawyer_suit"

/obj/item/clothing/head/helmet/space/phoronman/lawyer
	name = "phoronman lawyer helmet"
	icon_state = "phoronmanlawyer_helmet0"
	base_state = "phoronmanlawyer_helmet"

/obj/item/clothing/suit/space/phoronman/bee
	name = "phoronman bee suit"
	icon_state = "phoronmanbee_suit"

/obj/item/clothing/head/helmet/space/phoronman/bee
	name = "phoronman bee helmet"
	icon_state = "phoronmanbee_helmet0"
	base_state = "phoronmanbee_helmet"

//CARGO

/obj/item/clothing/suit/space/phoronman/cargo
	name = "phoronman cargo suit"
	icon_state = "phoronmanCargo_suit"

/obj/item/clothing/head/helmet/space/phoronman/cargo
	name = "phoronman cargo helmet"
	icon_state = "phoronmanCargo_helmet0"
	base_state = "phoronmanCargo_helmet"

/obj/item/clothing/suit/space/phoronman/miner
	name = "phoronman miner suit"
	icon_state = "phoronmanMiner_suit"
	armor = list(melee = 30, bullet = 5, laser = 15,energy = 5, bomb = 30, bio = 100, rad = 20)
	slowdown = 2
	goliath_reinforce = TRUE

/obj/item/clothing/head/helmet/space/phoronman/miner
	name = "phoronman miner helmet"
	icon_state = "phoronmanMiner_helmet0"
	base_state = "phoronmanMiner_helmet"
	armor = list(melee = 30, bullet = 5, laser = 15,energy = 5, bomb = 30, bio = 100, rad = 20)
	goliath_reinforce = TRUE


// MEDSCI

/obj/item/clothing/suit/space/phoronman/medical
	name = "phoronman medical suit"
	icon_state = "phoronmanMedical_suit"

/obj/item/clothing/head/helmet/space/phoronman/medical
	name = "phoronman medical helmet"
	icon_state = "phoronmanMedical_helmet0"
	base_state = "phoronmanMedical_helmet"

/obj/item/clothing/suit/space/phoronman/medical/paramedic
	name = "phoronman paramedic suit"
	icon_state = "phoronman_Paramedic"

/obj/item/clothing/head/helmet/space/phoronman/medical/paramedic
	name = "phoronman paramedic helmet"
	icon_state = "phoronman_Paramedic_helmet0"
	base_state = "phoronman_Paramedic_helmet"

/obj/item/clothing/suit/space/phoronman/medical/chemist
	name = "phoronman chemist suit"
	icon_state = "phoronman_Chemist"

/obj/item/clothing/head/helmet/space/phoronman/medical/chemist
	name = "phoronman chemist helmet"
	icon_state = "phoronman_Chemist_helmet0"
	base_state = "phoronman_Chemist_helmet"

/obj/item/clothing/suit/space/phoronman/medical/cmo
	name = "phoronman chief medical officer suit"
	icon_state = "phoronman_CMO"

/obj/item/clothing/head/helmet/space/phoronman/medical/cmo
	name = "phoronman chief medical officer helmet"
	icon_state = "phoronman_CMO_helmet0"
	base_state = "phoronman_CMO_helmet"

/obj/item/clothing/suit/space/phoronman/science
	name = "phoronman scientist suit"
	icon_state = "phoronmanScience_suit"

/obj/item/clothing/head/helmet/space/phoronman/science
	name = "phoronman scientist helmet"
	icon_state = "phoronmanScience_helmet0"
	base_state = "phoronmanScience_helmet"

/obj/item/clothing/suit/space/phoronman/science/rd
	name = "phoronman research director suit"
	icon_state = "phoronman_RD"

/obj/item/clothing/head/helmet/space/phoronman/science/rd
	name = "phoronman research director helmet"
	icon_state = "phoronman_RD_helmet0"
	base_state = "phoronman_RD_helmet"


//SECURITY

/obj/item/clothing/suit/space/phoronman/security
	name = "phoronman security suit"
	icon_state = "phoronmanSecurity_suit"
	armor = list(melee = 40, bullet = 15, laser = 35,energy = 5, bomb = 35, bio = 100, rad = 20)

/obj/item/clothing/head/helmet/space/phoronman/security
	name = "phoronman security helmet"
	icon_state = "phoronmanSecurity_helmet0"
	base_state = "phoronmanSecurity_helmet"
	armor = list(melee = 40, bullet = 15, laser = 35,energy = 5, bomb = 35, bio = 100, rad = 20)
	eyeprot = 1

/obj/item/clothing/suit/space/phoronman/security/hos
	name = "phoronman head of security suit"
	icon_state = "phoronman_HoS"

/obj/item/clothing/head/helmet/space/phoronman/security/hos
	name = "phoronman head of security helmet"
	icon_state = "phoronman_HoS_helmet0"
	base_state = "phoronman_HoS_helmet"

/obj/item/clothing/suit/space/phoronman/security/hop
	name = "phoronman head of personnel suit"
	icon_state = "phoronman_HoP"

/obj/item/clothing/head/helmet/space/phoronman/security/hop
	name = "phoronman head of personnel helmet"
	icon_state = "phoronman_HoP_helmet0"
	base_state = "phoronman_HoP_helmet"

/obj/item/clothing/suit/space/phoronman/security/captain
	name = "phoronman captain suit"
	icon_state = "phoronman_Captain"

/obj/item/clothing/head/helmet/space/phoronman/security/captain
	name = "phoronman captain helmet"
	icon_state = "phoronman_Captain_helmet0"
	base_state = "phoronman_Captain_helmet"


//MISC

/obj/item/clothing/suit/space/phoronman/prisoner
	name = "phoronman prisoner suit"
	icon_state = "phoronman_prisoner_suit"
	max_heat_protection_temperature = null
	pressure_resistance = null
	allowed = list(/obj/item/weapon/tank)

/obj/item/clothing/head/helmet/space/phoronman/prisoner
	name = "phoronman prisoner helmet"
	icon_state = "phoronman_prisoner_helmet0"
	base_state = "phoronman_prisoner_helmet"
	pressure_resistance = null

/obj/item/clothing/suit/space/phoronman/moltar
	name = "moltar's firesuit"
	icon_state = "phoronmanMoltar_suit"

/obj/item/clothing/head/helmet/space/phoronman/moltar
	name = "moltar's mask"
	icon_state = "phoronmanMoltar_helmet"
	base_state = "phoronmanMoltar_helmet"
	no_light=1



//NUKEOPS

/obj/item/clothing/suit/space/phoronman/nuclear
	name = "blood red phoronman suit"
	icon_state = "phoronman_Nukeops"
	armor = list(melee = 60, bullet = 50, laser = 30, energy = 15, bomb = 35, bio = 100, rad = 60)
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank,/obj/item/weapon/gun,/obj/item/ammo_storage,/obj/item/ammo_casing,/obj/item/weapon/melee/baton,/obj/item/weapon/melee/energy/sword,/obj/item/weapon/handcuffs)
	siemens_coefficient = 0.6

/obj/item/clothing/head/helmet/space/phoronman/nuclear
	name = "blood red phoronman helmet"
	icon_state = "phoronman_Nukeops_helmet0"
	base_state = "phoronman_Nukeops_helmet"
	armor = list(melee = 60, bullet = 50, laser = 30,energy = 15, bomb = 35, bio = 100, rad = 60)
	siemens_coefficient = 0.6
	var/obj/machinery/camera/camera

/obj/item/clothing/head/helmet/space/phoronman/nuclear/attack_self(mob/user)
	if(camera)
		..(user)
	else
		camera = new /obj/machinery/camera(src)
		camera.network = list("NUKE")
		cameranet.removeCamera(camera)
		camera.c_tag = user.name
		to_chat(user, "<span class='notice'>User scanned as [camera.c_tag]. Camera activated.</span>")

/obj/item/clothing/head/helmet/space/phoronman/nuclear/examine(mob/user)
	..()
	if(get_dist(user,src) <= 1)
		to_chat(user, "<span class='info'>This helmet has a built-in camera. It's [camera ? "" : "in"]active.</span>")


//CULT

/obj/item/clothing/suit/space/phoronman/cultist
	name = "phoronman cultist armor"
	icon_state = "phoronman_cult"
	item_state = "phoronman_cult"
	desc = "A bulky suit of armour, menacing with red energy. It looks like it would fit a phoronman."
	slowdown = 1
	armor = list(melee = 60, bullet = 50, laser = 30,energy = 15, bomb = 30, bio = 30, rad = 30)

/obj/item/clothing/head/helmet/space/phoronman/cultist
	name = "phoronman cultist helmet"
	icon_state = "phoronmanCult_helmet0"
	base_state = "phoronmanCult_helmet"
	desc = "A containment suit designed by the followers of Nar-Sie. It glows menacingly with unearthly flames."
	armor = list(melee = 60, bullet = 50, laser = 30,energy = 15, bomb = 30, bio = 30, rad = 30)
