/obj/item/weapon/gun/projectile/pistol
	name = "pink pistol"
	desc = "A small, quiet,  easily concealable gun. Uses .45 rounds."
	icon_state = "pistol"
	item_state = null
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guninhands_left.dmi', "right_hand" = 'icons/mob/in-hand/right/guninhands_right.dmi')
	w_class = 2.0
	max_shells = 10
	caliber = list(".45"  = 1)
	origin_tech = "combat=2;materials=2"
	ammo_type = "/obj/item/ammo_casing/c45"
	mag_type = "/obj/item/ammo_storage/magazine/c45"
	load_method = MAGAZINE

	barrel_slot_allowed = 1
	tactical_slot_allowed = 1
	underbarrel_slot_allowed = 0
	scope_slot_allowed = 0

	update_icon()
		..()
		icon_state = "[initial(icon_state)][barrel_slot ? ".silencer" : ""][stored_magazine ? ".full" : ""][chambered ? "" : ".empty"]"
		return

/obj/item/weapon/gun/projectile/pistol/syndi
	name = "syndicate pistol"
	desc = "A small, quiet,  easily concealable gun. Uses .45 rounds."
	icon_state = "silenced_pistol"
	origin_tech = "combat=2;materials=2;syndicate=5"

	barrel_slot_allowed = 1
	tactical_slot_allowed = 1
	underbarrel_slot_allowed = 0
	scope_slot_allowed = 0

/obj/item/weapon/gun/projectile/pistol/deagle
	name = "desert eagle"
	desc = "A robust handgun that uses .50 AE ammo"
	icon_state = "deagle"
	w_class = 2.0
	force = 14.0
	max_shells = 7
	caliber = list(".50" = 1)
	ammo_type ="/obj/item/ammo_casing/a50"
	mag_type = "/obj/item/ammo_storage/magazine/a50"
	origin_tech = "combat=4;materials=3;syndicate=5"

	barrel_slot_allowed = 0
	tactical_slot_allowed = 0
	underbarrel_slot_allowed = 0
	scope_slot_allowed = 0

	gun_flags = AUTOMAGDROP | EMPTYCASINGS

/obj/item/weapon/gun/projectile/pistol/deagle/gold
	desc = "A gold plated gun folded over a million times by superior martian gunsmiths. Uses .50 AE ammo."
	icon_state = "deagleg"
	item_state = "deagleg"

/obj/item/weapon/gun/projectile/pistol/deagle/camo
	desc = "A Deagle brand Deagle for operators operating operationally. Uses .50 AE ammo."
	icon_state = "deaglecamo"
	item_state = "deagleg"

/obj/item/weapon/gun/projectile/pistol/gyropistol
	name = "gyrojet pistol"
	desc = "A bulky pistol designed to fire self propelled rounds"
	icon_state = "gyropistol"
	max_shells = 8
	caliber = list("75" = 1)
	fire_sound = 'sound/weapons/elecfire.ogg'
	origin_tech = "combat=3"
	ammo_type = "/obj/item/ammo_casing/a75"
	mag_type = "/obj/item/ammo_storage/magazine/a75"
	load_method = 2

	gun_flags = AUTOMAGDROP | EMPTYCASINGS

	update_icon()
		..()
		if(stored_magazine)
			icon_state = "gyropistolloaded"
		else
			icon_state = "gyropistol"
		return

/obj/item/weapon/gun/projectile/pistol/stechkin
	name = "\improper Stechtkin pistol"
	desc = "A small, easily concealable gun. Uses 9mm rounds."
	icon_state = "pistol"
	w_class = 2
	max_shells = 8
	caliber = list("9mm" = 1)
	silenced = 0
	origin_tech = "combat=2;materials=2;syndicate=2"
	ammo_type = "/obj/item/ammo_casing/c9mm"
	mag_type = "/obj/item/ammo_storage/magazine/mc9mm"
	load_method = 2

	gun_flags = AUTOMAGDROP | EMPTYCASINGS | SILENCECOMP

