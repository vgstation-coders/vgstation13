
///////////////////////////////////////VISUAL EFFECTS//////////////////////////////////////////////

// Based on holopad rays. Causes a Shadow to move from T to C
// "sprite" var can be replaced to use another icon_state from icons/effects/96x96.dmi
/proc/shadow(var/atom/C,var/turf/T,var/sprite="rune_blind")
	var/disty = C.y - T.y
	var/distx = C.x - T.x
	var/newangle
	if(!disty)
		if(distx >= 0)
			newangle = 90
		else
			newangle = 270
	else
		newangle = arctan(distx/disty)
		if(disty < 0)
			newangle += 180
		else if(distx < 0)
			newangle += 360
	var/matrix/M1 = matrix()
	var/matrix/M2 = turn(M1.Scale(1,sqrt(distx*distx+disty*disty)),newangle)
	return anim(target = C, a_icon = 'icons/effects/96x96.dmi', flick_anim = sprite, lay = NARSIE_GLOW, offX = -WORLD_ICON_SIZE, offY = -WORLD_ICON_SIZE, plane = ABOVE_LIGHTING_PLANE, trans = M2)


///////////////////////////////////////CULT RITUALS////////////////////////////////////////////////
//Effects spawned by rune spells

/obj/effect/cult_ritual
	icon_state = ""
	anchored = 1

/obj/effect/cult_ritual/get_cult_power()
	return 1

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
	plane = ABOVE_LIGHTING_PLANE
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
		new /obj/effect/afterimage/red(T,user)
		user.forceMove(loc)
		sleep(1)
		new /obj/effect/afterimage/red(loc,user)
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


/obj/effect/afterimage
	icon = null
	icon_state = null
	anchored = 1
	mouse_opacity = 0
	var/image_color

/obj/effect/afterimage/red
	image_color = "red"

/obj/effect/afterimage/black
	image_color = "black"

/obj/effect/afterimage/New(var/turf/loc, var/atom/model, var/fadout = 5)
	..()
	if(model)
		src.appearance = model.appearance
		invisibility = 0
		alpha = 255
		dir = model.dir
		if (image_color)
			color = image_color
		layer = NARSIE_GLOW
		plane = ABOVE_LIGHTING_PLANE
	animate(src,alpha = 0, time = fadout)
	spawn(fadout)
		qdel(src)

/obj/effect/afterimage/cultify()
	return

/obj/effect/afterimage/ex_act()
	return

/obj/effect/afterimage/emp_act()
	return

/obj/effect/afterimage/blob_act()
	return

/obj/effect/afterimage/singularity_act()
	return


///////////////////////////////////////JAUNT////////////////////////////////////////////////
//Cultists ride in those when teleporting

/obj/effect/bloodcult_jaunt
	mouse_opacity = 0
	icon = 'icons/effects/96x96.dmi'
	icon_state ="cult_jaunt"
	invisibility = SEE_INVISIBLE_LEVEL_TWO
	alpha = 127
	layer = NARSIE_GLOW
	plane = ABOVE_LIGHTING_PLANE
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

	var/force_jaunt = FALSE

	var/failsafe = 100

/obj/effect/bloodcult_jaunt/New(var/turf/loc, var/mob/user, var/turf/destination, var/turf/packup, var/mob/activator)
	..()
	if (!user && !packup && !force_jaunt)
		qdel(src)
		return
	if (user)
		var/muted = FALSE
		if (user.anchored)
			to_chat(user, "<span class='warning'>The blood jaunt fails to grasp you as you are currently anchored.</span>")
		if (iscarbon(user))
			var/mob/living/carbon/C = user
			if (C.occult_muted())
				muted = TRUE
				to_chat(C, "<span class='warning'>The holy energies upon your body repel the blood jaunt.</span>")
		if (!muted && !user.anchored)
			user.forceMove(src)
			rider = user
			if (ismob(rider))
				var/mob/M = rider
				M.see_invisible = SEE_INVISIBLE_LEVEL_TWO
				M.see_invisible_override = SEE_INVISIBLE_LEVEL_TWO
				M.apply_vision_overrides()
				M.flags |= INVULNERABLE
	if (packup)
		var/list/noncult_victims = list()
		for (var/atom/movable/AM in packup)
			if (AM.anchored)
				if (ismob(AM))
					var/mob/M = AM
					to_chat(M, "<span class='warning'>The blood jaunt fails to grasp you as you are currently anchored.</span>")
				continue
			var/muted = FALSE
			if (iscarbon(AM))
				var/mob/living/carbon/C = AM
				if (C.occult_muted())
					muted = TRUE
					to_chat(C, "<span class='warning'>The holy energies upon your body repel the blood jaunt.</span>")
				if(!iscultist(C))
					noncult_victims += C
			if (!AM.anchored && !muted)
				AM.forceMove(src)
				packed.Add(AM)
				if (ismob(AM))
					var/mob/M = AM
					M.see_invisible = SEE_INVISIBLE_LEVEL_TWO
					M.see_invisible_override = SEE_INVISIBLE_LEVEL_TWO
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
	//calculating how many tiles we should have to cross so we can abort the jaunt if we go off-track
	failsafe = abs(starting.x - target.x) + abs(starting.y - target.y)
	//next, let's rotate the jaunter's sprite to face our destination
	init_angle()
	//now, let's launch the jaunter at our target
	init_jaunt()

