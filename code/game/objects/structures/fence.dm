//Chain link fences
//Can be cut with wirecutters up to 3 times, cutting takes 20 seconds
//If there's a wire placed under the fence, the fence is electrified and can't be touched/cut without gloves

//Fence smashing sound downloaded from http://freesound.org/people/hintringer/sounds/274768/

#define CUT_TIME (20 SECONDS)
#define CLIMB_TIME (20 SECONDS)

#define NO_HOLE 0 //section is intact
#define SMALL_HOLE 1 //small hole in the section - can pass small items through.
#define MEDIUM_HOLE 2 //medium hole in the section - can climb through (takes 20 seconds)
#define LARGE_HOLE 3 //large hole in the section - can walk through
#define MAX_HOLE_SIZE LARGE_HOLE

/obj/structure/fence
	name = "fence"
	desc = "A chain link fence. Not as effective as a wall, but generally it keeps people out."
	density = 1
	anchored = 1

	icon = 'icons/obj/structures/fence.dmi'
	icon_state = "straight"

	var/cuttable = TRUE
	var/hole_size= NO_HOLE
	var/invulnerable = FALSE

/obj/structure/fence/New()
	..()

	update_cut_status()

/obj/structure/fence/examine(mob/user)
	.=..()

	switch(hole_size)
		if(SMALL_HOLE)
			user.show_message("There is a small hole in \the [src].", MESSAGE_SEE)
		if(MEDIUM_HOLE)
			user.show_message("There is a large hole in \the [src].", MESSAGE_SEE)
		if(LARGE_HOLE)
			user.show_message("\The [src] has been completely cut through.", MESSAGE_SEE)

/obj/structure/fence/end
	icon_state = "end"
	cuttable = FALSE

/obj/structure/fence/corner
	icon_state = "corner"
	cuttable = FALSE

/obj/structure/fence/post
	icon_state = "post"
	cuttable = FALSE

/obj/structure/fence/cut/small
	icon_state = "straight_cut1"
	hole_size = SMALL_HOLE

/obj/structure/fence/cut/medium
	icon_state = "straight_cut2"
	hole_size = MEDIUM_HOLE

/obj/structure/fence/cut/large
	icon_state = "straight_cut3"
	hole_size = LARGE_HOLE

/obj/structure/fence/attackby(obj/item/W, mob/user)
	if(iswirecutter(W) && !shock(user, 100))
		if(!cuttable)
			to_chat(user, "<span class='notice'>This section of the fence can't be cut.</span>")
			return

		if(invulnerable)
			to_chat(user, "<span class='notice'>This fence is too strong to cut through.</span>")
			return

		var/current_stage = hole_size
		if(current_stage >= MAX_HOLE_SIZE)
			return

		user.visible_message("<span class='danger'>\The [user] starts cutting through \the [src] with \the [W].</span>",\
		"<span class='danger'>You start cutting through \the [src] with \the [W].</span>")

		if(do_after(user, src, CUT_TIME))
			if(current_stage == hole_size)

				switch(++hole_size)
					if(SMALL_HOLE)
						visible_message("<span class='notice'>\The [user] creates a small opening in \the [src] with \the [W].</span>")
						to_chat(user, "<span class='info'>This hole seems to be [user.is_fat() ? "way " : ""]too small to climb though, but you probably could throw something through it.</span>")
					if(MEDIUM_HOLE)
						visible_message("<span class='notice'>\The [user] cuts into \the [src] some more.</span>")
						if(user.is_fat())
							to_chat(user, "<span class='info'>While a thinner person could climb through this hole, it's still too small for you.</span>")
						else
							to_chat(user, "<span class='info'>You could probably fit yourself through that hole now. Although climbing through would be much faster if you made it even bigger.</span>")
					if(LARGE_HOLE)
						visible_message("<span class='notice'>\The [user] completely cuts through \the [src].</span>")
						to_chat(user, "<span class='info'>The hole in \the [src] is now big enough to walk through.</span>")

				update_cut_status()
		return

	if(hole_size >= SMALL_HOLE)
		user.drop_item(W, get_turf(src))

