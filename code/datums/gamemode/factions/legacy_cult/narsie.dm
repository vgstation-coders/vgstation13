/**
WHEN YOU FUCK WITH THIS FILE, UPDATE THE SUPERMATTER PORTAL AS WELL.
*/
var/global/narsie_behaviour = "CultStation13"
var/global/narsie_cometh = 0
var/global/list/narsie_list = list()
/obj/machinery/singularity/narsie //Moving narsie to its own file for the sake of being clearer
	name = "Nar-Sie"
	desc = "Your mind begins to bubble and ooze as it tries to comprehend what it sees."
	icon = 'icons/obj/narsie.dmi'
	icon_state = "narsie-small"
	pixel_x = -236 * PIXEL_MULTIPLIER
	pixel_y = -256 * PIXEL_MULTIPLIER

	current_size = 9 //It moves/eats like a max-size singulo, aside from range. --NEO.
	contained = 0 // Are we going to move around?
	dissipate = 0 // Do we lose energy over time?
	grav_pull = 10 //How many tiles out do we pull?
	consume_range = 3 //How many tiles out do we eat


/obj/machinery/singularity/narsie/New()
	..()
	narsie_list.Add(src)

/obj/machinery/singularity/narsie/Destroy()
	narsie_list.Remove(src)
	..()

/obj/machinery/singularity/narsie/large
	name = "Nar-Sie"
	icon = 'icons/obj/narsie.dmi'
	icon_state = "narsie"//mobs perceive the geometer of blood through their see_narsie proc

	// Pixel stuff centers Narsie.
	pixel_x = -236 * PIXEL_MULTIPLIER
	pixel_y = -256 * PIXEL_MULTIPLIER
	light_range = 1
	light_color = LIGHT_COLOR_RED

	current_size = 12
	consume_range = 12 // How many tiles out do we eat.
	var/announce=1
	var/narnar = 1
//	var/old_x
//	var/old_y

/obj/machinery/singularity/narsie/large/New()
	..()
	if(announce)
		to_chat(world, "<font size='15' color='red'><b>[uppertext(name)] HAS RISEN</b></font>")
		world << sound('sound/effects/wind/wind_5_1.ogg')
		if(narnar)
			narsie_spawn_animation()
	if(!narsie_cometh)//so we don't initiate Hell more than one time.
		/* Checks if the gamemode was cult
		if(istype(ticker.mode, /datum/game_mode/cult))
			var/datum/game_mode/cult/mode_ticker = ticker.mode
			if (mode_ticker.objectives[mode_ticker.current_objective] == "eldergod")
				mode_ticker.third_phase()*/

		if (emergency_shuttle)
			emergency_shuttle.incall()
			emergency_shuttle.can_recall = 0
			if(emergency_shuttle.endtime > world.timeofday + 1800 && emergency_shuttle.location != 1 && !emergency_shuttle.departed)
				emergency_shuttle.settimeleft(180)

		if(narnar)
			SetUniversalState(/datum/universal_state/hell)
		narsie_cometh = 1

	/* //For animating narsie manually, doesn't work well
	//Begin narsie vision
	for(var/mob/M in player_list)
		if(M.client)
			M.see_narsie(src)
	alpha = 0
	*/
/*
	updateicon()
*/

/obj/machinery/singularity/narsie/process()
	eat()

	if (!target || prob(5))
		pickcultist()

	move()

	if (prob(25))
		mezzer()

/obj/machinery/singularity/narsie/large/eat()
	set background = BACKGROUND_ENABLED

	for (var/turf/A in orange(consume_range, src))
		consume(A)

/obj/machinery/singularity/narsie/mezzer()
	for(var/mob/living/carbon/M in oviewers(8, src))
		if(M.stat == CONSCIOUS)
			if(M.flags & INVULNERABLE)
				continue
			if(!isanycultist(M))
				to_chat(M, "<span class='danger'>You feel your sanity crumble away in an instant as you gaze upon [src.name]...</span>")
				M.apply_effect(3, STUN)


/obj/machinery/singularity/narsie/large/to_bump(atom/A)
	if(!narnar)
		return
	if(isturf(A))
		narsiewall(A)
	else if(istype(A, /obj/structure/cult))
		qdel(A)

/obj/machinery/singularity/narsie/large/Bumped(atom/A)
	if(!narnar)
		return
	if(isturf(A))
		narsiewall(A)
	else if(istype(A, /obj/structure/cult))
		qdel(A)

/obj/machinery/singularity/narsie/move(var/force_move = 0)
	if(!move_self)
		return 0

	var/movement_dir = pick(alldirs - last_failed_movement)

	if(force_move)
		movement_dir = force_move

	if(target && prob(60))
		movement_dir = get_dir(src,target)

	spawn(0)
		step(src, movement_dir)
	spawn(1)
		step(src, movement_dir)
	return 1

/obj/machinery/singularity/narsie/large/move(var/force_move = 0)
	if(!move_self)
		return 0

	var/movement_dir = pick(alldirs - last_failed_movement)

	if(force_move)
		movement_dir = force_move

	if(target && prob(60))
		movement_dir = get_dir(src,target)
	spawn(0)
