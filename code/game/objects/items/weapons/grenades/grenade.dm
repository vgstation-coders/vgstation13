/obj/item/weapon/grenade
	name = "grenade"
	desc = "A hand held grenade, with an adjustable timer."
	w_class = W_CLASS_SMALL
	icon = 'icons/obj/grenade.dmi'
	icon_state = "grenade"
	item_state = "flashbang"
	throw_speed = 4
	throw_range = 20
	flags = FPRINT
	siemens_coefficient = 1
	slot_flags = SLOT_BELT
	var/active = 0
	var/det_time = 5 SECONDS
	mech_flags = MECH_SCAN_ILLEGAL

/obj/item/weapon/grenade/proc/clown_check(var/mob/living/user)
	if(clumsy_check(user) && prob(50))
		to_chat(user, "<span class='warning'>Huh? How does this thing work?</span>")

		activate(user)
		add_fingerprint(user)
		spawn(5)
			prime(user)
		return 0
	return 1


/*/obj/item/weapon/grenade/afterattack(atom/target as mob|obj|turf|area, mob/user as mob)
	if (istype(target, /obj/item/weapon/storage))
		return ..() // Trying to put it in a full container
	if (istype(target, /obj/item/weapon/gun/grenadelauncher))
		return ..()
	if((user.get_active_hand() == src) && (!active) && (clown_check(user)) && target.loc != src.loc)
		to_chat(user, "<span class='warning'>You prime the [name]! [det_time/10] seconds!</span>")
		active = 1
		icon_state = initial(icon_state) + "_active"
		playsound(loc, 'sound/weapons/armbomb.ogg', 75, 1, -3)
		spawn(det_time)
			prime()
			return
		user.dir = get_dir(user, target)
		user.drop_item(null, )
		var/t = (isturf(target) ? target : target.loc)
		walk_towards(src, t, 3)
	return*/


/obj/item/weapon/grenade/examine(mob/user)
	..()
	if(det_time > 1)
		to_chat(user, "<span class='info'>The timer is set to [det_time/10] seconds.</span>")
		return
	to_chat(user, "<span class='warning'>\The [src] is set for instant detonation.</span>")


/obj/item/weapon/grenade/attack_self(mob/user as mob)
	if(!active)
		if(clown_check(user))
			to_chat(user, "<span class='attack'>You prime \the [name]! [det_time/10] seconds!</span>")

			activate(user)
			add_fingerprint(user)
			if(iscarbon(user))
				var/mob/living/carbon/C = user
				C.throw_mode_on()
	return


/obj/item/weapon/grenade/proc/activate(mob/user as mob)
	if(active)
		return

	if(user)
		log_attack("<font color='red'>[user.name] ([user.ckey]) primed \a [src]</font>")
		log_admin("ATTACK: [user] ([user.ckey]) primed \a [src]")
		message_admins("ATTACK: [user] ([user.ckey]) primed \a [src]")

	icon_state = initial(icon_state) + "_active"
	active = 1
	playsound(loc, 'sound/weapons/armbomb.ogg', 75, 1, -3)

	spawn(det_time)
		if(gcDestroyed)
			return
		prime(user)


/obj/item/weapon/grenade/proc/prime()
//	playsound(loc, 'sound/items/Welder2.ogg', 25, 1)
	var/turf/T = get_turf(src)
	if(T)
		T.hotspot_expose(700,125,surfaces=istype(loc,/turf))

/obj/item/weapon/grenade/proc/update_mob()
	if(ismob(loc))
		var/mob/M = loc
		M.drop_from_inventory(src)


/obj/item/weapon/grenade/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(W.is_screwdriver(user))
		if(active)
			to_chat(user, "<span class = 'warning'>It's already primed!</span>")
			return
		var/new_time = input(user, "What would you like the timer to be set to, in seconds?","Time",det_time/10) as num
		if(new_time < 3)
			to_chat(user, "<span class = 'warning'>\The [src] beeps. The given time was too low.</span>")
			return
		if(!Adjacent(user, MAX_ITEM_DEPTH))
			to_chat(user, "<span class = 'warning'>You fumble while trying to modify \the [src]. It is best to keep the grenade in proximity when modifying it..</span>")
			return
		det_time = new_time SECONDS
		to_chat(user, "<span class = 'notice'>The detonation time is now [det_time/10] seconds.</span>")
		add_fingerprint(user)
	..()
	return

/obj/item/weapon/grenade/attack_hand()
	walk(src, null, null)
	..()
	return

/obj/item/weapon/grenade/attack_paw(mob/user as mob)
	return attack_hand(user)
