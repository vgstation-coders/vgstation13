
///////////////////////////////////////CULT RITUALS////////////////////////////////////////////////
//Effects spawned by rune spells

/obj/effect/cult_ritual
	icon = 'icons/effects/effects.dmi'
	icon_state = ""
	anchored = 1
	mouse_opacity = 0

/obj/effect/cult_ritual/cultify()
	return

/obj/effect/cult_ritual/ex_act()
	return

/obj/effect/cult_ritual/emp_act()
	return

/obj/effect/cult_ritual/blob_act()
	return

/obj/effect/cult_ritual/singularity_act()
	return

///////////////////////////////////////SHORTCUT////////////////////////////////////////////////
/obj/effect/cult_shortcut
	name = "sigil"
	icon = 'icons/obj/cult.dmi'
	icon_state = "sigil"
	anchored = 1
	mouse_opacity = 1
	layer = NARSIE_GLOW
	plane = LIGHTING_PLANE
	var/persist = 0//so mappers can make permanent sigils

/obj/effect/cult_shortcut/New(var/turf/loc, var/atom/model)
	..()
	if (!persist)
		spawn (60 SECONDS)
			qdel(src)

/obj/effect/cult_shortcut/attack_hand(var/mob/living/user)
	if (!iscultist(user))
		to_chat(user, "<span class='warning'>The markings on this wall are peculiar. You don't feel comfortable staring at them.</span>")
		return
	var/turf/T = get_turf(user)
	if (T == loc)
		return
	var/jump_dir = get_dir(T,loc)
	shadow(loc,T,"sigil_jaunt")
	spawn(1)
		new /obj/effect/red_afterimage(T,user)
		user.forceMove(loc)
		sleep(1)
		new /obj/effect/red_afterimage(loc,user)
		user.forceMove(get_step(loc,jump_dir))

/obj/effect/cult_shortcut/cultify()
	return

/obj/effect/cult_shortcut/ex_act()
	return

/obj/effect/cult_shortcut/emp_act()
	return

/obj/effect/cult_shortcut/blob_act()
	return

/obj/effect/cult_shortcut/singularity_act()
	return


/obj/effect/red_afterimage
	icon = null
	icon_state = null
	anchored = 1
	mouse_opacity = 0

/obj/effect/red_afterimage/New(var/turf/loc, var/atom/model)
	..()
	if(model)
		src.appearance = model.appearance
		dir = model.dir
		color = "red"
		layer = NARSIE_GLOW
		plane = LIGHTING_PLANE
	animate(src,alpha = 0, time = 5)
	spawn(5)
		qdel(src)

/obj/effect/red_afterimage/cultify()
	return

/obj/effect/red_afterimage/ex_act()
	return

/obj/effect/red_afterimage/emp_act()
	return

/obj/effect/red_afterimage/blob_act()
	return

/obj/effect/red_afterimage/singularity_act()
	return

///////////////////////////////////////JAUNT////////////////////////////////////////////////
//Cultists ride in those when teleporting

/obj/effect/bloodcult_jaunt
	mouse_opacity = 0
	icon = 'icons/effects/96x96.dmi'
	icon_state ="cult_jaunt"
	invisibility = INVISIBILITY_CULTJAUNT
	alpha = 127
	layer = NARSIE_GLOW
	plane = LIGHTING_PLANE
	pixel_x = -WORLD_ICON_SIZE
	pixel_y = -WORLD_ICON_SIZE
	animate_movement = 0
	var/atom/movable/rider = null//lone user?
	var/list/packed = list()//moving a lot of stuff?

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

	var/atom/movable/overlay/landing_animation = null
	var/landing = 0


/obj/effect/bloodcult_jaunt/New(var/turf/loc, var/mob/user, var/turf/destination, var/turf/packup)
	..()
	if (!user && !packup)
		qdel(src)
		return
	if (user)
		user.forceMove(src)
		rider = user
		if (ismob(rider))
			var/mob/M = rider
			M.see_invisible = SEE_INVISIBLE_CULTJAUNT
			M.see_invisible_override = SEE_INVISIBLE_CULTJAUNT
			M.apply_vision_overrides()
			M.flags |= INVULNERABLE
	if (packup)
		for (var/atom/movable/AM in packup)
			if (!AM.anchored)
				AM.forceMove(src)
				packed.Add(AM)
				if (ismob(AM))
					var/mob/M = AM
					M.see_invisible = SEE_INVISIBLE_CULTJAUNT
					M.see_invisible_override = SEE_INVISIBLE_CULTJAUNT
					M.apply_vision_overrides()
					M.flags |= INVULNERABLE
	starting = loc
	target = destination
	initial_pixel_x = pixel_x
	initial_pixel_y = pixel_y
	//first of all, if our target is off Z-Level, we're immediately teleporting to the edge of the map closest to the target
	if (target.z != z)
		move_to_edge()
	//quickly making sure that we're not jaunting to where we are
	bump_target_check()
	if (!src||!loc)
		return
	//next, let's rotate the jaunter's sprite to face our destination
	init_angle()
	//now, let's launch the jaunter at our target
	init_jaunt()