/obj/effect/bloodcult_jaunt/Destroy()
	if (rider)
		QDEL_NULL(rider)
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
	var/transform_matrix = turn(matrix(),target_angle+45)
	transform = transform_matrix

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
	set waitfor = 0
	if (!rider && packed.len <= 0 && !force_jaunt)
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
	if (loc == target || failsafe <= 0)
		playsound(target, 'sound/effects/cultjaunt_land.ogg', 30, 0, -3)
		if (force_jaunt)
			playsound(target, 'sound/effects/convert_failure.ogg', 30, 0, -1)
		if (rider)
			rider.forceMove(target)
			if (ismob(rider))
				var/mob/M = rider
				M.flags &= ~INVULNERABLE
				M.see_invisible = SEE_INVISIBLE_LIVING
				var/jaunter = FALSE
				for (var/obj/effect/cult_ritual/seer/seer_ritual in seer_rituals)
					if (seer_ritual.caster == M)
						jaunter = TRUE
						break
				if (!jaunter)
					M.see_invisible_override = 0
					M.apply_vision_overrides()
				if (iscarbon(rider))
					var/mob/living/carbon/C = rider
					if (istype(C.handcuffed,/obj/item/weapon/handcuffs/cult))
						C.pain_shock_stage = max(C.pain_shock_stage, 100)
						to_chat(C,"<span class='danger'>Traveling through the veil seems to have a recharging effect on the ghastly bindings as they begin to hurt you anew.</span>")
			rider = null
		if (packed.len > 0)
			for(var/atom/movable/AM in packed)
				AM.forceMove(target)
				if (ismob(AM))
					var/mob/M = AM
					M.flags &= ~INVULNERABLE
					M.see_invisible = SEE_INVISIBLE_LIVING
					var/jaunter = FALSE
					for (var/obj/effect/cult_ritual/seer/seer_ritual in seer_rituals)
						if (seer_ritual.caster == M)
							jaunter = TRUE
							break
					if (!jaunter)
						M.see_invisible_override = 0
						M.apply_vision_overrides()
					if (iscarbon(AM))
						var/mob/living/carbon/C = AM
						if (istype(C.handcuffed,/obj/item/weapon/handcuffs/cult))
							C.pain_shock_stage = max(C.pain_shock_stage, 100)
							to_chat(C,"<span class='danger'>Traveling through the veil seems to have a recharging effect on the ghastly bindings as they begin to hurt you anew.</span>")
			packed = list()

		if (landing_animation)
			flick("cult_jaunt_land",landing_animation)
		qdel(src)

/obj/effect/bloodcult_jaunt/traitor
	invisibility = 0
	alpha = 200
	force_jaunt = TRUE

/obj/effect/bloodcult_jaunt/traitor/init_jaunt()
	animate(src, alpha = 0, time = 3)
	..()


///////////////////////////////////////BLOODSTONE DEFENSES////////////////////////////////////////////////

