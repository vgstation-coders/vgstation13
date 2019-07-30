//Magazines are loaded directly into weapons
//Unlike boxes, they have no fumbling. Simply loading a magazine is instant

/obj/item/ammo_storage/magazine
	desc = "A magazine capable of holding bullets. Can be loaded into certain weapons."
	exact = 1 //we only load the thing we want to load

/obj/item/ammo_storage/magazine/mc9mm
	name = "magazine (9mm)"
	icon_state = "9x19p"
	origin_tech = Tc_COMBAT + "=2"
	ammo_type = "/obj/item/ammo_casing/c9mm"
	max_ammo = 8
	sprite_modulo = 8
	multiple_sprites = 1

/obj/item/ammo_storage/magazine/mc9mm/empty
	starting_ammo = 0

/obj/item/ammo_storage/magazine/beretta
	name = "Beretta 92FS magazine (9mm)"
	desc = "A magazine designed for the Beretta 92FS. Holds 15 rounds."
	icon = 'icons/obj/beretta.dmi'
	icon_state = "beretta_mag"
	origin_tech = Tc_COMBAT + "=2"
	caliber = MM9
	ammo_type = "/obj/item/ammo_casing/c9mm"
	exact = 0
	max_ammo = 15
	multiple_sprites = 1
	sprite_modulo = 15

/obj/item/ammo_storage/magazine/beretta/empty
	starting_ammo = 0

/obj/item/ammo_storage/magazine/a12ga
	name = "NT-12 box magazine (12ga)"
	desc = "A box magazine designed for the NT-12. Holds 4 rounds."
	icon_state = "nt12-mag"
	origin_tech = Tc_COMBAT + "=2"
	caliber = GAUGE12
	ammo_type = "/obj/item/ammo_casing/shotgun"
	exact = 0
	max_ammo = 4
	multiple_sprites = 1
	sprite_modulo = 4

/obj/item/ammo_storage/magazine/a12ga/empty
	starting_ammo = 0

/obj/item/ammo_storage/magazine/a12ga/drum
	name = "NT-12 drum magazine (12ga)"
	desc = "A drum magazine designed for the NT-12. Holds 20 rounds."
	icon_state = "nt12-drum"
	origin_tech = Tc_COMBAT + "=2"
	caliber = GAUGE12
	ammo_type = "/obj/item/ammo_casing/shotgun"
	exact = 0
	max_ammo = 20
	multiple_sprites = 1
	sprite_modulo = 20

/obj/item/ammo_storage/magazine/a12ga/drum/empty
	starting_ammo = 0

/obj/item/ammo_storage/magazine/a12mm
	name = "magazine (12mm)"
	icon_state = "12mm"
	origin_tech = Tc_COMBAT + "=2"
	ammo_type = "/obj/item/ammo_casing/a12mm/assault"
	max_ammo = 20
	multiple_sprites = 1
	sprite_modulo = 2

/obj/item/ammo_storage/magazine/a12mm/ops
	name = "C-20r magazine (12mm)"
	desc = "A magazine designed for the C-20r. Has 'SA' engraved on the side. Holds 20 rounds."
	icon_state = "12mm"
	origin_tech = Tc_COMBAT + "=2"
	ammo_type = "/obj/item/ammo_casing/a12mm"
	max_ammo = 20
	multiple_sprites = 1
	sprite_modulo = 2


/obj/item/ammo_storage/magazine/a12mm/empty
	starting_ammo = 0

/obj/item/ammo_storage/magazine/smg9mm
	name = "magazine (9mm)"
	icon_state = "smg9mm"
	origin_tech = Tc_COMBAT + "=3"
	ammo_type = "/obj/item/ammo_casing/c9mm"
	max_ammo = 18
	sprite_modulo = 3
	multiple_sprites = 1

/obj/item/ammo_storage/magazine/smg9mm/empty
	starting_ammo = 0

/obj/item/ammo_storage/magazine/a357
	name = "automag magazine (.357)"
	desc = "A magazine designed for the Automag VI handcannon. Holds 7 rounds."
	icon_state = "automag-mag"
	origin_tech = Tc_COMBAT + "=2;" + Tc_MATERIALS + "=2"
	caliber = POINT357
	ammo_type = "/obj/item/ammo_casing/a357"
	exact = 0
	max_ammo = 7
	multiple_sprites = 1
	sprite_modulo = 7

/obj/item/ammo_storage/magazine/a357/empty
	starting_ammo = 0

/obj/item/ammo_storage/magazine/a50
	name = "magazine (.50)"
	icon_state = "50ae"
	origin_tech = Tc_COMBAT + "=2"
	ammo_type = "/obj/item/ammo_casing/a50"
	max_ammo = 7
	multiple_sprites = 1
	sprite_modulo = 1

/obj/item/ammo_storage/magazine/a50/empty
	starting_ammo = 0

