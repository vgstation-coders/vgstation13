/obj/item/weapon/gun/energy/gun
	name = "energy gun"
	desc = "A basic energy-based gun with two settings: Stun and kill."
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
			to_chat(user, "<span class='warning'>[src.name] is now set to kill.</span>")
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
			to_chat(user, "<span class='warning'>[src.name] is now set to stun.</span>")
			projectile_type = "/obj/item/projectile/energy/electrode"
			modifystate = "energystun"
			if (power_supply.charge > 0)
				playsound(user,'sound/weapons/egun_toggle_taser.ogg',70,0,-5)
			else
				playsound(user,'sound/weapons/egun_toggle_noammo.ogg',73,0,-5)
	update_icon()

/obj/item/weapon/gun/energy/gun/nuclear
	name = "Advanced Energy Gun"
	desc = "An energy gun with an experimental miniaturized reactor."
	icon_state = "nucgun"
	origin_tech = Tc_COMBAT + "=3;" + Tc_MATERIALS + "=5;" + Tc_POWERSTORAGE + "=3"
	var/lightfail = 0
	var/charge_tick = 0

/obj/item/weapon/gun/energy/gun/nuclear/New()
	..()
	processing_objects.Add(src)


/obj/item/weapon/gun/energy/gun/nuclear/Destroy()
	processing_objects.Remove(src)
	..()


/obj/item/weapon/gun/energy/gun/nuclear/process()
	charge_tick++
	if(charge_tick < 4)
		return 0
	charge_tick = 0
	if(!power_supply)
		return 0
	if((power_supply.charge / power_supply.maxcharge) != 1)
		if(!failcheck())
			return 0
		power_supply.give(100)
		update_icon()
	return 1


/obj/item/weapon/gun/energy/gun/nuclear/proc/failcheck()
	lightfail = 0
	if (prob(src.reliability))
		return 1 //No failure
	if (prob(src.reliability))
		for (var/mob/living/M in range(0,src)) //Only a minor failure, enjoy your radiation if you're in the same tile or carrying it
			if (src in M.contents)
				to_chat(M, "<span class='warning'>Your gun feels pleasantly warm for a moment.</span>")
			else
				to_chat(M, "<span class='warning'>You feel a warm sensation.</span>")
			M.apply_effect(rand(3,120), IRRADIATE)
		lightfail = 1
	else
		for (var/mob/living/M in range(rand(1,4),src)) //Big failure, TIME FOR RADIATION BITCHES
			if (src in M.contents)
				to_chat(M, "<span class='warning'>Your gun's reactor overloads!</span>")
			to_chat(M, "<span class='warning'>You feel a wave of heat wash over you.</span>")
			M.apply_effect(300, IRRADIATE)
		crit_fail = 1 //break the gun so it stops recharging
		processing_objects.Remove(src)
		update_icon()
	return 0


/obj/item/weapon/gun/energy/gun/nuclear/proc/update_charge()
	if (crit_fail)
		overlays += image(icon = icon, icon_state = "nucgun-whee")
		return
	var/ratio = power_supply.charge / power_supply.maxcharge
	ratio = round(ratio, 0.25) * 100
	overlays += image(icon = icon, icon_state = "nucgun-[ratio]")


/obj/item/weapon/gun/energy/gun/nuclear/proc/update_reactor()
	if(crit_fail)
		overlays += image(icon = icon, icon_state = "nucgun-crit")
		return
	if(lightfail)
		overlays += image(icon = icon, icon_state = "nucgun-medium")
	else if ((power_supply.charge/power_supply.maxcharge) <= 0.5)
		overlays += image(icon = icon, icon_state = "nucgun-light")
	else
		overlays += image(icon = icon, icon_state = "nucgun-clean")


/obj/item/weapon/gun/energy/gun/nuclear/proc/update_mode()
	if (mode == 0)
		overlays += image(icon = icon, icon_state = "nucgun-stun")
	else if (mode == 1)
		overlays += image(icon = icon, icon_state = "nucgun-kill")


/obj/item/weapon/gun/energy/gun/nuclear/emp_act(severity)
	..()
	reliability -= round(15/severity)


/obj/item/weapon/gun/energy/gun/nuclear/update_icon()
	overlays.len = 0
	update_charge()
	update_reactor()
	update_mode()
