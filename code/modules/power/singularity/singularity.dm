var/list/global_singularity_pool

/obj/machinery/singularity
	name = "gravitational singularity" //Lower case
	desc = "The destructive, murderous Lord Singuloth, patron saint of Engineering. They harness its power to run the station's lighting and arcades."
	icon = 'icons/obj/singularity.dmi'
	icon_state = "singularity_s1"
	anchored = 1
	density = 0
	layer = SINGULARITY_LAYER
	plane = EFFECTS_PLANE
	luminosity = 6
	use_power = 0

	var/current_size = 1
	var/allowed_size = 1
	var/contained = 1 //Are we going to move around?
	var/energy = 100 //How strong are we?
	var/dissipate = 1 //Do we lose energy over time?
	var/dissipate_delay = 10
	var/dissipate_track = 0
	var/dissipate_strength = 1 //How much energy do we lose?
	var/move_self = 1 //Do we move on our own?
	var/grav_pull = 4 //How many tiles out do we pull?
	var/consume_range = 0 //How many tiles out do we eat.
	var/event_chance = 15 //Prob for event each tick.
	var/target = null //Its target. Moves towards the target if it has one.
	var/last_movement_dir = 0 //Log the singularity's last movement to produce biased movement (singularity prefers constant movement due to inertia)
	var/last_failed_movement = 0 //Will not move in the same dir if it couldnt before, will help with the getting stuck on fields thing.
	var/last_warning
	appearance_flags = LONG_GLIDE|TILE_MOVER
	var/chained = 0 //Adminbus chain-grab
	var/modifier = "" //for memes

/obj/machinery/singularity/New(loc, var/starting_energy = 50, var/temp = 0)
	//CARN: admin-alert for chuckle-fuckery.
	icon_state = modifier + icon_state
	admin_investigate_setup()
	energy = starting_energy

	if(temp)
		spawn(temp)
			qdel(src)

	..()
	machines -= src
	power_machines += src
	for(var/obj/machinery/singularity_beacon/singubeacon in machines)
		if(singubeacon.active)
			target = singubeacon
			break
	if(!global_singularity_pool)
		global_singularity_pool = list()
	global_singularity_pool += src

/obj/machinery/singularity/attack_hand(mob/user as mob)
	consume(user)
	return 1

/obj/machinery/singularity/blob_act(severity)
	return

/obj/machinery/singularity/supermatter_act(atom/source, severity)
	return

/obj/machinery/singularity/ex_act(severity)
	if(current_size > 10) //IT'S UNSTOPPABLE
		return
	switch(severity)
		if(1.0)
			if(prob(25))
				investigation_log(I_SINGULO, "has been destroyed by an explosion.")
				qdel(src)
				return
			else
				energy += 50
		if(2.0 to 3.0)
			energy += round((rand(20, 60)/2), 1)
			return

/obj/machinery/singularity/to_bump(atom/A)
	consume(A)

/obj/machinery/singularity/Bumped(atom/A)
	consume(A)

/obj/machinery/singularity/Crossed(atom/movable/A)
	consume(A)

/obj/machinery/singularity/attack_tk(mob/user)
	to_chat(user, "<span class = 'notice'>You attempt to comprehend \the [src]...</span>")
	spawn(rand(50,110))
		if(!user.gcDestroyed)
			if(prob(95))
				to_chat(user, "<span class = 'danger'>...and fail to do so.</span>")
				if(prob(50)) //50/50 of becoming unrecoverable
					user.visible_message("<span class = 'danger'>\The [user] screams as they are consumed from within!</span>")
					if(prob(50))
						user.audible_scream()
						var/matrix/M = matrix()
						M.Scale(0)
						animate(user, alpha = 0, transform = M, time = 3 SECONDS, easing = SINE_EASING)
						spawn(3 SECONDS)
							new /obj/effect/gibspawner/generic(get_turf(user))
							qdel(user)
					else
						playsound(user, get_sfx("soulstone"), 50,1)
						make_tracker_effects(get_turf(user), get_turf(src))
						user.dust()
				else
					user.visible_message("<span class = 'danger'>\The [user] explodes!</span>")
					..()
			else
				to_chat(user, "<span class = 'notice'>...and manage to grab onto something from the depths of \the [src]!</span>")
				if(do_after(user, src, 30))
					to_chat(user, "<span class = notice'>You manage to pull something from beyond to within normal space!</span>")
					var/obj/structure/losetta_stone/L = new
					L.alpha = 0
					L.forceMove(get_turf(user))
					animate(L, alpha = 255, time = 3 SECONDS)

/obj/machinery/singularity/process()
	dissipate()
	check_energy()

	if(current_size >= 3)
		move()
		pulse()
		if(prob(event_chance)) //Chance for it to run a special event TODO: Come up with one or two more that fit.
			event()
	eat()

/obj/machinery/singularity/attack_ai() //To prevent AIs from gibbing themselves when they click on one.
	return

