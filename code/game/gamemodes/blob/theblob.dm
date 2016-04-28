//I will need to recode parts of this but I am way too tired atm
/obj/effect/blob
	name = "blob"
	icon = 'icons/mob/blob_64x64.dmi'
	icon_state = "center"
	luminosity = 2
	desc = "Some blob creature thingy"
	density = 0
	opacity = 0
	anchored = 1
	penetration_dampening = 17
	var/health = 20
	var/maxhealth = 20
	var/health_timestamp = 0
	var/brute_resist = 4
	var/fire_resist = 1
	pixel_x = -16
	pixel_y = -16
	layer = 6
	var/spawning = 2
	var/dying = 0

	// A note to the beam processing shit.
	var/custom_process=0

	var/time_since_last_pulse

/obj/effect/blob/blob_act()
	return

/obj/effect/blob/New(loc)
	blobs += src
	if(istype(ticker.mode,/datum/game_mode/blob))
		var/datum/game_mode/blob/blobmode = ticker.mode
		if((blobs.len >= blobmode.blobnukeposs) && prob(3) && !blobmode.nuclear)
			blobmode.stage(2)
			blobmode.nuclear = 1
	src.dir = pick(cardinal)
	time_since_last_pulse = world.time
	if(spawning)
		icon_state = initial(icon_state) + "_spawn"
		spawn(10)
			spawning = 0//for sprites
			icon_state = initial(icon_state)
			src.update_icon(1)
	else
		update_icon()
	..(loc)
	for(var/atom/A in loc)
		A.blob_act()
	return

/obj/effect/blob/proc/aftermove()
	for(var/obj/effect/blob/B in loc)
		if(B != src)
			qdel(src)
			return
	update_icon()
	for(var/obj/effect/blob/B in orange(src,1))
		B.update_icon()


/obj/effect/blob/Destroy()
	dying = 1
	blobs -= src
	for(var/atom/movable/overlay/O in loc)
		returnToPool(O)

	for(var/obj/effect/blob/B in orange(loc,1))
		B.update_icon()
		if(!spawning)
			anim(target = B.loc, a_icon = 'icons/mob/blob_64x64.dmi', flick_anim = "connect_die", sleeptime = 50, direction = get_dir(B,src), lay = layer+0.3, offX = -16, offY = -16, col = "red")

	..()

/obj/effect/blob/projectile_check()
	return PROJREACT_BLOB

