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
	caliber = ".45"
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

/obj/item/ammo_storage/magazine/uzi45 //Uzi mag
	name = "magazine (.45)"
	icon_state = "uzi45"
	origin_tech = Tc_COMBAT + "=2"
	ammo_type = "/obj/item/ammo_casing/c45"
	max_ammo = 16
	multiple_sprites = 1
	sprite_modulo = 2

/obj/item/ammo_storage/magazine/uzi45/empty
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
	var/stuncharge = 100
	var/lasercharge = 100
	var/rapid_ammo_type = "/obj/item/ammo_casing/a12mm"
	var/rapid_ammo_count = 5
	var/flare_ammo_type = "/obj/item/ammo_casing/shotgun/flare"
	var/flare_ammo_count = 5
	var/ricochet_ammo_type = "/obj/item/ammo_casing/a75"
	var/ricochet_ammo_count = 5

/obj/item/ammo_storage/magazine/lawgiver/New()
	..()
	update_icon()

/obj/item/ammo_storage/magazine/lawgiver/examine(mob/user)
	..()
	to_chat(user, "<span class='info'>It has enough energy for [stuncharge/20] stun shot\s left.</span>")
	to_chat(user, "<span class='info'>It has enough energy for [lasercharge/20] laser shot\s left.</span>")
	to_chat(user, "<span class='info'>It has [rapid_ammo_count] rapid fire round\s remaining.</span>")
	to_chat(user, "<span class='info'>It has [flare_ammo_count] [istype(src, /obj/item/ammo_storage/magazine/lawgiver/demolition) ? "hi-EX" : "flare"] round\s remaining.</span>")
	to_chat(user, "<span class='info'>It has [ricochet_ammo_count] ricochet round\s remaining.</span>")

/obj/item/ammo_storage/magazine/lawgiver/update_icon()
	overlays.len = 0
	if(stuncharge > 0)
		var/image/stuncharge_overlay = image('icons/obj/ammo.dmi', src, "[initial(icon_state)]-stun-[stuncharge/20]")
		overlays += stuncharge_overlay
	if(lasercharge > 0)
		var/image/lasercharge_overlay = image('icons/obj/ammo.dmi', src, "[initial(icon_state)]-laser-[lasercharge/20]")
		overlays += lasercharge_overlay
	if(rapid_ammo_count > 0)
		var/image/rapid_ammo_overlay = image('icons/obj/ammo.dmi', src, "[initial(icon_state)]-rapid-[rapid_ammo_count]")
		overlays += rapid_ammo_overlay
	if(flare_ammo_count > 0)
		var/image/flare_ammo_overlay = image('icons/obj/ammo.dmi', src, "[initial(icon_state)]-flare-[flare_ammo_count]")
		overlays += flare_ammo_overlay
	if(ricochet_ammo_count > 0)
		var/image/ricochet_ammo_overlay = image('icons/obj/ammo.dmi', src, "[initial(icon_state)]-ricochet-[ricochet_ammo_count]")
		overlays += ricochet_ammo_overlay

/obj/item/ammo_storage/magazine/lawgiver/proc/isFull()
	if (stuncharge == 100 && lasercharge == 100 && rapid_ammo_count == 5 && flare_ammo_count == 5 && ricochet_ammo_count == 5)
		return 1
	else
		return 0

/obj/item/ammo_storage/magazine/lawgiver/demolition
	desc = "State-of-the-art bluespace technology allows this magazine to generate new rounds from energy, requiring only a power source to refill the full suite of ammunition types. This model is outfitted with high-explosive rounds."
	flare_ammo_type = "/obj/item/ammo_casing/a75"

/obj/item/ammo_storage/magazine/invisible
	desc = "Reading how many shots you had left just got a lot more difficult."
	ammo_type = "/obj/item/ammo_casing/invisible"
	max_ammo = 2