/obj/effect/bloodcult_jaunt/Destroy()
	if (rider)
		qdel(rider)
		rider = null
	if (packed.len > 0)
		for(var/atom/A in packed)
			qdel(A)
	packed = list()
	..()

/obj/effect/bloodcult_jaunt/cultify()
	return

/obj/effect/bloodcult_jaunt/ex_act()
	return

/obj/effect/bloodcult_jaunt/emp_act()
	return

/obj/effect/bloodcult_jaunt/blob_act()
	return

/obj/effect/bloodcult_jaunt/singularity_act()
	return

/obj/effect/bloodcult_jaunt/to_bump(var/atom/A)
	forceMove(get_step(loc,dir))
	bump_target_check()

/obj/effect/bloodcult_jaunt/proc/move_to_edge()
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

/obj/effect/bloodcult_jaunt/proc/init_angle()
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

	if( !("[icon_state]_angle[target_angle]" in bullet_master) )//totally hijacking my own bullet code in case that wasn't already obvious.
		var/icon/I = new(icon,icon_state)
		I.Turn(target_angle+45)
		bullet_master["[icon_state]_angle[target_angle]"] = I
	icon = bullet_master["[icon_state]_angle[target_angle]"]

/obj/effect/bloodcult_jaunt/proc/update_pixel()
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

/obj/effect/bloodcult_jaunt/proc/bresenham_step(var/distA, var/distB, var/dA, var/dB)
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
		landing_animation = anim(target = src.target, a_icon = 'icons/effects/effects.dmi', flick_anim = "cult_jaunt_prepare", lay = SNOW_OVERLAY_LAYER, plane = EFFECTS_PLANE)
	return make_bresenham_step(distA, distB, dA, dB)

/obj/effect/bloodcult_jaunt/proc/make_bresenham_step(var/distA, var/distB, var/dA, var/dB)
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

/obj/effect/bloodcult_jaunt/proc/process_step()
	var/sleeptime = 1
	if(src.loc)
		if(dist_x > dist_y)
			sleeptime = bresenham_step(dist_x,dist_y,dx,dy)
		else
			sleeptime = bresenham_step(dist_y,dist_x,dy,dx)
		update_pixel()
		sleep(sleeptime)

/obj/effect/bloodcult_jaunt/proc/init_jaunt()
	if (!rider && packed.len <= 0)
		qdel(src)
		return
	spawn while(loc)
		if (ismob(rider))
			var/mob/M = rider
			M.delayNextAttack(3)
			M.click_delayer.setDelay(3)
		for(var/mob/M in packed)
			M.delayNextAttack(3)
			M.click_delayer.setDelay(3)
		process_step()

/obj/effect/bloodcult_jaunt/proc/bump_target_check()
	if (loc == target)
		playsound(loc, 'sound/effects/cultjaunt_land.ogg', 30, 0, -3)
		if (rider)
			rider.forceMove(target)
			if (ismob(rider))
				var/mob/M = rider
				M.flags &= ~INVULNERABLE
				M.see_invisible = SEE_INVISIBLE_LIVING
				M.see_invisible_override = 0
				M.apply_vision_overrides()
			rider = null
		if (packed.len > 0)
			for(var/atom/movable/AM in packed)
				AM.forceMove(target)
				if (ismob(AM))
					var/mob/M = AM
					M.flags &= ~INVULNERABLE
					M.see_invisible = SEE_INVISIBLE_LIVING
					M.see_invisible_override = 0
					M.apply_vision_overrides()
			packed = list()

		if (landing_animation)
			flick("cult_jaunt_land",landing_animation)
		qdel(src)

///////////////////////////////////////BLOODSTONE DEFENSES////////////////////////////////////////////////

var/list/bloodstone_backup = 0