var/bloodstone_backup = 0

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
		var/mob/living/simple_animal/hostile/backup = new mobtype(get_turf(src))
		var/new_target = backup.FindTarget()
		backup.GiveTarget(new_target)
		backup.MoveToTarget()//no time to dilly dally
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
	if (isalien(victim))
		current_dots = clamp(round(victim.paralysis/2.5),0,5)
	else
		current_dots = clamp(round(victim.knockdown/2.5),0,5)

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
	while (victim && (victim.stat < DEAD) && (victim.knockdown || (isalien(victim) && victim.paralysis)))
		for (var/client/C in viewers)
			C.images -= indicator
		var/dots = clamp(1+round(victim.knockdown/2.5),1,6)
		if (isalien(victim))
			dots = clamp(1+round(victim.paralysis/2.5),1,6)
		var/anim = 0
		if (dots!=current_dots)
			anim = 1
			current_dots = dots
		indicator.overlays.len = 0
		indicator = image(icon='icons/obj/cult.dmi',loc=victim,icon_state="",layer=SNOW_OVERLAY_LAYER)
		indicator.plane = relative_plane(EFFECTS_PLANE)
		indicator.pixel_y = 8
		for (var/i = 1 to dots)
			var/state = "stun_dot1"
			if (current_dots == i)
				if (anim)
					state = "stun_dot2-flick"
					var/image/I = image(icon='icons/obj/cult.dmi',icon_state="stun_dot-gone")
					I.plane = relative_plane(EFFECTS_PLANE)
					I = place_indicator(I,i+1)
					indicator.overlays += I
				else
					state = "stun_dot2"
			var/image/I = image(icon='icons/obj/cult.dmi',icon_state=state)
			I.plane = relative_plane(EFFECTS_PLANE)
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
	indicator = null
	victim = null
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

/*
///////////////////////////////////OFFERINGS EFFECT////////////////////////////
/obj/effect/cult_offerings
	anchored = 1
	mouse_opacity = 0
	icon_state = "offerings"
*/

///////////////////////////////////THROWN DAGGER TRAP////////////////////////////

/obj/effect/rooting_trap/bloodnail
	name = "blood nail"
	desc = "A pointy red nail, appearing to pierce not through what it rests upon, but through the fabric of reality itself."
	icon_state = "bloodnail"

/obj/effect/rooting_trap/bloodnail/New()
	..()
	pixel_x = rand(-4, 4) * PIXEL_MULTIPLIER
	pixel_y = rand(-4, 4) * PIXEL_MULTIPLIER

/obj/effect/rooting_trap/bloodnail/stick_to(var/atom/A, var/side = null)
	pixel_x = rand(-4, 4) * PIXEL_MULTIPLIER
	pixel_y = rand(-4, 4) * PIXEL_MULTIPLIER
	playsound(A, 'sound/items/metal_impact.ogg', 30, 1)
	var/turf/T = get_turf(A)
	playsound(T, 'sound/weapons/hivehand_empty.ogg', 75, 1)
	. = ..()
	if (.)
		visible_message("<span class='warning'>\the [src] nails \the [A] to \the [T].</span>")

///////////////////////////////////CULT DANCE////////////////////////////////////
//used by the cultdance emote. other cult dances have their own procs
/obj/effect/cult_ritual/dance
	var/list/dancers = list()
	var/list/extras = list()
	var/datum/rune_spell/tearreality/tear

/obj/effect/cult_ritual/dance/New(var/turf/loc, var/mob/first_dancer)
	..()

	if (first_dancer)
		dancers += first_dancer
		we_can_dance()


/obj/effect/cult_ritual/dance/Destroy()
	dancers = list()
	tear = null
	for (var/obj/effect/cult_ritual/dance_platform/P in extras)
		P.dance_manager = null
	extras = list()
	..()

/obj/effect/cult_ritual/dance/proc/i_can_dance(var/mob/living/carbon/M)
	if (!M.incapacitated())
		return  TRUE
	else if (istype(M) && istype(M.handcuffed,/obj/item/weapon/handcuffs/cult)) //prisoners will be forced to dance even if incapacitated
		return TRUE
	return FALSE