/obj/item/ammo_storage/magazine/a75
	name = "magazine (.75)"
	icon_state = "75"
	ammo_type = "/obj/item/ammo_casing/a75"
	multiple_sprites = 1
	max_ammo = 8
	sprite_modulo = 8

/obj/item/ammo_storage/magazine/a75/empty
	starting_ammo = 0

/obj/item/ammo_storage/magazine/a762
	name = "magazine (a762)"
	icon_state = "a762"
	origin_tech = Tc_COMBAT + "=2"
	ammo_type = "/obj/item/ammo_casing/a762"
	max_ammo = 50
	multiple_sprites = 1
	sprite_modulo = 10

/obj/item/ammo_storage/magazine/a762/empty
	starting_ammo = 0

/obj/item/ammo_storage/magazine/c45
	name = "pistol magazine (.45)"
	desc = "A magazine designed for common .45 pistols. Holds 8 rounds."
	icon_state = "45"
	origin_tech = Tc_COMBAT + "=2"
	ammo_type = "/obj/item/ammo_casing/c45"
	exact = 0
	caliber = POINT45
	max_ammo = 8
	multiple_sprites = 1
	sprite_modulo = 1

/obj/item/ammo_storage/magazine/c45/empty
	starting_ammo = 0

/obj/item/ammo_storage/magazine/c45/rubber //I'd like to make it so magazines get recolored by contents, but whatever --Sonix
	name = "magazine (.45 rubber)"
	desc = "A magazine designed for common .45 pistols. This one has a blue marking to indicate it should contain rubber bullets. Holds 8 rounds."
	icon_state = "45R"
	ammo_type = "/obj/item/ammo_casing/c45/rubber"

/obj/item/ammo_storage/magazine/c45/rubber/empty
	starting_ammo = 0

/obj/item/ammo_storage/magazine/c45/practice
	name = "magazine (.45 practice)"
	desc = "A magazine designed for common .45 pistols. This one has a white marking to indicate it should contain practice bullets.  Holds 8 rounds."
	icon_state = "45P"
	ammo_type = "/obj/item/ammo_casing/c45/practice"


/obj/item/ammo_storage/magazine/c45/practice/empty
	starting_ammo = 0

/obj/item/ammo_storage/magazine/m380auto
	name = "pistol magazine (.380AUTO)"
	desc = "A magazine designed for common .380AUTO pistols. Holds 10 rounds."
	icon_state = "m380AUTO"
	origin_tech = Tc_COMBAT + "=2"
	ammo_type = "/obj/item/ammo_casing/c380auto"
	exact = 0
	caliber = POINT380
	max_ammo = 10
	multiple_sprites = 1
	sprite_modulo = 2

/obj/item/ammo_storage/magazine/m380auto/empty
	starting_ammo = 0

/obj/item/ammo_storage/magazine/m380auto/rubber
	name = "magazine (.380AUTO rubber)"
	desc = "A magazine designed for common .380AUTO pistols. This one has a blue marking to indicate it should contain rubber bullets. Holds 10 rounds."
	icon_state = "m380AUTO-R"
	ammo_type = "/obj/item/ammo_casing/c380auto/rubber"

/obj/item/ammo_storage/magazine/m380auto/rubber/empty
	starting_ammo = 0

/obj/item/ammo_storage/magazine/m380auto/practice
	name = "magazine (.380AUTO practice)"
	desc = "A magazine designed for common .380AUTO pistols. This one has a white marking to indicate it should contain practice bullets.  Holds 10 rounds."
	icon_state = "m380AUTO-P"
	ammo_type = "/obj/item/ammo_casing/c380auto/practice"

/obj/item/ammo_storage/magazine/m380auto/practice/empty
	starting_ammo = 0

/obj/item/ammo_storage/magazine/m380auto/extended
	name = "magazine (.380AUTO extended) "
	desc = "A magazine designed for .380AUTO vectors. Holds 20 rounds. This one doesn't fit into glocks."
	icon_state = "m380AUTO-E"
	max_ammo = 20
	multiple_sprites = 1
	sprite_modulo = 2

/obj/item/ammo_storage/magazine/m380auto/extended/empty
	starting_ammo = 0

/obj/item/ammo_storage/magazine/uzi45 //Uzi mag
	name = "magazine (.45)"
	icon_state = "uzi45"
	origin_tech = Tc_COMBAT + "=2"
	ammo_type = "/obj/item/ammo_casing/c45"
	max_ammo = 16
	multiple_sprites = 1
	sprite_modulo = 4

/obj/item/ammo_storage/magazine/uzi45/empty
	starting_ammo = 0

/obj/item/ammo_storage/magazine/uzi45/extended
	name = "extended magazine (.45)"
	icon_state = "uzi45_ext"
	max_ammo = 24
	multiple_sprites = 1
	sprite_modulo = 4

