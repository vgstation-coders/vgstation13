/obj/item/key
	name = "key"
	desc = "A simple key."
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "keys"
	w_class = W_CLASS_TINY
	var/obj/structure/bed/chair/vehicle/paired_to = null
	var/vin = null

/obj/item/key/initialize()
	if(vin)
		for(var/obj/structure/bed/chair/vehicle/V in vehicle_list)
			if(V.vin == vin)
				paired_to = V
				V.mykey = src

/obj/item/key/dropped(mob/user)
	..()
	if(locate(/obj/structure/table) in loc.contents)
		desc = "Why did they get left upon the table? [user] wanted to."

/obj/item/key/pickup(mob/user)
	desc = initial(desc)

/obj/item/key/Destroy()
	if(paired_to)
		paired_to.mykey = null
		paired_to = null
	..()

/obj/structure/bed/chair/vehicle
	name = "vehicle"
	var/nick = null
	icon = 'icons/obj/vehicles.dmi'
	anchored = 1
	density = 1
	buckle_range = 1
	var/empstun = 0
	var/health = 100
	var/max_health = 100

	plane = ABOVE_HUMAN_PLANE
	layer = VEHICLE_LAYER

	var/can_spacemove = 0
	var/ethereal = 0

	var/keytype = null
	var/obj/item/key/heldkey
	var/obj/item/key/mykey

	var/vin=null
	var/datum/delay_controller/move_delayer = new(1, ARBITRARILY_LARGE_NUMBER) //See setup.dm, 12
	var/movement_delay = 1 //Speed of the vehicle decreases as this value increases. Do NOT set to 0 holy shit.

	var/obj/machinery/cart/next_cart = null
	var/can_have_carts = TRUE

	var/mob/occupant
	mob_lock_type = /datum/locking_category/buckle/chair/vehicle
	var/wreckage_type = /obj/effect/decal/mecha_wreckage/vehicle
	var/last_warn

	var/list/offsets = list()
	var/last_dir

	var/list/datum/action/vehicle_actions = list()

	var/headlights = FALSE
	var/explodes_fueltanks = FALSE

/obj/structure/bed/chair/vehicle/proc/getMovementDelay()
	return movement_delay

/obj/structure/bed/chair/AltClick(mob/user as mob)
	buckle_chair(user,user, 1) // Can drag self to it.

/obj/structure/bed/chair/vehicle/proc/delayNextMove(var/delay, var/additive=0)
	move_delayer.delayNext(delay,additive)