/obj/effect/cult_ritual/dance/proc/we_can_dance()
	set waitfor = 0

	if (dancers.len <= 0)
		qdel(src)
		return

	if (tear)
		add_particles(PS_TEAR_REALITY)
		icon = 'icons/obj/cult.dmi'
		icon_state = "tear"
		while(src && loc)
			for (var/mob/M in dancers)
				if (get_dist(src,M) > 1 || !i_can_dance(M) || M.occult_muted())
					dancers -= M
					continue
			if ((dancers.len <= 0) && (tear.dance_count < tear.dance_target))
				qdel(src)
				return
			dance_move()
			sleep(3)
			dance_move()
			sleep(3)
			dance_move()
			if (tear.dance_count < tear.dance_target+10)
				adjust_particles(PVAR_SPAWNING, clamp(0.1 + 0.00375 * tear.dance_count,0.1,1), PS_TEAR_REALITY)
				var/scale = clamp(1 + 0.00416 * tear.dance_count,1,1.9)
				adjust_particles(PVAR_SCALE, list(scale, scale), PS_TEAR_REALITY)
			else
				remove_particles(PS_TEAR_REALITY)
			tear.update_crystals()
			sleep(6)
	else
		while(TRUE)
			for (var/mob/M in dancers)
				if (get_dist(src,M) > 1 || M.incapacitated() || M.occult_muted())
					dancers -= M
					continue
			if (dancers.len <= 0)
				qdel(src)
				return
			dance_step()
			sleep(3)
			dance_step()
			sleep(3)
			dance_step()
			sleep(6)

/obj/effect/cult_ritual/dance/proc/add_dancer(var/mob/dancer)
	if(dancer in dancers)
		return
	dancers += dancer

/obj/effect/cult_ritual/dance/proc/dance_step()
	var/dance_move = pick("clock","counter","spin")
	switch(dance_move)
		if ("clock")
			for (var/mob/M in dancers)
				INVOKE_EVENT(M, /event/before_move)
				switch (get_dir(src,M))
					if (NORTHWEST,NORTH)
						step_to(M, get_step(M,EAST))
					if (NORTHEAST,EAST)
						step_to(M, get_step(M,SOUTH))
					if (SOUTHEAST,SOUTH)
						step_to(M, get_step(M,WEST))
					if (SOUTHWEST,WEST)
						step_to(M, get_step(M,NORTH))
				INVOKE_EVENT(M, /event/after_move)
				INVOKE_EVENT(M, /event/moved, "mover" = M)
		if ("counter")
			for (var/mob/M in dancers)
				INVOKE_EVENT(M, /event/before_move)
				switch (get_dir(src,M))
					if (NORTHEAST,NORTH)
						step_to(M, get_step(M,WEST))
					if (SOUTHEAST,EAST)
						step_to(M, get_step(M,NORTH))
					if (SOUTHWEST,SOUTH)
						step_to(M, get_step(M,EAST))
					if (NORTHWEST,WEST)
						step_to(M, get_step(M,SOUTH))
				INVOKE_EVENT(M, /event/after_move)
				INVOKE_EVENT(M, /event/moved, "mover" = M)
		if ("spin")
			for (var/mob/M in dancers)
				spawn()
					M.dir = SOUTH
					INVOKE_EVENT(M, /event/face)
					sleep(0.75)
					M.dir = EAST
					INVOKE_EVENT(M, /event/face)
					sleep(0.75)
					M.dir = NORTH
					INVOKE_EVENT(M, /event/face)
					sleep(0.75)
					M.dir = WEST
					INVOKE_EVENT(M, /event/face)
					sleep(0.75)
					M.dir = SOUTH
					INVOKE_EVENT(M, /event/face)