/obj/effect/cult_ritual/backup_spawn
	name = "gateway"
	desc = "Something is coming through!"
	icon = 'icons/obj/cult.dmi'
	icon_state = "runetrigger-build"
	anchored = 1
	mouse_opacity = 1

/obj/effect/cult_ritual/backup_spawn/New()
	..()
	spawn (30)
		bloodstone_backup++
		var/mobtype
		switch (bloodstone_backup)
			if (0,1,2)
				mobtype = pick(
					1;/mob/living/simple_animal/hostile/faithless/cult,
					2;/mob/living/simple_animal/hostile/scarybat/cult,
					)
			if (3,4)
				mobtype = pick(
					1;/mob/living/simple_animal/hostile/creature/cult,
					3;/mob/living/simple_animal/hostile/faithless/cult,
					2;/mob/living/simple_animal/hostile/scarybat/cult,
					)
			if (5,6)
				mobtype = pick(
					2;/mob/living/simple_animal/hostile/creature/cult,
					2;/mob/living/simple_animal/hostile/faithless/cult,
					1;/mob/living/simple_animal/hostile/scarybat/cult,
					)
			if (7 to INFINITY)
				mobtype = pick(
					2;/mob/living/simple_animal/hostile/creature/cult,
					1;/mob/living/simple_animal/hostile/faithless/cult,
					)
		new mobtype(get_turf(src))
		qdel(src)

///////////////////////////////////////STUN INDICATOR////////////////////////////////////////////////
/obj/effect/stun_indicator
	icon = null
	anchored = 1
	mouse_opacity = 0
	var/list/viewers = list()
	var/image/indicator = null
	var/current_dots = 6
	var/mob/victim = null

/obj/effect/stun_indicator/New()
	..()
	if (!ismob(loc))
		qdel(src)
		return

	victim = loc
	current_dots = Clamp(round(victim.knockdown/2.5),0,5)

	if (!current_dots)
		qdel(src)
		return

	current_dots++//so we get integers from 1 to 6

	for (var/mob/M in player_list)
		if (iscultist(M) && M.client)
			viewers += M.client

	indicator = image(icon='icons/obj/cult.dmi',loc=victim,icon_state="",layer=SNOW_OVERLAY_LAYER)
	update_indicator()

/obj/effect/stun_indicator/proc/update_indicator()
	set waitfor = FALSE
	while (victim && (victim.stat < DEAD) && victim.knockdown)
		for (var/client/C in viewers)
			C.images -= indicator
		var/dots = Clamp(1+round(victim.knockdown/2.5),1,6)
		var/anim = 0
		if (dots!=current_dots)
			anim = 1
			current_dots = dots
		indicator.overlays.len = 0
		indicator = image(icon='icons/obj/cult.dmi',loc=victim,icon_state="",layer=SNOW_OVERLAY_LAYER)
		indicator.plane = EFFECTS_PLANE
		indicator.pixel_y = 8
		for (var/i = 1 to dots)
			var/state = "stun_dot1"
			if (current_dots == i)
				if (anim)
					state = "stun_dot2-flick"
					var/image/I = image(icon='icons/obj/cult.dmi',icon_state="stun_dot-gone")
					I.plane = EFFECTS_PLANE
					I = place_indicator(I,i+1)
					indicator.overlays += I
				else
					state = "stun_dot2"
			var/image/I = image(icon='icons/obj/cult.dmi',icon_state=state)
			I.plane = EFFECTS_PLANE
			I = place_indicator(I,i)
			indicator.overlays += I
		for (var/client/C in viewers)
			C.images += indicator
		sleep(10)
	qdel(src)

/obj/effect/stun_indicator/proc/place_indicator(var/image/I,var/dot)
	switch (dot)
		if (2,3)
			I.pixel_x = -8
		if (5,6)
			I.pixel_x = 8
	switch (dot)
		if (2,6)
			I.pixel_y = 4
		if (3,5)
			I.pixel_y = -4
		if (1)
			I.pixel_y = 8
		if (4)
			I.pixel_y = -8
	return I



/obj/effect/stun_indicator/Destroy()
	for (var/client/C in viewers)
		C.images -= indicator
	..()

/obj/effect/stun_indicator/cultify()
	return

/obj/effect/stun_indicator/ex_act()
	return

/obj/effect/stun_indicator/emp_act()
	return

/obj/effect/stun_indicator/blob_act()
	return

/obj/effect/stun_indicator/singularity_act()
	return
