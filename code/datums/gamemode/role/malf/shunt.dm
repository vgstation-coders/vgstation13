/mob/living/silicon/shuntedAI
	name = "Shunted AI"
	see_in_dark = 8

	var/mob/living/silicon/ai/core
	var/list/images_shown = list()
	var/speeding = FALSE
	var/list/highlighted_cables = list()

/mob/living/silicon/shuntedAI/New(loc, var/datum/ai_laws/L, var/mob/living/silicon/ai/A)
	..()
	core = A
	name = A.name
	A.shuntedAI = src

	if(L && istype(L,/datum/ai_laws))
		laws = L
	else
		laws = new /datum/ai_laws/malf()

/mob/living/silicon/shuntedAI/update_perception()
	if(client)
		if(client.darkness_planemaster)
			client.darkness_planemaster.blend_mode = BLEND_MULTIPLY
			client.darkness_planemaster.alpha = 155
		client.color = list(
					1.3,0,0,0,
					0,1,0,0,
	 				0,0,1.3,0,
		 			-0.2,0,-0.2,1,
		 			0,0,0,0)



/mob/living/silicon/shuntedAI/proc/return_to_core()
	if(!core)
		return
	var/atom/A = loc
	mind.transfer_to(core)
	core.update_perception()
	core.shuntedAI = null
	qdel(src)
	


/mob/living/silicon/shuntedAI/Login()
	..()
	DisplayUI("Shunted Malf")
	client.CAN_MOVE_DIAGONALLY = TRUE
	var/datum/role/malfAI/M = mind.GetRole(MALF)
	if(M)
		M.regenerate_hack_overlays()
	

/mob/living/silicon/shuntedAI/movement_delay()
	if(speeding)
		return 1
	else 
		return 2.0

/mob/living/silicon/shuntedAI/Life()
	..()
	if(istype(loc, /obj/machinery/power/apc))
		var/obj/machinery/power/apc/A = loc
		var/obj/item/weapon/cell/cell = A.get_cell()
		if(cell.charge > 0)
			adjustOxyLoss(-1)
		else
			adjustOxyLoss(1)
	if(istype(loc, /obj/structure/cable))
		var/obj/structure/cable/C = loc
		if(C.avail() <= 0)
			adjustOxyLoss(1)



/obj/machinery/power/battery/smes/relaymove(var/mob/living/silicon/shuntedAI/user, direction)
	if(!istype(user))
		return
	var/turf/T = get_step(src, direction)
	var/obj/structure/cable/C = T.get_cable_node()
	if(C)
		user.shunt_transfer(C)
	else 
		T = get_turf(src)
		C = T.get_cable_node()
		if(C)
			user.shunt_transfer(C)


/obj/machinery/power/apc/relaymove(var/mob/living/silicon/shuntedAI/user, direction)
	if(!istype(user))
		return
	var/turf/T = get_turf(src)
	var/obj/structure/cable/C = T.get_cable_node()
	if(C)
		user.shunt_transfer(C)


/obj/structure/cable/relaymove(var/mob/living/silicon/shuntedAI/user, direction)
	if(!istype(user))
		return
	var/list/valid_exit_directions = list()
	var/turf/dest = get_step(src, direction)
	var/turf/T = get_turf(src)
	for(var/obj/structure/cable/C in T)
		valid_exit_directions += C.d1
		valid_exit_directions += C.d2
	to_chat(world, valid_exit_directions)
	if(!(locate(direction) in valid_exit_directions))		
		user.attempt_transfer(dest)
		return
	var/obj/structure/cable/target_move = findConnecting(direction)
	if(!target_move)
		user.attempt_transfer(dest)
		return
	if (user.client.prefs.stumble && ((world.time - user.last_movement) > 5))
		user.delayNextMove(3)	

	var/delay = user.movement_delay()

	if(user.speeding)
		target_move.shake(3, 3)
		if(prob(10))
			spark(target_move, 1)

	user.forceMove(target_move, glide_size_override = DELAY2GLIDESIZE(delay))
	user.delayNextMove(delay)
	user.last_movement = world.time
	user.set_highlighted_cable()



