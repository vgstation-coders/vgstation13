/obj/item/key/lightcycle
	name = "light rod"
	desc = "A strange-looking glowing rod."
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "lightcycle_keys_inactive"
	w_class = W_CLASS_TINY
	var/cycle_active = FALSE
	var/obj/structure/bed/chair/vehicle/lightcycle/summoned_cycle = null
	var/l_color = "#FFFFFF"

/obj/item/key/lightcycle/New(atom/A, var/col)
	..(A)
	var/hue = rand(0,360)
	if(col)
		var/red = GetRedPart(col)
		var/green = GetGreenPart(col)
		var/blue = GetBluePart(col)
		var/list/hsl = rgb2hsl(red,green,blue)
		hue = hsl[1]
	var/list/rgb_list = hsl2rgb(hue, 100, 50)		//only neon colors
	l_color = rgb(rgb_list[1],rgb_list[2],rgb_list[3])
	icon += l_color
	update_icon()

/obj/item/key/lightcycle/update_icon()
	if(cycle_active)
		icon_state = "lightcycle_keys_active"
		cant_drop = 1
	else
		icon_state = "lightcycle_keys_inactive"
		cant_drop = 0

/obj/item/key/lightcycle/attack_self(mob/user)
	..()
	if(!ishuman(user))
		to_chat(user, "\The [src] refuses to break. You don't think you could fit on a light cycle anyway.")
		return
	if(cycle_active)
		summoned_cycle.unlock_atom(user)
	else
		summon_cycle(user)

/obj/item/key/lightcycle/proc/summon_cycle(mob/user)
	cycle_active = TRUE
	update_icon()
	summoned_cycle = new(get_turf(src))
	paired_to = summoned_cycle
	summoned_cycle.mykey = src
	summoned_cycle.summoning_rod = src
	summoned_cycle.l_color = l_color
	to_chat(user, "<span class='notice'>As you break the rod in half, \a [summoned_cycle] materializes around you!</span>")
	summoned_cycle.dir = user.dir
	summoned_cycle.buckle_mob(user,user)

/obj/item/key/lightcycle/dropped(user)
	..()
	if(cycle_active)
		summoned_cycle.unlock_atom(user)

/obj/structure/bed/chair/vehicle/lightcycle
	name = "light cycle"
	desc = "Some sort of motorcycle decked out in neon lights."
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "lightcycle"
	can_spacemove = 1
	keytype = /obj/item/key/lightcycle
	layer = FLY_LAYER
	pass_flags = PASSMOB|PASSDOOR
	wreckage_type = /obj/effect/decal/mecha_wreckage/vehicle/lightcycle
	var/obj/item/key/lightcycle/summoning_rod = null
	var/delay_ribbon = 0
	var/l_color = "#FFFFFF"
	var/lastdir = null
	var/lastLASTdir = null

/obj/structure/bed/chair/vehicle/lightcycle/Destroy()
	if(summoning_rod)
		summoning_rod.icon_state = initial(summoning_rod.icon_state)
		summoning_rod.summoned_cycle = null
		summoning_rod.cycle_active = FALSE
		summoning_rod.update_icon()
		summoning_rod.paired_to = null
		summoning_rod = null
	..()

/obj/structure/bed/chair/vehicle/lightcycle/update_icon()
	overlays.len = 0
	if(occupant)
		icon_state = "lightcycle"
	else
		icon_state = "lightcycle_norider"
	var/image/light_overlay = image('icons/obj/vehicles.dmi', src, "[icon_state]_overlay")
	light_overlay.icon += l_color
	overlays += light_overlay

/obj/structure/bed/chair/vehicle/lightcycle/can_apply_inertia()
	return FALSE

/obj/structure/bed/chair/vehicle/lightcycle/Process_Spacemove(var/check_drift = 0)
	return TRUE

/obj/structure/bed/chair/vehicle/lightcycle/set_keys()
	return

/obj/structure/bed/chair/vehicle/lightcycle/lock_atom(var/atom/movable/AM)
	..()
	update_icon()
	trigger_movement()

/obj/structure/bed/chair/vehicle/lightcycle/unlock_atom(var/atom/movable/AM)
	to_chat(occupant, "<span class='notice'>You begin dismounting \the [src]...")
	spawn(5)	//to prevent riders from just getting off the cycle to avoid hitting obstacles
		if(!gcDestroyed)
			..()
			update_icon()
			dismount(AM)

/obj/structure/bed/chair/vehicle/lightcycle/proc/dismount(mob/user)
	to_chat(user, "<span class='notice'>As you dismount \the [src], it dissolves into nothing.</span>")
	qdel(src)

/obj/structure/bed/chair/vehicle/lightcycle/proc/trigger_movement()
	while(occupant)
		movement_process()
		sleep(1)

