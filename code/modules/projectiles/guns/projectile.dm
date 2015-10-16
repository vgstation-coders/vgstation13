#define SPEEDLOADER 0 //The gun is loaded from a special loading device
#define MANUAL 1 //The gun is loaded manually. No fancy tricks, just slot rounds one by one
#define MAGAZINE 2 //The gun is loaded from a magazine

/obj/item/weapon/gun/projectile
	desc = "A classic revolver. Uses .357 ammo"
	name = "revolver"
	icon_state = "revolver"
	caliber = list("357" = 1)
	origin_tech = "combat=2;materials=2"
	w_class = 3.0
	starting_materials = list(MAT_IRON = 1000)
	w_type = RECYK_METAL
	recoil = 1
	var/ammo_type = "/obj/item/ammo_casing/a357"
	var/list/loaded = list() //All casings loaded into the gun
	var/max_shells = 7 //Only used by guns with no magazine
	var/load_method = SPEEDLOADER //How the weapon can be loaded, outside of manual
	var/obj/item/ammo_storage/magazine/stored_magazine = null //Loaded mag if any
	var/obj/item/ammo_casing/chambered = null //Bullet in the chamber
	var/mag_type = ""

/obj/item/weapon/gun/projectile/New()
	..()
	if(mag_type && load_method == MAGAZINE) //Magazine method
		stored_magazine = new mag_type(src)
		chamber_round() //No extra round in the magazine on start-up
	else //Not a magazine, so all bullets are shoved into the loaded queue
		for(var/i = 1, i <= max_shells, i++)
			loaded += new ammo_type(src)
	update_icon()
	return

//Loads the argument magazine into the gun
/obj/item/weapon/gun/projectile/proc/load_mag(var/obj/item/ammo_storage/magazine/AM, var/mob/user)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/obj/item/weapon/gun/projectile/proc/load_mag() called tick#: [world.time]")
	if(istype(AM, text2path(mag_type)) && !stored_magazine)
		if(user)
			user.drop_item(AM, src)
			user << "<span class='notice'>You load \the [AM] into \the [src].</span>"
		stored_magazine = AM
		playsound(get_turf(src), stored_magazine.magazine_insert_sound, 100, 1)
		if(!chambered) //So you can keep the chambered round with a new mag
			chamber_round()
		AM.update_icon()
		update_icon()
		return 1
	return 0

/obj/item/weapon/gun/projectile/proc/remove_mag(var/mob/user)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/obj/item/weapon/gun/projectile/proc/remove_mag() called tick#: [world.time]")
	if(stored_magazine)
		stored_magazine.loc = get_turf(src)
		if(user)
			user.put_in_hands(stored_magazine)
			user << "<span class='notice'>You pull \the [stored_magazine] out of \the [src]!</span>"
		playsound(get_turf(src), stored_magazine.magazine_remove_sound, 100, 1)
		stored_magazine.update_icon()
		stored_magazine = null
		update_icon()
		return 1
	return 0

/obj/item/weapon/gun/projectile/verb/manual_remove_mag()
	set name = "Remove Magazine"
	set category = "Object"
	set src in range(0)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""]) \\/obj/item/weapon/gun/projectile/verb/manual_remove_mag()  called tick#: [world.time]")
	if(stored_magazine)
		remove_mag()
	else
		usr << "<span class='warning'>\The [src] doesn't have a magazine loaded!</span>"

//Only used by guns with a magazine
/obj/item/weapon/gun/projectile/proc/chamber_round()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/obj/item/weapon/gun/projectile/proc/chamber_round() called tick#: [world.time]")
	if(chambered || !stored_magazine)
		return 0
	else
		var/obj/item/ammo_casing/round = stored_magazine.get_round()
		if(istype(round))
			chambered = round
			chambered.loc = src
			return 1
	return 0

//Fetch a particular ammo casing (known as AC from now on) from our ammo pool
/obj/item/weapon/gun/projectile/proc/getAC()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/obj/item/weapon/gun/projectile/proc/getAC() called tick#: [world.time]")
	var/obj/item/ammo_casing/AC = null
	if(mag_type && load_method == MAGAZINE)
		AC = chambered //Go fetch the chambered round
	else if(getAmmo())
		AC = loaded[1] //Fetch the first casing in the loaded list
	return AC

//Process a chambered round to fire it
/obj/item/weapon/gun/projectile/process_chambered()
	var/obj/item/ammo_casing/AC = getAC() //Fetch the ammo casing
	if(in_chamber) //The round is chambered
		return 1 //{R}
	if(isnull(AC) || !istype(AC)) //We can't find it
		return 0
	if(mag_type && load_method == MAGAZINE) //Magazine-loaded
		chambered = null //Cycle the chambered round
		chamber_round()
	else
		loaded -= AC //Remove casing from loaded list
	if(AC.eject_casing) //This casing is ejected (empty casing)
		AC.loc = get_turf(src) //Eject onto ground
	if(AC.BB) //If the ammo casing has the good stuff only
		in_chamber = AC.BB //Load projectile into chamber
		AC.BB.loc = src //Set projectile loc to gun
		AC.BB = null //Empty the casing's good stuff
		AC.update_icon()
		return 1 //Ready to fire sir
	return 0

