
////////////////////////////////////ENERGY GUN/////////////////////////////////////////////////////
/obj/item/weapon/gun/energy/gun
	name = "energy gun"
	desc = "A basic energy-based gun with two settings: Stun and kill."
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guns.dmi', "right_hand" = 'icons/mob/in-hand/right/guns.dmi')
	icon_state = "energystun100"
	item_state = null	//so the human update icon uses the icon_state instead.
	fire_sound = 'sound/weapons/Taser.ogg'

	charge_cost = 100 //How much energy is needed to fire.
	projectile_type = "/obj/item/projectile/energy/electrode"
	origin_tech = Tc_COMBAT + "=3;" + Tc_MAGNETS + "=2"
	modifystate = "energystun"


	var/mode = 0 //0 = stun, 1 = kill

/obj/item/weapon/gun/energy/gun/isHandgun()
	return TRUE

/obj/item/weapon/gun/energy/gun/attack_self(mob/living/user as mob)
	switch(mode)
		if(0)
			mode = 1
			charge_cost = 100
			fire_sound = 'sound/weapons/Laser.ogg'
			to_chat(user, "<span class='warning'>\The [src] is now set to kill.</span>")
			projectile_type = "/obj/item/projectile/beam"
			modifystate = "energykill"
			if (power_supply.charge > 0)
				playsound(user,'sound/weapons/egun_toggle_laser.ogg',70,0,-5)
			else
				playsound(user,'sound/weapons/egun_toggle_noammo.ogg',73,0,-5)
		if(1)
			mode = 0
			charge_cost = 100
			fire_sound = 'sound/weapons/Taser.ogg'
			to_chat(user, "<span class='warning'>\The [src] is now set to stun.</span>")
			projectile_type = "/obj/item/projectile/energy/electrode"
			modifystate = "energystun"
			if (power_supply.charge > 0)
				playsound(user,'sound/weapons/egun_toggle_taser.ogg',70,0,-5)
			else
				playsound(user,'sound/weapons/egun_toggle_noammo.ogg',73,0,-5)
	update_icon()

////////////////////////////ADVANCED ENERGY GUN////////////////////////////////////////////////////

/obj/item/weapon/gun/energy/gun/nuclear
	name = "\improper Advanced Energy Gun"
	desc = "An improved energy gun featuring a miniaturized fission reactor that recharges its battery over time. Susceptible to EMPs."
	icon_state = "nucgun"
	item_state = "nucgun"
	origin_tech = Tc_COMBAT + "=3;" + Tc_MATERIALS + "=5;" + Tc_POWERSTORAGE + "=3"
	var/core_stability = 10
	var/charge_tick = 0

/obj/item/weapon/gun/energy/gun/nuclear/New()
	..()
	processing_objects.Add(src)
	update_icon()

/obj/item/weapon/gun/energy/gun/nuclear/Destroy()
	processing_objects.Remove(src)
	..()

/obj/item/weapon/gun/energy/gun/nuclear/process()
	if (core_stability < 10)
		if (prob(core_stability))//the core will slowly stabilize itself over time if it hasn't overloaded yet
			core_stability++
			update_icon()
	if(power_supply && core_stability > 0)
		charge_tick++
		if(charge_tick < 4)
			return
		charge_tick = 0
		if(power_supply.charge < power_supply.maxcharge)
			power_supply.give(core_stability*10)
			update_icon()

/obj/item/weapon/gun/energy/gun/nuclear/proc/critfail()
	if(power_supply)
		power_supply.charge = 0

	for (var/mob/living/M in range(4,src))
		if (src in M.contents)
			to_chat(M, "<span class='danger'>Your gun's reactor overloads!</span>")
		to_chat(M, "<span class='warning'>You feel a wave of heat wash over you.</span>")
		M.apply_radiation(300 / max(1,get_dist(src,M)), RAD_EXTERNAL)

	processing_objects.Remove(src)

/obj/item/weapon/gun/energy/gun/nuclear/emp_act(severity)
	..()
	core_stability -= round(4/severity)
	if (core_stability <= 0)
		critfail()

/obj/item/weapon/gun/energy/gun/nuclear/update_icon()
	overlays.len = 0

	var/stunkill = "stun"
	if (mode == 1)
		stunkill = "kill"

	var/charge = 0
	var/ratio = 0
	if (power_supply)
		ratio = round(power_supply.charge / power_supply.maxcharge, 0.20) * 100
		if(power_supply.charge >= power_supply.maxcharge)
			charge = 5
		else if (power_supply.charge <= 0)
			charge = 0
		else
			switch(power_supply.charge / power_supply.maxcharge)
				if (0 to 0.25)
					charge = 1
				if (0.25 to 0.50)
					charge = 2
				if (0.50 to 0.75)
					charge = 3
				if (0.75 to 1)
					charge = 4

	overlays += image(icon, src, icon_state = "nucgun-[stunkill][charge]")

	if (core_stability <= 0)
		item_state = "nucguncrit"
	else
		item_state = "[initial(item_state)][stunkill][ratio]"

	switch (core_stability)
		if (-INFINITY to 0)
			overlays += image(icon, src, icon_state = "nucgun-crit")
		if (1 to 4)
			overlays += image(icon, src, icon_state = "nucgun-med")
		if (5 to 9)
			overlays += image(icon, src, icon_state = "nucgun-light")
		if (10 to INFINITY)
			overlays += image(icon, src, icon_state = "nucgun-clean")

////////////////////////////ADVANCED ENERGY GUN (old)//////////////////////////////////////////////

/obj/item/weapon/gun/energy/gun/nuclear/experimental
	name = "\improper Advanced Energy Gun"
	desc = "An energy gun with an experimental miniaturized reactor."
	icon_state = "nucgunold"
	item_state = "nucgunold"

/obj/item/weapon/gun/energy/gun/nuclear/experimental/update_icon()
	overlays.len = 0

	var/ratio = 0
	if (power_supply)
		ratio = round(power_supply.charge / power_supply.maxcharge, 0.25) * 100

	item_state = "[initial(item_state)][ratio]"

	if (core_stability <= 0)
		overlays += image(icon = icon, icon_state = "nucgunold-whee")
		overlays += image(icon = icon, icon_state = "nucgunold-crit")
	else
		overlays += image(icon = icon, icon_state = "nucgunold-[ratio]")
		if (core_stability < 5)
			overlays += image(icon = icon, icon_state = "nucgunold-medium")
		else if (core_stability < 10)
			overlays += image(icon = icon, icon_state = "nucgunold-light")
		else
			overlays += image(icon = icon, icon_state = "nucgunold-clean")

	if (mode == 0)
		overlays += image(icon = icon, icon_state = "nucgunold-stun")
	else if (mode == 1)
		overlays += image(icon = icon, icon_state = "nucgunold-kill")
