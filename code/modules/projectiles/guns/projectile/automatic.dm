/obj/item/weapon/gun/projectile/automatic
	name = "submachine gun"
	desc = "A lightweight, fast firing gun. Uses 9mm rounds."
	icon_state = "saber"
	item_state = null
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guninhands_left.dmi', "right_hand" = 'icons/mob/in-hand/right/guninhands_right.dmi')
	w_class = 3.0
	max_shells = 18
	caliber = list("9mm" = 1)
	origin_tech = "combat=4;materials=2"
	ammo_type = "/obj/item/ammo_casing/c9mm"
	automatic = 1 //Means you can use this to hold down a room
	fire_delay = 2 //How quickly the gun can fire in ticks in general

	//Burst fire procs
	var/burst_busy = 0 //Helper
	var/burst_allowed = 1 //We can use burst fire on this weapon
	var/burst_fire = 1 //Is burst fire enabled or disabled
	var/burst_count = 3 //How many bullets in a burst. Do note that they all go out at once
	var/burst_firerate = 1 //How quickly the gun can fire in ticks on burst mode
	var/burst_delay = 5 //How long between bursts
	var/burst_last_fired

	load_method = MAGAZINE
	mag_type = "/obj/item/ammo_storage/magazine/smg9mm"

/obj/item/weapon/gun/projectile/automatic/isHandgun()
	return 0

//Helper proc for general rate of fire
/obj/item/weapon/gun/projectile/automatic/proc/burst_ready_to_fire()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\proc/ready_to_fire() called tick#: [world.time]")
	if(!burst_allowed) //This one is going to be simple
		return 0
	if(world.time >= burst_last_fired + burst_delay)
		return 1
	else
		return 0

/obj/item/weapon/gun/projectile/automatic/verb/toggle_firerate()
	set name = "Toggle Firerate"
	set category = "Object"
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""]) \\/obj/item/weapon/gun/projectile/automatic/verb/ToggleFire()  called tick#: [world.time]")
	//Simple cycle
	if(!burst_allowed)
		usr << "<span class='warning'>\The [src]'s firerate cannot be toggled.</span>"
		return
	burst_fire = !burst_fire
	usr.visible_message("<span class='notice'>[usr] toggles \the [src]'s firerate.</span>", \
	"<span class='notice'>You toggle \the [src] to '[burst_fire ? "Burst Fire":"Single Fire"]' mode.</span>")

/obj/item/weapon/gun/projectile/automatic/update_icon()
	..()
	icon_state = "[initial(icon_state)][stored_magazine ? "-[stored_magazine.max_ammo]" : ""][chambered ? "" : "-e"]"
	return

/obj/item/weapon/gun/projectile/automatic/Fire(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, params, reflex = 0, struggle = 0)
	if(burst_fire)
		if(!ready_to_fire() || (!burst_ready_to_fire() && !burst_busy))
			return
		fire_delay = burst_firerate - 1 //Sanity needed
		burst_busy = 1
		var/shots_fired = 0 //Haha, I'm so clever
		var/to_shoot = min(burst_count, getAmmo())
		for(var/i = 1; i <= to_shoot; i++)
			..()
			shots_fired++
			sleep(burst_firerate) //Make sure we don't hit our own cooldown, that would be dumb
		burst_last_fired = world.time
		burst_busy = 0
		if(shots_fired) //Only warn the admins if any shots were fired
			message_admins("[usr] just shot [shots_fired] bullets in burst fire out of [getAmmo() + shots_fired] from their [src.name].")
	else
		fire_delay = initial(fire_delay) //Reset the fire delay
		..() //Default behavior, single shot, let's go

/obj/item/weapon/gun/projectile/automatic/micro_uzi
	name = "Micro-Uzi"
	desc = "The most popular pocket-sized submachine gun on the black market. Small magazines for a small weapon, fires quickly. Uses .45 rounds."
	icon_state = "micro-uzi"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guninhands_left.dmi', "right_hand" = 'icons/mob/in-hand/right/guninhands_right.dmi')
	w_class = 2.0
	max_shells = 12
	fire_delay = 1
	burst_count = 4
	caliber = list(".45" = 1)
	origin_tech = "combat=5;materials=2;syndicate=8"
	ammo_type = "/obj/item/ammo_casing/c45"
	mag_type = "/obj/item/ammo_storage/magazine/uzimicro45"

/obj/item/weapon/gun/projectile/automatic/micro_uzi/isHandgun()
	return 1

//Based off the FN F2000
/obj/item/weapon/gun/projectile/automatic/c20r
	name = "\improper C-20R"
	desc = "A lightweight burst-fire assault rifle. A favourite of many mercenary operatives, the most famous users of this gun are the mysterious Syndicate. Uses 5.56x45 rounds. Has a 'Scarborough Arms - Per falcis, per pravitas' buttstamp."
	icon_state = "c20r"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guns.dmi', "right_hand" = 'icons/mob/in-hand/right/guns.dmi')
	item_state = "c20r"
	w_class = 3.0
	max_shells = 30
	burst_count = 3
	caliber = list("556x45" = 1)
	origin_tech = "combat=5;materials=2;syndicate=8"
	ammo_type = "/obj/item/ammo_casing/a556x45"
	mag_type = "/obj/item/ammo_storage/magazine/a556x45"
	fire_sound = 'sound/weapons/c20r.ogg'
	fire_sound_far = 'sound/weapons/c20r_far.ogg'

	gun_flags = AUTOMAGDROP | SILENCECOMP

