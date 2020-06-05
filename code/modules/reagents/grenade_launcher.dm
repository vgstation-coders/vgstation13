/obj/item/weapon/gun/grenadelauncher
	name = "grenade launcher"
	icon = 'icons/obj/gun.dmi'
	icon_state = "riotgun"
	item_state = "riotgun"
	w_class = W_CLASS_LARGE
	throw_speed = 2
	throw_range = 10
	force = 5.0
	var/list/grenades = new/list()
	var/max_grenades = 3
	var/timer_override = FALSE
	var/timer_override_value = 5 SECONDS
	starting_materials = list(MAT_IRON = 2000)
	w_type = RECYK_METAL

/obj/item/weapon/gun/grenadelauncher/examine(mob/user)
	..()
	if(timer_override)
		to_chat(user, "<span class='info'>Timer override is active. Fired grenades will detonate after [timer_override_value/10] seconds.</span>")
	if(!(grenades.len))
		to_chat(user, "<span class='info'>It is empty.</span>")
	else
		to_chat(user, "<span class='info'>It has [grenades.len] / [max_grenades] grenades loaded.</span>")
		for(var/obj/item/weapon/grenade/G in grenades)
			to_chat(user, "[bicon(G)] [G.name]")


/obj/item/weapon/gun/grenadelauncher/attackby(obj/item/I as obj, mob/user as mob)

	if((istype(I, /obj/item/weapon/grenade)))
		if(grenades.len < max_grenades)
			if(user.drop_item(I, src))
				grenades += I
				to_chat(user, "<span class='notice'>You load the [I.name] into the [src.name].</span>")
				to_chat(user, "<span class='notice'>[grenades.len] / [max_grenades] grenades loaded.</span>")
		else
			to_chat(user, "<span class='warning'>The [src.name] cannot hold more grenades.</span>")

/obj/item/weapon/gun/grenadelauncher/afterattack(atom/target, mob/living/user, flag, params, struggle = 0)
	if(flag)
		return //we're placing gun on a table or in backpack

	if (istype(target, /obj/item/weapon/storage/backpack ))
		return

	else if (locate (/obj/structure/table, src.loc))
		return

	else if(target == user)
		return

	if(grenades.len)
		spawn(0) fire_grenade(target,user)
	else
		to_chat(usr, "<span class='warning'>The [src.name] is empty.</span>")

/obj/item/weapon/gun/grenadelauncher/proc/fire_grenade(atom/target, mob/user)
	user.visible_message("<span class='warning'>[user] fired a grenade!</span>")
	to_chat(user, "<span class='danger'>You fire the grenade launcher!</span>")
	var/obj/item/weapon/grenade/F = grenades[1] //Now with less copypasta!
	grenades -= F
	F.forceMove(user.loc)
	F.throw_at(target, 30, 2)
	message_admins("[key_name_admin(user)] fired [F.name] from [src.name].")
	log_game("[key_name_admin(user)] launched [F.name] from [src.name].")
	playsound(user.loc, 'sound/weapons/grenadelauncher.ogg', 50, 1, -3)
	if(timer_override)
		F.det_time = timer_override_value
	F.activate()

/obj/item/weapon/gun/grenadelauncher/verb/TimerOverrideMode()
	set name = "Toggle Timer Override Mode"
	set category = "Object"
	set src in usr

	if(timer_override)
		to_chat(usr, "You deactivate the timing override on \the [src]. Fired grenades will now use their individual timers")
		timer_override = FALSE
	else
		var/new_time = input(usr, "Fired grenades will now be prime using \the [src]'s timer rather than their own. What would you like the timer to be set to, in seconds?","Time",timer_override_value/10) as num
		if(new_time < 3)
			to_chat(usr, "<span class = 'warning'>\The [src] beeps. The given time cannot be below 3 second.</span>")
			return
		if(!Adjacent(usr, MAX_ITEM_DEPTH))
			to_chat(usr, "<span class = 'warning'>You fumble while trying to modify \the [src]. It is best to keep the [src] in proximity when modifying it..</span>")
			return
		timer_override_value = new_time SECONDS
		to_chat(usr, "<span class = 'notice'>The detonation time on your shots is now [timer_override_value/10] seconds.</span>")
		timer_override = TRUE
	return

/obj/item/weapon/gun/grenadelauncher/verb/Unload()
	set name = "Unload Grenades"
	set category = "Object"
	set src in usr
	if(!isturf(usr.loc))
		to_chat(usr, "<span class = 'notice'>You cannot unload \the [src] in here.</span>")
		return
	for(var/obj/item/weapon/grenade/G in grenades)
		grenades -= G
		G.forceMove(get_turf(src))

/obj/item/weapon/gun/grenadelauncher/syndicate
	name = "C32R multiple grenade launcher"
	desc = "A six-shot revolver-type grenade launcher. Not exactly the biggest revolution in terms of tech, but it can fire grenades just fine. Or at least Syndicate Command said so. Try to aim far away from face."
	icon_state = "syndie_mgl"
	item_state = "riotgun"
	max_grenades = 6
