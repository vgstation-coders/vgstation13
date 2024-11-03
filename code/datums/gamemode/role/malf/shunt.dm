/obj/effect/malf_jaunt
	mouse_opacity = 0
	icon = 'icons/effects/effects.dmi'
	icon_state ="bloodnail"
	color = "#ffee00"
	invisibility = 101
	alpha = 180
	layer = NARSIE_GLOW
	plane = ABOVE_LIGHTING_PLANE
	animate_movement = 0
	var/mob/living/silicon/ai/rider = null
	var/mutable_appearance/ma
	var/atom/targetatom
	var/returning_to_core = FALSE

	var/turf/starting = null
	var/turf/target = null

	var/dist_x = 0
	var/dist_y = 0
	var/dx = 0
	var/dy = 0
	var/error = 0
	var/target_angle = 0

	var/override_starting_X = 0
	var/override_starting_Y = 0
	var/override_target_X = 0
	var/override_target_Y = 0

	//update_pixel stuff
	var/PixelX = 0
	var/PixelY = 0

	var/initial_pixel_x = 0
	var/initial_pixel_y = 0

	var/landing = 0

	var/failsafe = 100


/obj/effect/malf_jaunt/New(var/turf/loc, var/mob/living/silicon/ai/user, var/atom/destination, var/corereturn = FALSE)
	..()
	if (!user)
		qdel(src)
		return
	user.forceMove(src)
	rider = user
	user.flags |= INVULNERABLE

	starting = loc
	returning_to_core = corereturn
	targetatom = destination
	target = get_turf(destination)
	initial_pixel_x = pixel_x
	initial_pixel_y = pixel_y
	if (target.z != z)	//Malfs shouldn't be able to shunt off-station, but just in case.
		move_to_edge()
	bump_target_check()
	if (!src||!loc)
		return
	failsafe = abs(starting.x - target.x) + abs(starting.y - target.y)
	init_angle()

	ma = new(src)
	ma.invisibility = 0
	rider.client.images |= ma

	init_jaunt()

/obj/effect/malf_jaunt/Destroy()
	if (rider)
		QDEL_NULL(rider)
	..()

/obj/effect/malf_jaunt/cultify()
	return

/obj/effect/malf_jaunt/ex_act()
	return

/obj/effect/malf_jaunt/emp_act()
	return

/obj/effect/malf_jaunt/blob_act()
	return

/obj/effect/malf_jaunt/singularity_act()
	return

/obj/effect/malf_jaunt/to_bump(var/atom/A)
	forceMove(get_step(loc,dir))
	bump_target_check()

/obj/effect/malf_jaunt/proc/move_to_edge()
	var/target_x
	var/target_y
	var/dx = abs(target.x - world.maxx/2)
	var/dy = abs(target.y - world.maxy/2)
	if (dx > dy)
		target_y = world.maxy/2 + rand(-4,4)
		if (target.x > world.maxx/2)
			target_x = world.maxx - TRANSITIONEDGE - rand(16,20)
		else
			target_x = TRANSITIONEDGE + rand(16,20)
	else
		target_x = world.maxx/2 + rand(-4,4)
		if (target.y > world.maxy/2)
			target_y = world.maxy - TRANSITIONEDGE - rand(16,20)
		else
			target_y = TRANSITIONEDGE + rand(16,20)

	var/turf/T = locate(target_x,target_y,target.z)
	starting = T
	forceMove(T)

/obj/effect/malf_jaunt/proc/init_angle()
	dist_x = abs(target.x - starting.x)
	dist_y = abs(target.y - starting.y)

	override_starting_X = starting.x
	override_starting_Y = starting.y
	override_target_X = target.x
	override_target_Y = target.y

	if (target.x > starting.x)
		dx = EAST
	else
		dx = WEST

	if (target.y > starting.y)
		dy = NORTH
	else
		dy = SOUTH

	if(dist_x > dist_y)
		error = dist_x/2 - dist_y
	else
		error = dist_y/2 - dist_x

	target_angle = round(Get_Angle(starting,target))
	var/transform_matrix = turn(matrix(),target_angle+45)
	transform = transform_matrix

/obj/effect/malf_jaunt/proc/update_pixel()
	if(src && starting && target)
		var/AX = (override_starting_X - src.x)*WORLD_ICON_SIZE
		var/AY = (override_starting_Y - src.y)*WORLD_ICON_SIZE
		var/BX = (override_target_X - src.x)*WORLD_ICON_SIZE
		var/BY = (override_target_Y - src.y)*WORLD_ICON_SIZE
		var/XXcheck = ((BX-AX)*(BX-AX))+((BY-AY)*(BY-AY))
		if(!XXcheck)
			return
		var/XX = (((BX-AX)*(-BX))+((BY-AY)*(-BY)))/XXcheck

		PixelX = round(BX+((BX-AX)*XX))
		PixelY = round(BY+((BY-AY)*XX))

		PixelX += initial_pixel_x
		PixelY += initial_pixel_y

		pixel_x = PixelX
		pixel_y = PixelY

/obj/effect/malf_jaunt/proc/bresenham_step(var/distA, var/distB, var/dA, var/dB)
	var/dist = get_dist(src,target)
	if (dist > 135)
		make_bresenham_step(distA, distB, dA, dB)
	if (dist > 45)
		make_bresenham_step(distA, distB, dA, dB)
	if (dist > 15)
		make_bresenham_step(distA, distB, dA, dB)
	if (dist < 10 && !landing)
		landing = 1
		playsound(src.target, 'sound/effects/cultjaunt_prepare.ogg', 75, 0, -3)
	return make_bresenham_step(distA, distB, dA, dB)

/obj/effect/malf_jaunt/proc/make_bresenham_step(var/distA, var/distB, var/dA, var/dB)
	if(error < 0)
		var/atom/step = get_step(src, dB)
		if(!step)
			qdel(src)
		src.Move(step)
		failsafe--
		error += distA
		bump_target_check()
		return 0//so that we don't move twice slower in diagonals
	else
		var/atom/step = get_step(src, dA)
		if(!step)
			qdel(src)
		src.Move(step)
		failsafe--
		error -= distB
		dir = dA
		if(error < 0)
			dir = dA + dB
		bump_target_check()
		return 1

/obj/effect/malf_jaunt/proc/process_step()
	var/sleeptime = 1
	if(src.loc)
		if(dist_x > dist_y)
			sleeptime = bresenham_step(dist_x,dist_y,dx,dy)
		else
			sleeptime = bresenham_step(dist_y,dist_x,dy,dx)
		update_pixel()
		sleep(sleeptime)

/obj/effect/malf_jaunt/proc/init_jaunt()
	if (!rider)
		qdel(src)
		return
	spawn while(loc)
		if (ismob(rider))
			var/mob/M = rider
			M.delayNextAttack(3)
			M.click_delayer.setDelay(3)
		process_step()

/obj/effect/malf_jaunt/proc/bump_target_check()
	if (loc == target || failsafe <= 0)
		playsound(loc, 'sound/effects/cultjaunt_land.ogg', 30, 0, -3)
		rider.flags &= ~INVULNERABLE
		rider.client.images -= ma
		if (rider)
			if(returning_to_core)
				var/mob/living/silicon/ai/A = targetatom
				A.shuntedAI = null
				rider.mind.transfer_to(A)
			else
				var/obj/machinery/power/apc/P = targetatom
				if(!P) // oh well
					rider.gib()
				else
					rider.forceMove(targetatom)
					if(istype(targetatom))
						P.occupant = rider
					P.update_icon()
			ma = null
			rider = null
		qdel(src)
