/obj/item/key
	name = "key"
	desc = "A simple key."
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "keys"
	w_class = W_CLASS_TINY
	var/obj/structure/bed/chair/vehicle/paired_to = null
	var/vin = null

/obj/item/key/New()
	if(vin)
		for(var/obj/structure/bed/chair/vehicle/V in world)
			if(V.vin == vin)
				paired_to = V
				V.mykey = src


/obj/structure/bed/chair/vehicle
	name = "vehicle"
	var/nick = null
	icon = 'icons/obj/vehicles.dmi'
	anchored = 1
	density = 1
	noghostspin = 1 //You guys are no fun
	var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread

	var/empstun = 0
	var/health = 100
	var/max_health = 100

	plane = ABOVE_HUMAN_PLANE
	layer = VEHICLE_LAYER

	var/can_spacemove = 0
	var/ethereal = 0

	var/keytype = null
	var/obj/item/key/mykey

	var/vin=null
	var/datum/delay_controller/move_delayer = new(1, ARBITRARILY_LARGE_NUMBER) //See setup.dm, 12
	var/movement_delay = 0 //Speed of the vehicle decreases as this value increases. Anything above 6 is slow, 1 is fast and 0 is very fast

	var/obj/machinery/cart/next_cart = null
	var/can_have_carts = TRUE

	var/mob/occupant
	lock_type = /datum/locking_category/buckle/chair/vehicle
	var/wreckage_type = /obj/effect/decal/mecha_wreckage/vehicle

/obj/structure/bed/chair/vehicle/proc/getMovementDelay()
	return movement_delay

/obj/structure/bed/chair/vehicle/proc/delayNextMove(var/delay, var/additive=0)
	move_delayer.delayNext(delay,additive)

/obj/structure/bed/chair/vehicle/can_apply_inertia()
	return 1 //No anchored check - so that vehicles can fly off into space

/obj/structure/bed/chair/vehicle/New()
	..()
	processing_objects |= src

	if(!nick)
		nick=name
	set_keys()

/obj/structure/bed/chair/vehicle/proc/set_keys()
	if(keytype && !vin)
		mykey = new keytype(src.loc)
		mykey.paired_to=src

/obj/structure/bed/chair/vehicle/process()
	if(empstun > 0)
		empstun--
	if(empstun < 0)
		empstun = 0

/obj/structure/bed/chair/vehicle/attackby(obj/item/W, mob/user)
	if (istype(W, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = W
		if (WT.remove_fuel(0))
			add_fingerprint(user)
			user.visible_message("<span class='notice'>[user] has fixed some of the dents on \the [src].</span>", "<span class='notice'>You fix some of the dents on \the [src]</span>")
			health += 20
			HealthCheck()
		else
			to_chat(user, "Need more welding fuel!")
			return
	else if(istype(W, /obj/item/key))
		if(keytype)
			to_chat(user, "Hold \the [W] in one of your hands while you drive \the [src].")
		else
			to_chat(user, "You don't need a key.")

/obj/structure/bed/chair/vehicle/proc/check_key(var/mob/user)
	if(!keytype)
		return 1
	if(mykey)
		return user.is_holding_item(mykey)

/obj/structure/bed/chair/vehicle/relaymove(var/mob/living/user, direction)
	if(user.incapacitated())
		unlock_atom(user)
		return
	if(!check_key(user))
		to_chat(user, "<span class='notice'>You'll need the keys in one of your hands to drive \the [src].</span>")
		return 0
	if(empstun > 0)
		if(user)
			to_chat(user, "<span class='warning'>\The [src] is unresponsive.</span>")
		return 0
	if(move_delayer.blocked())
		return 0

	//If we're in space or our area has no gravity...
	var/turf/T = get_turf(loc)
	if(!T)
		return 0
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

	step(src, direction)
	delayNextMove(getMovementDelay())

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

/obj/structure/bed/chair/vehicle/proc/can_buckle(mob/M, mob/user)
	if(M != user || !ishuman(user) || !Adjacent(user) || user.restrained() || user.lying || user.stat || user.locked_to || occupant)
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

	lock_atom(M, /datum/locking_category/buckle/chair/vehicle)

	add_fingerprint(user)

/obj/structure/bed/chair/vehicle/handle_layer()
	if(dir == SOUTH)
		plane = ABOVE_HUMAN_PLANE
		layer = VEHICLE_LAYER
	else
		plane = OBJ_PLANE
		layer = ABOVE_OBJ_LAYER

/obj/structure/bed/chair/vehicle/MouseDrop_T(var/atom/movable/C, mob/user)
	..()

	if (user.incapacitated() || !in_range(user, src) || !can_have_carts)
		return

	if (istype(C, /obj/machinery/cart))

		if (!next_cart)
			next_cart = C
			next_cart.previous_cart = src
			user.visible_message("[user] connects [C] to [src].", "You connect [C] to [src]")
			playsound(get_turf(src), 'sound/misc/buckle_click.ogg', 50, 1)
			return

		else if (next_cart == C)
			next_cart.previous_cart = null
			next_cart = null
			user.visible_message("[user] disconnects [C] to [src].", "You disconnect [C] to [src]")
			playsound(get_turf(src), 'sound/misc/buckle_unclick.ogg', 50, 1)
			return

/obj/structure/bed/chair/vehicle/update_dir()
	. = ..()

	update_mob()

/obj/structure/bed/chair/vehicle/proc/update_mob()
	if(!occupant)
		return

	switch(dir)
		if(SOUTH)
			occupant.pixel_x = 0
			occupant.pixel_y = 7 * PIXEL_MULTIPLIER
		if(WEST)
			occupant.pixel_x = 13 * PIXEL_MULTIPLIER
			occupant.pixel_y = 7 * PIXEL_MULTIPLIER
		if(NORTH)
			occupant.pixel_x = 0
			occupant.pixel_y = 4 * PIXEL_MULTIPLIER
		if(EAST)
			occupant.pixel_x = -13 * PIXEL_MULTIPLIER
			occupant.pixel_y = 7 * PIXEL_MULTIPLIER

/obj/structure/bed/chair/vehicle/emp_act(severity)
	switch(severity)
		if(1)
			src.empstun = (rand(5,10))
		if(2)
			src.empstun = (rand(1,5))
	src.visible_message("<span class='danger'>The [src.name]'s motor short circuits!</span>")
	spark_system.attach(src)
	spark_system.set_up(5, 0, src)
	spark_system.start()

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

/obj/structure/bed/chair/vehicle/Bump(var/atom/movable/obstacle)
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

	AM.pixel_x = 0
	AM.pixel_y = 0

	if(occupant == AM)
		occupant = null

/obj/structure/bed/chair/vehicle/lock_atom(var/atom/movable/AM)
	. = ..()
	if(!.)
		return

	occupant = AM

	update_mob()

/obj/structure/bed/chair/vehicle/Move()
	var/oldloc = loc
	..()
	if (loc == oldloc)
		return
	if(next_cart)
		next_cart.Move(oldloc)

/datum/locking_category/buckle/chair/vehicle
