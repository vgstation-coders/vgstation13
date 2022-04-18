//////////////////////////////
//Contents: Ladders, Stairs.//
//////////////////////////////

/obj/structure/z_ladder
	name = "ladder"
	desc = "A ladder. You can climb it up and down."
	icon_state = "ladder01"
	icon = 'icons/obj/structures.dmi'
	density = 0
	opacity = 0
	anchored = 1

	var/allowed_directions = DOWN
	var/obj/structure/z_ladder/target_up
	var/obj/structure/z_ladder/target_down

	var/const/climb_time = 2 SECONDS

/obj/structure/z_ladder/New()
	if(world.has_round_started())
		initialize()
	..()

/obj/structure/z_ladder/initialize()
	// the upper will connect to the lower
	if(allowed_directions & DOWN) //we only want to do the top one, as it will initialize the ones before it.
		for(var/obj/structure/z_ladder/L in GetBelow(src))
			if(L.allowed_directions & UP)
				target_down = L
				L.target_up = src
				return
	update_icon()

/obj/structure/z_ladder/Destroy()
	if(target_down)
		target_down.target_up = null
		target_down = null
	if(target_up)
		target_up.target_down = null
		target_up = null
	return ..()

/obj/structure/z_ladder/attackby(obj/item/C, mob/user)
	attack_hand(user)

/obj/structure/z_ladder/attack_hand(var/mob/M)
	if(!M.may_climb_ladders(src))
		return

	var/obj/structure/z_ladder/target_ladder = getTargetLadder(M)
	if(!target_ladder)
		return
	if(!M.Move(get_turf(src)))
		to_chat(M, "<span class='notice'>You fail to reach \the [src].</span>")
		return

	var/direction = target_ladder == target_up ? "up" : "down"

	M.visible_message("<span class='notice'>\The [M] begins climbing [direction] \the [src]!</span>",
	"You begin climbing [direction] \the [src]!",
	"You hear the grunting and clanging of a metal ladder being used.")

	target_ladder.visible_message("<span class='notice'>You hear something coming [direction] \the [src]</span>")

	if(do_after(M, src, climb_time))
		climbLadder(M, target_ladder)

/obj/structure/z_ladder/attack_ghost(var/mob/M)
	var/target_ladder = getTargetLadder(M)
	if(target_ladder)
		M.forceMove(get_turf(target_ladder))

/obj/structure/z_ladder/proc/getTargetLadder(var/mob/M)
	if((!target_up && !target_down) || (target_up && !istype(target_up.loc, /turf) || (target_down && !istype(target_down.loc,/turf))))
		to_chat(M, "<span class='notice'>\The [src] is incomplete and can't be climbed.</span>")
		return
	if(target_down && target_up)
		var/direction = alert(M,"Do you want to go up or down?", "Ladder", "Up", "Down", "Cancel")

		if(direction == "Cancel")
			return

		if(!M.may_climb_ladders(src))
			return

		switch(direction)
			if("Up")
				return target_up
			if("Down")
				return target_down
	else
		return target_down || target_up

/mob/proc/may_climb_ladders(var/ladder)
	if(!Adjacent(ladder))
		to_chat(src, "<span class='warning'>You need to be next to \the [ladder] to start climbing.</span>")
		return FALSE
	if(!held_items.len)
		to_chat(src, "<span class='warning'>You do not have hands to grab \the [ladder].</span>")
		return FALSE
	if(incapacitated())
		to_chat(src, "<span class='warning'>You are physically unable to climb \the [ladder].</span>")
		return FALSE
	return TRUE

/mob/dead/observer/ghost/may_climb_ladders(var/ladder)
	return TRUE

/obj/structure/z_ladder/proc/climbLadder(var/mob/M, var/target_ladder)
	var/turf/T = get_turf(target_ladder)
	for(var/atom/A in T)
		if(!A.Cross(M, M.loc, 1.5, 0))
			to_chat(M, "<span class='notice'>\The [A] is blocking \the [src].</span>")
			return FALSE
	return M.Move(T)

/obj/structure/z_ladder/Cross(obj/mover, turf/source, height, airflow)
	return airflow || !density

/obj/structure/z_ladder/update_icon()
	icon_state = "ladder[!!(allowed_directions & UP)][!!(allowed_directions & DOWN)]"

/obj/structure/z_ladder/up
	allowed_directions = UP
	icon_state = "ladder10"

/obj/structure/z_ladder/updown
	allowed_directions = UP|DOWN
	icon_state = "ladder11"

//TODO: Preferably make these work without border_dummy. This was the simplest way to convert their old behavior.
/obj/structure/stairs
	name = "\improper stairs"
	desc = "Stairs leading to another deck."
	icon = 'icons/obj/stairs.dmi'
	icon_state = "stairs"
	density = 1
	opacity = 0
	anchored = 1

/obj/structure/stairs/New()
	..()
	if(world.has_round_started())
		initialize()
	setup_border_dummy()