/obj/item/weapon/gun/projectile/attackby(var/obj/item/A as obj, mob/user as mob)
	if(istype(A, /obj/item/gun_part/silencer) && src.gun_flags & SILENCECOMP)
		if(user.l_hand != src && user.r_hand != src) //If we're not in his hands
			user << "<span class='notice'>You'll need \the [src] in your hands to do that.</span>"
			return
		user.drop_item(A, src) //Put the silencer into the gun
		user.visible_message("<span class='notice'>[user] screws \a [A.name] onto \the [src].</span>", \
		"<span class='notice'>You screw \a [A.name] onto \the [src].</span>")
		silenced = A //Add the silencer to the gun
		update_icon()
		return 1

	if(istype(A, /obj/item/ammo_storage/magazine))
		var/obj/item/ammo_storage/magazine/AM = A
		if(load_method == MAGAZINE) //Magazine loading
			if(!stored_magazine)
				load_mag(AM, user)
			else
				user << "<span class='warning'>There is already a magazine loaded in \the [src]!</span>"
		else //Not a magazine-loaded weapon, what are you even doing ?
			user << "<span class='warning'>You can't load \the [src] with a magazine!</span>"
	if(istype(A, /obj/item/ammo_storage) && load_method != MAGAZINE) //Loading with an ammo storage
		var/obj/item/ammo_storage/AS = A
		AS.load_from(AS, src, user) //Use method in ammunition.dm
	if(istype(A, /obj/item/ammo_casing)) //Loading one ammo casing
		var/obj/item/ammo_casing/AC = A
		//message_admins("Loading the [src], with [AC], [AC.caliber] and [caliber.len]") //Enable this for testing
		if(AC.BB && caliber[AC.caliber]) //A used bullet can't be fired twice
			if(load_method == MAGAZINE && !chambered) //We can only load the casing if a casing isn't chambered
				user.drop_item(AC, src)
				chambered = AC
				user.visible_message("<span class='notice'>[user] loads one [AC.name] round into \his [src.name]'s chamber!</span>", \
				"<span class='notice'>You load one [AC.name] round into your [src.name]'s chamber!</span>")
				playsound(get_turf(src), AC.casing_insert_sound, 100, 1)
			else if(getAmmo() < max_shells) //We can load if there's place
				user.drop_item(AC, src)
				loaded += AC
				user.visible_message("<span class='notice'>[user] loads one [AC.name] round into \his [src.name]!</span>", \
				"<span class='notice'>You load one [AC.name] round into your [src.name]!</span>")
				playsound(get_turf(src), AC.casing_insert_sound, 100, 1)

	A.update_icon()
	update_icon()
	return

/obj/item/weapon/gun/projectile/attack_self(mob/user as mob)
	if(target)
		return ..()
	if(loaded.len || stored_magazine) //A magazine or rounds in general are loaded
		if(load_method == SPEEDLOADER) //Speedloader, empty it on the ground
			for(var/obj/item/ammo_casing/AC in loaded)
				loaded -= AC
				AC.forceMove(get_turf(src)) //Eject casing onto ground.

			user.visible_message("<span class='notice'>[user] unloads \the [src]'s speedloader on the ground!</span>", \
			"<span class='notice'>You unload \the [src]'s speedloader on the ground!</span>")
			update_icon()
			return
		if(load_method == MAGAZINE && stored_magazine) //Magazine, take it out. Simple as that
			remove_mag(user)
	else //No magazine or loaded rounds
		if(chambered) //Empty the chamber. Gun safety 101
			var/obj/item/ammo_casing/AC = chambered
			AC.loc = get_turf(src) //Eject casing onto ground.
			chambered = null
			user.visible_message("<span class='notice'>[user] unloads \the [AC] from \the [src]'s chamber!</span>", \
			"<span class='notice'>You unload \the [AC] from \the [src]'s chamber!</span>")
			update_icon()
			return
		if(silenced) //The gun has a silencer
			if(user.l_hand != src && user.r_hand != src)
				..()
				return
			user.visible_message("<span class='notice'>[user] unscrews \the [silenced] from \the [src].</span>", \
			"<span class='notice'>You unscrew \the [silenced] from \the [src].</span>")
			user.put_in_hands(silenced)
			silenced = 0
			update_icon()
			return
		else
			user.visible_message("<span class='notice'>[user] checks \the [src]</span>", \
			"<span class='notice'>You check \the [src] and confirm it's fully unloaded.</span>")

/obj/item/weapon/gun/projectile/afterattack(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, flag, struggle = 0)
	..()
	if(!chambered && stored_magazine && !stored_magazine.ammo_count() && gun_flags & AUTOMAGDROP) //AUTOMAGDROP decides whether or not the mag is dropped automatically when empty
		remove_mag()
		playsound(user, 'sound/weapons/smg_empty_alarm.ogg', 40, 1) //Beep beep beep
	return

/obj/item/weapon/gun/projectile/examine(mob/user)
	..()
	if(load_method == MAGAZINE)
		user << "<span class='info'>This weapon is magazine-loaded. It [stored_magazine ? "has":"doesn't have"] a magazine loaded.</span>"
	if(load_method == SPEEDLOADER)
		user << "<span class='info'>This weapon has a speedloader. Inside the speedloader, there are [getAmmo()] round\s out of [max_shells] remaining.</span>"
	if(load_method == MANUAL)
		user << "<span class='info'>This weapon is loaded manually.</span>"
	if(istype(silenced, /obj/item/gun_part/silencer))
		user << "<span class='info'>This weapon has a supressor.</span>"

/obj/item/weapon/gun/projectile/proc/getAmmo()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/obj/item/weapon/gun/projectile/proc/getAmmo() called tick#: [world.time]")
	var/bullets = 0
	if(mag_type && load_method == MAGAZINE)
		if(stored_magazine)
			bullets += stored_magazine.ammo_count()
		if(chambered)
			bullets++
	else
		for(var/obj/item/ammo_casing/AC in loaded)
			if(istype(AC))
				bullets += 1
	return bullets
