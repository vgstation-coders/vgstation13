//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:33

// Added spess ghoasts/cameras to this so they don't add to the lag. - N3X.
var/global/list/uneatable = list(
	/obj/effect/overlay,
	/mob/dead,
	/mob/camera,
	/mob/new_player
	)

/obj/machinery/singularity/
	name = "Gravitational Singularity"
	desc = "A Gravitational Singularity."
	icon = 'icons/obj/singularity.dmi'
	icon_state = "singularity_s1"
	anchored = 1
	density = 1
	layer = 6
	luminosity = 6
	unacidable = 1 // Don't comment this out.
	use_power = 0

	var/current_size = 1
	var/allowed_size = 1
	var/contained = 1 // Are we going to move around?
	var/energy = 100 // How strong are we?
	var/dissipate = 1 // Do we lose energy over time?
	var/dissipate_delay = 10
	var/dissipate_track = 0
	var/dissipate_strength = 1 // How much energy do we lose?
	var/move_self = 1 // Do we move on our own?
	var/grav_pull = 4 // How many tiles out do we pull?
	var/consume_range = 0 // How many tiles out do we eat.
	var/event_chance = 15 // Prob for event each tick.
	var/target = null // Its target. Moves towards the target if it has one.
	var/last_failed_movement = 0 // Will not move in the same dir if it couldnt before, will help with the getting stuck on fields thing.
	var/last_warning

/obj/machinery/singularity/New(loc, var/starting_energy = 50, var/temp = 0)
	// CARN: admin-alert for chuckle-fuckery.
	admin_investigate_setup()
	energy = starting_energy

	if (temp)
		spawn (temp)
			qdel(src)

	..()

	for (var/obj/machinery/singularity_beacon/singubeacon in machines)
		if (singubeacon.active)
			target = singubeacon
			break

/obj/machinery/singularity/attack_hand(mob/user as mob)
	consume(user)
	return 1

/obj/machinery/singularity/blob_act(severity)
	return

/obj/machinery/singularity/ex_act(severity)
	switch(severity)
		if(1.0)
			if(prob(25))
				investigate_log("has been destroyed by an explosion.","singulo")
				qdel(src)
				return
			else
				energy += 50
		if(2.0 to 3.0)
			energy += round((rand(20,60)/2),1)
			return

/obj/machinery/singularity/bullet_act(obj/item/projectile/P)
	return 0 // Will there be an impact? Who knows. Will we see it? No.

/obj/machinery/singularity/Bump(atom/A)
	consume(A)

/obj/machinery/singularity/Bumped(atom/A)
	consume(A)

/obj/machinery/singularity/process()
	eat()
	dissipate()
	check_energy()

	if (current_size >= 3)
		move()
		pulse()

		if (prob(event_chance)) // Chance for it to run a special event TODO: Come up with one or two more that fit.
			event()

/obj/machinery/singularity/attack_ai() // To prevent ais from gibbing themselves when they click on one.
	return

/obj/machinery/singularity/proc/admin_investigate_setup()
	last_warning = world.time
	var/count = locate(/obj/machinery/containment_field) in orange(30, src)

	if (!count)
		message_admins("A singulo has been created without containment fields active ([x], [y], [z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>).")

	investigate_log("was created. [count ? "" : "<font color='red'>No containment fields were active.</font>"]", "singulo")

/obj/machinery/singularity/proc/dissipate()
	if (!dissipate)
		return

	if(dissipate_track >= dissipate_delay)
		energy -= dissipate_strength
		dissipate_track = 0
	else
		dissipate_track++