//Just a copypaste of atom/movable/Cross(). Vehicles are children of beds for some fucking reason and none of the current movement code has any inheritance, so whatever.
/obj/structure/bed/chair/vehicle/Cross(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	return (!density || !height || air_group)

/obj/structure/bed/chair/vehicle/proc/is_too_heavy(var/turf/simulated/floor/glass/glassfloor)
	return !istype(glassfloor, /turf/simulated/floor/glass/plasma)

/obj/structure/bed/chair/vehicle/can_apply_inertia()
	return 1 //No anchored check - so that vehicles can fly off into space

/obj/structure/bed/chair/vehicle/New()
	..()
	processing_objects |= src
	vehicle_list.Add(src)
	if(!nick)
		nick=name
	set_keys()
	make_offsets()
	if(headlights)
		new /datum/action/vehicle/toggle_headlights(src)

/obj/structure/bed/chair/vehicle/Destroy()
	vehicle_list.Remove(src)
	if(mykey)
		mykey.paired_to = null
		mykey = null
	if(heldkey)
		qdel(heldkey)
		heldkey = null
	..()

/obj/structure/bed/chair/vehicle/proc/set_keys()
	if(keytype && !vin)
		mykey = new keytype(src.loc)
		mykey.paired_to=src

/obj/structure/bed/chair/vehicle/process()
	if(empstun > 0)
		empstun--
	if(empstun < 0)
		empstun = 0

/obj/structure/bed/chair/vehicle/attackby(obj/item/W, mob/living/user)
	if(iswelder(W) && health < max_health)
		var/obj/item/tool/weldingtool/WT = W
		if (WT.remove_fuel(0))
			add_fingerprint(user)
			user.visible_message("<span class='notice'>[user] has fixed some of the dents on \the [src].</span>", "<span class='notice'>You fix some of the dents on \the [src]</span>")
			health += 20
			HealthCheck()
		else
			to_chat(user, "Need more welding fuel!")
			return
	else if(istype(W, /obj/item/key))
		if(!heldkey)
			if(keytype)
				if(!istype(W, keytype))
					to_chat(user, "<span class='warning'>\The [W] doesn't fit into \the [src]'s ignition.</span>")
					return
				if(mykey && mykey != W)
					to_chat(user, "<span class='warning'>\The [src] is paired to a different key.</span>")
					return
				if(((M_CLUMSY in user.mutations) || user.getBrainLoss() >= 60) && prob(50))
					to_chat(user, "<span class='warning'>You try to insert \the [W] to \the [src]'s ignition but you miss the slot!</span>")
					return
				if(user.drop_item(W, src))
					to_chat(user, "<span class='notice'>You insert \the [W] into \the [src]'s ignition and turn it.</span>")
					user.visible_message("<span class='notice'>\The [src]'s engine roars to life!</span>")
					src.heldkey = W
					return
				else //In case the key is unable to leave the user's hand. IE glue.
					to_chat(user, "<span class='notice'>You fail to put \the [W] into \the [src]'s ignition and turn it.</span>")
			else
				to_chat(user, "<span class='notice'>You don't need a key.</span>")
		else
			to_chat(user, "<span class='notice'>\The [src] already has \the [heldkey] in it.</span>")
	else if(W.is_screwdriver(user) && !heldkey)
		var/mob/living/carbon/human/H = user
		to_chat(user, "<span class='warning'>You jam \the [W] into \the [src]'s ignition and feel like a genius as you try turning it!</span>")
		playsound(src, "sound/items/screwdriver.ogg", 10, 1)
		H.adjustBrainLoss(10)
	else if(W.is_wrench(user))
		return
	else
		return ..()

/obj/structure/bed/chair/vehicle/attack_hand(mob/user)
	if(occupant && occupant == user)
		return ..()
	if(heldkey && !user.incapacitated() && Adjacent(user) && user.dexterity_check())
		to_chat(user, "<span class='notice'>You remove \the [heldkey] from \the [src]'s ignition.</span>")
		user.visible_message("<span class='notice'>\The [src]'s engine shuts off.</span>")
		heldkey.forceMove(get_turf(user))
		user.put_in_hands(heldkey)
		heldkey = null
	else
		..()

/obj/structure/bed/chair/vehicle/proc/check_key(var/mob/user)
	if(!keytype)
		return 1
	if(mykey)
		return heldkey == mykey || user.is_holding_item(mykey)
	return istype(heldkey, keytype) || user.find_held_item_by_type(keytype)


/obj/structure/bed/chair/vehicle/relaymove(var/mob/living/user, direction)
	if(user.incapacitated())
		unlock_atom(user)
		return
	if(!check_key(user))
		if(can_warn())
			to_chat(user, "<span class='notice'>You'll need the key in one of your hands or inside the ignition slot to drive \the [src].</span>")
		return 0
	if(empstun > 0)
		if(user && can_warn(user))
			to_chat(user, "<span class='warning'>\The [src] is unresponsive.</span>")
		return 0
	if(move_delayer.blocked())
		return 0
	if (istype(locked_to, /obj/machinery/bot/mulebot))
		var/obj/machinery/bot/mulebot/M = locked_to
		M.unload(0)

	//If we're in space or our area has no gravity...
	var/turf/T = loc
	if(!istype(T))
		return 0 //location isn't a turf or doesn't exist
	if(!T.has_gravity())
		// Block relaymove() if needed.
		if(!Process_Spacemove(0))
			return 0

	var/can_pull_tether = 0
	if(user.tether)
		if(user.tether.attempt_to_follow(user,get_step(src,direction)))
			can_pull_tether = 1
		else
			var/datum/chain/tether_datum = user.tether.chain_datum
			tether_datum.snap = 1
			tether_datum.Delete_Chain()

	var/movedelay = getMovementDelay()
	set_glide_size(DELAY2GLIDESIZE(movedelay))
	step(src, direction)
	delayNextMove(movedelay)

	if(T != loc)
		user.handle_hookchain(direction)

	if(user.tether && can_pull_tether)
		user.tether.follow(user,T)
		var/datum/chain/tether_datum = user.tether.chain_datum
		if(!tether_datum.Check_Integrity())
			tether_datum.snap = 1
			tether_datum.Delete_Chain()

	update_mob()
	/*
	if(istype(src.loc, /turf/space) && (!src.Process_Spacemove(0, user)))
		var/turf/space/S = src.loc
		S.Entered(src)*/

/obj/structure/bed/chair/vehicle/proc/can_warn() //Should be used for any instance of to_chat in relaymove
	if(world.time < last_warn + 1 SECONDS)
		return 0
	last_warn = world.time
	return 1

/obj/structure/bed/chair/vehicle/proc/can_buckle(mob/M, mob/user)
	if(M != user || !ishigherbeing(user) || user.restrained() || user.lying || user.stat || user.locked_to || occupant)
		return 0
	if(!Adjacent(user) && buckle_range <= 1)
		return 0
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.mind && H.mind.special_role == HIGHLANDER)
			if(user == M)
				to_chat(user, "<span class='warning'>A true highlander has no need for a mount!</span>")
			return 0
	return 1

