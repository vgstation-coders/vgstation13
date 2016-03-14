/obj/item/weapon/gun/projectile/automatic //Hopefully someone will find a way to make these fire in bursts or something. --Superxpdude
	name = "submachine gun"
	desc = "A lightweight, fast firing gun. Uses 9mm rounds."
	icon_state = "saber"	//ugly
	item_state = null
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guninhands_left.dmi', "right_hand" = 'icons/mob/in-hand/right/guninhands_right.dmi')
	w_class = 3.0
	max_shells = 18
	caliber = list("9mm" = 1)
	origin_tech = "combat=3;materials=2"
	ammo_type = "/obj/item/ammo_casing/c9mm"
	automatic = 1
	fire_delay = 0
	var/burstfire = 0 //Whether or not the gun fires multiple bullets at once
	var/burst_count = 3
	load_method = 2
	mag_type = "/obj/item/ammo_storage/magazine/smg9mm"
	starting_materials = list(MAT_IRON = 3500)
	//modules
	barrel_slot_allowed = 1
	tactical_slot_allowed = 1
	underbarrel_slot_allowed = 0
	scope_slot_allowed = 0

	attack_self(mob/user as mob)
		if(user.a_intent == "help")
			burstfire = !burstfire
			if(!burstfire)//fixing a bug where burst fire being toggled on then off would leave the gun unable to shoot at its normal speed.
				fire_delay = initial(fire_delay)
			to_chat(usr, "You toggle \the [src]'s firing setting to [burstfire ? "burst fire" : "single fire"].")

	isHandgun()
		return 0

	update_icon()
		..()
		icon_state = "[initial(icon_state)][stored_magazine ? ".full" : ""][scope_slot ? ".scope" : ""][barrel_slot ? ".silencer" : ""]"
		return

	Fire(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, params, reflex = 0, struggle = 0)
		if(burstfire == 1)
			if(ready_to_fire())
				fire_delay = 0
			else
				to_chat(usr, "<span class='warning'>\The [src] is still cooling down!</span>")
				return
			var/shots_fired = 0
			var/to_shoot = min(burst_count, getAmmo())
			for(var/i = 1; i <= to_shoot; i++)
				..()
				shots_fired++
			message_admins("[usr] just shot [shots_fired] burst fire bullets out of [getAmmo() + shots_fired] from their [src].")
			fire_delay = shots_fired * fire_delay
		else
			..()

/obj/item/weapon/gun/projectile/automatic/rnd //submachine for RnD by viton
	icon_state = "rndsmg"
	starting_materials = list(MAT_IRON = 2500)
	origin_tech = "combat=4;materials=3"

/obj/item/weapon/gun/projectile/automatic/mini_uzi
	name = "Uzi"
	desc = "A lightweight, fast firing gun, for when you want someone dead. Uses .45 rounds."
	icon_state = "mini-uzi"
	item_state = null
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guninhands_left.dmi', "right_hand" = 'icons/mob/in-hand/right/guninhands_right.dmi')
	w_class = 3.0
	max_shells = 10
	burst_count = 3
	caliber = list(".45" = 1)
	origin_tech = "combat=3;materials=2;syndicate=4"
	ammo_type = "/obj/item/ammo_casing/c45"
	mag_type = "/obj/item/ammo_storage/magazine/uzi45"

	barrel_slot_allowed = 1
	tactical_slot_allowed = 0
	underbarrel_slot_allowed = 0
	scope_slot_allowed = 0

	isHandgun()
		return 1

/obj/item/weapon/gun/projectile/automatic/k4me
	name = "\improper Carbine Mk4 short"
	desc = "Short version of Carbine Mk4, for elite of elite, Uses 5.56 rounds. That gun have module slots for - Tactical silenser, Scope, Flashlight."
	icon_state = "k4me"
	item_state = "c20r"
	max_shells = 30
	burst_count = 3
	starting_materials = list(MAT_IRON = 3200)
	caliber = list("5.56" = 1)
	origin_tech = "combat=4;materials=4"
	ammo_type = "/obj/item/ammo_casing/a556"
	mag_type = "/obj/item/ammo_storage/magazine/a556"
	recoil = 2

	barrel_slot_allowed = 1
	tactical_slot_allowed = 1
	underbarrel_slot_allowed = 0
	scope_slot_allowed = 1

	isHandgun()
		return 1

/obj/item/weapon/gun/projectile/automatic/ak7me
	name = "\improper AK 7me"
	desc = "Ha, custom modification of Carbine Mk4 short Uses 7.62 rounds."
	icon_state = "ak7me"
	w_class = 3.0
	max_shells = 30
	caliber = list("7.62" = 1)
	ammo_type = "/obj/item/ammo_casing/a762"
	mag_type = "/obj/item/ammo_storage/magazine/a762/x30"
	origin_tech = "combat=3;materials=2"
	starting_materials = list(MAT_IRON = 1500)
	gun_flags = AUTOMAGDROP
	recoil = 2

	barrel_slot_allowed = 0
	tactical_slot_allowed = 0
	underbarrel_slot_allowed = 0
	scope_slot_allowed = 0

	isHandgun()
		return 1