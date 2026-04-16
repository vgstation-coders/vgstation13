//Chain link fences
//Can be cut with wirecutters up to 3 times, cutting takes 20 seconds
//If there's a wire placed under the fence, the fence is electrified and can't be touched/cut without gloves

//Fence smashing sound downloaded from http://freesound.org/people/hintringer/sounds/274768/

#define CLIMB_TIME (20 SECONDS)

#define NO_HOLE 0 //section is intact
#define SMALL_HOLE 1 //small hole in the section - can pass small items through.
#define MEDIUM_HOLE 2 //medium hole in the section - can climb through (takes 20 seconds)
#define LARGE_HOLE 3 //large hole in the section - can walk through
#define CUT_THROUGH 4 //entirely gone!

/obj/structure/fence
	name = "fence"
	desc = "A chain link fence. Not as effective as a wall, but generally it keeps people out."
	density = 1
	anchored = 1
	pass_flags_self = PASSGRILLE
	icon = 'icons/obj/structures/fence.dmi'
	icon_state = "straight0"
	var/uncut_state = "straight"
	sheet_type = /obj/item/stack/sheet/plasteel
	sheet_amt = 2

	var/cut_time = 100
	var/cuttable = TRUE
	var/hole_size= NO_HOLE

/obj/structure/fence/examine(mob/user)
	.=..()

	switch(hole_size)
		if(SMALL_HOLE)
			user.show_message("There is a small hole in \the [src].", MESSAGE_SEE)
		if(MEDIUM_HOLE)
			user.show_message("There is a large hole in \the [src].", MESSAGE_SEE)
		if(LARGE_HOLE)
			user.show_message("\The [src] has been completely cut through.", MESSAGE_SEE)

/obj/structure/fence/canSmoothWith()
	var/static/list/smoothables = list(
		/obj/structure/fence,
		/obj/structure/grille,
		/turf/simulated/wall,
	)
	return smoothables

/obj/structure/fence/relativewall()
	. = ..()
	update_junction()

/obj/structure/fence/change_dir(new_dir, changer)
	. = ..()
	relativewall()

/obj/structure/fence/proc/update_junction()
	uncut_state = initial(uncut_state)
	switch(junction)
		if(NORTH|SOUTH,NORTH|SOUTH|EAST,NORTH|SOUTH|WEST)
			dir = WEST
		if(EAST|WEST,NORTH|EAST|WEST,SOUTH|EAST|WEST)
			dir = NORTH
		if(NORTH,SOUTH,EAST,WEST,NORTH|EAST,SOUTH|EAST,NORTH|WEST,SOUTH|WEST)
			uncut_state = "endcorner"
			dir = junction
	update_cut_status()

/obj/structure/fence/post
	icon_state = "post0"
	uncut_state = "post"
	cuttable = FALSE

/obj/structure/fence/cut/small
	hole_size = SMALL_HOLE

/obj/structure/fence/cut/medium
	hole_size = MEDIUM_HOLE

/obj/structure/fence/cut/large
	hole_size = LARGE_HOLE

/obj/structure/fence/attackby(obj/item/W, mob/user)
	if(istype(W,/obj/item/weapon/pickaxe/drill))
		user.visible_message("<span class='danger'>\The [user] starts cutting through \the [src] with \the [W].</span>",\
							"<span class='danger'>You start cutting through \the [src] with \the [W].</span>")
		if(do_after(user, src, cut_time/2))
			user.visible_message("<span class='notice'>\The [user] cuts through \the [src] with \the [W].</span>",
							"<span class='info'>You cut \the [src] back into rods with \the [W].</span>")
			dismantle(user)
		return

	if((W.sharpness_flags & SHARP_BLADE) && !shock(user, 100, W.siemens_coefficient))
		if(!cuttable)
			to_chat(user, "<span class='notice'>This section of the fence can't be cut.</span>")
			return

		var/current_stage = hole_size

		if(cut_time)
			user.visible_message("<span class='danger'>\The [user] starts cutting through \the [src] with \the [W].</span>",\
			"<span class='danger'>You start cutting through \the [src] with \the [W].</span>")

		if(do_after(user, src, cut_time/W.sharpness))
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
						visible_message("<span class='notice'>\The [user] cuts into \the [src] even more.</span>")
						to_chat(user, "<span class='info'>The hole in \the [src] is now big enough to walk through.</span>")
					if(CUT_THROUGH)
						visible_message("<span class='notice'>\The [user] completely cuts through \the [src].</span>")
						to_chat(user, "<span class='info'>\The [src] is now rods again.</span>")
						dismantle(user)
						return

				update_cut_status()
		return

	if(hole_size && istype(W,sheet_type))
		var/obj/item/stack/S = W
		if(S.use(1))
			to_chat(user, "<span class='info'>You repair \the [src] with a rod.</span>")
			hole_size = NO_HOLE
			update_cut_status()
			return

	if(hole_size >= SMALL_HOLE)
		user.drop_item(W, get_turf(src))

/obj/structure/fence/attack_paw(mob/user)
	if(M_HULK in user.mutations)
		if(prob(50))
			user.do_attack_animation(src, user)
			visible_message("<span class='danger'>[user] smashes [src] apart!</span>")
			user.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ))
			dismantle(user)