/obj/machinery/singularity/proc/admin_investigate_setup()
	last_warning = world.time
	var/count = locate(/obj/machinery/containment_field) in orange(30, src)

	if(!count)
		message_admins("A singulo has been created without containment fields active ([x], [y], [z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>).")

	investigation_log(I_SINGULO,"was created. [count ? "" : "<font color='red'>No containment fields were active.</font>"]")

/obj/machinery/singularity/proc/dissipate()
	if(!dissipate)
		return

	if(dissipate_track >= dissipate_delay)
		energy -= dissipate_strength
		dissipate_track = 0
	else
		dissipate_track++

/obj/machinery/singularity/proc/expand(var/force_size = 0, var/growing = 1)
	if(current_size > 10 && !force_size) //If this is happening, this is an error
		message_admins("expand() was called on a super singulo. This should not happen.")
		return
	var/temp_allowed_size = allowed_size

	if(force_size)
		temp_allowed_size = force_size

	if(temp_allowed_size <= STAGE_FIVE && growing && is_near_shield())
		move_away_from_shield()

	switch(temp_allowed_size)
		if(STAGE_ONE)
			current_size = 1
			icon = 'icons/obj/singularity.dmi'
			pixel_x = 0
			pixel_y = 0
			bound_width = WORLD_ICON_SIZE
			bound_x = 0
			bound_height = WORLD_ICON_SIZE
			bound_y = 0
			grav_pull = 4
			consume_range = 0
			dissipate_delay = 10
			dissipate_track = 0
			dissipate_strength = 1
			overlays = 0
			if(chained)
				overlays += image(icon = icon, icon_state = "chain_s1")
			visible_message("<span class='notice'>\The [src] shrinks to a rather pitiful size.</span>")
		if(STAGE_TWO)
			current_size = 3
			icon = 'icons/effects/96x96.dmi'
			pixel_x = -32 * PIXEL_MULTIPLIER
			pixel_y = -32 * PIXEL_MULTIPLIER
			bound_width = 3 * WORLD_ICON_SIZE
			bound_x = -WORLD_ICON_SIZE
			bound_height = 3 * WORLD_ICON_SIZE
			bound_y = -WORLD_ICON_SIZE
			grav_pull = 6
			consume_range = 1
			dissipate_delay = 5
			dissipate_track = 0
			dissipate_strength = 5
			overlays = 0
			if(chained)
				overlays += image(icon = icon, icon_state = "chain_s3")
			if(growing)
				visible_message("<span class='notice'>\The [src] noticeably grows in size.</span>")
			else
				visible_message("<span class='notice'>\The [src] shrinks to a less powerful size.</span>")
		if(STAGE_THREE)
			current_size = 5
			icon = 'icons/effects/160x160.dmi'
			pixel_x = -64 * PIXEL_MULTIPLIER
			pixel_y = -64 * PIXEL_MULTIPLIER
			bound_width = 5 * WORLD_ICON_SIZE
			bound_x = -2 * WORLD_ICON_SIZE
			bound_height = 5 * WORLD_ICON_SIZE
			bound_y = -2 * WORLD_ICON_SIZE
			grav_pull = 8
			consume_range = 2
			dissipate_delay = 4
			dissipate_track = 0
			dissipate_strength = 20
			overlays = 0
			if(chained)
				overlays += image(icon = icon, icon_state = "chain_s5")
			if(growing)
				visible_message("<span class='notice'>\The [src] expands to a reasonable size.</span>")
			else
				visible_message("<span class='notice'>\The [src] has returned to a safe size.</span>")
		if(STAGE_FOUR)
			current_size = 7
			icon = 'icons/effects/224x224.dmi'
			pixel_x = -96 * PIXEL_MULTIPLIER
			pixel_y = -96 * PIXEL_MULTIPLIER
			bound_width = 7 * WORLD_ICON_SIZE
			bound_x = -3 * WORLD_ICON_SIZE
			bound_height = 7 * WORLD_ICON_SIZE
			bound_y = -3 * WORLD_ICON_SIZE
			grav_pull = 10
			consume_range = 3
			dissipate_delay = 10
			dissipate_track = 0
			dissipate_strength = 10
			overlays = 0
			if(chained)
				overlays += image(icon = icon, icon_state = "chain_s7")
			if(growing)
				visible_message("<span class='warning'>\The [src] expands to a dangerous size.</span>")
			else
				visible_message("<span class='notice'>Miraculously, \the [src] shrinks back to a containable size.</span>")
		if(STAGE_FIVE)
			current_size = 9
			icon = 'icons/effects/288x288.dmi'
			pixel_x = -128 * PIXEL_MULTIPLIER
			pixel_y = -128 * PIXEL_MULTIPLIER
			bound_width = 9 * WORLD_ICON_SIZE
			bound_x = -4 * WORLD_ICON_SIZE
			bound_height = 9 * WORLD_ICON_SIZE
			bound_y = -4 * WORLD_ICON_SIZE
			grav_pull = 10
			consume_range = 4
			dissipate = 0 //It cant go smaller due to energy loss.
			overlays = 0
			if(chained)
				overlays += image(icon = icon, icon_state = "chain_s9")
			if(growing)
				visible_message("<span class='danger'><font size='2'>\The [src] has grown out of control!</font></span>")
			else
				visible_message("<span class='warning'>\The [src] miraculously shrinks and loses its supermatter properties.</span>")
				//Literally the only case where it should do that, can only be done by adminbus, so just reset its name and desc to default
				name = initial(name)
				desc = initial(desc)
		if(STAGE_SUPER) //SUPERSINGULO
			name = "super [name]" //Super version of whatever it was named. Shouldn't fire more than once
			desc = "The final form of Lord Singuloth. <b>It has the power to destroy worlds.</b> It can most likely still be used to power arcades too, <b>if you dare.</b>"
			current_size = 11
			icon = 'icons/effects/352x352.dmi'
			pixel_x = -160 * PIXEL_MULTIPLIER
			pixel_y = -160 * PIXEL_MULTIPLIER
			bound_width = 11 * WORLD_ICON_SIZE
			bound_x = -5 * WORLD_ICON_SIZE
			bound_height = 11 * WORLD_ICON_SIZE
			bound_y = -5 * WORLD_ICON_SIZE
			grav_pull = 16
			consume_range = 5
			dissipate = 0 //It cant go smaller due to e loss
			event_chance = 25 //Events will fire off more often.
			if(chained)
				overlays += image(icon = icon, icon_state = "chain_s9")
			visible_message("<span class='sinister'><font size='3'>You witness the creation of a destructive force that cannot possibly be stopped by human hands.</font></span>")

		if(STAGE_SSGSS) //SUPER SINGULO GOD SUPER SINGULO
			name = "[name] god [name]" //it gets worse
			desc = "The true final form of Lord Singuloth. <b>It has the power to destroy galaxies.</b> It can most likely still be used to power arcades too, <b>if you dare.</b>"
			current_size = 13
			icon = 'icons/effects/384x384.dmi'
			pixel_x = -192 * PIXEL_MULTIPLIER
			pixel_y = -192 * PIXEL_MULTIPLIER
			bound_width = 13 * WORLD_ICON_SIZE
			bound_x = -6 * WORLD_ICON_SIZE
			bound_height = 13 * WORLD_ICON_SIZE
			bound_y = -6 * WORLD_ICON_SIZE
			grav_pull = 24
			consume_range = 5
			plane = 21
			visible_message("<span class='sinister'><font size='3'>You witness the creation of a destructive force that challenges that of the very gods.</font></span>")

	if(current_size == allowed_size)
		investigation_log(I_SINGULO,"<font color='red'>grew to size [current_size].</font>")
		return 1
	else if(current_size < (--temp_allowed_size) && current_size < 11)
		expand(temp_allowed_size)
	else
		return 0