/obj/machinery/singularity/proc/expand(var/force_size = 0)
	var/temp_allowed_size = allowed_size

	if (force_size)
		temp_allowed_size = force_size

	switch (temp_allowed_size)
		if (1)
			current_size = 1
			icon = 'icons/obj/singularity.dmi'
			icon_state = "singularity_s1"
			pixel_x = 0
			pixel_y = 0
			grav_pull = 4
			consume_range = 0
			dissipate_delay = 10
			dissipate_track = 0
			dissipate_strength = 1
		if (3) // 1 to 3 does not check for the turfs if you put the gens right next to a 1x1 then its going to eat them.
			current_size = 3
			icon = 'icons/effects/96x96.dmi'
			icon_state = "singularity_s3"
			pixel_x = -32
			pixel_y = -32
			grav_pull = 6
			consume_range = 1
			dissipate_delay = 5
			dissipate_track = 0
			dissipate_strength = 5
		if (5)
			if ((check_turfs_in(1, 2)) && (check_turfs_in(2, 2)) && (check_turfs_in(4, 2)) && (check_turfs_in(8, 2)))
				current_size = 5
				icon = 'icons/effects/160x160.dmi'
				icon_state = "singularity_s5"
				pixel_x = -64
				pixel_y = -64
				grav_pull = 8
				consume_range = 2
				dissipate_delay = 4
				dissipate_track = 0
				dissipate_strength = 20
		if(7)
			if ((check_turfs_in(1, 3)) && (check_turfs_in(2, 3)) && (check_turfs_in(4, 3)) && (check_turfs_in(8, 3)))
				current_size = 7
				icon = 'icons/effects/224x224.dmi'
				icon_state = "singularity_s7"
				pixel_x = -96
				pixel_y = -96
				grav_pull = 10
				consume_range = 3
				dissipate_delay = 10
				dissipate_track = 0
				dissipate_strength = 10
		if(9) // This one also lacks a check for gens because it eats everything.
			current_size = 9
			icon = 'icons/effects/288x288.dmi'
			icon_state = "singularity_s9"
			pixel_x = -128
			pixel_y = -128
			grav_pull = 10
			consume_range = 4
			dissipate = 0 // It cant go smaller due to e loss.

	if (current_size == allowed_size)
		investigate_log("<font color='red'>grew to size [current_size].</font>", "singulo")
		return 1
	else if (current_size < (--temp_allowed_size))
		expand(temp_allowed_size)
	else
		return 0

/obj/machinery/singularity/proc/check_energy()
	if (energy <= 0)
		investigate_log("collapsed.", "singulo")
		qdel(src)
		return 0

	switch (energy) // Some of these numbers might need to be changed up later -Mport.
		if (1 to 199)
			allowed_size = 1
		if (200 to 499)
			allowed_size = 3
		if (500 to 999)
			allowed_size = 5
		if (1000 to 1999)
			allowed_size = 7
		if (2000 to INFINITY)
			allowed_size = 9

	if (current_size != allowed_size)
		expand()
	return 1

/obj/machinery/singularity/proc/eat()
	set background = BACKGROUND_ENABLED

	if (defer_powernet_rebuild != 2)
		defer_powernet_rebuild = 1

	for (var/turf/T in trange(grav_pull, src)) // TODO: Create a similar trange for orange to prevent snowflake of self check.
		consume(T)

	if (defer_powernet_rebuild != 2)
		defer_powernet_rebuild = 0

/*
 * Singulo optimization.
 * Jump out whenever we've made a decision.
 */
/obj/machinery/singularity/proc/canPull(const/atom/movable/A)
	// If we're big enough, stop checking for this and that and JUST EAT.
	if (current_size >= 9)
		return 1

	if (A && !A.anchored)
		if (A.canSingulothPull(src))
			return 1

	return 0

/obj/machinery/singularity/proc/consume(const/atom/A)
	if (is_type_in_list(A, uneatable))
		return 0

	var/gain = 0

	if (istype(A, /mob/living)) // Mobs get gibbed.
		var/mob/living/M = A
		gain = 20

		if (istype(M,/mob/living/carbon/human))
			var/mob/living/carbon/human/H = M

			if (H.mind)
				switch (H.mind.assigned_role)
					if ("Station Engineer", "Chief Engineer")
						gain = 100
					if ("Clown")
						gain = rand(-300, 300) // HONK!
		M.gib()
	else if (istype(A, /obj/))
		if (istype(A, /obj/item/weapon/storage/backpack/holding))
			var/dist = max((current_size - 2), 1)
			explosion(get_turf(src), dist, dist * 2, dist * 4)
			return

		if (istype(A, /obj/machinery/singularity)) // Welp now you did it.
			var/obj/machinery/singularity/S = A
			energy += (S.energy / 2) // Absorb most of it.
			qdel(S)
			var/dist = max((current_size - 2), 1)
			explosion(get_turf(src), dist, dist * 2, dist * 4)
			return

		A.ex_act(1)

		if (A)
			qdel(A)

		gain = 2
	else if (isturf(A))
		var/dist = get_dist(A, src)

		for (var/atom/movable/AM in A.contents)
			if (AM == src) // This is the snowflake.
				continue

			if (dist <= consume_range)
				consume(AM)
				continue

			if (dist > consume_range && canPull(AM))
				if (is_type_in_list(AM, uneatable))
					continue

				if (101 == AM.invisibility)
					continue

				spawn (0)
					step_towards(AM, src)

		if (dist <= consume_range && !istype(A, /turf/space))
			var/turf/T = A
			if(istype(T,/turf/simulated/wall))
				var/turf/simulated/wall/W = T
				W.del_suppress_resmoothing=1 // Reduce lag from wallsmoothing.
			T.ChangeTurf(/turf/space)
			gain = 2

	energy += gain