/obj/structure/fence/attack_hand(mob/user)
	if(user.a_intent == I_HURT)
		var/strength = 1
		var/mob/living/carbon/human/H = user
		if(istype(H))
			strength = H.get_strength()

		user.visible_message("<span class='danger'>\The [user] hits \the [src]!</span>")
		playsound(get_turf(src), 'sound/effects/fence_smash.ogg', 30 * strength, 1) //Sound is louder the stronger you are
		shock(user, 100)
		return 1

	if(hole_size == MEDIUM_HOLE)
		if(user.is_fat())
			to_chat(user, "<span class='info'>You're too fat to fit through that hole.</span>")
			return

		user.visible_message("<span class='danger'>\The [user] starts climbing through \the [src]!</span>",\
		"<span class='info'>You start climbing through \the [src]. This will take about [CLIMB_TIME / 10] seconds.</span>")

		if(do_after(user, src, CLIMB_TIME) && !shock(user, 70)) //70% chance to get shocked
			user.forceMove(get_turf(src)) //Could be exploitable as it doesn't check for any other dense objects on the turf. Fix when fences are buildable!
			user.visible_message("<span class='danger'>\The [user] climbs through \the [src]!</span>")

	return 1

/obj/structure/fence/proc/update_cut_status()
	if(!cuttable)
		return

	density = 1

	switch(hole_size)
		if(NO_HOLE)
			icon_state = initial(icon_state)
		if(SMALL_HOLE)
			icon_state = "straight_cut1"
		if(MEDIUM_HOLE)
			icon_state = "straight_cut2"
		if(LARGE_HOLE)
			icon_state = "straight_cut3"
			density = 0

/obj/structure/fence/Bumped(atom/user)
	if(ismob(user))
		shock(user, 60)

//Mostly copied from grille.dm
/obj/structure/fence/Cross(atom/movable/mover, turf/target, height = 1.5, air_group = 0)
	if(air_group || (height == 0))
		return 1
	if(istype(mover) && mover.checkpass(PASSGRILLE))
		return 1
	else
		if(istype(mover, /obj/item/projectile))
			var/obj/item/projectile/projectile = mover
			return prob(projectile.grillepasschance) //Fairly hit chance
		else
			return !density

//Mostly copied from grille.dm
/obj/structure/fence/proc/shock(mob/user, prb = 100)
	if(!prob(prb)) //If the probability roll failed, don't go further
		return 0
	if(!in_range(src, user)) //To prevent TK and mech users from getting shocked
		return 0
	//Process the shocking via powernet, our job is done here
	var/turf/T = get_turf(src)
	var/obj/structure/cable/C = T.get_cable_node()
	if(C)
		if(electrocute_mob(user, C, src))
			var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
			s.set_up(3, 1, src)
			s.start()
			return 1
		else
			return 0
	return 0

//FENCE DOORS

/obj/structure/fence/door
	name = "fence door"
	desc = "Not very useful without a real lock."
	icon_state = "door_closed"
	cuttable = FALSE
	var/open = FALSE

/obj/structure/fence/door/New()
	..()

	update_door_status()

/obj/structure/fence/door/opened
	icon_state = "door_opened"
	open = TRUE

/obj/structure/fence/door/attack_hand(mob/user)
	if(can_open(user))
		toggle(user)

	return 1

/obj/structure/fence/door/proc/toggle(mob/user)
	switch(open)
		if(FALSE)
			visible_message("<span class='notice'>\The [user] opens \the [src].</span>")
			open = TRUE
		if(TRUE)
			visible_message("<span class='notice'>\The [user] closes \the [src].</span>")
			open = FALSE

	update_door_status()
	playsound(get_turf(src), 'sound/machines/click.ogg', 100, 1)

/obj/structure/fence/door/proc/update_door_status()
	switch(open)
		if(FALSE)
			density = 1
			icon_state = "door_closed"
		if(TRUE)
			density = 0
			icon_state = "door_opened"

/obj/structure/fence/door/proc/can_open(mob/user)
	return TRUE

//Secure doors - can only be opened/closed from one direction
//For example, you can open and close them if you're standing south of them, but can't if you're standing north
/obj/structure/fence/door/secure
	name = "secure fence door"
	desc = "A fence door with a door latch. It can only be opened and closed from one direction."

	var/permitted_direction = SOUTH

/obj/structure/fence/door/secure/from_south
	permitted_direction = SOUTH

/obj/structure/fence/door/secure/from_north
	permitted_direction = NORTH

/obj/structure/fence/door/secure/from_east
	permitted_direction = EAST

/obj/structure/fence/door/secure/from_west
	permitted_direction = WEST

/obj/structure/fence/door/secure/can_open(mob/user)
	//User must be standing in the permitted direction from the door, or must have telekinesis
	if((M_TK in usr.mutations) || (get_dir(src, user) == permitted_direction))
		return TRUE
	else
		to_chat(user, "<span class='warning'>You can't reach the door latch from here!</span>")
		return FALSE

#undef CUT_TIME
#undef CLIMB_TIME

#undef NO_HOLE
#undef SMALL_HOLE
#undef MEDIUM_HOLE
#undef LARGE_HOLE
#undef MAX_HOLE_SIZE