/obj/machinery/singularity/proc/check_energy()
	if(energy <= 0)
		investigation_log(I_SINGULO, "collapsed.")
		qdel(src)
		return 0

	switch(energy) //Some of these numbers might need to be changed up later -Mport.
		if(1 to 199)
			allowed_size = 1
		if(200 to 499)
			allowed_size = 3
		if(500 to 999)
			allowed_size = 5
		if(1000 to 1999)
			allowed_size = 7
		if(2000 to INFINITY)
			allowed_size = 9

	if(current_size != allowed_size && current_size < 11)
		if(current_size > allowed_size)
			expand(null, 0)
		else
			expand(null, 1)
	if(icon_state != modifier + "singularity_s[current_size]")
		icon_state = modifier + "singularity_s[current_size]"
	return 1

/obj/machinery/singularity/proc/eat()
	// This is causing issues. Do not renable - N3X
	// Specifically, eat() builds up in the background from taking too long and eventually crashes the singo.
	//set background = BACKGROUND_ENABLED
	//var/ngrabbed=0
	//Note on June 27, 2019. Apparently it IS being used, so... go wild!
	var/turf/T = get_turf(src)
	for(var/z0 in GetOpenConnectedZlevels(T))
		var/z_dist = abs(z0 - T.z)
		if(z_dist <= grav_pull)
			for(var/atom/X in orange(grav_pull - z_dist, locate(T.x,T.y,z0)))
				if(X.type == /atom/movable/light)//since there's one on every turf
					continue
				if (current_size > 11 && X.type == /turf/unsimulated/wall/supermatter) // galaxy end ongoing
					continue
				// Caps grabbing shit at 100 items.
				//if(ngrabbed==100)
					//warning("Singularity eat() capped at [ngrabbed]")
					//return
				//if(!isturf(X))//a stage five singularity has a grav pull of 10, that means it covers 441 turfs (21x21) at every ticks.
					//ngrabbed++
				try
					var/dist = get_dist(X, src)
					var/obj/machinery/singularity/S = src
					if(!istype(src))
						return
					if(dist > consume_range)
						X.singularity_pull(S, current_size)
					else if(dist <= consume_range)
						consume(X)
				catch(var/exception/e)
					error("Singularity eat() caught exception:")
					error(e)

					spawn(0) //So the following line doesn't stop execution
						throw e //So ALL debug information is sent to the runtime log

					continue

	//for(var/turf/T in trange(grav_pull, src)) // TODO: Create a similar trange for orange to prevent snowflake of self check.
	//	consume(T)

	//testing("Singularity eat() ate [ngrabbed] items.")
	return