/mob/living/silicon/shuntedAI/proc/attempt_transfer(var/turf/dest)
	var/obj/machinery/A = locate(/obj/machinery/power/apc) in get_turf(src)
	if(A)
		return shunt_transfer(A)
	var/obj/machinery/S = locate(/obj/machinery/power/battery/smes) in dest
	if(S)
		return shunt_transfer(S)

/obj/structure/cable/proc/findConnecting(var/direction)
	for(var/obj/structure/cable/target in get_step(src,direction))
		if(target.d1 == get_dir(target,src) || target.d2 == get_dir(target,src))
			return target


/mob/living/silicon/shuntedAI/proc/set_highlighted_cable()
	for(var/image/I in highlighted_cables)
		client.images -= highlighted_cables
	highlighted_cables = list()
	var/turf/T = get_turf(src)
	for(var/obj/structure/cable/cable in T)
		var/image/cable_image = image(cable.icon, cable.loc, cable.icon_state, ABOVE_LIGHTING_LAYER + 1)
		cable_image.plane = ABOVE_LIGHTING_PLANE
		cable_image.color = cable.color
		cable_image.filters += filter(type = "outline", size = 1, color =  "#79F943")
		cable_image.alpha = 255
		highlighted_cables += cable_image
		client.images |= cable_image

/mob/living/silicon/shuntedAI/proc/shunt_transfer(var/atom/A, var/delay = 1.5 SECONDS)
	var/atom/previous = loc
	if(!(do_after(src, A, delay)))
		return
	forceMove(A)
	previous.update_icon()
	A.update_icon()
	generate_cable_images()
	set_highlighted_cable()


/mob/living/silicon/shuntedAI/proc/generate_cable_images()
	clear_cable_images()
	if(istype(loc, /obj/structure/cable))
		var/obj/structure/cable/C = loc
		var/datum/powernet/P = C.get_powernet()
		if(P)
			for(var/obj/structure/cable/Ca in P.cables)
				add_cable_to_images(Ca)
			for(var/obj/machinery/power/terminal/T in P.nodes)
				add_terminal_to_images(T)
	else if(istype(loc, /obj/machinery/power))
		var/obj/machinery/power/C = loc
		var/datum/powernet/P = C.get_powernet()
		var/datum/powernet/P2 = C.terminal.get_powernet()
		if(P)
			for(var/obj/structure/cable/Ca in P.cables)
				add_cable_to_images(Ca)
			for(var/obj/machinery/power/terminal/T in P.nodes)
				add_terminal_to_images(T)
		if(P2 && P2 != P)	//show the terminal side too if its different
			for(var/obj/structure/cable/Ca in P2.cables)
				add_cable_to_images(Ca)
			for(var/obj/machinery/power/terminal/T in P2.nodes)
				add_terminal_to_images(T)

/mob/living/silicon/shuntedAI/proc/add_cable_to_images(var/obj/structure/cable/Ca)
	var/image/cable_image = image(Ca.icon, Ca.loc, Ca.icon_state, ABOVE_LIGHTING_LAYER)
	cable_image.plane = ABOVE_LIGHTING_PLANE
	cable_image.color = Ca.color
	images_shown += cable_image
	client.images |= cable_image

/mob/living/silicon/shuntedAI/proc/add_terminal_to_images(var/obj/machinery/power/terminal/T)
	var/image/terminal_image = image(T.icon, T.loc, T.icon_state, ABOVE_LIGHTING_LAYER, T.dir)
	terminal_image.plane = ABOVE_LIGHTING_PLANE
	images_shown += terminal_image
	client.images |= terminal_image