//		old_x = src.x
//		old_y = src.y
		step(src, movement_dir)
		narsiefloor(get_turf(loc))
		for(var/mob/M in player_list)
			if(M.client)
				M.see_narsie(src,movement_dir)
	spawn(10)
//		old_x = src.x
//		old_y = src.y
		step(src, movement_dir)
		narsiefloor(get_turf(loc))
		for(var/mob/M in player_list)
			if(M.client)
				M.see_narsie(src,movement_dir)
	return 1

/obj/machinery/singularity/narsie/proc/narsiefloor(var/turf/T)//leaving "footprints"
	if(!(istype(T, /turf/simulated/wall/cult)||istype(T, /turf/space)))
		if(T.icon_state != "cult-narsie")
			T.desc = "something that goes beyond your understanding went this way"
			T.icon_state = "cult-narsie"
			T.luminosity = 1

/obj/machinery/singularity/narsie/proc/narsiewall(var/turf/T)
	T.desc = "An opening has been made on that wall, but who can say if what you seek truly lies on the other side?"
	T.icon = 'icons/turf/walls.dmi'
	T.icon_state = "cult-narsie"
	T.opacity = 0
	T.setDensity(FALSE)
	luminosity = 1

/obj/machinery/singularity/narsie/large/consume(const/atom/A) //Has its own consume proc because it doesn't need energy and I don't want BoHs to explode it. --NEO
//NEW BEHAVIOUR
	if(narsie_behaviour == "CultStation13")
	//MOB PROCESSING
		if (istype(A, /mob/) && (get_dist(A, src) <= 7))
			var/mob/M = A

			if(M.flags & INVULNERABLE)
				return 0

			M.cultify()
			stat_collection.cult_narsie_corpses_fed++

	//ITEM PROCESSING
		else if (istype(A, /obj/))
			var/obj/O = A
			O.cultify()

	//TURF PROCESSING
		else if (isturf(A))
			var/dist = get_dist(A, src)

			for (var/atom/movable/AM in A.contents)
				if (dist <= consume_range)
					consume(AM)
					continue

				if (dist > consume_range && canPull(AM))
					if (101 == AM.invisibility)
						continue

			if (dist <= consume_range && !istype(A, /turf/space))
				var/turf/T = A
				if(T.holy)
					T.holy = 0 //Nar-Sie doesn't give a shit about sacred grounds.
				T.cultify()

//OLD BEHAVIOUR
	else if(narsie_behaviour == "Nar-Singulo")

		if (istype(A, /mob/living/))
			var/mob/living/C2 = A

			if(C2.flags & INVULNERABLE)
				return 0

			C2.dust() // Changed from gib(), just for less lag.

		else if (istype(A, /obj/))
			if (isbot(A))
				var/obj/machinery/bot/B = A
				if(B.flags & INVULNERABLE)
					return
			qdel(A)

			if (A)
				qdel(A)
		else if (isturf(A))
			var/dist = get_dist(A, src)

			for (var/atom/movable/AM2 in A.contents)
				if (AM2 == src) // This is the snowflake.
					continue

				if (dist <= consume_range)
					consume(AM2)
					continue

				if (dist > consume_range && canPull(AM2))

					if (101 == AM2.invisibility)
						continue

					spawn (0)
						step_towards(AM2, src)

			if (dist <= consume_range && !istype(A, get_base_turf(A.z)))
				var/turf/T2 = A
				T2.ChangeTurf(get_base_turf(T2.z))


/obj/machinery/singularity/narsie/consume(const/atom/A) //This one is for the small ones.

	if (istype(A, /mob/living/))
		var/mob/living/C2 = A

		if(C2.flags & INVULNERABLE)
			return 0

		C2.dust() // Changed from gib(), just for less lag.

	else if (istype(A, /obj/))
		if (isbot(A))
			var/obj/machinery/bot/B = A
			if(B.flags & INVULNERABLE)
				return
		qdel(A)

		if (A)
			qdel(A)
	else if (isturf(A))
		var/dist = get_dist(A, src)

		for (var/atom/movable/AM2 in A.contents)
			if (AM2 == src) // This is the snowflake.
				continue

			if (dist <= consume_range)
				consume(AM2)
				continue

			if (dist > consume_range && canPull(AM2))

				if (101 == AM2.invisibility)
					continue

				spawn (0)
					step_towards(AM2, src)

		if (dist <= consume_range && !istype(A, get_base_turf(A.z)))
			var/turf/T2 = A
			T2.ChangeTurf(get_base_turf(T2.z))

/obj/machinery/singularity/narsie/ex_act(severity) //No throwing bombs at it either. --NEO
	return

/obj/machinery/singularity/narsie/proc/pickcultist() //Narsie rewards his cultists with being devoured first, then picks a ghost to follow. --NEO
	var/list/cultists = list()
	var/datum/faction/cult = find_active_faction_by_type(/datum/faction/bloodcult)
	if (!cult)
		cult = find_active_faction_by_type(/datum/faction/cult/narsie)
	for(var/datum/mind/cult_nh_mind in cult.members)
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

	to_chat(target, "<span class='notice'><b>[capname] HAS LOST INTEREST IN YOU.</b></span>")
	target = food

	if (ishuman(target))
		to_chat(target, "<span class='danger'>[capname] HUNGERS FOR YOUR SOUL.</span>")
	else
		to_chat(target, "<span class='danger'>[capname] HAS CHOSEN YOU TO LEAD HIM TO HIS NEXT MEAL.</span>")

