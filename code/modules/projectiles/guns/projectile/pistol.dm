/obj/item/weapon/gun/projectile/silenced
	name = "silenced pistol"
	desc = "A small, quiet,  easily concealable gun. Uses .45 rounds."
	icon_state = "silenced_pistol"
	item_state = null
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guninhands_left.dmi', "right_hand" = 'icons/mob/in-hand/right/guninhands_right.dmi')
	w_class = 3.0
	max_shells = 10
	caliber = list(".45"  = 1)
	silenced = 1
	origin_tech = "combat=2;materials=2;syndicate=8"
	ammo_type = "/obj/item/ammo_casing/c45"
	mag_type = "/obj/item/ammo_storage/magazine/c45"
	load_method = 2


/obj/item/weapon/gun/projectile/deagle
	name = "desert eagle"
	desc = "A robust handgun that uses .50 AE ammo"
	icon_state = "deagle"
	item_state = null
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guninhands_left.dmi', "right_hand" = 'icons/mob/in-hand/right/guninhands_right.dmi')
	force = 14.0
	max_shells = 7
	caliber = list(".50" = 1)
	ammo_type ="/obj/item/ammo_casing/a50"
	mag_type = "/obj/item/ammo_storage/magazine/a50"
	load_method = 2

	gun_flags = AUTOMAGDROP | EMPTYCASINGS

/obj/item/weapon/gun/projectile/deagle/gold
	desc = "A gold plated gun folded over a million times by superior martian gunsmiths. Uses .50 AE ammo."
	icon_state = "deagleg"
	item_state = "deagleg"


/obj/item/weapon/gun/projectile/deagle/camo
	desc = "A Deagle brand Deagle for operators operating operationally. Uses .50 AE ammo."
	icon_state = "deaglecamo"
	item_state = "deagleg"



/obj/item/weapon/gun/projectile/gyropistol
	name = "gyrojet pistol"
	desc = "A bulky pistol designed to fire self propelled rounds"
	icon_state = "gyropistol"
	item_state = null
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guninhands_left.dmi', "right_hand" = 'icons/mob/in-hand/right/guninhands_right.dmi')
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

/obj/item/weapon/gun/projectile/pistol
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

/obj/item/weapon/gun/projectile/pistol/update_icon()
	..()
	icon_state = "[initial(icon_state)][silenced ? "-silencer" : ""][chambered ? "" : "-e"]"
	return

/obj/item/weapon/gun/projectile/mateba
	name = "mateba"
	desc = "When you absolutely, positively need a 10mm hole in the other guy. Uses .357 ammo."	//>10mm hole >.357
	icon_state = "mateba"
	origin_tech = "combat=2;materials=2"

// A gun to play Russian Roulette!
// You can spin the chamber to randomize the position of the bullet.

/obj/item/weapon/gun/projectile/russian
	name = "Russian Revolver"
	desc = "A Russian made revolver. Uses .357 ammo. It has a single slot in it's chamber for a bullet."
	max_shells = 6
	origin_tech = "combat=2;materials=2"

/obj/item/weapon/gun/projectile/russian/New()
	..()
	loaded = new/list(6)
	loaded[1] = new ammo_type(src)
	Spin()
	update_icon()

/obj/item/weapon/gun/projectile/russian/proc/Spin()

	loaded = shuffle(loaded)

/obj/item/weapon/gun/projectile/russian/attackby(var/obj/item/A as obj, mob/user as mob)

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

/obj/item/weapon/gun/projectile/russian/attack_self(mob/user as mob)

	user.visible_message("<span class='warning'>[user] spins the chamber of the revolver.</span>", "<span class='warning'>You spin the revolver's chamber.</span>")
	playsound(user, 'sound/weapons/revolver_spin.ogg', 50, 1)
	if(getAmmo() > 0)
		Spin()

/obj/item/weapon/gun/projectile/russian/attack(atom/target as mob|obj|turf|area, mob/living/user as mob|obj)

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

/obj/item/weapon/gun/projectile/detective
	desc = "A cheap Martian knock-off of a Smith & Wesson Model 10. Uses .38-Special rounds."
	name = "revolver"
	icon_state = "detective"
	max_shells = 6
	caliber = list("38" = 1, "357" = 1)
	origin_tech = "combat=2;materials=2"
	ammo_type = "/obj/item/ammo_casing/c38"
	var/perfect = 0

	special_check(var/mob/living/carbon/human/M) //to see if the gun fires 357 rounds safely. A non-modified revolver randomly blows up
		if(getAmmo()) //this is a good check, I like this check
			var/obj/item/ammo_casing/AC = loaded[1]
			if(caliber["38"] == 0) //if it's been modified, this is true
				return 1
			if(istype(AC, /obj/item/ammo_casing/a357) && !perfect && prob(70 - (getAmmo() * 10)))	//minimum probability of 10, maximum of 60
				to_chat(M, "<span class='danger'>[src] blows up in your face.</span>")
				M.take_organ_damage(0,20)
				M.drop_item(src, force_drop = 1)
				qdel(src)
				return 0
		return 1

	verb/rename_gun()
		set name = "Name Gun"
		set category = "Object"
		set desc = "Click to rename your gun. If you're the detective."

		var/mob/M = usr
		if(!M.mind)	return 0
		if(!M.mind.assigned_role == "Detective")
			to_chat(M, "<span class='notice'>You don't feel cool enough to name this gun, chump.</span>")
			return 0

		var/input = stripped_input(usr,"What do you want to name the gun?", ,"", MAX_NAME_LEN)

		if(src && input && !M.stat && in_range(src,M))
			name = input
			to_chat(M, "You name the gun [input]. Say hello to your new friend.")
			return 1

	attackby(var/obj/item/A as obj, mob/user as mob)
		..()
		if(isscrewdriver(A) || istype(A, /obj/item/weapon/conversion_kit))
			var/obj/item/weapon/conversion_kit/CK
			if(istype(A, /obj/item/weapon/conversion_kit))
				CK = A
				if(!CK.open)
					to_chat(user, "<span class='notice'>This [CK.name] is useless unless you open it first. </span>")
					return
			if(caliber["38"])
				to_chat(user, "<span class='notice'>You begin to reinforce the barrel of [src].</span>")
				if(getAmmo())
					afterattack(user, user)	//you know the drill
					playsound(user, fire_sound, 50, 1)
					user.visible_message("<span class='danger'>[src] goes off!</span>", "<span class='danger'>[src] goes off in your face!</span>")
					return
				if(do_after(user, src, 30))
					if(getAmmo())
						to_chat(user, "<span class='notice'>You can't modify it!</span>")
						return
					caliber["38"] = 0
					desc = "The barrel and chamber assembly seems to have been modified."
					to_chat(user, "<span class='warning'>You reinforce the barrel of [src]! Now it will fire .357 rounds.</span>")
					if(CK && istype(CK))
						perfect = 1
			else
				to_chat(user, "<span class='notice'>You begin to revert the modifications to [src].</span>")
				if(getAmmo())
					afterattack(user, user)	//and again
					playsound(user, fire_sound, 50, 1)
					user.visible_message("<span class='danger'>[src] goes off!</span>", "<span class='danger'>[src] goes off in your face!</span>")
					return
				if(do_after(user, src, 30))
					if(getAmmo())
						to_chat(user, "<span class='notice'>You can't modify it!</span>")
						return
					caliber["38"] = 1
					desc = initial(desc)
					to_chat(user, "<span class='warning'>You remove the modifications on [src]! Now it will fire .38 rounds.</span>")
					perfect = 0