/obj/item/weapon/gun/projectile/automatic/c20r/update_icon()
	..()
	overlays = 0
	if(stored_magazine)
		icon_state = "c20r-[round(getAmmo(), 5)]"
	else
		icon_state = "c20r"
	if(silenced)
		overlays += "[icon_state]-silencer"
	return

/obj/item/weapon/gun/projectile/automatic/xcom
	name = "\improper Antique Assault Rifle"
	desc = "An iconic, fast firing assault rifle with a slow, controlled burst fire system. A relic of a long-gone time."
	icon_state = "xcomassaultrifle"
	item_state = null
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guninhands_left.dmi', "right_hand" = 'icons/mob/in-hand/right/guninhands_right.dmi')
	origin_tech = "combat=5;materials=2"
	w_class = 3.0
	max_shells = 20 //That authentic XCOM feeling. Five slow bursts of four bullets per mag
	burst_count = 4
	burst_delay = 10
	caliber = list("12mm" = 1)
	ammo_type = "/obj/item/ammo_casing/a12mm"
	mag_type = "/obj/item/ammo_storage/magazine/a12mm"
	fire_sound = 'sound/weapons/c20r.ogg'
	fire_sound_far = 'sound/weapons/c20r_far.ogg'

	gun_flags = AUTOMAGDROP

/obj/item/weapon/gun/projectile/automatic/l6_saw
	name = "\improper L6 SAW"
	desc = "A rather traditionally made light machine gun with a pleasantly lacquered wooden pistol grip. Has 'Aussec Armoury- 2531' engraved on the reciever"
	icon_state = "l6closed100"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guns.dmi', "right_hand" = 'icons/mob/in-hand/right/guns.dmi')
	item_state = "l6closedmag"
	w_class = 4
	slot_flags = 0
	max_shells = 120 //Buy a L6 SAW magazine, get 20 bullets for free
	burst_count = 10 //Small magdump
	burst_delay = 10 //Supression fire delay
	caliber = list("a762" = 1)
	origin_tech = "combat=5;materials=1;syndicate=2"
	ammo_type = "/obj/item/ammo_casing/a762"
	mag_type = "/obj/item/ammo_storage/magazine/a762"
	fire_sound = 'sound/weapons/smg.ogg'
	fire_sound_far = 'sound/weapons/smg_far.ogg'
	var/cover_open = 0


/obj/item/weapon/gun/projectile/automatic/l6_saw/attack_self(mob/user as mob)
	cover_open = !cover_open
	user.visible_message("<span class='notice'>[user] [cover_open ? "opens" : "closes"] \the [src]'s cover.</span>", \
	"<span class='notice'>You [cover_open ? "open" : "close"] \the [src]'s cover.</span>")
	update_icon()


/obj/item/weapon/gun/projectile/automatic/l6_saw/update_icon()
	icon_state = "l6[cover_open ? "open" : "closed"][stored_magazine ? round(getAmmo(), 20) : "-empty"]"


/obj/item/weapon/gun/projectile/automatic/l6_saw/afterattack(atom/target as mob|obj|turf, mob/living/user as mob|obj, flag, params) //what I tried to do here is just add a check to see if the cover is open or not and add an icon_state change because I can't figure out how c-20rs do it with overlays
	if(cover_open)
		user << "<span class='warning'>\The [src]'s cover is open! Close it before firing!</span>"
	else
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
		remove_mag(user)
		user << "<span class='notice'>You remove \the [stored_magazine] from \the [src].</span>"


/obj/item/weapon/gun/projectile/automatic/l6_saw/attackby(obj/item/ammo_storage/magazine/a762/A as obj, mob/user as mob)
	if(!cover_open)
		user << "<span class='warning'>\The [src]'s cover is closed! You can't insert a new mag!</span>"
		return
	else if(cover_open)
		..()

/obj/item/weapon/gun/projectile/automatic/l6_saw/manual_remove_mag() //special because of its cover
	if(cover_open && stored_magazine)
		remove_mag(usr)
		usr << "<span class='notice'>You remove \the [stored_magazine] from \the [src].</span>"
	else if(stored_magazine)
		usr << "<span class='warning'>\The [src]'s cover is closed! You can't remove the mag!</span>"
	else
		usr << "<span class='warning'>\The [src] doesn't have a magazine loaded!</span>"


/* The thing I found with guns in ss13 is that they don't seem to simulate the rounds in the magazine in the gun.
   Afaik, since projectile.dm features a revolver, this would make sense since the magazine is part of the gun.
   However, it looks like subsequent guns that use removable magazines don't take that into account and just get
   around simulating a removable magazine by adding the casings into the loaded list and spawning an empty magazine
   when the gun is out of rounds. Which means you can't eject magazines with rounds in them. The below is a very
   rough and poor attempt at making that happen. -Ausops */

/* Guns now properly store and move magazines and bullets about. Moving bullets from loaded to the magazine and back again on actions
   still feels poorly coded and hacky, but it's more trouble than this to attempt to modify gun code any further. Perhaps a braver
   soul than I might feel that some injustice was done in quitting most of the way there, but I think this is modular enough. */

/* Changed a lot of code. Far sounds, better hostage taking. I hope I've done some more justice to gunplay. */