/obj/effect/cult_ritual/dance/proc/dance_move()
	var/dance_move = pick("clock","counter","spin")
	switch(dance_move)
		if ("clock")
			for (var/obj/effect/cult_ritual/dance_platform/P in extras)
				P.moving = TRUE
			for (var/mob/M in dancers)
				INVOKE_EVENT(M, /event/before_move)
				switch (get_dir(src,M))
					if (NORTHWEST,NORTH)
						M.forceMove(get_step(M,EAST))
						M.dir = EAST
					if (NORTHEAST,EAST)
						M.forceMove(get_step(M,SOUTH))
						M.dir = SOUTH
					if (SOUTHEAST,SOUTH)
						M.forceMove(get_step(M,WEST))
						M.dir = WEST
					if (SOUTHWEST,WEST)
						M.forceMove(get_step(M,NORTH))
						M.dir = NORTH
				INVOKE_EVENT(M, /event/after_move)
				INVOKE_EVENT(M, /event/moved, "mover" = M)
			for (var/obj/effect/cult_ritual/dance_platform/P in extras)
				switch (get_dir(src,P))
					if (NORTHWEST,NORTH)
						step_to(P, get_step(P,EAST))
					if (NORTHEAST,EAST)
						step_to(P, get_step(P,SOUTH))
					if (SOUTHEAST,SOUTH)
						step_to(P, get_step(P,WEST))
					if (SOUTHWEST,WEST)
						step_to(P, get_step(P,NORTH))
				P.moving = FALSE
		if ("counter")
			for (var/obj/effect/cult_ritual/dance_platform/P in extras)
				P.moving = TRUE
			for (var/mob/M in dancers)
				INVOKE_EVENT(M, /event/before_move)
				switch (get_dir(src,M))
					if (NORTHEAST,NORTH)
						M.forceMove(get_step(M,WEST))
						M.dir = WEST
					if (SOUTHEAST,EAST)
						M.forceMove(get_step(M,NORTH))
						M.dir = NORTH
					if (SOUTHWEST,SOUTH)
						M.forceMove(get_step(M,EAST))
						M.dir = EAST
					if (NORTHWEST,WEST)
						M.forceMove(get_step(M,SOUTH))
						M.dir = SOUTH
				INVOKE_EVENT(M, /event/after_move)
				INVOKE_EVENT(M, /event/moved, "mover" = M)
			for (var/obj/effect/cult_ritual/dance_platform/P in extras)
				switch (get_dir(src,P))
					if (NORTHEAST,NORTH)
						step_to(P, get_step(P,WEST))
					if (SOUTHEAST,EAST)
						step_to(P, get_step(P,NORTH))
					if (SOUTHWEST,SOUTH)
						step_to(P, get_step(P,EAST))
					if (NORTHWEST,WEST)
						step_to(P, get_step(P,SOUTH))
				P.moving = FALSE
		if ("spin")
			for (var/mob/M in dancers)
				spawn()
					M.dir = SOUTH
					INVOKE_EVENT(M, /event/face)
					sleep(0.75)
					M.dir = EAST
					INVOKE_EVENT(M, /event/face)
					sleep(0.75)
					M.dir = NORTH
					INVOKE_EVENT(M, /event/face)
					sleep(0.75)
					M.dir = WEST
					INVOKE_EVENT(M, /event/face)
					sleep(0.75)
					M.dir = SOUTH
					INVOKE_EVENT(M, /event/face)

///////////////////////////////////DANCE PLATEFORMS////////////////////////////////////
//Tear Reality rune uses those

var/list/dance_platform_prisoners = list()

/obj/effect/cult_ritual/dance_platform
	anchored = 1
	icon = 'icons/obj/cult.dmi'
	icon_state = "blank"
	layer = ABOVE_OBJ_LAYER
	plane = OBJ_PLANE
	alpha = 0
	var/moving = FALSE
	var/mob/living/dancer = null
	var/datum/rune_spell/tearreality/source = null
	var/prisoner = FALSE
	var/obj/effect/cult_ritual/dance/dance_manager

/obj/effect/cult_ritual/dance_platform/New(var/turf/loc, var/datum/rune_spell/tearreality/runespell)
	..()
	if (!runespell)
		qdel(src)
		return

	var/image/I_circle = image(icon, src, "dance_platform_empty")
	I_circle.plane = relative_plane(ABOVE_TURF_PLANE)
	I_circle.layer = ABOVE_TILE_LAYER
	I_circle.appearance_flags |= RESET_COLOR
	overlays += I_circle
	transform *= 0.3
	source = runespell
	processing_objects += src
	idle_pulse()

	spawn(5)
		animate(src, alpha = 255, transform = matrix(), time = 4)

/obj/effect/cult_ritual/dance_platform/Destroy()
	if (dancer && prisoner)
		dancer.SetStunned(-4)
	dancer = null
	source = null
	dance_manager = null
	processing_objects -= src
	..()

/obj/effect/cult_ritual/dance_platform/process()
	if (dancer && prisoner)
		dancer.SetStunned(4)

	if (dancer)
		if (dancer.loc != loc)
			dancer = null
			source.lost_dancer()
			prisoner = FALSE
			overlays.len = 0
			var/image/I_circle = image(icon, src, "dance_platform_empty")
			I_circle.plane = relative_plane(ABOVE_TURF_PLANE)
			I_circle.layer = ABOVE_TILE_LAYER
			I_circle.appearance_flags |= RESET_COLOR
			overlays += I_circle
		else
			source.dance_increment(dancer)
	else
		for (var/mob/living/carbon/C in loc)
			if (valid_dancer(C))
				break

/obj/effect/cult_ritual/dance_platform/Crossed(var/atom/movable/mover)
	valid_dancer(mover)