/obj/item/ammo_storage/magazine/microuzi9 //microuzi mag
	name = "magazine (9mm)"
	icon_state = "uzi45"//sprites are identical. this should probably be fixed in the future by a gunspriter to avoid confusion
	origin_tech = Tc_COMBAT + "=2"
	ammo_type = "/obj/item/ammo_casing/c9mm"
	max_ammo = 20
	multiple_sprites = 1
	sprite_modulo = 4

/obj/item/ammo_storage/magazine/microuzi9/empty
	starting_ammo = 0

/obj/item/ammo_storage/magazine/lawgiver
	name = "lawgiver magazine"
	desc = "State-of-the-art bluespace technology allows this magazine to generate new rounds from energy, requiring only a power source to refill the full suite of ammunition types."
	icon_state = "lawgiver"
	item_state = "syringe_kit"
	origin_tech = Tc_COMBAT + "=2;" + Tc_BLUESPACE + "=5"
	ammo_type = null
	max_ammo = 0
	multiple_sprites = 1
	sprite_modulo = 2
	var/list/ammo_counters
	var/compatible_gun_type = /obj/item/weapon/gun/lawgiver

/obj/item/ammo_storage/magazine/lawgiver/New()
	..()
	var/list/new_ammo_counters = list()
	for(var/datum/lawgiver_mode/mode in lawgiver_modes[compatible_gun_type])
		new_ammo_counters[mode] = LAWGIVER_MAX_AMMO * mode.ammo_per_shot
	ammo_counters = new_ammo_counters
	update_icon()

/obj/item/ammo_storage/magazine/lawgiver/proc/generate_description()
	. = list("<span class='info'>")
	for(var/datum/lawgiver_mode/mode in ammo_counters)
		var/ammo_left = ammo_counters[mode] / mode.ammo_per_shot
		switch(mode.kind)
			if(LAWGIVER_MODE_KIND_ENERGY)
				. += "It has enough energy for [ammo_left] [mode.firing_mode] shot[ammo_left != 1 ? "s" : ""] left.\n"
			if(LAWGIVER_MODE_KIND_BULLET)
				. += "It has [ammo_left] [mode.firing_mode] round[ammo_left != 1 ? "s" : ""] remaining.\n"
	. += "</span>"
	return jointext(., null)

/obj/item/ammo_storage/magazine/lawgiver/examine(mob/user)
	..()
	to_chat(user, generate_description())

/obj/item/ammo_storage/magazine/lawgiver/update_icon()
	overlays.len = 0
	// We only have 5 overlays but potentially more
	// than 5 ammo types. Ammo types after the 5th don't
	// get an overlay.
	var/static/list/available_overlays = list(
		"stun", "laser", "rapid", "flare", "ricochet",
	)
	for(var/i in 1 to min(available_overlays.len, ammo_counters.len))
		var/datum/lawgiver_mode/mode = ammo_counters[i]
		var/ammo_left = ammo_counters[mode] / mode.ammo_per_shot
		overlays += image('icons/obj/ammo.dmi', src, "[initial(icon_state)]-[available_overlays[i]]-[ammo_left]")

/obj/item/ammo_storage/magazine/lawgiver/proc/isEmpty()
	for(var/datum/lawgiver_mode/mode in ammo_counters)
		if(ammo_counters[mode] != 0)
			return FALSE
	return TRUE

/obj/item/ammo_storage/magazine/lawgiver/proc/isFull()
	for(var/datum/lawgiver_mode/mode in ammo_counters)
		if(ammo_counters[mode] != LAWGIVER_MAX_AMMO * mode.ammo_per_shot)
			return FALSE
	return TRUE

/obj/item/ammo_storage/magazine/lawgiver/recharger_process(var/obj/machinery/recharger/charger)
	if(isFull())
		charger.update_icon()
		charger.icon_state = "recharger2"
		return

	icon_state = "recharger1"

	var/charged_amount = 0
	for(var/datum/lawgiver_mode/mode in ammo_counters)
		if(ammo_counters[mode] == LAWGIVER_MAX_AMMO * mode.ammo_per_shot)
			continue
		charged_amount += mode.ammo_per_shot * charger.charging_speed_modifier
		ammo_counters[mode] = min(ammo_counters[mode] + charged_amount, LAWGIVER_MAX_AMMO * mode.ammo_per_shot)

	charger.try_use_power(100 * charger.charging_speed_modifier + 100 * charger.charging_speed_modifier * charger.efficiency_modifier)
	charger.update_icon()

/obj/item/ammo_storage/magazine/lawgiver/demolition
	desc = "State-of-the-art bluespace technology allows this magazine to generate new rounds from energy, requiring only a power source to refill the full suite of ammunition types. This model is outfitted with high-explosive rounds."
	compatible_gun_type = /obj/item/weapon/gun/lawgiver/demolition

/obj/item/ammo_storage/magazine/invisible
	desc = "Reading how many shots you had left just got a lot more difficult."
	ammo_type = "/obj/item/ammo_casing/invisible"
	max_ammo = 2