/*
 * Singulo optimization.
 * Jump out whenever we've made a decision.
 */
/obj/machinery/singularity/proc/canPull(const/atom/movable/A)
	if(A && !A.anchored)
		if(A.canSingulothPull(src))
			return 1

	return 0

/obj/machinery/singularity/proc/isGodSingulo()
	if(current_size == STAGE_SSGSS)
		return 1
	return 0

/obj/machinery/singularity/proc/makeSuperMatterSea(atom/A)
	if(isturf(A.loc))
		var/turf/newsea = A.loc
		if(!istype(newsea, /turf/unsimulated/wall/supermatter))
			newsea.ChangeTurf(/turf/unsimulated/wall/supermatter)

/obj/machinery/singularity/proc/consume(const/atom/A)
	var/gain = A.singularity_act(current_size,src)
	src.energy += gain
	return

/*
 * Some modifications have been done in here. The Singularity's movement is now biased instead of truly random
 * This means that if it isn't influcenced by a beacon, it will prefer the direction it last moved to
 * In general, it's last movement has a 3/4th chance of being the next
 */
/obj/machinery/singularity/proc/move(var/force_move = 0)
	if(!move_self && !force_move)
		return 0

	var/movement_dir = pick(alldirs - last_failed_movement)

	if(force_move) //We are forcing the Singularity to move in a particular direction
		movement_dir = force_move //Go this way

	if(!force_move && target && prob(66)) //Otherwise we have a singularity beacon online
		movement_dir = get_dir(src,target) //Moves to a singulo beacon, if there is one

	if(!force_move && !target && last_failed_movement != last_movement_dir && prob(66)) //Otherwise we will perform a biased movement
		movement_dir = last_movement_dir

	last_movement_dir = movement_dir //We have chosen our direction, log it

	if(current_size >= 9) //The superlarge one does not care about things in its way
		set_glide_size(DELAY2GLIDESIZE(SS_WAIT_MACHINERY/2), min = 0)
		spawn(0)
			step(src, movement_dir)
		spawn(SS_WAIT_MACHINERY/2)
			step(src, movement_dir)
		if(isGodSingulo())
			makeSuperMatterSea(src)
		return 1
	else if(check_turfs_in(movement_dir))
		last_failed_movement = 0 //Reset this because we moved
		spawn(0)
			set_glide_size(DELAY2GLIDESIZE(SS_WAIT_MACHINERY), min = 0)
			step(src, movement_dir)
		if(isGodSingulo())
			makeSuperMatterSea(src)
		return 1
	else
		last_failed_movement = movement_dir
	return 0

/obj/machinery/singularity/proc/check_turfs_in(var/direction = 0, var/step = 0, var/startturf)
	if(!direction)
		return 0
	var/steps = 0
	if(!step)
		steps = Ceiling(current_size/2)
	else
		steps = step
	var/list/turfs = list()
	var/turf/T
	if(startturf)
		T = get_turf(startturf)
	else
		T = get_turf(src)
	for(var/i = 1 to steps)
		T = get_step(T, direction)
	if(!isturf(T))
		return 0
	turfs.Add(T)
	var/dir2 = 0
	var/dir3 = 0
	switch(direction)
		if(NORTH, SOUTH)
			dir2 = 4
			dir3 = 8
		if(EAST, WEST)
			dir2 = 1
			dir3 = 2
	var/turf/T2 = T
	for(var/j = 1 to steps)
		T2 = get_step(T2, dir2)
		if(!isturf(T2))
			return 0
		turfs.Add(T2)
	for(var/k = 1 to steps)
		T = get_step(T, dir3)
		if(!isturf(T))
			return 0
		turfs.Add(T)
	for(var/turf/T3 in turfs)
		if(isnull(T3))
			continue
		if(!can_move(T3))
			return 0
	return 1

/obj/machinery/singularity/proc/can_move(const/turf/T)
	if(!isturf(T))
		return 0

	if((locate(/obj/machinery/containment_field) in T) || (locate(/obj/machinery/shieldwall) in T))
		return 0
	else if(locate(/obj/machinery/field_generator) in T)
		var/obj/machinery/field_generator/G = locate(/obj/machinery/field_generator) in T

		if(G && G.active)
			return 0
	else if(locate(/obj/machinery/shieldwallgen) in T)
		var/obj/machinery/shieldwallgen/S = locate(/obj/machinery/shieldwallgen) in T

		if(S && S.active)
			return 0
	return 1

