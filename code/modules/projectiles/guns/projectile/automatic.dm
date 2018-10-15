/obj/item/weapon/gun/projectile/automatic //Hopefully someone will find a way to make these fire in bursts or something. --Superxpdude
	name = "submachine gun"
	desc = "A lightweight, fast firing gun. Uses 9mm rounds."
	icon_state = "saber"	//ugly
	item_state = null
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guninhands_left.dmi', "right_hand" = 'icons/mob/in-hand/right/guninhands_right.dmi')
	w_class = W_CLASS_MEDIUM
	max_shells = 18
	caliber = list(MM9 = 1)
	origin_tech = Tc_COMBAT + "=4;" + Tc_MATERIALS + "=2"
	ammo_type = "/obj/item/ammo_casing/c9mm"
	automatic = 1
	fire_delay = 0
	var/burstfire = 0 //Whether or not the gun fires multiple bullets at once
	var/burst_count = 3
	var/burstfiring = 0
	load_method = 2
	mag_type = "/obj/item/ammo_storage/magazine/smg9mm"


/obj/item/weapon/gun/projectile/automatic/isHandgun()
	return FALSE

/obj/item/weapon/gun/projectile/automatic/verb/ToggleFire()
	set name = "Toggle Burstfire"
	set category = "Object"
	if(!(world.time >= last_fired + fire_delay) || burstfiring)
		to_chat(usr, "<span class='warning'>\The [src] is still cooling down!</span>")
	else
		burstfire = !burstfire
		if(!burstfire)//fixing a bug where burst fire being toggled on then off would leave the gun unable to shoot at its normal speed.
			fire_delay = initial(fire_delay)
		to_chat(usr, "You toggle \the [src]'s firing setting to [burstfire ? "burst fire" : "single fire"].")

/obj/item/weapon/gun/projectile/automatic/update_icon()
	..()
	icon_state = "[initial(icon_state)][stored_magazine ? "-[stored_magazine.max_ammo]" : ""][silenced ? "-silencer":""][chambered ? "" : "-e"]"
	return

/obj/item/weapon/gun/projectile/automatic/Fire(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, params, reflex = 0, struggle = 0)
	if(burstfire == TRUE)
		if(!ready_to_fire())
			return 1
		var/shots_fired = 0 //haha, I'm so clever
		var/to_shoot = min(burst_count, getAmmo())
		if(defective && prob(20))
			to_shoot = getAmmo()
		for(var/i = 1 to to_shoot)
			..()
			burstfiring = 1
			shots_fired++
			if(!user.contents.Find(src) || jammed)
				break
			if(defective && shots_fired > burst_count)
				recoil = 1 + min(shots_fired - burst_count, 6)
			if(defective && prob(max(0, shots_fired - burst_count * 4)))
				to_chat(user, "<span class='danger'>\The [src] explodes!.</span>")
				explosion(get_turf(loc), -1, 0, 2)
				user.drop_item(src, force_drop = 1)
				qdel(src)
		recoil = initial(recoil)
		burstfiring = 0
		return 1
	else
		.=..()

/obj/item/weapon/gun/projectile/automatic/failure_check(var/mob/living/carbon/human/M)
	if(!burstfire && prob(5))
		burstfire = 1
		return 1
	return ..()

/obj/item/weapon/gun/projectile/automatic/lockbox
	mag_type = "/obj/item/ammo_storage/magazine/smg9mm/empty"

/obj/item/weapon/gun/projectile/automatic/uzi
	name = "\improper Uzi"
	desc = "A lightweight, fast firing gun for when you definitely want someone dead. Uses .45 rounds."
	icon_state = "mini-uzi"
	item_state = null
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guninhands_left.dmi', "right_hand" = 'icons/mob/in-hand/right/guninhands_right.dmi')
	w_class = W_CLASS_MEDIUM
	max_shells = 10
	burst_count = 3
	caliber = list(POINT45 = 1)
	origin_tech = Tc_COMBAT + "=5;" + Tc_MATERIALS + "=2;" + Tc_SYNDICATE + "=8"
	ammo_type = "/obj/item/ammo_casing/c45"
	mag_type = "/obj/item/ammo_storage/magazine/uzi45"

/obj/item/weapon/gun/projectile/automatic/uzi/isHandgun()
	return TRUE

/obj/item/weapon/gun/projectile/automatic/uzi/micro
	name = "\improper Micro Uzi"
	desc = "A concealable rapid-fire machine pistol for filling a target with lead. Chambered for .45 rounds. Has mounting for a silencer."
	icon_state = "microsmg"
	item_state = "microuzi"
	gun_flags = EMPTYCASINGS | SILENCECOMP
	w_class = W_CLASS_SMALL


/obj/item/weapon/gun/projectile/automatic/c20r
	name = "\improper C-20r SMG"
	desc = "A lightweight, fast firing gun for when you REALLY want someone dead. Uses 12mm rounds. Has a \"Scarborough Arms - Per falcis, per pravitas\" buttstamp."
	icon_state = "c20r"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guns.dmi', "right_hand" = 'icons/mob/in-hand/right/guns.dmi')
	item_state = "c20r"
	w_class = W_CLASS_MEDIUM
	max_shells = 20
	burst_count = 4
	caliber = list(MM12 = 1)
	origin_tech = Tc_COMBAT + "=5;" + Tc_MATERIALS + "=2;" + Tc_SYNDICATE + "=8"
	ammo_type = "/obj/item/ammo_casing/a12mm"
	mag_type = "/obj/item/ammo_storage/magazine/a12mm/ops"
	fire_sound = 'sound/weapons/Gunshot_c20.ogg'
	mag_drop_sound = 'sound/weapons/smg_empty_alarm.ogg'
	automagdrop_delay_time = 0
	load_method = 2

	gun_flags = AUTOMAGDROP | EMPTYCASINGS