/obj/machinery/singularity/narsie/on_capture()
	chained = 1
	move_self = 0
	icon_state ="narsie-small-chains"

/obj/machinery/singularity/narsie/on_release()
	chained = 0
	move_self = 1
	icon_state ="narsie-small"

/obj/machinery/singularity/narsie/large/on_capture()
	chained = 1
	move_self = 0
	icon_state ="narsie-chains"
	for(var/mob/M in mob_list)//removing the client image of nar-sie while it is chained
		if(M.client)
			M.see_narsie(src)

/obj/machinery/singularity/narsie/large/on_release()
	chained = 0
	move_self = 1
	icon_state ="narsie"

/obj/machinery/singularity/narsie/cultify()
	return
/*
////////////////Glow//////////////////
/obj/machinery/singularity/narsie/proc/updateicon()
	overlays = 0
	overlays += image(icon,"glow-[icon_state]",overlay_layer)
*/


/**
 * Wizard narsie.
 */
/obj/machinery/singularity/narsie/wizard
	grav_pull = 0

/obj/machinery/singularity/narsie/wizard/eat()
	set background = BACKGROUND_ENABLED

	for (var/turf/T in trange(consume_range, src))
		consume(T)

/**
 * MR. CLEAN
 */
var/global/mr_clean_targets = list(
	/obj/effect/decal/cleanable,
	/obj/effect/decal/mecha_wreckage,
	/obj/effect/decal/remains,
	/obj/effect/plantsegment,
	///obj/effect/plant_controller,
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
	narnar = 0

/obj/machinery/singularity/narsie/large/clean/process()
	eat()

	if (!target || prob(5))
		pickuptrash()

	move()

	if (prob(25))
		mezzer()

/obj/machinery/singularity/narsie/large/clean/mezzer()
	for(var/mob/living/carbon/M in oviewers(8, src))
		if(M.stat == CONSCIOUS)
			if(M.flags & INVULNERABLE)
				continue
			to_chat(M, "<span class='warning'>You take a moment to admire [src.name] hard at work...</span>")
			M.apply_effect(3, STUN)

/obj/machinery/singularity/narsie/large/clean/update_icon()
	overlays = 0

	if (target && !isturf(target))
		overlays += image(icon = icon, icon_state = "eyes")

/obj/machinery/singularity/narsie/large/clean/acquire(var/mob/food)
	..()
	update_icon()

/obj/machinery/singularity/narsie/large/clean/consume(const/atom/A)

	if (istype(A, /mob/living/))

		var/mob/living/L = A
		if(L.flags & INVULNERABLE)
			return 0

		if (isrobot(L))
			var/mob/living/silicon/robot/R = L

			if (R.mmi)
				qdel(R.mmi) // Nuke MMI.
				R.mmi = null
		qdel(L) // Just delete it.
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

				if (101 == AM.invisibility)
					continue

				spawn (0)
					step_towards(AM, src)

/*
 * Mr. Clean just follows the dirt and grime.
 */
/obj/machinery/singularity/narsie/large/clean/proc/pickuptrash()
	var/list/targets = list()
	for(var/obj/effect/E in world)
		if(is_type_in_list(E, mr_clean_targets) && E.z == src.z)
			targets += E
	if(targets.len)
		acquire(pick(targets))
		return

/obj/machinery/singularity/narsie/large/clean/move(var/force_move = 0)
	if(!move_self)
		return 0

	var/movement_dir = pick(alldirs - last_failed_movement)

	if(force_move)
		movement_dir = force_move

	if(target && prob(60))
		movement_dir = get_dir(src,target)

	spawn(0)
		step(src, movement_dir)
	spawn(1)
		step(src, movement_dir)
	return 1

/obj/machinery/singularity/narsie/large/clean/on_capture()
	chained = 1
	move_self = 0

/obj/machinery/singularity/narsie/large/clean/on_release()
	chained = 0
	move_self = 1

/obj/machinery/singularity/narsie/large/calm//for when we want a Nar-Sie that stays put and doesn't end the round. Mostly for debug purposes.
	announce = 0
	move_self = 0
	consume_range = 0

/obj/machinery/singularity/narsie/large/calm/New()
	narsie_cometh = 1//so we don't force a shuttle call
	..()
	narsie_cometh = 0

/obj/machinery/singularity/narsie/large/calm/pickcultist()
	if(!move_self)
		return
	else
		..()

/obj/machinery/singularity/narsie/proc/narsie_spawn_animation()
	icon = 'icons/obj/narsie_spawn_anim.dmi'
	dir = SOUTH
	flick("narsie_spawn_anim",src)
	sleep(10)
	icon = 'icons/obj/narsie.dmi'
	icon_state = "narsie"
