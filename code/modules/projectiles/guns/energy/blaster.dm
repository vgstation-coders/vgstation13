//plasma
/obj/item/weapon/gun/energy/plasma
	name = "plasma gun"
	desc = "A high-power plasma gun. You shouldn't ever see this."
	icon_state = "xray"
	item_state = null
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guninhands_left.dmi', "right_hand" = 'icons/mob/in-hand/right/guninhands_right.dmi')
	fire_sound = 'sound/weapons/elecfire.ogg'
	origin_tech = "combat=5;materials=3;magnets=2"
	projectile_type = /obj/item/projectile/energy/plasma
	charge_cost = 50

/obj/item/weapon/gun/energy/plasma/pistol
	name = "Plasma pistol"
	desc = "Plasma pistol that is given to members of an unknown shadow organization."
	icon_state = "ppistol"
	origin_tech = "combat=3;magnets=3;materials=4;plasmatech=3"
	item_state = null
	lefthand_file = 'icons/mob/guns_lefthand.dmi'
	righthand_file = 'icons/mob/guns_righthand.dmi'
	starting_materials = list(MAT_IRON = 1000)
	projectile_type = /obj/item/projectile/energy/plasma/pistol
	charge_cost = 750
	w_class = 2.0
	cell_removing = 1

/obj/item/weapon/gun/energy/plasma/pistol/old
	name = "plasma pistol"
	desc = "A state of the art pistol utilizing plasma in a uranium-235 lined core to output searing bolts of energy."
	icon_state = "alienpistol"
	item_state = null
	w_class = 1.0
	projectile_type = /obj/item/projectile/energy/plasma/pistol
	cell_removing = 0
	charge_cost = 100

/obj/item/weapon/gun/energy/plasma/light
	name = "light plasma rifle"
	desc = "A state of the art rifle utilizing plasma in a uranium-235 lined core to output radiating bolts of energy."
	icon_state = "plightrifle"
	origin_tech = "combat=4;materials=4;magnets=3;plasmatech=4"
	item_state = null
	projectile_type = /obj/item/projectile/energy/plasma/light
	two_handed = 1
	charge_cost = 500
	cell_removing = 1

/obj/item/weapon/gun/energy/plasma/light/old
	name = "plasma rifle"
	desc = "Light plasma rifle that is given to members of an unknown shadow organization."
	icon_state = "lightalienrifle"
	item_state = null
	projectile_type = /obj/item/projectile/energy/plasma/light
	charge_cost = 50

/obj/item/weapon/gun/energy/plasma/rifle
	name = "plasma rifle"
	desc = "A state of the art cannon utilizing plasma in a uranium-235 lined core to output hi-power, radiating bolts of energy."
	icon_state = "prifle"
	item_state = null
	origin_tech = "combat=4;materials=4;magnets=3;plasmatech=4"
	projectile_type = /obj/item/projectile/energy/plasma/rifle
	slot_flags = SLOT_BACK
	two_handed = 1
	w_class = 4
	charge_cost = 500
	cell_removing = 1

/obj/item/weapon/gun/energy/plasma/rifle/old
	name = "plasma cannon"
	desc = "Plasma rifle that is given to members of an unknown shadow organization."
	icon_state = "alienrifle"
	item_state = null
	w_class = 4.0
	slot_flags = null
	projectile_type = /obj/item/projectile/energy/plasma/rifle
	charge_cost = 150
	cell_removing = 0


//ions
/obj/item/weapon/gun/energy/ionrifle
	name = "ion rifle"
	desc = "A man portable anti-armor weapon designed to disable mechanical threats"
	icon_state = "ionrifle"
	item_state = null
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guninhands_left.dmi', "right_hand" = 'icons/mob/in-hand/right/guninhands_right.dmi')
	fire_sound = 'sound/weapons/ion.ogg'
	origin_tech = "combat=2;magnets=4"
	w_class = 4.0
	flags = FPRINT
	siemens_coefficient = 1
	slot_flags = SLOT_BACK
	charge_cost = 100
	projectile_type = "/obj/item/projectile/ion"

	emp_act(severity)
		if(severity <= 2)
			power_supply.use(round(power_supply.maxcharge / severity))
			update_icon()
		else
			return

//other
/obj/item/weapon/gun/energy/decloner
	name = "biological demolecularisor"
	desc = "A gun that discharges high amounts of controlled radiation to slowly break a target into component elements."
	icon_state = "decloner"
	item_state = null
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guninhands_left.dmi', "right_hand" = 'icons/mob/in-hand/right/guninhands_right.dmi')
	fire_sound = 'sound/weapons/pulse3.ogg'
	origin_tech = "combat=5;materials=4;powerstorage=3"
	charge_cost = 100
	projectile_type = "/obj/item/projectile/energy/declone"

/obj/item/weapon/gun/energy/radgun
	name = "radgun"
	desc = "An experimental energy gun that fires radioactive projectiles that deal toxin damage, irradiate, and scramble DNA, giving the victim a different appearance and name, and potentially harmful or beneficial mutations. Recharges automatically."
	icon_state = "radgun"
	item_state = null
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guninhands_left.dmi', "right_hand" = 'icons/mob/in-hand/right/guninhands_right.dmi')
	fire_sound = 'sound/weapons/radgun.ogg'
	charge_cost = 100
	var/charge_tick = 0
	projectile_type = "/obj/item/projectile/energy/rad"

	New()
		..()
		processing_objects.Add(src)

	Destroy()
		processing_objects.Remove(src)
		..()

	process()
		charge_tick++
		if(charge_tick < 4) return 0
		charge_tick = 0
		if(!power_supply) return 0
		power_supply.give(100)
		update_icon()
		return 1