/obj/structure/bed/chair/vehicle/buckle_mob(mob/M, mob/user)
	if(!can_buckle(M,user))
		return

	M.visible_message(\
		"<span class='notice'>[M] climbs onto \the [nick]!</span>",\
		"<span class='notice'>You climb onto \the [nick]!</span>")

	if(!Adjacent(M))
		playsound(src, 'sound/weapons/emitter2.ogg', 50, 1)

	lock_atom(M, /datum/locking_category/buckle/chair/vehicle)

	add_fingerprint(user)

	for (var/datum/action/action in vehicle_actions)
		if (action.owner && action.owner != user)
			action.Remove(action.owner)
		action.Grant(user)

/obj/structure/bed/chair/vehicle/manual_unbuckle(mob/user, var/resisting = FALSE)
	..()
	for (var/datum/action/action in vehicle_actions)
		action.Remove(user)

/obj/structure/bed/chair/vehicle/handle_layer()
	if(dir == SOUTH)
		plane = ABOVE_HUMAN_PLANE
		layer = VEHICLE_LAYER
	else
		plane = OBJ_PLANE
		layer = ABOVE_OBJ_LAYER

/obj/structure/bed/chair/vehicle/MouseDropTo(var/atom/movable/C, mob/user)
	..()

	if (user.incapacitated() || !in_range(user, src) || !in_range(src, C) || !can_have_carts)
		return

	if (istype(C, /obj/machinery/cart))

		if (!next_cart)
			var/obj/machinery/cart/connecting = C
			if(connecting.previous_cart)
				to_chat(user, "\The [connecting] already has a cart connected to it!", "red")
				return
			next_cart = C
			next_cart.previous_cart = src
			user.visible_message("[user] connects [C] to [src].", "You connect [C] to [src]")
			playsound(src, 'sound/misc/buckle_click.ogg', 50, 1)
			return

		else if (next_cart == C)
			next_cart.previous_cart = null
			next_cart = null
			user.visible_message("[user] disconnects [C] to [src].", "You disconnect [C] to [src]")
			playsound(src, 'sound/misc/buckle_unclick.ogg', 50, 1)
			return

/obj/structure/bed/chair/vehicle/update_dir()
	. = ..()

	update_mob()

/obj/structure/bed/chair/vehicle/proc/make_offsets()
	offsets = list(
		"[SOUTH]" = list("x" = 0, "y" = 7 * PIXEL_MULTIPLIER),
		"[WEST]" = list("x" = 13 * PIXEL_MULTIPLIER, "y" = 7 * PIXEL_MULTIPLIER),
		"[NORTH]" = list("x" = 0, "y" = 4 * PIXEL_MULTIPLIER),
		"[EAST]" = list("x" = -13 * PIXEL_MULTIPLIER, "y" = 7 * PIXEL_MULTIPLIER)
		)

/obj/structure/bed/chair/vehicle/proc/update_mob()
	if(!occupant)
		return
	if(!(dir in cardinal))
		return

	if(last_dir)
		occupant.pixel_x -= offsets["[last_dir]"]["x"]
		occupant.pixel_y -= offsets["[last_dir]"]["y"]

	occupant.pixel_x += offsets["[dir]"]["x"]
	occupant.pixel_y += offsets["[dir]"]["y"]

	last_dir = dir

/obj/structure/bed/chair/vehicle/emp_act(severity)
	switch(severity)
		if(1)
			src.empstun = (rand(5,10))
		if(2)
			src.empstun = (rand(1,5))
	src.visible_message("<span class='danger'>The [src.name]'s motor short circuits!</span>")
	spark(src, 5)

/obj/structure/bed/chair/vehicle/bullet_act(var/obj/item/projectile/Proj)
	var/hitrider = 0
	if(istype(Proj, /obj/item/projectile/ion))
		Proj.on_hit(src, 2)
		return

	if(occupant)
		if(prob(75))
			hitrider = 1
			var/act = occupant.bullet_act(Proj)
			if(act >= 0)
				visible_message("<span class='warning'>[occupant] is hit by \the [Proj]!")
				if(istype(Proj, /obj/item/projectile/energy))
					unlock_atom(occupant)
			return
		if(istype(Proj, /obj/item/projectile/energy/electrode))
			if(prob(25))
				visible_message("<span class='warning'>\The [src.name] absorbs \the [Proj]")
				if(!istype(occupant, /mob/living/carbon/human))
					occupant.bullet_act(Proj)
				else
					var/mob/living/carbon/human/H = occupant
					H.electrocute_act(0, src, 1, 0)
				unlock_atom(occupant)

	if(!hitrider)
		visible_message("<span class='warning'>[Proj] hits \the [nick]!</span>")
		if(!Proj.nodamage && Proj.damage_type == BRUTE || Proj.damage_type == BURN)
			health -= Proj.damage
		HealthCheck()