/obj/effect/blob/CanPass(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	if(air_group || (height==0))	return 1
	if(istype(mover) && mover.checkpass(PASSBLOB))	return 1
	return 0

/obj/effect/blob/beam_connect(var/obj/effect/beam/B)
	..()
	last_beamchecks["\ref[B]"]=world.time+1
	apply_beam_damage(B) // Contact damage for larger beams (deals 1/10th second of damage)
	if(!custom_process && !(src in processing_objects))
		processing_objects.Add(src)


/obj/effect/blob/beam_disconnect(var/obj/effect/beam/B)
	..()
	apply_beam_damage(B)
	last_beamchecks.Remove("\ref[B]") // RIP
	update_health()
	update_icon()
	if(beams.len == 0)
		if(!custom_process && src in processing_objects)
			processing_objects.Remove(src)

/obj/effect/blob/apply_beam_damage(var/obj/effect/beam/B)
	var/lastcheck=last_beamchecks["\ref[B]"]

	// Standard damage formula / 2
	var/damage = ((world.time - lastcheck)/10)  * (B.get_damage() / 2)

	// Actually apply damage
	health -= damage

	// Update check time.
	last_beamchecks["\ref[B]"]=world.time

/obj/effect/blob/handle_beams()
	// New beam damage code (per-tick)
	for(var/obj/effect/beam/B in beams)
		apply_beam_damage(B)
	update_health()
	update_icon()

/obj/effect/blob/process()
	handle_beams()
	Life()
	return

/obj/effect/blob/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	..()
	var/damage = Clamp(0.01 * exposed_temperature / fire_resist, 0, 4 - fire_resist)
	if(damage)
		health -= damage
		update_health()
		update_icon()

/obj/effect/blob/proc/Life()
	return


/obj/effect/blob/proc/Pulse(var/pulse = 0, var/origin_dir = 0)//Todo: Fix spaceblob expand
	/*
	if(time_since_last_pulse >= world.time)
		return
	*/
	time_since_last_pulse = world.time

	//set background = 1

	for(var/mob/M in loc)
		M.blob_act()

	if(run_action())//If we can do something here then we dont need to pulse more
		return

	if(pulse > 30)
		return//Inf loop check

	//Looking for another blob to pulse
	var/list/dirs = cardinal.Copy()
	dirs.Remove(origin_dir)//Dont pulse the guy who pulsed us
	for(var/i in 1 to 4)
		if(!dirs.len)	break
		var/dirn = pick_n_take(dirs)
		var/turf/T = get_step(src, dirn)
		var/obj/effect/blob/B = locate() in T
		if(!B)
			expand(T)//No blob here so try and expand
			return
		spawn(2)
			B.Pulse((pulse+1),get_dir(src.loc,T))
		return
	return


/obj/effect/blob/proc/run_action()
	return 0


/obj/effect/blob/proc/expand(var/turf/T = null, var/prob = 1)
	if(prob && !prob(health))
		return
	if(istype(T, /turf/space) && prob(75))
		return
	if(!T)
		var/list/dirs = cardinal.Copy()
		for(var/i in 1 to 4)
			var/dirn = pick_n_take(dirs)
			T = get_step(src, dirn)
			if(!(locate(/obj/effect/blob) in T))	break
			else	T = null

	if(!T)	return 0
	var/obj/effect/blob/normal/B = new(src.loc, min(src.health, 30))
	B.density = 1
	if(istype(src,/obj/effect/blob/normal))
		var/num = rand(1,100)
		num /= 10000
		B.layer = layer - num
	if(T.Enter(B,src))//Attempt to move into the tile
		B.density = initial(B.density)
		spawn(1)
			B.forceMove(T)
			B.aftermove()
			if(B.spawning > 1)
				B.spawning = 1
	else
		T.blob_act()//If we cant move in hit the turf
		B.Delete()

	for(var/atom/A in T)//Hit everything in the turf
		A.blob_act()
	return 1


/obj/effect/blob/ex_act(severity)
	var/damage = 150
	health -= ((damage/brute_resist) - (severity * 5))
	update_health()
	update_icon()
	return


/obj/effect/blob/bullet_act(var/obj/item/projectile/Proj)
	..()
	switch(Proj.damage_type)
		if(BRUTE)
			health -= (Proj.damage/brute_resist)
		if(BURN)
			health -= (Proj.damage/fire_resist)

	update_health()
	update_icon()
	return 0


/obj/effect/blob/attackby(var/obj/item/weapon/W, var/mob/user)
	user.delayNextAttack(10)
	playsound(get_turf(src), 'sound/effects/attackblob.ogg', 50, 1)
	src.visible_message("<span class='warning'><B>The [src.name] has been attacked with \the [W][(user ? " by [user]." : ".")]</span>")
	var/damage = 0
	switch(W.damtype)
		if("fire")
			damage = (W.force / max(src.fire_resist,1))
			if(istype(W, /obj/item/weapon/weldingtool) || istype(W, /obj/item/weapon/pickaxe/plasmacutter))
				playsound(get_turf(src), 'sound/effects/blobweld.ogg', 100, 1)
		if("brute")
			damage = (W.force / max(src.brute_resist,1))

	health -= damage
	update_health()
	update_icon()
	return

/obj/effect/blob/proc/change_to(var/type, var/mob/camera/blob/M = null)
	if(!ispath(type))
		error("[type] is an invalid type for the blob.")
	if("[type]" == "/obj/effect/blob/core")
		new type(src.loc, 200, null, 1, M)
	else
		new type(src.loc)
	spawning = 1//so we don't show red severed connections
	Delete()
	return

/obj/effect/blob/proc/Delete()
	qdel(src)

/obj/effect/blob/normal
	luminosity = 2
	health = 21

/obj/effect/blob/normal/Delete()
	..()

/obj/effect/blob/normal/Pulse(var/pulse = 0, var/origin_dir = 0)
	..()
	anim(target = loc, a_icon = 'icons/mob/blob_64x64.dmi', flick_anim = "pulse", sleeptime = 15, lay = 12, offX = -16, offY = -16, alph = 51)


/obj/effect/blob/normal/update_icon(var/spawnend = 0)
	spawn(1)
		overlays.len = 0

		overlays += image(icon,"roots", layer = 3)

		if(!spawning)
			for(var/obj/effect/blob/B in orange(src,1))
				if(B.spawning == 1)
					anim(target = loc, a_icon = 'icons/mob/blob_64x64.dmi', flick_anim = "connect_spawn", sleeptime = 15, direction = get_dir(src,B), lay = layer+0.1, offX = -16, offY = -16)
					spawn(8)
						update_icon()
				else if(!B.dying && !B.spawning)
					if(spawnend)
						anim(target = loc, a_icon = 'icons/mob/blob_64x64.dmi', flick_anim = "connect_spawn", sleeptime = 15, direction = get_dir(src,B), lay = layer+0.1, offX = -16, offY = -16)
					else

						if(istype(B,/obj/effect/blob/core))
							overlays += image(icon,"connect",dir = get_dir(src,B), layer = layer)
						else
							var/num = rand(1,100)
							num /= 10000
							overlays += image(icon,"connect",dir = get_dir(src,B), layer = layer+0.1-num)

		if(spawnend)
			spawn(10)
				update_icon()

		..()

/obj/effect/blob/update_icon(var/spawnend = 0)
	if(health < maxhealth)
		var/hurt_percentage = round((health * 100) / maxhealth)
		var/hurt_icon
		switch(hurt_percentage)
			if(0 to 25)
				hurt_icon = "hurt_100"
			if(26 to 50)
				hurt_icon = "hurt_75"
			if(51 to 75)
				hurt_icon = "hurt_50"
			else
				hurt_icon = "hurt_25"
		overlays += image(icon,hurt_icon, layer = layer+0.15)



/obj/effect/blob/proc/update_health()
	if(health <= 0)
		dying = 1
		playsound(get_turf(src), 'sound/effects/blobsplat.ogg', 50, 1)

		Delete()
		return
