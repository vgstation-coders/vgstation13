//Immovable rod

//Passes through the station destroyed all dense objects and damage all dense turfs
//As well as hurting all dense mobs
//Recoded as a projectile for better movement/appearance

var/list/all_rods = list()

/datum/event/immovable_rod
	announceWhen = 1

/datum/event/immovable_rod/can_start(var/list/active_with_role)
	if(active_with_role["Engineer"] > 1)
		return 15
	return 0

/datum/event/immovable_rod/big/can_start(var/list/active_with_role)
	if(active_with_role["Engineer"] > 2)
		return 15
	return 0

/datum/event/immovable_rod/hyper/can_start(var/list/active_with_role)
	return 0

/datum/event/immovable_rod/announce()
	command_alert(/datum/command_alert/immovable_rod)

/datum/event/immovable_rod/start()
	immovablerod()
/datum/event/immovable_rod/big/start()
	immovablerod(1)
/datum/event/immovable_rod/hyper/start()
	immovablerod(2)

/proc/immovablerod(var/rodlevel = 0)
	var/obj/item/projectile/immovablerod/myrod
	switch(rodlevel)
		if(0)
			myrod = new /obj/item/projectile/immovablerod(locate(1,1,1))
		if(1)
			myrod = new /obj/item/projectile/immovablerod/big(locate(1,1,1))
		if(2)
			myrod = new /obj/item/projectile/immovablerod/hyper(locate(1,1,1))

	myrod.starting = myrod.loc
	myrod.ThrowAtStation()

/obj/item/projectile/immovablerod
	name = "\improper Immovable Rod"
	desc = "What the fuck is that?"
	icon = 'icons/obj/objects.dmi'
	icon_state = "immrod"
	throwforce = 100
	density = 1
	anchored = 1
	grillepasschance = 0
	mouse_opacity = 1
	projectile_speed = 1.33
	var/clongSound = 'sound/effects/bang.ogg'

/obj/item/projectile/immovablerod/big
	name = "\improper Immovable Pillar"
	icon = 'icons/obj/objects_64x64.dmi'
	pixel_x = -16
	pixel_y = -16
	clongSound = 'sound/effects/immovablerod_clong.ogg'

/obj/item/projectile/immovablerod/hyper
	name = "\improper Immovable Monolith"
	icon = 'icons/obj/objects_96x96.dmi'
	pixel_x = -32
	pixel_y = -32
	lock_angle = 1
	clongSound = 'sound/effects/immovablerod_clong.ogg'

/obj/item/projectile/immovablerod/New()
	all_rods += src
	..()

/obj/item/projectile/immovablerod/Destroy()
	all_rods -= src
	..()

/obj/item/projectile/immovablerod/hyper/New()
	..()
	var/image/I = image('icons/obj/objects_96x96.dmi',"immrod_bottom")
	I.plane = relative_plane(PLATING_PLANE-1)
	overlays += I

/obj/item/projectile/immovablerod/throw_at(atom/end)
	for(var/mob/dead/observer/people in observers)
		to_chat(people, "<span class = 'notice'>\A [src] has been thrown at the station, <a href='?src=\ref[people];follow=\ref[src]'>Follow it</a></span>")
	original = end
	starting = loc
	current = loc
	OnFired()
	yo = target.y - y
	xo = target.x - x
	process()

/obj/item/projectile/immovablerod/ex_act()
	return

/obj/item/projectile/immovablerod/singularity_act(size,var/obj/machinery/singularity/singularity)
	singularity.expand(STAGE_FIVE) //An unstoppable object must have crazy mass, also seriously what are the chances of this
	qdel(src)

/obj/item/projectile/immovablerod/bresenham_step(var/distA, var/distB, var/dA, var/dB)
	if(error < 0)
		var/atom/newloc = get_step(src, dB)
		if(!newloc)
			bullet_die()
		forceMove(newloc)
		error += distA
		return 0//so that bullets going in diagonals don't move twice slower
	else
		var/atom/newloc = get_step(src, dA)
		if(!newloc)
			bullet_die()
		forceMove(newloc)
		error -= distB
		return 1