/obj/machinery/singularity/proc/move(var/force_move = 0)
	if(!move_self)
		return 0

	var/movement_dir = pick(alldirs - last_failed_movement)

	if(force_move)
		movement_dir = force_move

	if(target && prob(60))
		movement_dir = get_dir(src,target) //moves to a singulo beacon, if there is one

	if(current_size >= 9)//The superlarge one does not care about things in its way
		spawn(0)
			step(src, movement_dir)
		spawn(1)
			step(src, movement_dir)
		return 1
	else if(check_turfs_in(movement_dir))
		last_failed_movement = 0//Reset this because we moved
		spawn(0)
			step(src, movement_dir)
		return 1
	else
		last_failed_movement = movement_dir
	return 0

/obj/machinery/singularity/proc/check_turfs_in(var/direction = 0, var/step = 0)
	if(!direction)
		return 0
	var/steps = 0
	if(!step)
		switch(current_size)
			if(1)
				steps = 1
			if(3)
				steps = 3//Yes this is right
			if(5)
				steps = 3
			if(7)
				steps = 4
			if(9)
				steps = 5
	else
		steps = step
	var/list/turfs = list()
	var/turf/T = src.loc
	for(var/i = 1 to steps)
		T = get_step(T,direction)
	if(!isturf(T))
		return 0
	turfs.Add(T)
	var/dir2 = 0
	var/dir3 = 0
	switch(direction)
		if(NORTH||SOUTH)
			dir2 = 4
			dir3 = 8
		if(EAST||WEST)
			dir2 = 1
			dir3 = 2
	var/turf/T2 = T
	for(var/j = 1 to steps)
		T2 = get_step(T2,dir2)
		if(!isturf(T2))
			return 0
		turfs.Add(T2)
	for(var/k = 1 to steps)
		T = get_step(T,dir3)
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
	if (!isturf(T))
		return 0

	if ((locate(/obj/machinery/containment_field) in T) || (locate(/obj/machinery/shieldwall) in T))
		return 0
	else if (locate(/obj/machinery/field_generator) in T)
		var/obj/machinery/field_generator/G = locate(/obj/machinery/field_generator) in T

		if (G && G.active)
			return 0
	else if (locate(/obj/machinery/shieldwallgen) in T)
		var/obj/machinery/shieldwallgen/S = locate(/obj/machinery/shieldwallgen) in T

		if (S && S.active)
			return 0
	return 1

/obj/machinery/singularity/proc/event()
	var/numb = pick(1, 2, 3, 4, 5, 6)

	switch (numb)
		if (1) // EMP.
			emp_area()
		if (2, 3) // Tox damage all carbon mobs in area.
			toxmob()
		if (4) // Stun mobs who lack optic scanners.
			mezzer()
		else
			return 0
	return 1


/obj/machinery/singularity/proc/toxmob()
	var/toxrange = 10
	var/toxdamage = 4
	var/radiation = 15
	var/radiationmin = 3
	if (src.energy>200)
		toxdamage = round(((src.energy-150)/50)*4,1)
		radiation = round(((src.energy-150)/50)*5,1)
		radiationmin = round((radiation/5),1)//
	for(var/mob/living/M in view(toxrange, src.loc))
		M.apply_effect(rand(radiationmin,radiation), IRRADIATE)
		toxdamage = (toxdamage - (toxdamage*M.getarmor(null, "rad")))
		M.apply_effect(toxdamage, TOX)
	return