/obj/structure/fence/attack_alien(mob/living/user)
	if(prob(50))
		user.do_attack_animation(src, user)
		visible_message("<span class='danger'>[user] slices [src] apart!</span>")
		playsound(src, 'sound/effects/fence_smash.ogg', 100, 1)
		dismantle(user)

/obj/structure/fence/attack_animal(mob/living/simple_animal/user)
	if(user.environment_smash_flags & SMASH_WALLS)
		if(prob(50))
			user.do_attack_animation(src, user)
			visible_message("<span class='danger'>[user] smashes [src] apart!</span>")
			playsound(src, 'sound/effects/fence_smash.ogg', 100, 1)
			dismantle(user)

/obj/structure/fence/attack_hand(mob/user)
	if(user.a_intent == I_HURT)
		var/strength = 1
		var/mob/living/carbon/human/H = user
		if(istype(H))
			strength = H.get_strength()

		user.visible_message("<span class='danger'>\The [user] hits \the [src]!</span>")
		playsound(src, 'sound/effects/fence_smash.ogg', 30 * strength, 1) //Sound is louder the stronger you are
		shock(user, 100)
		attack_paw(user)
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
	setDensity(TRUE)

	if(!cuttable)
		icon_state = "[uncut_state]0"
		return

	icon_state = "[uncut_state][hole_size]"
	if(hole_size == LARGE_HOLE)
		setDensity(FALSE)

	cut_time = hole_size < LARGE_HOLE ? initial(cut_time) : 0

/obj/structure/fence/proc/dismantle(mob/user)
	drop_stack(sheet_type,get_turf(src),sheet_amt,user)
	qdel(src)

/obj/structure/fence/Bumped(atom/user)
	if(ismob(user))
		shock(user, 60)

//Mostly copied from grille.dm
/obj/structure/fence/Cross(atom/movable/mover, turf/target, height = 1.5, air_group = 0)
	if(air_group || (height == 0))
		return 1
	if(istype(mover) && mover.checkpass(pass_flags_self))
		return 1
	else
		if(istype(mover, /obj/item/projectile))
			var/obj/item/projectile/projectile = mover
			return prob(projectile.grillepasschance) //Fairly hit chance
		else
			return !density

//Mostly copied from grille.dm
/obj/structure/fence/proc/shock(mob/user, prb = 100, siemens_coefficient = 1)
	if(!prob(prb)) //If the probability roll failed, don't go further
		return 0
	if(!in_range(src, user)) //To prevent TK and mech users from getting shocked
		return 0
	//Process the shocking via powernet, our job is done here
	var/turf/T = get_turf(src)
	var/obj/structure/cable/C = T.get_cable_node()
	if(C)
		if(electrocute_mob(user, C, src, siemens_coefficient))
			spark(src)
			return 1
		else
			return 0
	return 0

/obj/structure/fence/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if(prob(50))
				new /obj/item/stack/rods(loc,1)
				qdel(src)
				return
		if(3.0)
			return

//FENCE DOORS

/obj/structure/fence/door
	name = "fence door"
	desc = "Not very useful without a real lock."
	icon_state = "door_closed"
	cuttable = FALSE
	var/open = FALSE
	var/inverted = FALSE //for relativewalling

/obj/structure/fence/door/New()
	..()
	set_up_access()
	update_door_status()

/obj/structure/fence/door/update_junction()
	if((junction & NORTH) || (junction & SOUTH))
		dir = inverted ? EAST : WEST
	if((junction & EAST) || (junction & WEST))
		dir = inverted ? SOUTH : NORTH

/obj/structure/fence/door/opened
	icon_state = "door_opened"
	open = TRUE

/obj/structure/fence/door/attack_hand(mob/user)
	if(can_open(user))
		if(open || check_access(user))
			toggle(user)
		else
			playsound(loc, 'sound/machines/denied.ogg', 50, 1)
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
	playsound(src, 'sound/machines/click.ogg', 100, 1)

/obj/structure/fence/door/proc/update_door_status()
	switch(open)
		if(FALSE)
			setDensity(TRUE)
			icon_state = "door_closed"
		if(TRUE)
			setDensity(FALSE)
			icon_state = "door_opened"

/obj/structure/fence/door/proc/can_open(mob/user)
	return TRUE

//Secure doors - can only be opened/closed from one direction
//For example, you can open and close them if you're standing south of them, but can't if you're standing north
/obj/structure/fence/door/secure
	name = "secure fence door"
	desc = "A fence door with a door latch. It can only be opened and closed from one direction."

/obj/structure/fence/door/secure/inverted
	inverted = TRUE

/obj/structure/fence/door/secure/can_open(mob/user)
	//User must be standing in the permitted direction from the door, or must have telekinesis
	if((M_TK in usr.mutations) || (get_dir(src, user) == dir))
		return TRUE
	else
		to_chat(user, "<span class='warning'>You can't reach the door latch from here!</span>")
		return FALSE

/obj/structure/fence/door/secure/AltClick(mob/user)
	// must be on same turf
	if(!user.incapacitated() && get_turf(user) == get_turf(src) && user.dexterity_check() && allowed(user))
		inverted = !inverted
		change_dir(opposite_dirs[dir])
		to_chat(user, "<span class='notice'>You flip the door latch to the other side of the door. It now faces [dir2text(dir)].</span>")
	. = ..()

#undef CLIMB_TIME

#undef NO_HOLE
#undef SMALL_HOLE
#undef MEDIUM_HOLE
#undef LARGE_HOLE
#undef CUT_THROUGH
