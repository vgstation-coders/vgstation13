//I will need to recode parts of this but I am way too tired atm
/obj/effect/blob
	name = "blob"
	icon = 'icons/mob/blob.dmi'
	luminosity = 3
	desc = "Some blob creature thingy"
	density = 0
	opacity = 0
	anchored = 1
	var/health = 20
	var/health_timestamp = 0
	var/brute_resist = 4
	var/fire_resist = 1
	var/stun_time = 0

	// A note to the beam processing shit.
	var/custom_process=0

/obj/effect/blob/New(loc)
	blobs += src
	if(istype(ticker.mode,/datum/game_mode/blob))
		var/datum/game_mode/blob/blobmode = ticker.mode
		if((blobs.len >= blobmode.blobnukeposs) && prob(3) && !blobmode.nuclear)
			blobmode.stage(2)
			blobmode.nuclear = 1
	src.dir = pick(1, 2, 4, 8)
	src.update_icon()
	..(loc)
	for(var/atom/A in loc)
		A.blob_act()
	return


/obj/effect/blob/Destroy()
	blobs -= src
	..()

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
		update_icon()

/obj/effect/blob/proc/Life()
	stun_time--
	if(brute_resist<4 && prob(20))
		brute_resist++
	return


/obj/effect/blob/proc/Pulse(var/pulse = 0, var/origin_dir = 0)//Todo: Fix spaceblob expand

	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/obj/effect/blob/proc/Pulse() called tick#: [world.time]")

	//set background = 1

	if(run_action())//If we can do something here then we dont need to pulse more
		return

	if(pulse > 30)
		return//Inf loop check

	//Looking for another blob to pulse
	var/list/dirs = cardinal.Copy()
	dirs.Remove(origin_dir)//Dont pulse the guy who pulsed us
	for(var/i = 1 to 4)
		if(!dirs.len)	break
		var/dirn = pick(dirs)
		dirs.Remove(dirn)
		var/turf/T = get_step(src, dirn)
		var/obj/effect/blob/B = (locate(/obj/effect/blob) in T)
		if(!B)
			expand(T)//No blob here so try and expand
			return
		B.Pulse((pulse+1),get_dir(src.loc,T))
		return
	return


/obj/effect/blob/proc/run_action()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/obj/effect/blob/proc/run_action() called tick#: [world.time]")
	return 0


/obj/effect/blob/proc/expand(var/turf/T = null, var/prob = 1)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/obj/effect/blob/proc/expand() called tick#: [world.time]")
	if(prob && !prob(health))
		return
	if(istype(T, /turf/space) && prob(75))
		return
	if(stun_time) return 0
	if(!T)
		var/list/dirs = cardinal
		for(var/i = 1 to 4)
			var/dirn = pick(dirs)
			dirs.Remove(dirn)
			T = get_step(src, dirn)
			if(!(locate(/obj/effect/blob) in T))	break
			else	T = null

	if(!T)	return 0
	var/obj/effect/blob/normal/B = new /obj/effect/blob/normal(src.loc, min(src.health, 30))
	B.density = 1
	if(T.Enter(B,src))//Attempt to move into the tile
		B.density = initial(B.density)
		B.loc = T
	else
		T.blob_act()//If we cant move in hit the turf
		B.Delete()

	for(var/atom/A in T)//Hit everything in the turf
		A.blob_act()
	return 1


/obj/effect/blob/ex_act(severity)
	var/damage = 150
	health -= ((damage/brute_resist) - (severity * 5))
	update_icon()
	return


/obj/effect/blob/bullet_act(var/obj/item/projectile/Proj)
	..()
	switch(Proj.damage_type)
	 if(BRUTE)
		 health -= (Proj.damage/brute_resist)
	 if(BURN)
		 health -= (Proj.damage/fire_resist)
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
			if(istype(W, /obj/item/weapon/weldingtool))
				playsound(get_turf(src), 'sound/effects/blobweld.ogg', 100, 1)
		if("brute")
			damage = (W.force / max(src.brute_resist,1))

	health -= damage
	update_icon()
	return

/obj/effect/blob/attack_hand(mob/living/carbon/human/H as mob)
	if(!H.is_hand_valid_for_attack()) return
	if(H.gloves && istype(H.gloves,/obj/item/clothing/gloves))
		var/obj/item/clothing/gloves/G = H.gloves
		if(G.cell)
			if(H.a_intent == I_HURT) //Stungloves
				if(G.cell.charge >= 2500)
					G.cell.use(2500)
					visible_message("<span class='danger'>[src] has been touched with the stun gloves by [H]!</span>")
					log_attack("<font color='red'>[H.name] ([H.ckey]) stungloved [src.name].</font>")
					health -= (15 / max(src.fire_resist,1)) //It burns!
					update_icon()
					return 1
				else
					H << "<span class='warning'>Not enough charge!</span>"
					visible_message("<span class='danger'>[src] has been touched with the stun gloves by [H]!</span>")
					return
	switch(H.a_intent)
		if(I_HELP)
			visible_message("<span class='info'>[H] gave [src] the 'hover hand'.</span>")
			return
		if(I_DISARM)
			visible_message("<span class='danger'>[H] disrupted [src]!</span>")
			playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
			stun_time += 5
		if(I_GRAB)
			if(brute_resist>1)
				brute_resist -= 2
				brute_resist = max(1,brute_resist)
			playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
			visible_message("<span class='danger'>[H] stretched out [src]!</span>")
		if(I_HURT)
			log_attack("[H.name] ([H.ckey]) [H.species.attack_verb]ed [src.name].")
			visible_message("<span class='danger'>[H] [H.species.attack_verb]ed [src]!</span>")
			var/damage = rand(0, H.species.max_hurt_damage)
			if(!damage)
				if(H.species.attack_verb == "punch")
					playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
				else
					playsound(loc, 'sound/weapons/slashmiss.ogg', 25, 1, -1)

				visible_message("<span class='danger'>[H] has attempted to [H.species.attack_verb] [src]!</span>")
				return 0
			if(M_HULK in H.mutations)			damage += 5


			if(H.species.attack_verb == "punch")
				playsound(loc, "punch", 25, 1, -1)
			else
				playsound(loc, 'sound/weapons/slice.ogg', 25, 1, -1)
			visible_message("<span class='danger'>[H] has [H.species.attack_verb]ed [src]!</span>")
			damage = (damage / max(src.brute_resist,1))
			health -= damage
			update_icon()
	H << "<span class='warning'>It burns!</span>"
	H.adjustBruteLoss(rand(0,3))
	return 1

/obj/effect/blob/proc/change_to(var/type, var/mob/camera/blob/M = null)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/obj/effect/blob/proc/change_to() called tick#: [world.time]")
	if(!ispath(type))
		error("[type] is an invalid type for the blob.")
	if("[type]" == "/obj/effect/blob/core")
		new type(src.loc, 200, null, 1, M)
	else
		new type(src.loc)
	Delete()
	return

/obj/effect/blob/proc/Delete()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/obj/effect/blob/proc/Delete() called tick#: [world.time]")
	qdel(src)

/obj/effect/blob/normal
	icon_state = "blob"
	luminosity = 0
	health = 21

/obj/effect/blob/normal/Delete()
	src.loc = null
	blobs -= src
	..()

/obj/effect/blob/normal/update_icon()
	if(health <= 0)
		playsound(get_turf(src), 'sound/effects/blobsplat.ogg', 50, 1)
		Delete()
		return
	if(health <= 15)
		icon_state = "blob_damaged"
		return