/obj/machinery/singularity/proc/mezzer()
	for(var/mob/living/carbon/M in oviewers(8, src))
		if(istype(M, /mob/living/carbon/brain)) //Ignore brains
			continue

		if(M.stat == CONSCIOUS)
			if (istype(M,/mob/living/carbon/human))
				var/mob/living/carbon/human/H = M
				if(istype(H.glasses,/obj/item/clothing/glasses/meson))
					H << "\blue You look directly into The [src.name], good thing you had your protective eyewear on!"
					return
		M << "\red You look directly into The [src.name] and feel weak."
		M.apply_effect(3, STUN)
		for(var/mob/O in viewers(M, null))
			O.show_message(text("\red <B>[] stares blankly at The []!</B>", M, src), 1)

/obj/machinery/singularity/proc/emp_area()
	empulse(src, 8, 10)

/obj/machinery/singularity/proc/pulse()
	for(var/obj/machinery/power/rad_collector/R in rad_collectors)
		if (get_dist(R, src) <= 15) // Better than using orange() every process.
			R.receive_pulse(energy)

/obj/machinery/singularity/narsie // Moving narsie to a child object of the singularity so it can be made to function differently. --NEO.
	name = "Nar-Sie"
	desc = "Your mind begins to bubble and ooze as it tries to comprehend what it sees."
	icon = 'icons/obj/magic_terror.dmi'
	pixel_x = -89
	pixel_y = -85

	current_size = 9 //It moves/eats like a max-size singulo, aside from range. --NEO.
	contained = 0 // Are we going to move around?
	dissipate = 0 // Do we lose energy over time?
	grav_pull = 10 //How many tiles out do we pull?
	consume_range = 3 //How many tiles out do we eat

/obj/machinery/singularity/narsie/large
	name = "Nar-Sie"
	icon = 'icons/obj/narsie.dmi'

	// Pixel stuff centers Narsie.
	pixel_x = -236
	pixel_y = -256

	current_size = 12
	consume_range = 12 // How many tiles out do we eat.
	var/announce=1

/obj/machinery/singularity/narsie/large/New(var/cultspawn=0)
	..()
	if(announce)
		world << "<font size='15' color='red'><b>[uppertext(name)] HAS RISEN</b></font>"

	if (emergency_shuttle)
		emergency_shuttle.incall(0.3) // Cannot recall.

	if(cultspawn)
		SetUniversalState(/datum/universal_state/hell)

/obj/machinery/singularity/narsie/process()
	eat()

	if (!target || prob(5))
		pickcultist()

	move()

	if (prob(25))
		mezzer()

/obj/machinery/singularity/narsie/mezzer()
	for(var/mob/living/carbon/M in oviewers(8, src))
		if(M.stat == CONSCIOUS)
			if(!iscultist(M))
				M << "\red You feel your sanity crumble away in an instant as you gaze upon [src.name]..."
				M.apply_effect(3, STUN)


/obj/machinery/singularity/narsie/consume(const/atom/A) //Has its own consume proc because it doesn't need energy and I don't want BoHs to explode it. --NEO
	if (is_type_in_list(A, uneatable))
		return 0

	if (istype(A, /mob/living/))
		var/mob/living/C = A
		C.dust() // Changed from gib(), just for less lag.

	else if (istype(A, /obj/))
		A.ex_act(1)

		if (A)
			qdel(A)
	else if (isturf(A))
		var/dist = get_dist(A, src)

		for (var/atom/movable/AM in A.contents)
			if (AM == src) // This is the snowflake.
				continue

			if (dist <= consume_range)
				consume(AM)
				continue

			if (dist > consume_range && canPull(AM))
				if (is_type_in_list(AM, uneatable))
					continue

				if (101 == AM.invisibility)
					continue

				spawn (0)
					step_towards(AM, src)

		if (dist <= consume_range && !istype(A, /turf/space))
			var/turf/T = A
			if(istype(T,/turf/simulated/wall))
				var/turf/simulated/wall/W = T
				W.del_suppress_resmoothing=1 // Reduce lag from wallsmoothing.
			T.ChangeTurf(/turf/space)

/obj/machinery/singularity/narsie/ex_act(severity) //No throwing bombs at it either. --NEO
	return