/obj/machinery/singularity/proc/is_near_shield()
	for(var/dir in cardinal)
		if(!check_turfs_in(dir))
			return 1
	return 0

/obj/machinery/singularity/proc/move_away_from_shield()

	var/list/dirs_to_try = alldirs.Copy()
	dirs_while_label:
		while(dirs_to_try.len)
			var/checkdir = pick(dirs_to_try)
			if(!check_turfs_in(checkdir))
				dirs_to_try -= checkdir
				continue

			var/newturf = get_step(src,checkdir)
			for(var/dir in cardinal)
				if(!check_turfs_in(dir, startturf = newturf))
					dirs_to_try -= checkdir
					continue dirs_while_label

			step(src, checkdir)
			return 1
	return 0

/obj/machinery/singularity/proc/event()
	var/numb = pick(1, 2, 3, 4, 5, 6)

	switch(numb)
		if(1) //EMP.
			emp_area()
		if(2, 3) //Tox damage all carbon mobs in area.
			toxmob()
		if(4) //Stun mobs who lack optic scanners.
			mezzer()
		else
			return 0
	if(current_size > 9)
		smwave()
	return 1


/obj/machinery/singularity/proc/toxmob()
	var/toxrange = 10
	var/toxdamage = 4
	if(src.energy > 200)
		toxdamage = round(((src.energy-150)/50)*4,1)
	for(var/mob/living/M in view(toxrange, src.loc))
		if(M.flags & INVULNERABLE)
			continue
		toxdamage = (toxdamage - (toxdamage*M.getarmor(null, "rad")))
		M.apply_effect(toxdamage, TOX)
	return


/obj/machinery/singularity/proc/mezzer()
	for(var/mob/living/carbon/M in oviewers(8, src))
		if(istype(M, /mob/living/carbon/brain)) //Ignore brains
			continue
		if(M.flags & INVULNERABLE)
			continue
		if(M.stat == CONSCIOUS)
			if(istype(M,/mob/living/carbon/human))
				var/mob/living/carbon/human/H = M
				if(istype(H.glasses,/obj/item/clothing/glasses/scanner/meson) && current_size < 11)
					to_chat(H, "<span class='notice'>You stare directly into \the [src], good thing you had your protective eyewear on!</span>")
					return
				else
					to_chat(H, "<span class='warning'>You stare directly into \the [src] but your eyewear does absolutely nothing to protect you from it!</span>")
				M.visible_message("<span class='danger'>[M] stares blankly at \the [src]!</span>", \
				"<span class='danger'>You stare directly into \the [src] and feel [current_size > 9 ? "helpless" : "weak"].</span>")
				M.apply_effect(3, STUN)

/obj/machinery/singularity/proc/emp_area()
	if(current_size < 11)
		empulse(src, 8, 10)
	else
		empulse(src, 12, 16)

/obj/machinery/singularity/proc/smwave()
	for(var/mob/living/M in view(10, src.loc))
		if(prob(67))
			M.apply_radiation(rand(energy), RAD_EXTERNAL)
			to_chat(M, "<span class='warning'>You hear an uneartly ringing, then what sounds like a shrilling kettle as you are washed with a wave of heat.</span>")
			to_chat(M, "<span class='notice'>Miraculously, it fails to kill you.</span>")
		else
			to_chat(M, "<span class='danger'>You hear an uneartly ringing, then what sounds like a shrilling kettle as you are washed with a wave of heat.</span>")
			to_chat(M, "<span class='danger'>You don't even have a moment to react as you are reduced to ashes by the intense radiation.</span>")
			M.dust()
	return

/obj/machinery/singularity/proc/pulse()
	emitted_harvestable_radiation(get_turf(src), energy, range = 15)

/obj/machinery/singularity/proc/on_capture()
	chained = 1
	overlays = 0
	move_self = 0
	switch(current_size)
		if(1)
			overlays += image('icons/obj/singularity.dmi',"chain_s1")
		if(3)
			overlays += image('icons/effects/96x96.dmi',"chain_s3")
		if(5)
			overlays += image('icons/effects/160x160.dmi',"chain_s5")
		if(7)
			overlays += image('icons/effects/224x224.dmi',"chain_s7")
		if(9)
			overlays += image('icons/effects/288x288.dmi',"chain_s9")

/obj/machinery/singularity/proc/on_release()
	chained = 0
	overlays = 0
	move_self = 1

/obj/machinery/singularity/cultify()
	var/dist = max((current_size - 2), 1)
	explosion(get_turf(src), dist, dist * 2, dist * 4)
	qdel(src)

/obj/machinery/singularity/singularity_act(var/other_size=0,var/obj/machinery/singularity/S)
	if(S == src) //don't eat yourself idiot
		return
	if(other_size >= current_size)
		var/gain = (energy/2)
		var/dist = max((current_size - 2), 1)
		explosion(src.loc,(dist),(dist*2),(dist*4))
		qdel(src)
		return(gain)

