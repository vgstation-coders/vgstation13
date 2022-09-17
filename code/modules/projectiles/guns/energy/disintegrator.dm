
////////////////////////////////////SMALL DISINTEGRATOR/////////////////////////////////////////////////////
/obj/item/weapon/gun/energy/smalldisintegrator
	name = "Disintegrator"
	desc = "An energy weapon commonly used by mothership greys for self-defense. A power cord secured to the grip controls firing mode selection."
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guninhands_left.dmi', "right_hand" = 'icons/mob/in-hand/right/guninhands_right.dmi')
	icon_state = "disintegratorscorch100"
	item_state = null	//so the human update icon uses the icon_state instead.
	fire_sound = 'sound/weapons/ray1.ogg'

	charge_cost = 100 //How much energy is needed to fire.
	projectile_type = "/obj/item/projectile/beam/scorchray"
	origin_tech = Tc_COMBAT + "=3;" + Tc_MAGNETS + "=2;" + Tc_MATERIALS + "=1"
	modifystate = "disintegratorscorch"
	fire_delay = 0.6 SECONDS // Barely noticeable, mostly here to allow the firing noise .ogg to finish ~0.55 seconds

	var/mode = 0 //0 = scorch, 1 = microwave

/obj/item/weapon/gun/energy/smalldisintegrator/isHandgun()
	return TRUE

/obj/item/weapon/gun/energy/smalldisintegrator/attack_self(mob/living/user as mob)
	switch(mode)
		if(0)
			mode = 1
			fire_sound = 'sound/weapons/ray2.ogg'
			to_chat(user, "<span class='warning'>\The [src] is now set to microwave.</span>")
			projectile_type = "/obj/item/projectile/energy/microwaveray"
			modifystate = "disintegratormicrowave"
			if (power_supply.charge > 0)
				playsound(user,'sound/weapons/egun_toggle_laser.ogg',70,0,-5)
			else
				playsound(user,'sound/weapons/egun_toggle_noammo.ogg',73,0,-5)
		if(1)
			mode = 0
			fire_sound = 'sound/weapons/ray1.ogg'
			to_chat(user, "<span class='warning'>\The [src] is now set to scorch.</span>")
			projectile_type = "/obj/item/projectile/beam/scorchray"
			modifystate = "disintegratorscorch"
			if (power_supply.charge > 0)
				playsound(user,'sound/weapons/egun_toggle_taser.ogg',70,0,-5)
			else
				playsound(user,'sound/weapons/egun_toggle_noammo.ogg',73,0,-5)
	update_icon()

////////////////////////////////////HEAVY DISINTEGRATOR/////////////////////////////////////////////////////
/obj/item/weapon/gun/energy/heavydisintegrator
	name = "Heavy Disintegrator"
	desc = "An upgraded disintegrator, standard issue for the mothership's defense forces."
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guninhands_left.dmi', "right_hand" = 'icons/mob/in-hand/right/guninhands_right.dmi')
	icon_state = "heavydisintegratorimmolate100"
	item_state = null	//so the human update icon uses the icon_state instead.
	fire_sound = 'sound/weapons/ray1.ogg'

	charge_cost = 50 //How much energy is needed to fire.
	projectile_type = "/obj/item/projectile/beam/immolationray"
	origin_tech = Tc_COMBAT + "=4;" + Tc_MAGNETS + "=2;" + Tc_MATERIALS + "=2"
	modifystate = "heavydisintegratorimmolate"
	fire_delay = 1.2 SECONDS // Here to slightly counterbalance the more damaging ray, but a lot less noticeable than the laser cannon

	var/mode = 0 //0 = immolate, 1 = scramble

/obj/item/weapon/gun/energy/heavydisintegrator/attack_self(mob/living/user as mob)
	switch(mode)
		if(0)
			mode = 1
			fire_sound = 'sound/weapons/ray2.ogg'
			to_chat(user, "<span class='warning'>\The [src] is now set to scramble.</span>")
			projectile_type = "/obj/item/projectile/energy/scramblerray"
			modifystate = "heavydisintegratorscramble"
			if (power_supply.charge > 0)
				playsound(user,'sound/weapons/egun_toggle_laser.ogg',70,0,-5)
			else
				playsound(user,'sound/weapons/egun_toggle_noammo.ogg',73,0,-5)
		if(1)
			mode = 0
			fire_sound = 'sound/weapons/ray1.ogg'
			to_chat(user, "<span class='warning'>\The [src] is now set to immolate.</span>")
			projectile_type = "/obj/item/projectile/beam/immolationray"
			modifystate = "heavydisintegratorimmolate"
			if (power_supply.charge > 0)
				playsound(user,'sound/weapons/egun_toggle_taser.ogg',70,0,-5)
			else
				playsound(user,'sound/weapons/egun_toggle_noammo.ogg',73,0,-5)
	update_icon()

////////////////////////////////////ADVANCED DISINTEGRATOR/////////////////////////////////////////////////////
/obj/item/weapon/gun/energy/advdisintegrator
	name = "Advanced Disintegrator"
	desc = "The latest disintegrator model, issued exclusively to mothership administrators for self-defense."
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guninhands_left.dmi', "right_hand" = 'icons/mob/in-hand/right/guninhands_right.dmi')
	icon_state = "advdisintegrator100"
	modifystate = "advdisintegrator"
	item_state = null	//so the human update icon uses the icon_state instead.
	fire_sound = 'sound/weapons/ray1.ogg'

	charge_cost = 50 //How much energy is needed to fire.
	projectile_type = "/obj/item/projectile/beam/atomizationray"
	origin_tech = Tc_COMBAT + "=5;" + Tc_MATERIALS + "=3" + Tc_POWERSTORAGE + "=4"
	fire_delay = 0.6 SECONDS // Barely noticeable, mostly here to allow the firing noise .ogg to finish ~0.55 seconds

	var/charge_tick = 0
	var/charge_wait = 4 // This one charges itself like the Captain's laser, at the cost of fun alternate modes

/obj/item/weapon/gun/energy/advdisintegrator/isHandgun()
	return TRUE

/obj/item/weapon/gun/energy/advdisintegrator/New()
	..()
	processing_objects.Add(src)


/obj/item/weapon/gun/energy/advdisintegrator/Destroy()
	processing_objects.Remove(src)
	..()

/obj/item/weapon/gun/energy/advdisintegrator/process()
	charge_tick++
	if(charge_tick < charge_wait)
		return 0
	charge_tick = 0
	if(!power_supply)
		return 0
	power_supply.give(100)
	update_icon()
	return 1

/obj/item/weapon/gun/energy/advdisintegrator/dissolvable() // Can't be destroyed by polyacid
	return 0