/obj/effect/cult_ritual/dance_platform/proc/valid_dancer(var/atom/movable/mover)
	if (!dancer && !moving)
		if (iscarbon(mover))
			var/mob/living/carbon/C = mover
			if (C.mind && !C.isDead())
				if (iscultist(C))
					dancer = C
					overlays.len = 0
					var/image/I_circle = image(icon, src, "dance_platform_full")
					I_circle.plane = relative_plane(ABOVE_TURF_PLANE)
					I_circle.layer = ABOVE_TILE_LAYER
					I_circle.appearance_flags |= RESET_COLOR
					var/image/I_markings = image(icon, src,"dance_platform_markings")
					I_markings.plane = relative_plane(OBJ_PLANE)
					I_markings.layer = BELOW_TABLE_LAYER
					overlays += I_circle
					overlays += I_markings
					source.dancer_check(C)
					return TRUE
				else
					if (istype(C.handcuffed,/obj/item/weapon/handcuffs/cult))
						dancer = C
						prisoner = TRUE
						dancer.SetStunned(4)
						overlays.len = 0
						var/image/I_circle = image(icon, src, "dance_platform_full")
						I_circle.plane = relative_plane(ABOVE_TURF_PLANE)
						I_circle.layer = ABOVE_TILE_LAYER
						I_circle.appearance_flags |= RESET_COLOR
						var/image/I_markings = image(icon, src,"dance_platform_markings")
						I_markings.plane = relative_plane(OBJ_PLANE)
						I_markings.layer = BELOW_TABLE_LAYER
						overlays += I_circle
						overlays += I_markings
						var/image/I = image('icons/obj/cult.dmi', src, "dance_prisoner")
						I.plane = relative_plane(ABOVE_LIGHTING_PLANE)
						I.layer = NARSIE_GLOW
						overlays += I
						var/mob_ref = "\ref[C]"
						if (!(mob_ref in dance_platform_prisoners))//prevents chat spamming by dragging the prisoner across all the dance platforms
							dance_platform_prisoners += mob_ref
							to_chat(C, "<span class='danger'>Dark tentacles emerge from the rune and trap your legs in place. The occult bindings on your arms seem to react to them. You will need to resist out of those or get some outside help if you are to escape this circle.</span>")
							spawn(20 SECONDS)
								dance_platform_prisoners -= mob_ref
						source.dancer_check(C)
						return TRUE
		else if (isshade(mover) || isconstruct(mover))
			var/mob/living/simple_animal/SA = mover
			if (SA.mind && !SA.isDead())
				if (iscultist(SA))
					dancer = SA
					overlays.len = 0
					var/image/I_circle = image(icon, src, "dance_platform_full")
					I_circle.plane = relative_plane(ABOVE_TURF_PLANE)
					I_circle.layer = ABOVE_TILE_LAYER
					I_circle.appearance_flags |= RESET_COLOR
					var/image/I_markings = image(icon, src,"dance_platform_markings")
					I_markings.plane = relative_plane(OBJ_PLANE)
					I_markings.layer = BELOW_TABLE_LAYER
					overlays += I_circle
					overlays += I_markings
					source.dancer_check(SA)
					return TRUE
	return FALSE

/obj/effect/cult_ritual/dance_platform/Uncrossed(var/atom/movable/mover)
	if (!moving && dancer && mover == dancer)
		overlays.len = 0
		var/image/I_circle = image(icon, src, "dance_platform_empty")
		I_circle.plane = relative_plane(ABOVE_TURF_PLANE)
		I_circle.layer = ABOVE_TILE_LAYER
		I_circle.appearance_flags |= RESET_COLOR
		overlays += I_circle
		if (prisoner)
			dancer.SetStunned(0)
			prisoner = FALSE
			anim(target = loc, a_icon = 'icons/obj/cult.dmi', flick_anim = "dancer_prisoner-stop", lay = NARSIE_GLOW, plane = ABOVE_LIGHTING_PLANE)
		if (dance_manager)
			dance_manager.dancers -= dancer
		dancer = null
		source.lost_dancer()

/obj/structure/dance_check
	icon = 'icons/effects/effects.dmi'
	icon_state = "blank"
	density = 0
	mouse_opacity = 0
	invisibility = 101
	var/datum/rune_spell/tearreality/source

/obj/structure/dance_check/New(turf/loc, var/_source)
	..()
	if (_source)
		source = _source
	else
		qdel(src)