/obj/item/weapon/gun/projectile/automatic/c20r/update_icon()
	..()
	if(stored_magazine)
		icon_state = "c20r-[round(getAmmo(),4)]"
	else
		icon_state = "c20r"
	return

/obj/item/weapon/gun/projectile/automatic/xcom
	name = "\improper Assault Rifle"
	desc = "A lightweight, fast firing gun, issued to shadow organization members."
	icon_state = "xcomassaultrifle"
	item_state = null
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guninhands_left.dmi', "right_hand" = 'icons/mob/in-hand/right/guninhands_right.dmi')
	origin_tech = Tc_COMBAT + "=5;" + Tc_MATERIALS + "=2"
	w_class = W_CLASS_MEDIUM
	max_shells = 20
	burst_count = 4
	caliber = list(MM12 = 1)
	ammo_type = "/obj/item/ammo_casing/a12mm/assault"
	mag_type = "/obj/item/ammo_storage/magazine/a12mm"
	fire_sound = 'sound/weapons/Gunshot_c20.ogg'
	load_method = 2
	gun_flags = AUTOMAGDROP | EMPTYCASINGS

/obj/item/weapon/gun/projectile/automatic/xcom/lockbox
	mag_type = "/obj/item/ammo_storage/magazine/a12mm/empty"


/obj/item/weapon/gun/projectile/automatic/l6_saw
	name = "\improper L6 SAW"
	desc = "A rather traditionally made light machine gun with a pleasantly lacquered wooden pistol grip. Has 'Aussec Armoury- 2531' engraved on the reciever"
	icon_state = "l6closed100"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guns.dmi', "right_hand" = 'icons/mob/in-hand/right/guns.dmi')
	item_state = "l6closedmag"
	w_class = W_CLASS_LARGE
	slot_flags = 0
	max_shells = 50
	burst_count = 5
	caliber = list(POINT762 = 1)
	origin_tech = Tc_COMBAT + "=5;" + Tc_MATERIALS + "=1;" + Tc_SYNDICATE + "=2"
	ammo_type = "/obj/item/ammo_casing/a762"
	mag_type = "/obj/item/ammo_storage/magazine/a762"
	fire_sound = 'sound/weapons/Gunshot_smg.ogg'
	load_method = 2
	var/cover_open = 0


/obj/item/weapon/gun/projectile/automatic/l6_saw/attack_self(mob/user as mob)
	cover_open = !cover_open
	to_chat(user, "<span class='notice'>You [cover_open ? "open" : "close"] [src]'s cover.</span>")
	update_icon()


/obj/item/weapon/gun/projectile/automatic/l6_saw/update_icon()
	icon_state = "l6[cover_open ? "open" : "closed"][stored_magazine ? round(getAmmo(), 25) : "-empty"]"


/obj/item/weapon/gun/projectile/automatic/l6_saw/can_discharge()
	. = ..()
	if(cover_open)
		to_chat(loc, "<span class='notice'>[src]'s cover is open! Close it before firing!</span>")
		return 0


/obj/item/weapon/gun/projectile/automatic/l6_saw/afterattack(atom/target as mob|obj|turf, mob/living/user as mob|obj, flag, params, struggle = 0) //what I tried to do here is just add a check to see if the cover is open or not and add an icon_state change because I can't figure out how c-20rs do it with overlays
	if(can_discharge())
		..()
		update_icon()


/obj/item/weapon/gun/projectile/automatic/l6_saw/attack_hand(mob/user as mob)
	if(loc != user)
		..()
		return	//let them pick it up
	if(!cover_open)
		..()
	else if(cover_open && stored_magazine) //since attack_self toggles the cover and not the magazine, we use this instead
		//drop the mag
		RemoveMag(user)
		to_chat(user, "<span class='notice'>You remove the magazine from [src].</span>")


/obj/item/weapon/gun/projectile/automatic/l6_saw/attackby(obj/item/ammo_storage/magazine/a762/A as obj, mob/user as mob)
	if(!cover_open)
		to_chat(user, "<span class='notice'>[src]'s cover is closed! You can't insert a new mag!</span>")
		return
	else if(cover_open)
		..()

/obj/item/weapon/gun/projectile/automatic/l6_saw/force_removeMag() //special because of its cover
	if(!cover_open)
		to_chat(usr, "<span class='rose'>The [src]'s cover has to be open to do that!</span>")
		return
	..()


/* The thing I found with guns in ss13 is that they don't seem to simulate the rounds in the magazine in the gun.
   Afaik, since projectile.dm features a revolver, this would make sense since the magazine is part of the gun.
   However, it looks like subsequent guns that use removable magazines don't take that into account and just get
   around simulating a removable magazine by adding the casings into the loaded list and spawning an empty magazine
   when the gun is out of rounds. Which means you can't eject magazines with rounds in them. The below is a very
   rough and poor attempt at making that happen. -Ausops */

/* Guns now properly store and move magazines and bullets about. Moving bullets from loaded to the magazine and back again on actions
   still feels poorly coded and hacky, but it's more trouble than this to attempt to modify gun code any further. Perhaps a braver
   soul than I might feel that some injustice was done in quitting most of the way there, but I think this is modular enough. */