/obj/item/weapon/gun/projectile/mateba
	name = "mateba"
	desc = "When you absolutely, positively need a 10mm hole in the other guy. Uses .357 ammo."	//>10mm hole >.357
	icon_state = "mateba"
	origin_tech = "combat=2;materials=2"

/obj/item/weapon/gun/projectile/russian
	name = "Russian Revolver"
	desc = "A Russian made revolver. Uses .357 ammo. It has a single slot in it's chamber for a bullet."
	max_shells = 6
	origin_tech = "combat=2;materials=2"

	New()
		..()
		loaded = new/list(6)
		loaded[1] = new ammo_type(src)
		Spin()
		update_icon()

	proc/Spin()
		loaded = shuffle(loaded)

	attackby(var/obj/item/A as obj, mob/user as mob)
		if(!A) return
		var/num_loaded = 0
		if(istype(A, /obj/item/ammo_storage/magazine))
			if((load_method == 2) && getAmmo())	return
			var/obj/item/ammo_storage/magazine/AM = A
			for(var/obj/item/ammo_casing/AC in AM.stored_ammo)
				if(getAmmo() > 0 || getAmmo() >= max_shells)
					break
				if(caliber[AC.caliber] && getAmmo() < max_shells)
					AC.loc = src
					AM.stored_ammo -= AC
					loaded += AC
					num_loaded++
				break
			A.update_icon()
		if(num_loaded)
			user.visible_message("<span class='warning'>[user] loads a single bullet into the revolver and spins the chamber.</span>", "<span class='warning'>You load a single bullet into the chamber and spin it.</span>")
		else
			user.visible_message("<span class='warning'>[user] spins the chamber of the revolver.</span>", "<span class='warning'>You spin the revolver's chamber.</span>")
		if(getAmmo() > 0)
			Spin()
		update_icon()
		return

	attack_self(mob/user as mob)
		user.visible_message("<span class='warning'>[user] spins the chamber of the revolver.</span>", "<span class='warning'>You spin the revolver's chamber.</span>")
		playsound(user, 'sound/weapons/revolver_spin.ogg', 50, 1)
		if(getAmmo() > 0)
			Spin()

	attack(atom/target as mob|obj|turf|area, mob/living/user as mob|obj)
		if(!getAmmo())
			user.visible_message("<span class='warning'>*click*</span>", "<span class='warning'>*click*</span>")
			playsound(user, 'sound/weapons/empty.ogg', 100, 1)
			return
		if(isliving(target) && isliving(user))
			if(target == user)
				var/datum/organ/external/affecting = user.zone_sel.selecting
				if(affecting == "head")

					var/obj/item/ammo_casing/AC = loaded[1]
					if(!AC || !AC.BB)
						user.visible_message("<span class='warning'>*click*</span>", "<span class='warning'>*click*</span>")
						playsound(user, 'sound/weapons/empty.ogg', 100, 1)
						loaded.Cut(1,2)
						loaded += AC
						return
					if(AC.BB)
						in_chamber = AC.BB //Load projectile into chamber.
						AC.BB.loc = src //Set projectile loc to gun.
						AC.BB = null //Empty casings
						AC.update_icon()
					if(!in_chamber)
						return
					var/obj/item/projectile/P = new AC.projectile_type
					playsound(user, fire_sound, 50, 1)
					user.visible_message("<span class='danger'>[user.name] fires [src] at \his head!</span>", "<span class='danger'>You fire [src] at your head!</span>", "You hear a [istype(in_chamber, /obj/item/projectile/beam) ? "laser blast" : "gunshot"]!")
					if(!P.nodamage)
						user.apply_damage(300, BRUTE, affecting) // You are dead, dead, dead.
					in_chamber = null
					loaded.Cut(1,2)
					loaded += AC
					return
		..()