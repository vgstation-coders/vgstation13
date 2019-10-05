var/global/list/falltempoverlays = list()


/spell/aoe_turf/fall
	name = "Time Stop"
	desc = "This spell temporarily stops time for everybody around you, except for you. The spell lasts 3 seconds, and upgrading its power can further increase the duration."
	user_type = USER_TYPE_WIZARD
	specialization = UTILITY

	abbreviation = "MS"

	spell_flags = NEEDSCLOTHES

	selection_type = "range"
	school = "transmutation"
	charge_max = 500 // now 2min
	invocation = "OMNIA RUINAM"
	invocation_type = SpI_SHOUT
	range = 6
	cooldown_min = 200
	cooldown_reduc = 100
	level_max = list(Sp_TOTAL = 3, Sp_SPEED = 3, Sp_POWER = 3)
	hud_state = "wiz_timestop"
	var/image/aoe_underlay
	var/list/oureffects = list()
	var/list/affected = list()
	var/sleepfor
	var/the_world_chance = 30
	var/sleeptime = 30

#define duration_increase_per_level 10

/spell/aoe_turf/fall/empower_spell()
	if(!can_improve(Sp_POWER))
		return 0
	spell_levels[Sp_POWER]++
	range++
	sleeptime += duration_increase_per_level
	var/upgrade_desc = "Your control over time strengthens, you can now stop time for [sleeptime/10] second\s and in a radius of [range*2] meter\s."

	return upgrade_desc

/spell/aoe_turf/fall/get_upgrade_info(upgrade_type, level)
	if(upgrade_type == Sp_POWER)
		return "Increase the spell's duration by [duration_increase_per_level/10] second\s and radius by 2 meters."
	return ..()

#undef duration_increase_per_level

/spell/aoe_turf/fall/New()
	..()
	buildimage()

/spell/aoe_turf/fall/proc/buildimage()
	aoe_underlay = image(icon = 'icons/effects/640x640.dmi', icon_state = "fall", layer = DECAL_LAYER)
	aoe_underlay.plane = ABOVE_TURF_PLANE
	aoe_underlay.transform /= 50
	aoe_underlay.pixel_x = -304 * PIXEL_MULTIPLIER
	aoe_underlay.pixel_y = -304 * PIXEL_MULTIPLIER
	aoe_underlay.mouse_opacity = 0
/proc/CircleCoords(var/c_x, var/c_y, var/r)
	. = list()
	var/r_sqr = r*r
	var/x
	var/y
	var/i

	for(y = -r, y <= r, y++)
		x = round(sqrt(r_sqr - y*y))
		for(i = -x, i <= x, i++)
			. += "[x],[y]"

/spell/aoe_turf/fall/perform(mob/user = usr, skipcharge = 0, var/ignore_timeless = FALSE, var/ignore_path = null) //if recharge is started is important for the trigger spells
	if(!holder)
		set_holder(user) //just in case
	if(!cast_check(skipcharge, user))
		return
	if(cast_delay && !spell_do_after(user, cast_delay))
		return
	var/list/targets = choose_targets(user)
	if(targets && targets.len)
		if(prob(the_world_chance))
			invocation = "ZA WARUDO"
		invocation(user, targets)
		take_charge(user, skipcharge)

		targets = before_cast(targets, user)
		if(!targets.len)
			return
		user.attack_log += text("\[[time_stamp()]\] <font color='red'>[user.real_name] ([user.ckey]) cast the spell [name].</font>")
		if(prob(critfailchance))
			critfail(targets, user)
		else
			cast(targets, user, ignore_timeless, ignore_path)
		after_cast(targets) //generates the sparks, smoke, target messages etc.
		invocation = initial(invocation)