/obj/machinery/singularity/narsie/proc/pickcultist() //Narsie rewards his cultists with being devoured first, then picks a ghost to follow. --NEO
	var/list/cultists = list()
	for(var/datum/mind/cult_nh_mind in ticker.mode.cult)
		if(!cult_nh_mind.current)
			continue
		if(cult_nh_mind.current.stat)
			continue
		var/turf/pos = get_turf(cult_nh_mind.current)
		if(pos.z != src.z)
			continue
		cultists += cult_nh_mind.current
	if(cultists.len)
		acquire(pick(cultists))
		return
		//If there was living cultists, it picks one to follow.
	for(var/mob/living/carbon/human/food in living_mob_list)
		if(food.stat)
			continue
		var/turf/pos = get_turf(food)
		if(pos.z != src.z)
			continue
		cultists += food
	if(cultists.len)
		acquire(pick(cultists))
		return
		//no living cultists, pick a living human instead.
	for(var/mob/dead/observer/ghost in player_list)
		if(!ghost.client)
			continue
		var/turf/pos = get_turf(ghost)
		if(pos.z != src.z)
			continue
		cultists += ghost
	if(cultists.len)
		acquire(pick(cultists))
		return
		//no living humans, follow a ghost instead.

/obj/machinery/singularity/narsie/proc/acquire(const/mob/food)
	var/capname = uppertext(name)

	target << "\blue <b>[capname] HAS LOST INTEREST IN YOU.</b>"
	target = food

	if (ishuman(target))
		target << "\red <b>[capname] HUNGERS FOR YOUR SOUL.</b>"
	else
		target << "\red <b>[capname] HAS CHOSEN YOU TO LEAD HIM TO HIS NEXT MEAL.</b>"

/**
 * Wizard narsie.
 */
/obj/machinery/singularity/narsie/wizard
	grav_pull = 0

/obj/machinery/singularity/narsie/wizard/eat()
	set background = BACKGROUND_ENABLED

	if (defer_powernet_rebuild != 2)
		defer_powernet_rebuild = 1

	for (var/turf/T in trange(consume_range, src))
		consume(T)

	if (defer_powernet_rebuild != 2)
		defer_powernet_rebuild = 0

/**
 * MR. CLEAN
 */
var/global/mr_clean_targets = list(
	/obj/effect/decal/cleanable,
	/obj/effect/decal/mecha_wreckage,
	/obj/effect/decal/remains,
	/obj/effect/spacevine,
	/obj/effect/spacevine_controller,
	/obj/effect/biomass,
	/obj/effect/biomass_controller,
	/obj/effect/rune,
	/obj/effect/blob,
	/obj/effect/spider
)

/obj/machinery/singularity/narsie/large/clean // Mr. Clean.
	name = "Mr. Clean"
	desc = "This universe is dirty. Time to change that."
	icon = 'icons/obj/mrclean.dmi'
	icon_state = ""

/obj/machinery/singularity/narsie/large/clean/update_icon()
	overlays = 0

	if (target && !isturf(target))
		overlays += "eyes"

/obj/machinery/singularity/narsie/large/clean/acquire(var/mob/food)
	..()
	update_icon()

/obj/machinery/singularity/narsie/large/clean/consume(const/atom/A)
	if (is_type_in_list(A, uneatable))
		return 0

	if (istype(A, /mob/living/))
		if (isrobot(A))
			var/mob/living/silicon/robot/R = A

			if (R.mmi)
				del(R.mmi) // Nuke MMI.
		qdel(A) // Just delete it.
	else if (is_type_in_list(A, mr_clean_targets))
		qdel(A)
	else if (isturf(A))
		var/turf/T = A
		T.clean_blood()
		var/dist = get_dist(T, src)

		for (var/atom/movable/AM in T.contents)
			if (AM == src) // This is the snowflake.
				continue

			if (dist <= consume_range)
				consume(AM)
				continue

			if (dist > consume_range && canPull(AM))
				if (is_type_in_list(AM, uneatable))
					continue

				if (101 == AM.invisibility)
					continue

				spawn (0)
					step_towards(AM, src)

/*
 * Mr. Clean just follows the dirt and grime.
 */
/obj/machinery/singularity/narsie/large/clean/pickcultist()
	var/list/targets = list()
	for(var/obj/effect/E in world)
		if(is_type_in_list(E, mr_clean_targets) && E.z == src.z)
			targets += E
	if(targets.len)
		acquire(pick(targets))
		return