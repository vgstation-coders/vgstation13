/////////////////////////////////////
/////////////GUN PARTS///////////////
/////////////////////////////////////

/*Contains:
 - Basic gun energy cell
 - Crap gun energy cell
 - Suspicious looking gun energy cell
 - Hyper capacity gun energy cell
 - Rechargable capacity gun energy cell
 _
 _
 - Silencer
 - Sniper Scope
 - Grenate Launcher
*/

//Combat Power Cells
/obj/item/weapon/cell/ammo
	name = "Basic gun energy cell"
	desc = "Mini gun cell with good capacity, used for most energy weapons. Warning: DONT ATTEMPT FUCKING INSTALL THAT CELL BACKWARDS, YOU BASTARDS!!!"
	icon = 'icons/obj/guns/misc.dmi'
	icon_state = "basic_ammocell"
	item_state = "basic_ammocell"
	origin_tech = "powerstorage=3"
	maxcharge = 5000
	w_class = 1
	m_amt = 30
	g_amt = 30

/obj/item/weapon/cell/ammo/crap
	name = "Crap gun energy cell"
	desc = "First model of Gun energy cells.. Stupid and very unstable, but easy to find.."
	maxcharge = 2500

/obj/item/weapon/cell/ammo/syndi
	name = "Suspicious looking gun energy cell"
	desc = "Strange gun cell, hm, that cell have super capacity.. and.. syndicate bandge. Wow."
	icon_state = "syndi_ammocell"
	item_state = "syndi_ammocell"
	origin_tech = "powerstorage=5"
	maxcharge = 10000
	m_amt = 30
	g_amt = 30

/obj/item/weapon/cell/ammo/hyper
	name = "Hyper capacity gun energy cell"
	desc = "Mini gun cell with hyper capacity, rare."
	icon_state = "hyper_ammocell"
	item_state = "hyper_ammocell"
	origin_tech = "powerstorage=4"
	maxcharge = 15000
	m_amt = 30
	g_amt = 30

/obj/item/weapon/cell/ammo/rechargable
	name = "Rechargable capacity gun energy cell"
	desc = "Rechargable cell, thats is great step for all energy technologies"
	icon_state = "rechargable_ammocell"
	item_state = "rechargable_ammocell"
	origin_tech = "powerstorage=6"
	maxcharge = 2500
	m_amt = 30
	g_amt = 30
	var/charge_tick = 0

	process()
		charge_tick++
		if(charge_tick < 4) return 0
		charge_tick = 0
		src.give(250)
		update_icon()
		return 1

	New()
		..()
		processing_objects.Add(src)

	Destroy()
		processing_objects.Remove(src)
		..()

/obj/item/gun_part/silencer
	name = "silencer"
	icon_state = "silencer"
	icon = 'icons/obj/guns/misc.dmi'
	desc = "a silencer, can be attached on tactical pistols, rifles"
	origin_tech = "material=1;combat=1"
	w_class = 2
	var/oldsound = null
	var/initial_w_class = null
	starting_materials = list(MAT_IRON = 200)

/obj/item/gun_part/sniper_scope
	name = "scope"
	icon_state = "scope"
	desc = "basic scope, used on sniper rifles, rifles, tactical SMG."
	origin_tech = "material=1;combat=1"
	starting_materials = list(MAT_IRON = 200)
	starting_materials = list(MAT_GLASS = 100)

/obj/item/weapon/gun/projectile/grenadelauncher
	name = "grenade launcher"
	desc = "A break-operated grenade launcher."
	fire_sound = 'sound/weapons/elecfire.ogg'
	icon_state = "riotgun"
	item_state = "gun"
	max_shells = 1
	w_class = 3.0
	starting_materials = list(MAT_IRON = 2000)
	w_type = RECYK_METAL
	recoil = 1
	caliber = list("rpg" = 1)
	origin_tech = "combat=4;materials=2;syndicate=2"
	ammo_type = "/obj/item/ammo_casing/rocket_rpg"

/obj/item/weapon/gun/projectile/grenadelauncher/attackby(var/obj/item/A, mob/living/user, params)
	..()
	if(istype(A, /obj/item/ammo_storage/box) || istype(A, /obj/item/ammo_casing))
		chamber_round()