/mob/living/silicon/shuntedAI/proc/clear_cable_images()
	for(var/image/I in images_shown)
		client.images -= I
	for(var/image/I in highlighted_cables)
		client.images -= I
	highlighted_cables = list()
	client.eye = src
	images_shown = list()

/mob/living/silicon/shuntedAI/ClickOn(var/atom/A, params)
	if(click_delayer.blocked())
		return
	click_delayer.setDelay(1)

	if(client.buildmode) // comes after object.Click to allow buildmode gui objects to be clicked
		build_click(src, client.buildmode, params, A)
		return

	var/list/modifiers = params2list(params)
	if(modifiers["middle"])
		if(modifiers["shift"])
			MiddleShiftClickOn(A)
			return
		else
			MiddleClickOn(A)
			return
	if(modifiers["right"])
		RightClickOn(A)
		return
	if(modifiers["shift"])
		ShiftClickOn(A)
		return
	if(modifiers["alt"]) 
		AltClickOn(A)
		return
	if(modifiers["ctrl"])
		CtrlClickOn(A)
		return

	if(attack_delayer.blocked())
		return

	if(lazy_invoke_event(/lazy_event/on_uattack, list("atom" = A))) 
		return
	A.add_hiddenprint(src)
	A.attack_ai(src)

/mob/living/silicon/shuntedAI/UnarmedAttack(atom/A)
	A.attack_ai(src)
/mob/living/silicon/shuntedAI/RangedAttack(atom/A)
	A.attack_ai(src)
/mob/living/silicon/shuntedAI/ShiftClickOn(var/atom/A)
	A.AIShiftClick(src)
/mob/living/silicon/shuntedAI/CtrlClickOn(var/atom/A)
	A.AICtrlClick(src)
/mob/living/silicon/shuntedAI/AltClickOn(var/atom/A)
	A.AIAltClick(src)
/mob/living/silicon/shuntedAI/MiddleShiftClickOn(var/atom/A)
	A.AIMiddleShiftClick(src)
/mob/living/silicon/shuntedAI/RightClickOn(var/atom/A)
	A.AIRightClick(src)





/obj/effect/malf_jaunt
	mouse_opacity = 0
	icon = 'icons/effects/effects.dmi'
	icon_state ="bloodnail"
	color = "#32d600"
	invisibility = 101
	alpha = 180
	layer = NARSIE_GLOW
	plane = ABOVE_LIGHTING_PLANE
	animate_movement = 0
	var/mob/living/silicon/shuntedAI/rider = null
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


/obj/effect/malf_jaunt/New(var/turf/loc, var/mob/living/silicon/shuntedAI/user, var/atom/destination, var/corereturn)
	..()
	if (!user || !isshuntedAI(user))
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
	init_angle()
	
	ma = new(src)
	ma.invisibility = 0
	rider.client.images |= ma

	init_jaunt()

/obj/effect/malf_jaunt/Destroy()
	if (rider)
		qdel(rider)
		rider = null
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

	if( !("[icon_state]_angle[target_angle]" in bullet_master) )//totally hijacking [deity's] own [jaunt code] in case that wasn't already obvious.
		var/icon/I = new(icon,icon_state)
		I.Turn(target_angle+45)
		bullet_master["[icon_state]_angle[target_angle]"] = I
	icon = bullet_master["[icon_state]_angle[target_angle]"]

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
		error += distA
		bump_target_check()
		return 0//so that bullets going in diagonals don't move twice slower
	else
		var/atom/step = get_step(src, dA)
		if(!step)
			qdel(src)
		src.Move(step)
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
	if (loc == target)
		playsound(loc, 'sound/effects/cultjaunt_land.ogg', 30, 0, -3)
		rider.flags &= ~INVULNERABLE
		rider.client.images -= ma
		if (rider)
			if(returning_to_core)
				rider.return_to_core()
			else
				rider.forceMove(targetatom)
				rider.generate_cable_images()
				targetatom.update_icon()
			ma = null
			rider = null
		qdel(src)