/obj/machinery/singularity/shuttle_act() //Shuttles can't kill the singularity honk
	return

/*
/obj/machinery/singularity/can_shuttle_move() //The days of destroying centcomm are gone
	return
*/ //Fuck you centcomm

/obj/machinery/singularity/Destroy()
	..()
	power_machines -= src
	global_singularity_pool -= src

/obj/machinery/singularity/bite_act(mob/user)
	consume(user)

/obj/machinery/singularity/kick_act(mob/user)
	consume(user)

/obj/machinery/singularity/acidable()
	return 0

/obj/machinery/singularity/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0, glide_size_override = 0)
	if(timestopped)
		return 0
	return forceMove(get_step(src,Dir))


////////////This singularity is upgraded to be controlled by deadchat. God save us all.

/datum/deadchat_listener/singulo_listener
	name = "deadchat-controlled singularity listener"
	var/obj/machinery/singularity/deadchat_controlled/parent

/datum/deadchat_listener/singulo_listener/deadchat_event(var/ckey, var/message)
	parent.process_deadchat(ckey,message)

/obj/machinery/singularity/deadchat_controlled
	desc = "The destructive, murderous Lord Singuloth, patron saint of Engineering. This one seems... unstable. Oh god."
	var/deadchat_mode = "Anarchy"
	var/list/ckey_to_cooldown = list()
	var/datum/deadchat_listener/singulo_listener/listener
	move_self = 0

	var/input_cooldown = 60 //In deca-seconds
	var/democracy_cooldown = 120
	var/list/inputs = list("UP","DOWN","LEFT","RIGHT")
	var/deadchat_active = 1
	appearance_flags = TILE_MOVER

/obj/machinery/singularity/deadchat_controlled/Destroy()
	..()
	var/message = "<span class='recruit'>The deadchat-played singularity has been destroyed. Good job, retards."
	deadchat_active=0
	for(var/mob/M in player_list)
		if(istype(M, /mob/new_player) || !M.client)
			continue
		if(M.client && M.client.holder && M.client.holder.rights & R_ADMIN && (M.client.prefs.toggles & CHAT_DEAD))
			to_chat(M, message)
		else if(M.client && M.stat == DEAD && !istype(M, /mob/dead/observer/deafmute) && (M.client.prefs.toggles & CHAT_DEAD))
			to_chat(M, message)
		else if(M.client && istype(M,/mob/living/carbon/brain) && (M.client.prefs.toggles & CHAT_DEAD))
			var/mob/living/carbon/brain/B = M
			if(B.brain_dead_chat())
				to_chat(M, message)
	global_deadchat_listeners -= listener
	global_singularity_pool -= src
	qdel(listener)

/obj/machinery/singularity/deadchat_controlled/New(loc, var/starting_energy = 50, var/temp = 0)
	..()
	listener = new /datum/deadchat_listener/singulo_listener
	listener.parent = src
	global_deadchat_listeners += listener
	global_singularity_pool -= src


/obj/machinery/singularity/deadchat_controlled/proc/process_deadchat(var/ckey, var/message)
	if(deadchat_mode == "Anarchy")
		var/cooldown = ckey_to_cooldown[ckey]
		if(!cooldown)
			ckey_to_cooldown[ckey] = 0
			cooldown = 0
		if(cooldown > 0)
			return
		var/direction
		message = uppertext(message)
		switch(message) //*shrug
			if("UP")
				direction = NORTH
			if("DOWN")
				direction = SOUTH
			if("LEFT")
				direction = WEST
			if("RIGHT")
				direction = EAST
		if(direction)
			set_glide_size(DELAY2GLIDESIZE(0.1 SECONDS))
			forceMove(get_step(src,direction))
			eat_no_pull()
			ckey_to_cooldown[ckey] = 1
			spawn(input_cooldown)
				ckey_to_cooldown[ckey] = 0
	else if(deadchat_mode == "Democracy")
		var/vote = ckey_to_cooldown[ckey]
		if(!vote)
			ckey_to_cooldown[ckey] = 0
			vote = -1
		message = uppertext(message)
		if(inputs.Find(message))
			ckey_to_cooldown[ckey] = message

/obj/machinery/singularity/deadchat_controlled/proc/eat_no_pull() //Copied from proc/eat() and altered
	for(var/atom/X in orange(consume_range, src))
		if(X.type == /atom/movable/light)
			continue
		if(current_size > 11 && X.type == /turf/unsimulated/wall/supermatter)
			continue
		consume(X)