/obj/structure/dance_check/to_bump(var/atom/A)
	source.blocker = A//So we can tell the rune's activator exactly what is blocking the dance path


///////////////////////////////////TEAR SPAWNERS////////////////////////////////////
//Used by the tear reality rune to spawn obsidian pillars and gateways across the station
/obj/effect/cult_ritual/tear_spawners
	icon = 'icons/effects/effects.dmi'
	icon_state = "blank"
	density = 0
	mouse_opacity = 0
	invisibility = 101
	var/datum/rune_spell/tearreality/source = null
	var/finished = FALSE
	var/direction = 0
	var/steps = 0

	var/near_turfs = list()
	var/far_turfs = list()

/obj/effect/cult_ritual/tear_spawners/New(turf/loc, var/datum/rune_spell/tearreality/_source)
	if (!_source)
		qdel(src)
		return
	source = _source
	if (source.destroying_self)
		qdel(src)
		return
	..()
	if (!finished)
		start_loop()

/obj/effect/cult_ritual/tear_spawners/Destroy()
	source = null
	..()

/obj/effect/cult_ritual/tear_spawners/proc/perform_step()
	move_step()
	after_step()

/obj/effect/cult_ritual/tear_spawners/proc/start_loop()
	set waitfor = 0
	spawn()
		while(!finished && direction)
			perform_step()
			sleep(1)

/obj/effect/cult_ritual/tear_spawners/proc/execute(var/level)
	return
/obj/effect/cult_ritual/tear_spawners/proc/after_step()
	return
/obj/effect/cult_ritual/tear_spawners/proc/move_step()
	switch(direction)
		if (SOUTH)
			y--
			if (y <= TRANSITIONEDGE)
				finished = TRUE
				qdel(src)
				return
		if (NORTH)
			y++
			if (y >= (world.maxy - TRANSITIONEDGE))
				finished = TRUE
				qdel(src)
		if (EAST)
			x++
			if (x >= (world.maxx - TRANSITIONEDGE))
				finished = TRUE
				qdel(src)
		if (WEST)
			x--
			if (x <= TRANSITIONEDGE)
				finished = TRUE
				qdel(src)
				return

	steps++

/obj/effect/cult_ritual/tear_spawners/vertical_spawner
	direction = SOUTH
	var/steps_to_pillars_and_gateways = 16
	var/steps_to_pillars = 8

	var/ready_to_spawn_pillars_and_gateways = FALSE

/obj/effect/cult_ritual/tear_spawners/vertical_spawner/after_step()
	if (steps == steps_to_pillars)
		new /obj/effect/cult_ritual/tear_spawners/horizontal_spawner/alt/left(loc,source)
		new /obj/effect/cult_ritual/tear_spawners/horizontal_spawner/alt/right(loc,source)
	if (steps == steps_to_pillars_and_gateways)
		new /obj/effect/cult_ritual/tear_spawners/horizontal_spawner/left(loc,source)
		new /obj/effect/cult_ritual/tear_spawners/horizontal_spawner/right(loc,source)
		ready_to_spawn_pillars_and_gateways = TRUE
		steps = 0

	if (ready_to_spawn_pillars_and_gateways)
		if (isfloor(loc))
			new /obj/effect/cult_ritual/tear_spawners/gateway_spawner/special(loc, source)
			ready_to_spawn_pillars_and_gateways = FALSE

/obj/effect/cult_ritual/tear_spawners/vertical_spawner/up
	direction = NORTH

/obj/effect/cult_ritual/tear_spawners/horizontal_spawner
	var/steps_to_spire = 8
	var/steps_to_gateway = 15
	var/also_spawn_gateways = TRUE

	var/ready_to_spawn_pillar = FALSE
	var/ready_to_spawn_gateway = FALSE

/obj/effect/cult_ritual/tear_spawners/horizontal_spawner/after_step()
	if (steps == steps_to_spire)
		ready_to_spawn_pillar = TRUE
	if (also_spawn_gateways && steps == steps_to_gateway)
		ready_to_spawn_gateway = TRUE
	if (steps == (2*steps_to_spire))
		ready_to_spawn_pillar = TRUE
		steps = 0

	if (ready_to_spawn_pillar)
		if (isfloor(loc))
			new /obj/effect/cult_ritual/tear_spawners/pillar_spawner(loc, source, direction)
			ready_to_spawn_pillar = FALSE

	if (ready_to_spawn_gateway)
		if (isfloor(loc))
			new /obj/effect/cult_ritual/tear_spawners/gateway_spawner(loc, source)
			ready_to_spawn_gateway = FALSE