/obj/item/projectile/immovablerod/proc/break_stuff()
	if(loc.density)
		loc.ex_act(2)
		if(prob(25))
			clong()

/obj/item/projectile/immovablerod/big/break_stuff()
	if(loc && !istype(loc,/turf/space))
		if(loc.density)
			loc.ex_act(2)
		else
			loc.ex_act(3)
			if(istype(loc,/turf/simulated/floor))
				var/turf/simulated/floor/under = loc
				under.break_tile_to_plating()

		for(var/turf/T in orange(loc,1))
			T.ex_act(3)

		if(prob(50))
			clong()

/obj/item/projectile/immovablerod/hyper/break_stuff()
	if(loc && !istype(loc,/turf/space))
		loc.ex_act(1)
		for(var/turf/T in orange(loc,1))
			if(prob(50))
				if(istype(T,/turf/simulated/floor))
					var/turf/simulated/floor/under = T
					under.break_tile_to_plating()
				else
					T.ex_act(3)
			else
				T.ex_act(3)

		for(var/turf/T in orange(loc,2))
			if(prob(50))
				T.ex_act(3)
			else
				T.add_dust()

		if(prob(50))
			clong()

/obj/item/projectile/immovablerod/forceMove(atom/NewLoc, Dir = 0, step_x = 0, step_y = 0, glide_size_override = 0, from_tp = 0)
	..()
	if(z != starting.z)
		qdel(src)
		return

	break_stuff()

	for(var/atom/clong in loc)
		if(!clong.density)
			continue

		if(istype(clong, /obj))
			if(clong.density)
				clong.ex_act(1)

		else if(istype(clong, /mob))
			if(istype(clong, /mob/living/carbon/human))
				var/mob/living/carbon/human/H = clong
				H.visible_message("<span class='danger'>[H.name] is penetrated by an immovable rod!</span>" , "<span class='userdanger'>The rod penetrates you!</span>" , "<span class ='danger'>You hear a CLANG!</span>")
				H.gib()
			else if(clong.density || (istype(clong,/mob/living) && prob(10))) //Only 1 Ian was harmed in the coding of this object, RIP
				clong.visible_message("<span class='danger'>[clong] is scraped by an immovable rod!</span>" , "<span class='userdanger'>The rod scrapes part of you off!</span>" , "<span class ='danger'>You hear a CLANG!</span>")
				clong.ex_act(2)

		if(prob(25) && (!clong || !clong.density || clong.gcDestroyed)) //did we just clear some shit?
			clong()

/obj/item/projectile/immovablerod/proc/clong()
	for (var/mob/M in range(loc,20))
		to_chat(M,"<FONT size=[max(0, 5 - round(get_dist(src, M)/4))]>CLANG!</FONT>")
		M.playsound_local(loc, clongSound, 100 - (get_dist(src,M)*5), 1)

/proc/random_start_turf(var/z)
	var/startx
	var/starty
	var/chosen_dir = pick(NORTH, SOUTH, EAST, WEST)

	switch(chosen_dir)

		if(NORTH) //North, along the y = max edge
			starty = world.maxy - (TRANSITIONEDGE + 2)
			startx = rand((TRANSITIONEDGE + 2), world.maxx - (TRANSITIONEDGE + 2))

		if(SOUTH) //South, along the y = 0 edge
			starty = (TRANSITIONEDGE + 2)
			startx = rand((TRANSITIONEDGE + 2), world.maxx - (TRANSITIONEDGE + 2))

		if(EAST) //East, along the x = max edge
			starty = rand((TRANSITIONEDGE + 2), world.maxy - (TRANSITIONEDGE + 2))
			startx = world.maxx - (TRANSITIONEDGE + 2)

		if(WEST) //West, along the x = 0 edge
			starty = rand((TRANSITIONEDGE + 2), world.maxy - (TRANSITIONEDGE + 2))
			startx = (TRANSITIONEDGE + 2)

	var/turf/T = locate(startx, starty, z)
	return T