/obj/machinery/singularity/deadchat_controlled/proc/begin_democracy_loop()
	if(democracy_cooldown < 1)
		democracy_cooldown = 1 //setting it to 0 kills the serb so let's not ever let that happen again
	spawn(democracy_cooldown)
		if(!deadchat_active) //Bit gunky but I'm not entirely certain how src/self works in byond, would if(src == null) work?
			return
		var/result = count_democracy_votes()
		if(result != 5)
			set_glide_size(DELAY2GLIDESIZE(0.1 SECONDS))
			forceMove(get_step(src,result))
			eat()
			var/direction_name = "up"
			switch(result)
				if(2)
					direction_name = "down"
				if(3)
					direction_name = "left"
				if(4)
					direction_name = "right"
			var/message = "<span class='recruit'>The singularity moved [direction_name]!.<br>New vote started. It will end in [democracy_cooldown/10] seconds." //There should really be a proc for sending messages to deadchat but I'm too lazy to copy/paste it
			for(var/mob/M in player_list)
				if(istype(M, /mob/new_player) || !M.client)
					continue
				if(M.client && M.client.holder && M.client.holder.rights & R_ADMIN && (M.client.prefs.toggles & CHAT_DEAD)) //admins can toggle deadchat on and off. This is a proc in admin.dm and is only give to Administrators and above
					to_chat(M, message)
				else if(M.client && M.stat == DEAD && !istype(M, /mob/dead/observer/deafmute) && (M.client.prefs.toggles & CHAT_DEAD))
					to_chat(M, message)
				else if(M.client && istype(M,/mob/living/carbon/brain) && (M.client.prefs.toggles & CHAT_DEAD))
					var/mob/living/carbon/brain/B = M
					if(B.brain_dead_chat())
						to_chat(M, message)
		else
			var/message = "<span class='recruit'>No votes were cast this cycle. Remember, type UP, DOWN, LEFT, or RIGHT to cast a vote!"
			for(var/mob/M in player_list)
				if(istype(M, /mob/new_player) || !M.client)
					continue
				if(M.client && M.client.holder && M.client.holder.rights & R_ADMIN && (M.client.prefs.toggles & CHAT_DEAD)) //admins can toggle deadchat on and off. This is a proc in admin.dm and is only give to Administrators and above
					to_chat(M, message)
				else if(M.client && M.stat == DEAD && !istype(M, /mob/dead/observer/deafmute) && (M.client.prefs.toggles & CHAT_DEAD))
					to_chat(M, message)
				else if(M.client && istype(M,/mob/living/carbon/brain) && (M.client.prefs.toggles & CHAT_DEAD))
					var/mob/living/carbon/brain/B = M
					if(B.brain_dead_chat())
						to_chat(M, message)
		begin_democracy_loop()

/obj/machinery/singularity/deadchat_controlled/proc/count_democracy_votes()	//Will return 5 if empty list
	var/list/votes = list(0,0,0,0)
	var/found_vote = 0
	for(var/vote in ckey_to_cooldown)
		switch(ckey_to_cooldown[vote])
			if("UP")
				votes[1]++
			if("DOWN")
				votes[2]++
			if("LEFT")
				votes[3]++
			if("RIGHT")
				votes[4]++
		if(ckey_to_cooldown[vote] != -1)
			found_vote = 1
		ckey_to_cooldown[vote] = -1
	if(!found_vote)
		return 5
	if(votes[1] >= votes[2] && votes[1] >= votes[3] && votes[1] >= votes[4])
		return NORTH
	else if(votes[2] >= votes[3] && votes[2] >= votes[4])
		return SOUTH
	else if(votes[3] >= votes[4])
		return WEST
	else
		return EAST