/obj/structure/bed/chair/vehicle/proc/HealthCheck()
	if(health > max_health)
		health = max_health
	if(health <= 0)
		die()

/obj/structure/bed/chair/vehicle/suicide_act(var/mob/living/user)
	if(occupant == user)
		to_chat(viewers(user), "<span class='danger'>[user] is licking the keyhole of the [src]! It looks like \he's trying to commit suicide.</span>")
		return(SUICIDE_ACT_FIRELOSS)
	to_chat(viewers(user), "<span class='danger'>[user] is placing \his mouth on the exhaust pipe of the [src]! It looks like \he's trying to commit suicide.</span>")
	return(SUICIDE_ACT_TOXLOSS|SUICIDE_ACT_OXYLOSS)

/obj/structure/bed/chair/vehicle/ex_act(severity)
	switch (severity)
		if(1.0)
			health -= 100
		if(2.0)
			health -= 75
		if(3.0)
			health -= 45
	HealthCheck()

/obj/structure/bed/chair/vehicle/proc/die() //called when health <= 0
	density = 0
	visible_message("<span class='warning'>\The [nick] explodes!</span>")
	explosion(src.loc,-1,0,2,7,10)
	//icon_state = "pussywagon_destroyed"
	unlock_atom(occupant)
	if(wreckage_type)
		var/obj/effect/decal/mecha_wreckage/wreck = new wreckage_type(src.loc)
		setup_wreckage(wreck)
	qdel(src)

/obj/structure/bed/chair/vehicle/proc/setup_wreckage(var/obj/effect/decal/mecha_wreckage/wreck)
	// Transfer salvagables here.
	return

/obj/structure/bed/chair/vehicle/to_bump(var/atom/movable/obstacle)
	if(obstacle == src || (is_locking(/datum/locking_category/buckle/chair/vehicle, subtypes=TRUE) && obstacle == get_locked(/datum/locking_category/buckle/chair/vehicle, subtypes=TRUE)[1]))
		return

	if(istype(obstacle, /obj/structure))// || istype(obstacle, /mob/living)
		if(!obstacle.anchored)
			obstacle.Move(get_step(obstacle,src.dir))
	..()

/obj/structure/bed/chair/vehicle/unlock_atom(var/atom/movable/AM)
	. = ..()
	if(!.)
		return

	AM.pixel_x -= offsets["[dir]"]["x"]
	AM.pixel_y -= offsets["[dir]"]["y"]

	last_dir = null

	if(occupant == AM)
		occupant = null

/obj/structure/bed/chair/vehicle/lock_atom(var/atom/movable/AM)
	. = ..()
	if(!.)
		return

	occupant = AM

	update_mob()

/obj/structure/bed/chair/vehicle/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0, glide_size_override = 0)
	var/oldloc = loc
	..()
	if (loc == oldloc)
		return
	if(next_cart)
		sleep(0)
		next_cart.Move(oldloc, glide_size_override = src.glide_size)

/obj/structure/bed/chair/vehicle/proc/disconnected() //proc that carts call, we have no use for it
	return

/datum/locking_category/buckle/chair/vehicle


/////////////////////////////////////
//           VEHICLE ACTIONS
////////////////////////////////////

/datum/action/vehicle/toggle_headlights
	name = "toggle headlights"
	desc = "Turn the headlights on or off."
	var/on = FALSE
	var/brightness = 6
	var/sounds = list('sound/items/flashlight_on.ogg','sound/items/flashlight_off.ogg')

/datum/action/vehicle/toggle_headlights/New(var/obj/structure/bed/chair/vehicle/Target)
	..()
	icon_icon = Target.icon
	button_icon_state = Target.icon_state
	Target.vehicle_actions += src

/datum/action/vehicle/toggle_headlights/Trigger()
	if(!..())
		return FALSE
	on = !on
	if(on)
		target.set_light(brightness)
		playsound(target, sounds[1], 50, 1)
	else
		target.kill_light()
		playsound(target, sounds[2], 50, 1)
	target.update_icon()

/datum/action/vehicle/toggle_headlights/siren
	name = "toggle siren"
	desc = "Turn the siren lights on or off."
	sounds = list('sound/voice/woopwoop.ogg','sound/items/flashlight_off.ogg')