/obj/effect/cult_ritual/tear_spawners/horizontal_spawner/alt
	steps = 4
	also_spawn_gateways = FALSE

/obj/effect/cult_ritual/tear_spawners/horizontal_spawner/left
	direction = WEST

/obj/effect/cult_ritual/tear_spawners/horizontal_spawner/right
	direction = EAST

/obj/effect/cult_ritual/tear_spawners/horizontal_spawner/alt/left
	direction = WEST

/obj/effect/cult_ritual/tear_spawners/horizontal_spawner/alt/right
	direction = EAST

/obj/effect/cult_ritual/tear_spawners/pillar_spawner
	finished = TRUE
	var/obj/structure/cult/pillar

/obj/effect/cult_ritual/tear_spawners/pillar_spawner/New(turf/loc, var/datum/rune_spell/tearreality/_source, var/_direction)
	if (!_direction)
		qdel(src)
		return
	..()
	if (source)
		source.pillar_spawners += src
	direction = _direction

	for(var/direc in cardinal)
		var/turf/T = get_step(src, direc)
		near_turfs += T
		var/turf/U = get_step(T, direc)
		far_turfs += U

	for(var/direc in diagonal)
		var/turf/T = get_step(src, direc)
		far_turfs += T

/obj/effect/cult_ritual/tear_spawners/pillar_spawner/move_step()
	return

/obj/effect/cult_ritual/tear_spawners/pillar_spawner/execute(var/level)
	switch(level)
		if (1)
			var/turf/T = loc
			if (T && !T.holy)
				T.cultify()
		if (2)
			var/turf/T = loc
			if (T && !T.holy)
				switch(direction)
					if (EAST)
						pillar = new /obj/structure/cult/pillar/alt(loc)
					if (WEST)
						pillar = new /obj/structure/cult/pillar(loc)
			for (var/turf/U in near_turfs)
				if (!U.holy)
					U.cultify()
		if (3)
			if (pillar)
				pillar.update_icon()
			for (var/turf/T in far_turfs)
				if (!T.holy)
					T.cultify()

/obj/effect/cult_ritual/tear_spawners/pillar_spawner/proc/cancel()
	if (!pillar)
		qdel(src)
		return
	spawn(rand(1 SECONDS, 5 SECONDS))
		if (pillar)
			pillar.takeDamage(100)
		for (var/turf/T in far_turfs)
			T.decultify()
		sleep(rand(10 SECONDS, 20 SECONDS))
		if (pillar)
			pillar.takeDamage(100)
		for (var/turf/T in near_turfs)
			T.decultify()
		sleep(rand(20 SECONDS, 30 SECONDS))
		var/turf/T = loc
		T.decultify()

/obj/effect/cult_ritual/tear_spawners/gateway_spawner
	finished = TRUE

/obj/effect/cult_ritual/tear_spawners/gateway_spawner/New(turf/loc, var/datum/rune_spell/tearreality/_source)
	..()
	source?.gateway_spawners += src

	for(var/direc in cardinal)
		var/turf/T = get_step(src, direc)
		near_turfs += T
		var/turf/U = get_step(T, direc)
		far_turfs += U

	for(var/direc in diagonal)
		var/turf/T = get_step(src, direc)
		far_turfs += T

/obj/effect/cult_ritual/tear_spawners/gateway_spawner/move_step()
	return

/obj/effect/cult_ritual/tear_spawners/gateway_spawner/special
	finished = FALSE

/obj/effect/cult_ritual/tear_spawners/gateway_spawner/special/start_loop()
	spawn()
		x++
		if (isfloor(loc))
			new /obj/effect/cult_ritual/tear_spawners/pillar_spawner(loc, source, EAST)
		sleep(1)
		x -= 2
		if (isfloor(loc))
			new /obj/effect/cult_ritual/tear_spawners/pillar_spawner(loc, source, WEST)
		sleep(1)
		x++
	finished = TRUE

/obj/effect/cult_ritual/tear_spawners/gateway_spawner/execute(var/level)
	if (level == 3)
		var/turf/T = loc
		if (T && !T.holy)
			new /obj/effect/gateway/active/cult(loc)