/client/proc/deadchat_singularity()
	set category = "Fun"
	set name = "Spawn Deadchat-Controlled Singularity"
	if(!src.holder)
		return 0
	if(!global_singularity_pool.len)
		return 0
	if(!holder.rights || !check_rights(R_FUN,0))
		to_chat(holder, "They (you) do it for free, yet they (you) still don't have R_FUN perms... sad!")
		return 0
	var/list/organized_list = list()
	for(var/obj/machinery/singularity/singularity in global_singularity_pool)
		var/organized_hash = "[singularity] - [singularity.x], [singularity.y], [singularity.z]"
		organized_list[organized_hash] = singularity
	if(!global_singularity_pool.len)
		to_chat(holder, "There are no singularities to be transformed into a deadchat-controlled one. Spawn one first... if you dare.")
		return 0
	var/singulo_name = input(src,"Select a singularity.", "Confirm", null) as null|anything in organized_list
	var/obj/machinery/singularity/target_singulo = organized_list[singulo_name]
	if(target_singulo)
		var/list/singulo_options = list("Democracy","Anarchy")
		var/option_chosen = input(src,"Choose a mode.", "Confirm", null) as null|anything in singulo_options
		if(option_chosen == "Anarchy")
			var/cooldown = input("Please enter the cooldown each player has in seconds.", "Cooldown") as num
			if(!cooldown)
				return 0
			cooldown *= 10 //Decasecond conversion
			log_admin("[src] just turned the [singulo_name] into a deadchat-controlled one.")
			message_admins("[src] just turned the [singulo_name] into a deadchat-controlled one.")
			target_singulo.investigation_log(I_SINGULO,"<font color='red'>[src] just turned the [singulo_name] into a deadchat-controlled one. It is on anarchy mode, cooldown [cooldown] decaseconds. If you're reading this, god save the deadmin.</font>.")

			var/obj/machinery/singularity/deadchat_controlled/new_singulo = new /obj/machinery/singularity/deadchat_controlled(get_turf(target_singulo))
			new_singulo.energy = target_singulo.energy
			new_singulo.allowed_size = target_singulo.allowed_size
			new_singulo.expand(null, 0)
			new_singulo.input_cooldown = cooldown
			if(target_singulo.current_size >= STAGE_SUPER)
				new_singulo.expand(target_singulo.current_size, 1)
			qdel(target_singulo)

			var/message = "<span class='recruit'>An admin has begun DEADCHAT-CONTROLLED SINGULARITY!<br>It is on <b>ANARCHY</b> mode.<br>Simply type UP, DOWN, LEFT, or RIGHT to move the singularity.<br>Cooldown per person is currently [new_singulo.input_cooldown/10] seconds.<br>"
			for(var/mob/M in player_list)
				if(istype(M, /mob/new_player) || !M.client)
					continue
				if(M.client && M.client.holder && M.client.holder.rights & R_ADMIN && (M.client.prefs.toggles & CHAT_DEAD)) //admins can toggle deadchat on and off. This is a proc in admin.dm and is only give to Administrators and above
					to_chat(M, message + "<a href='?src=\ref[M];follow=\ref[new_singulo]'>(Follow)</a>")
				else if(M.client && M.stat == DEAD && !istype(M, /mob/dead/observer/deafmute) && (M.client.prefs.toggles & CHAT_DEAD))
					to_chat(M, message + "<a href='?src=\ref[M];follow=\ref[new_singulo]'>(Follow)</a>")
				else if(M.client && istype(M,/mob/living/carbon/brain) && (M.client.prefs.toggles & CHAT_DEAD))
					var/mob/living/carbon/brain/B = M
					if(B.brain_dead_chat())
						to_chat(M, message + "<a href='?src=\ref[M];follow=\ref[new_singulo]'>(Follow)</a>")
		else if(option_chosen == "Democracy")
			var/interval = input("Please enter the interval that the singulo makes a move in seconds.", "Interval") as num
			if(!interval)
				return 0
			interval *= 10 //Decasecond conversion
			if(interval < 10)
				interval = 10
			log_admin("[src] just turned the [singulo_name] into a deadchat-controlled one.")
			message_admins("[src] just turned the [singulo_name] into a deadchat-controlled one.")
			target_singulo.investigation_log(I_SINGULO,"<font color='red'>[src] just turned the [singulo_name] into a deadchat-controlled one. It is on democracy mode, cooldown [interval] decaseconds. If you're reading this, god save the deadmin.</font>.")

			var/obj/machinery/singularity/deadchat_controlled/new_singulo = new /obj/machinery/singularity/deadchat_controlled(get_turf(target_singulo))
			new_singulo.energy = target_singulo.energy
			new_singulo.allowed_size = target_singulo.allowed_size
			new_singulo.expand(null, 0)
			new_singulo.democracy_cooldown = interval
			new_singulo.deadchat_mode = "Democracy"
			new_singulo.begin_democracy_loop()
			if(target_singulo.current_size >= STAGE_SUPER)
				new_singulo.expand(target_singulo.current_size, 1)
			qdel(target_singulo)

			var/message = "<span class='recruit'>An admin has begun DEADCHAT-CONTROLLED SINGULARITY!<br>It is on <b>DEMOCRACY</b> mode.<br>Simply type UP, DOWN, LEFT, or RIGHT to cast a vote on which direction it should move. Your vote will be your latest message.<br>The singulo will move every [new_singulo.democracy_cooldown/10] seconds. Votes start now!<br>"
			for(var/mob/M in player_list)
				if(istype(M, /mob/new_player) || !M.client)
					continue
				if(M.client && M.client.holder && M.client.holder.rights & R_ADMIN && (M.client.prefs.toggles & CHAT_DEAD))
					to_chat(M, message + "<a href='?src=\ref[M];follow=\ref[new_singulo]'>(Follow)</a>")
				else if(M.client && M.stat == DEAD && !istype(M, /mob/dead/observer/deafmute) && (M.client.prefs.toggles & CHAT_DEAD))
					to_chat(M, message + "<a href='?src=\ref[M];follow=\ref[new_singulo]'>(Follow)</a>")
				else if(M.client && istype(M,/mob/living/carbon/brain) && (M.client.prefs.toggles & CHAT_DEAD))
					var/mob/living/carbon/brain/B = M
					if(B.brain_dead_chat())
						to_chat(M, message + "<a href='?src=\ref[M];follow=\ref[new_singulo]'>(Follow)</a>")

/obj/machinery/singularity/special
	name = "specialarity"
	modifier = "special_"

/obj/machinery/singularity/scrungulartiy
	name = "grabibational scrungulartiy"
	modifier = "scrung_"