/obj/structure/stairs/initialize()
	for(var/turf/turf in locs)
		var/turf/simulated/open/above = GetAbove(turf)
		if(!above)
			warning("Stair created without level above: ([loc.x], [loc.y], [loc.z])")
			return qdel(src)
		if(!istype(above))
			above.ChangeTurf(/turf/simulated/open)

// And now the actual going, fail uncross to move up, hence bumped()
/obj/structure/stairs/Bumped(atom/movable/A)
	if(A.dir == dir)
		var/turf/simulated/open/above = GetAbove(A)
		if(!above || !istype(above))
			return
		var/turf/target = get_step(above, dir)
		A.Move(target)
		if(isliving(A))
			var/mob/living/L = A
			if(L.pulling)
				L.pulling.Move(target)

/obj/structure/stairs/Cross(atom/movable/mover, turf/target, height = 1.5, air_group = 0)
	return !density || !istype(mover) || (bounds_dist(border_dummy, mover) >= 0)

/obj/structure/stairs/attackby(obj/item/W, mob/user)
	if(iswelder(W))
		var/obj/item/tool/weldingtool/WT = W
		if(WT.remove_fuel(1, user))
			user.visible_message("<span class='warning'>[user] begins slicing through \the [src]'s step plates.</span>", \
			"<span class='notice'>You begin slicing through \the [src]'s step plates.</span>", \
			"<span class='warning'>You hear welding noises.</span>")
			playsound(src, 'sound/items/Welder.ogg', 100, 1)
			if(do_after(user, src, 100))
				if(!istype(src))
					return
				playsound(src, 'sound/items/Welder.ogg', 100, 1)
				user.visible_message("<span class='warning'>[user] slices through \the [src]'s step plates.</span>", \
				"<span class='notice'>You slice through \the [src]'s step plates.</span>", \
				"<span class='warning'>You hear welding noises.</span>")
				var/obj/structure/stairs_frame/SF = null
				switch(dir)
					if(NORTH)
						SF = new /obj/structure/stairs_frame(get_step(loc,SOUTH))
					if(EAST)
						SF = new /obj/structure/stairs_frame(get_step(loc,WEST))
					if(SOUTH)
						SF = new /obj/structure/stairs_frame(loc)
					if(WEST)
						SF = new /obj/structure/stairs_frame(loc)
				SF.dir = dir
				SF.anchored = anchored
				qdel(src)

// type paths to make mapping easier.
/obj/structure/stairs/north
	dir = NORTH
	bound_height = 2 * WORLD_ICON_SIZE
	bound_y = -WORLD_ICON_SIZE
	pixel_y = -WORLD_ICON_SIZE

/obj/structure/stairs/south
	dir = SOUTH
	bound_height = 2 * WORLD_ICON_SIZE

/obj/structure/stairs/east
	dir = EAST
	bound_width = 2 * WORLD_ICON_SIZE
	bound_x = -WORLD_ICON_SIZE
	pixel_x = -WORLD_ICON_SIZE

/obj/structure/stairs/west
	dir = WEST
	bound_width = 2 * WORLD_ICON_SIZE

/obj/structure/stairs_frame
	name = "\improper stair frame"
	desc = "Frames of stairs that are supposed to lead to another deck."
	icon = 'icons/obj/stairs.dmi'
	icon_state = "stairframe"
	density = 0

/obj/structure/stairs_frame/attackby(obj/item/W, mob/user)
	if(W.is_wirecutter(user))
		W.playtoolsound(src, 100)
		user.visible_message("<span class='warning'>[user] dissasembles \the [src].</span>", \
		"<span class='notice'>You dissasemble \the [src].</span>")
		new /obj/item/stack/sheet/metal(get_turf(src), 4)
		qdel(src)

	if(W.is_wrench(user))
		user.visible_message("<span class='warning'>[user] [anchored ? "unanchors" : "anchors"] \the [src].</span>", \
		"<span class='notice'>You [anchored ? "unanchor" : "anchor"] \the [src].</span>")
		add_hiddenprint(user)
		add_fingerprint(user)
		anchored = !anchored

	else if(istype(W, /obj/item/stack/sheet/metal))
		var/obj/item/stack/sheet/metal/S = W
		if(!anchored)
			to_chat(user, "<span class='warning'>The [src] must be anchored first!.</span>")
			return
		else
			if(S.amount < 4)
				return ..() // ?
			user.visible_message("<span class='notice'>[user] starts installing step plates to \the [src].</span>", \
			"<span class='notice'>You start installing step plates to \the [src].</span>")
			if(do_after(user, src, 80))
				if(S.amount < 4) //User being tricky
					return
				S.use(4)
				user.visible_message("<span class='notice'>[user] finishes installing step plates to \the [src].</span>", \
				"<span class='notice'>You finish installing step plates to \the [src].</span>")
				switch(dir)
					if(NORTH)
						new /obj/structure/stairs/north(get_step(loc,NORTH))
					if(EAST)
						new /obj/structure/stairs/east(get_step(loc,EAST))
					if(SOUTH)
						new /obj/structure/stairs/south(loc)
					if(WEST)
						new /obj/structure/stairs/west(loc)
				qdel(src)
			return