/obj/structure/bed/chair/vehicle/lightcycle/proc/movement_process()
	if(!occupant)
		return
	if(occupant.incapacitated())
		unlock_atom(occupant)
		return
	if(!check_key(occupant))
		unlock_atom(occupant)
		return
	var/turf/T = get_turf(src)
	if(!T.has_gravity())
		if(!Process_Spacemove(0))
			return

	var/can_pull_tether = 0
	if(occupant.tether)
		if(occupant.tether.attempt_to_follow(occupant,get_step(src,dir)))
			can_pull_tether = 1
		else
			var/datum/chain/tether_datum = occupant.tether.chain_datum
			tether_datum.snap = 1
			tether_datum.Delete_Chain()

	step(src, dir)

	if(occupant)
		if(T != loc)
			var/mob/living/L = occupant
			if(istype(L))
				L.handle_hookchain(dir)

		if(occupant.tether && can_pull_tether)
			occupant.tether.follow(occupant,T)
			var/datum/chain/tether_datum = occupant.tether.chain_datum
			if(!tether_datum.Check_Integrity())
				tether_datum.snap = 1
				tether_datum.Delete_Chain()

	spawn(1)
		if(delay_ribbon)
			delay_ribbon--
		else
			new /obj/lightribbon(T,l_color,lastdir,lastLASTdir)
			lastLASTdir = lastdir
			lastdir = dir

	update_mob()

/obj/structure/bed/chair/vehicle/lightcycle/relaymove(var/mob/living/user, direction)
	if(!check_key(user))
		to_chat(user, "<span class='notice'>You'll need the keys in one of your hands to drive \the [src].</span>")

	if(direction != turn(dir, 180))
		dir = direction
		user.dir = direction

	update_mob()

/obj/structure/bed/chair/vehicle/lightcycle/Bump(atom/A)
	if(occupant)
		occupant.visible_message("<span class=\"warning\">\The [src] crashes into \the [A] and dissolves into nothing as its rider is blown apart!</span>",\
		"<span class=\"warning\">As you collide with \the [A], you are blown to pieces.</span>")
	else
		visible_message("<span class=\"warning\">\The [src] smacks into \the [A] and dissolves into nothing.</span>",\
		"<span class=\"warning\">You hear a loud crack as you dissolve into nothing.</span>")

	playsound(src, 'sound/effects/supermatter.ogg', 50, 1)

	if(occupant)
		occupant.gib()
	qdel(src)

/obj/structure/bed/chair/vehicle/lightcycle/handle_layer()
	return

/obj/structure/bed/chair/vehicle/lightcycle/update_mob()
	if(!occupant)
		return

	occupant.pixel_y = 2 * PIXEL_MULTIPLIER

/obj/lightribbon
	name = "light ribbon"
	desc = "A wall of light ejected from the back of a light cycle."
	anchored = 1
	density = 1
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "lightcycle_ribbon"
	var/l_color = "#FFFFFF"
	var/erasing = FALSE

/obj/lightribbon/New(atom/A, var/col, var/currdir, var/lastdir)
	..(A)
	if(currdir)
		if(!lastdir)
			dir = currdir
		else if(((currdir == NORTH || currdir == SOUTH) && (lastdir == NORTH || lastdir == SOUTH)) || ((currdir == EAST || currdir == WEST) && (lastdir == EAST || lastdir == WEST)))
			dir = currdir
		else if((lastdir == WEST && currdir == SOUTH) || (lastdir == NORTH && currdir == EAST))
			dir = SOUTHEAST
		else if((lastdir == EAST && currdir == SOUTH) || (lastdir == NORTH && currdir == WEST))
			dir = SOUTHWEST
		else if((lastdir == WEST && currdir == NORTH) || (lastdir == SOUTH && currdir == EAST))
			dir = NORTHEAST
		else if((lastdir == EAST && currdir == NORTH) || (lastdir == SOUTH && currdir == WEST))
			dir = NORTHWEST
	else
		qdel(src)
		return
	if(col)
		l_color = col
		icon += l_color
	set_light(1,5,l_color)

/obj/lightribbon/attackby(obj/item/weapon/W, mob/user)
	if(!(user.locked_to && istype(user.locked_to, /obj/structure/bed/chair/vehicle/lightcycle)))
		to_chat(user, "\The [src] dissipates as you hit it with \the [W].")
		qdel(src)

/obj/lightribbon/proc/erase()	//can be called by admins to erase the whole line of ribbon
	erasing = TRUE
	for(var/obj/lightribbon/L in orange(1,src))
		if(L.l_color == l_color)
			if(!L.erasing)
				spawn(1)
					L.erase()
	qdel(src)

/obj/effect/decal/mecha_wreckage/vehicle/lightcycle
	// TODO: SPRITE PLS
	//icon = 'icons/obj/vehicles.dmi'
	//icon_state = "lightcycle_wreck"
	name = "light cycle wreckage"
	desc = "Awaiting garbage collection."