/spell/aoe_turf/fall/cast(list/targets, mob/user, var/ignore_timeless = FALSE, var/ignore_path)
	var/turf/ourturf = get_turf(user)

	var/list/potentials = circlerangeturfs(user, range)
	if(istype(potentials) && potentials.len)
		targets = potentials
	/*spawn(120)
		del(aoe_underlay)
		buildimage()*/
	spawn()
		for(var/client/C in clients)
			if(C.mob)
				C.mob.see_fall(ourturf, range)
		spawn(10)
			for(var/client/C in clients)
				if(C.mob)
					C.mob.see_fall()

	INVOKE_EVENT(user.on_spellcast, list("spell" = src, "target" = targets))

		//animate(aoe_underlay, transform = null, time = 2)
	//var/oursound = (invocation == "ZA WARUDO" ? 'sound/effects/theworld.ogg' :'sound/effects/fall.ogg')
	//playsound(user, oursound, 100, 0, 0, 0, 0)

	sleepfor = world.time + sleeptime
	for(var/turf/T in targets)
		
		oureffects += getFromPool(/obj/effect/stop/sleeping, T, sleepfor, user.mind, src, invocation == "ZA WARUDO", ignore_path)
		for(var/atom/movable/everything in T)
			if(isliving(everything))
				var/mob/living/L = everything
				if(ignore_path && istype(everything,ignore_path))
					continue
				if(L == holder)
					continue
				if(!ignore_timeless && L.flags & TIMELESS)
					continue
				affected += L
				invertcolor(L)
				spawn() recursive_timestop(L)
				L.playsound_local(L, 'sound/effects/theworld2.ogg', 100, 0, 0, 0, 0)
			else
				if(ignore_path && istype(everything,ignore_path))
					continue
				if(!ignore_timeless && everything.flags & TIMELESS)
					continue
				spawn() recursive_timestop(everything)
				if(everything.ignoreinvert)
					continue
				invertcolor(everything)
				affected += everything
			everything.timestopped = 1
		invertcolor(T)
		T.timestopped = 1

		affected += T
	return
	
/spell/aoe_turf/fall/proc/recursive_timestop(var/atom/O, var/ignore_timeless = FALSE)
	var/list/processing_list = list(O)
	var/list/processed_list = new/list()


	while (processing_list.len)
		var/atom/A = processing_list[1]

		affected |= A

		if(A != holder)
			if(ignore_timeless || !(A.flags & TIMELESS))
				A.timestopped = 1

		for (var/atom/B in A)
			if (!processed_list[B])
				processing_list |= B

		processing_list.Cut(1, 2)
		processed_list[A] = A

/spell/aoe_turf/fall/after_cast(list/targets)
	while(world.time < sleepfor)
		sleep(1)
	//animate(aoe_underlay, transform = aoe_underlay.transform / 50, time = 2)
	for(var/obj/effect/stop/sleeping/S in oureffects)
		returnToPool(S)
		oureffects -= S
	for(var/atom/everything in affected)
		everything.appearance = falltempoverlays[everything]
		falltempoverlays -= everything
		everything.ignoreinvert = initial(everything.ignoreinvert)
		everything.timestopped = 0
	affected.len = 0

/mob/var/image/fallimage

/mob/proc/see_fall(var/turf/T, range = 8)
	var/turf/T_mob = get_turf(src)
	if((!T || isnull(T)) && fallimage)
		animate(fallimage, transform = fallimage.transform / 50, time = 2)
		sleep(2)
		del(fallimage)
		return
	else if(T && T_mob && (T.z == T_mob.z) && (get_dist(T,T_mob) <= 15))// &&!(T in view(T_mob)))
		var/matrix/original
		if(!fallimage)
			fallimage = image(icon = 'icons/effects/640x640.dmi', icon_state = "fall", layer = DECAL_LAYER)
			fallimage.plane = ABOVE_TURF_PLANE
			original = fallimage.transform
			fallimage.transform /= 50
			fallimage.mouse_opacity = 0
		var/new_x = WORLD_ICON_SIZE * (T.x - T_mob.x) - (9.5*WORLD_ICON_SIZE)
		var/new_y = WORLD_ICON_SIZE * (T.y - T_mob.y) - (9.4*WORLD_ICON_SIZE)
		fallimage.pixel_x = new_x
		fallimage.pixel_y = new_y
		fallimage.loc = T_mob

		to_chat(src, fallimage)
		animate(fallimage, transform = original / (8/range), time = 3)

/proc/invertcolor(atom/A)
//	to_chat(world, "invert color start")
	if(A.ignoreinvert)
		return
	if(!falltempoverlays[A])
		falltempoverlays[A] = A.appearance

	A.color=	  list(-1,0,0,
						0,-1,0,
						0,0,-1,
						1,1,1)

/proc/timestop(atom/A, var/duration, var/range, var/ignore_timeless = FALSE, var/ignore_path = null)
	if(!A || !duration)
		return
	var/mob/caster = new
	var/spell/aoe_turf/fall/fall = new /spell/aoe_turf/fall
	caster.invisibility = 101
	caster.setDensity(FALSE)
	caster.anchored = 1
	caster.flags = INVULNERABLE
	caster.add_spell(fall)
	fall.spell_flags = 0
	fall.invocation_type = SpI_NONE
	fall.the_world_chance = 0
	fall.range = range ? range : 7		//how big
	fall.sleeptime = duration			//for how long
	caster.forceMove(get_turf(A))
	spawn()
		if(ignore_path)
			fall.perform(caster, skipcharge = 1, ignore_timeless = ignore_timeless, ignore_path = ignore_path)
		else
			fall.perform(caster, skipcharge = 1, ignore_timeless = ignore_timeless)
		