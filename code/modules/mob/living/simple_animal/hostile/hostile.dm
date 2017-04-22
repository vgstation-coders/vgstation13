/mob/living/simple_animal/hostile
	faction = "hostile"
	stop_automated_movement_when_pulled = 0
	environment_smash = 1 //Set to 1 to break closets,tables,racks, etc; 2 for walls; 3 for rwalls

	var/stance = HOSTILE_STANCE_IDLE	//Used to determine behavior
	var/atom/target // /vg/ edit:  Removed type specification so spiders can target doors.
	var/attack_same = 0 //Set us to 1 to allow us to attack our own faction, or 2, to only ever attack our own faction
	var/ranged = 0
	var/rapid = 0
	var/projectiletype
	var/projectilesound
	var/casingtype
	var/move_to_delay = 2 //delay for the automated movement.
	var/list/friends = list()
	var/vision_range = 9 //How big of an area to search for targets in, a vision of 9 attempts to find targets as soon as they walk into screen view

	var/aggro_vision_range = 9 //If a mob is aggro, we search in this radius. Defaults to 9 to keep in line with original simple mob aggro radius
	var/idle_vision_range = 9 //If a mob is just idling around, it's vision range is limited to this. Defaults to 9 to keep in line with original simple mob aggro radius
	var/ranged_message = "fires" //Fluff text for ranged mobs
	var/ranged_cooldown = 0 //What the starting cooldown is on ranged attacks
	var/ranged_cooldown_cap = 3 //What ranged attacks, after being used are set to, to go back on cooldown, defaults to 3 life() ticks
	var/retreat_distance = null //If our mob runs from players when they're too close, set in tile distance. By default, mobs do not retreat.
	var/minimum_distance = 1 //Minimum approach distance, so ranged mobs chase targets down, but still keep their distance set in tiles to the target, set higher to make mobs keep distance
	var/search_objects = 0 //If we want to consider objects when searching around, set this to 1. If you want to search for objects while also ignoring mobs until hurt, set it to 2. To completely ignore mobs, even when attacked, set it to 3
	var/list/wanted_objects = list() //A list of objects that will be checked against to attack, should we have search_objects enabled
	var/stat_attack = 0 //Mobs with stat_attack to 1 will attempt to attack things that are unconscious, Mobs with stat_attack set to 2 will attempt to attack the dead.
	var/stat_exclusive = 0 //Mobs with this set to 1 will exclusively attack things defined by stat_attack, stat_attack 2 means they will only attack corpses
	var/attack_faction = null //Put a faction string here to have a mob only ever attack a specific faction
	var/friendly_fire = 0 //If set to 1, they won't hesitate to shoot their target even if a friendly is in the way.

/mob/living/simple_animal/hostile/resetVariables()
	..("wanted_objects", "friends", args)
	wanted_objects = list()
	friends = list()

/mob/living/simple_animal/hostile/Life()
	if(timestopped)
		return 0 //under effects of time magick
	. = ..()
	//Cooldowns
	if(ranged)
		ranged_cooldown--

	if(istype(loc, /obj/item/device/mobcapsule))
		return 0
	if(!.)
		walk(src, 0)
		return 0
	if(client && !deny_client_move)
		return 0
	if(!stat)
		if(size > SIZE_TINY && istype(loc, /obj/item/weapon/holder)) //If somebody picked us up and we're big enough to fight!
			var/mob/living/L = loc.loc
			if(!istype(L) || (L.faction != src.faction) || !CanAttack(L)) //If we're not being held by a mob, OR we're being held by a mob who isn't from our faction OR we're being held by a mob whom we don't consider a valid target!
				returnToPool(loc)
			else
				return 0

		switch(stance)
			if(HOSTILE_STANCE_IDLE)
				if(environment_smash)
					EscapeConfinement()
				var/new_target = FindTarget()
				GiveTarget(new_target)

			if(HOSTILE_STANCE_ATTACK)
				if(!(flags & INVULNERABLE))
					MoveToTarget()
					DestroySurroundings()

			if(HOSTILE_STANCE_ATTACKING)
				if(!(flags & INVULNERABLE))
					AttackTarget()
					DestroySurroundings()

//////////////HOSTILE MOB TARGETTING AND AGGRESSION////////////


/mob/living/simple_animal/hostile/proc/ListTargets()//Step 1, find out what we can see
	var/list/L = new()

	if (!search_objects)
		L.Add(ohearers(vision_range, src))

		for (var/obj/mecha/M in mechas_list)
			if (get_dist(M, src) <= vision_range && can_see(src, M, vision_range))
				L.Add(M)
	else
		L.Add(oview(vision_range, src))

	return L

/mob/living/simple_animal/hostile/proc/FindTarget()//Step 2, filter down possible targets to things we actually care about
	var/list/Targets = list()
	var/Target
	for(var/atom/A in ListTargets())
		if(Found(A))//Just in case people want to override targetting
			var/list/FoundTarget = list()
			FoundTarget += A
			Targets = FoundTarget
			break
		if(CanAttack(A))//Can we attack it?
			Targets += A
			continue
	Target = PickTarget(Targets)
	return Target //We now have a target

/mob/living/simple_animal/hostile/proc/Found(var/atom/A)//This is here as a potential override to pick a specific target if available
	return

/mob/living/simple_animal/hostile/proc/PickTarget(var/list/Targets)//Step 3, pick amongst the possible, attackable targets
	if(target != null)//If we already have a target, but are told to pick again, calculate the lowest distance between all possible, and pick from the lowest distance targets
		for(var/atom/A in Targets)
			var/target_dist = get_dist(src, target)
			var/possible_target_distance = get_dist(src, A)
			if(target_dist < possible_target_distance)
				Targets -= A
	if(!Targets.len)//We didnt find nothin!
		return
	var/chosen_target = pick(Targets)//Pick the remaining targets (if any) at random
	return chosen_target

/mob/living/simple_animal/hostile/CanAttack(var/atom/the_target)//Can we actually attack a possible target?
	if(see_invisible < the_target.invisibility)//Target's invisible to us, forget it
		return 0
	if(isliving(the_target) && search_objects < 2)
		var/mob/living/L = the_target
		//WE ONLY ATTACK LIVING MOBS UNLESS SPECIFIED OTHERWISE
		if(L.stat > stat_attack || (L.stat != stat_attack && stat_exclusive == 1))
			return 0
		//WE DON'T ATTACK INVULNERABLE MOBS (such as etheral jaunting mobs, or passengers of the adminbus)
		if(L.flags & INVULNERABLE)
			return 0
		//WE DON'T ATTACK MOMMI
		if(isMoMMI(L))
			return 0
		//WE DON'T OUR OWN FACTION UNLESS SPECIFIED OTHERWISE
		if((L.faction == src.faction && !attack_same) || (L.faction != src.faction && attack_same == 2) || (L.faction != attack_faction && attack_faction))
			return 0
		//IF OUR FACTION IS A REFERENCE TO A SPECIFIC MOB THEN WE DON'T ATTACK HIM (examples include viscerator grenades, staff of animation mimics, asteroid monsters)
		if((faction == "\ref[L]") && !attack_same)
			return 0
		//IF WE ARE GOLD SLIME+PLASMA MONSTERS THEN WE DON'T ATTACK SLIMES/SLIME PEOPLE/ADAMANTINE GOLEMS
		if(faction == "slimesummon")
			if(isslime(L))
				return 0
			if(ishuman(L))
				var/mob/living/carbon/human/H = L
				if(H.dna)
					if((H.dna.mutantrace == "slime") || (isgolem(H)))
						return 0
		//IF WE ARE MOBS SPAWNED BY THE ADMINBUS THEN WE DON'T ATTACK TEST DUMMIES OR IAN (wait what? man that's snowflaky as fuck)
		if((istype(L,/mob/living/simple_animal/corgi/Ian) || istype(L,/mob/living/carbon/human/dummy)) && (faction == "adminbus mob"))
			return 0
		//WE DON'T ATTACK OUR FRIENDS (used by lazarus injectors, and rabid slimes)
		if(friends.Find(L))
			return 0
		return 1
	if(isobj(the_target))
		//if(the_target.type in wanted_objects)
		if(is_type_in_list(the_target,wanted_objects))
			return 1
		if(istype(the_target, /obj/mecha) && search_objects < 2)
			var/obj/mecha/M = the_target
			if(M.occupant)//Just so we don't attack empty mechs
				if(CanAttack(M.occupant))
					return 1
	return 0

/mob/living/simple_animal/hostile/proc/GiveTarget(var/new_target)//Step 4, give us our selected target
	target = new_target
	if(target != null)
		Aggro()
		stance = HOSTILE_STANCE_ATTACK
	return

/mob/living/simple_animal/hostile/proc/MoveToTarget()//Step 5, handle movement between us and our target
	stop_automated_movement = 1
	if(!target || !CanAttack(target))
		LoseTarget()
		return

	if(isturf(loc))
		if(target in ListTargets())
			var/target_distance = get_dist(src,target)
			if(ranged)//We ranged? Shoot at em
				if(target_distance >= 2 && ranged_cooldown <= 0)//But make sure they're a tile away at least, and our range attack is off cooldown
					OpenFire(target)
			if(target.Adjacent(src))	//If they're next to us, attack
				AttackingTarget()
			if(canmove && space_check())
				if(retreat_distance != null && target_distance <= retreat_distance) //If we have a retreat distance, check if we need to run from our target
					walk_away(src,target,retreat_distance,move_to_delay)
				else
					Goto(target,move_to_delay,minimum_distance)//Otherwise, get to our minimum distance so we chase them
			return

	if(target.loc != null && get_dist(src, target.loc) <= vision_range)//We can't see our target, but he's in our vision range still
		if(FindHidden(target) && environment_smash)//Check if he tried to hide in something to lose us
			var/atom/A = target.loc
			if(canmove && space_check())
				Goto(A,move_to_delay,minimum_distance)
			if(A.Adjacent(src))
				A.attack_animal(src)
			return
		else
			LostTarget()
			return

	LostTarget()

/mob/living/simple_animal/hostile/proc/Goto(var/target, var/delay, var/minimum_distance)
	walk_to(src, target, minimum_distance, delay)

/mob/living/simple_animal/hostile/adjustBruteLoss(var/damage)
	..(damage)
	if(!stat && search_objects < 3)//Not unconscious, and we don't ignore mobs
		if(search_objects)//Turn off item searching and ignore whatever item we were looking at, we're more concerned with fight or flight
			search_objects = 0
			target = null
		if(stance == HOSTILE_STANCE_IDLE)//If we took damage while idle, immediately attempt to find the source of it so we find a living target
			Aggro()
			var/new_target = FindTarget()
			GiveTarget(new_target)
		if(stance == HOSTILE_STANCE_ATTACK)//No more pulling a mob forever and having a second player attack it, it can switch targets now if it finds a more suitable one
			if(target != null && prob(25))
				var/new_target = FindTarget()
				GiveTarget(new_target)

/mob/living/simple_animal/hostile/proc/AttackTarget()


	stop_automated_movement = 1
	if(!target || !CanAttack(target))
		LoseTarget()
		return 0
	if(!(target in ListTargets()))
		LostTarget()
		return 0
	if(isturf(loc) && target.Adjacent(src))
		AttackingTarget()
		return 1

/mob/living/simple_animal/hostile/proc/AttackingTarget()
	target.attack_animal(src)

/mob/living/simple_animal/hostile/proc/Aggro()
	vision_range = aggro_vision_range

/mob/living/simple_animal/hostile/proc/LoseAggro()
	stop_automated_movement = 0
	vision_range = idle_vision_range

/mob/living/simple_animal/hostile/proc/LoseTarget()
	stance = HOSTILE_STANCE_IDLE
	target = null
	walk(src, 0)
	LoseAggro()

/mob/living/simple_animal/hostile/proc/LostTarget()
	stance = HOSTILE_STANCE_IDLE
	walk(src, 0)
	LoseAggro()

//////////////END HOSTILE MOB TARGETTING AND AGGRESSION////////////

/mob/living/simple_animal/hostile/Die()
	LoseAggro()
	..()
	walk(src, 0)

/mob/living/simple_animal/hostile/inherit_mind(mob/living/simple_animal/from)
	..()

	var/mob/living/simple_animal/hostile/H = from
	if(istype(H))
		src.friends |= H.friends

/mob/living/simple_animal/hostile/proc/OpenFire(var/atom/ttarget)
	set waitfor = 0

	var/target_turf = get_turf(ttarget)
	if(rapid)
		sleep(1)
		TryToShoot(target_turf, ttarget)
		sleep(3)
		TryToShoot(target_turf, ttarget)
		sleep(3)
		TryToShoot(target_turf, ttarget)
	else
		TryToShoot(target_turf, ttarget)

/mob/living/simple_animal/hostile/proc/TryToShoot(var/atom/target_turf, atom/target)
	if(!target)
		target = src.target

	if(Shoot(target_turf, src.loc, src))
		ranged_cooldown = ranged_cooldown_cap
		if(ranged_message)
			visible_message("<span class='warning'><b>[src]</b> [ranged_message] at [target]!</span>", 1)
		if(casingtype)
			new casingtype(get_turf(src))

/mob/living/simple_animal/hostile/proc/Shoot(var/atom/target, var/atom/start, var/mob/user, var/bullet = 0)
	if(target == start)
		return 0
	if(!istype(target, /turf))
		return 0

	//Friendly Fire check (don't bother if the mob is controlled by a player)
	if(!friendly_fire && !ckey)
		var/obj/item/projectile/friendlyCheck/fC = getFromPool(/obj/item/projectile/friendlyCheck,user.loc)
		fC.current = target
		var/turf/T = get_turf(user)
		var/turf/U = get_turf(target)
		fC.original = target
		fC.target = U
		fC.current = T
		fC.starting = T
		fC.yo = target.y - start.y
		fC.xo = target.x - start.x

		var/atom/potentialImpact = fC.process()
		if(potentialImpact && !CanAttack(potentialImpact))
			returnToPool(fC)
			return 0
		returnToPool(fC)
	//Friendly Fire check - End

	var/obj/item/projectile/A = new projectiletype(user.loc)

	if(!A)
		return 0

	playsound(user, projectilesound, 100, 1)

	A.current = target

	var/turf/T = get_turf(src)
	var/turf/U = get_turf(target)
	A.original = target
	A.target = U
	A.current = T
	A.starting = T
	A.yo = target.y - start.y
	A.xo = target.x - start.x
	spawn()
		A.OnFired()
		A.process()

	return 1

/mob/living/simple_animal/hostile/proc/DestroySurroundings()
	if(environment_smash)
		EscapeConfinement()
		var/list/smash_dirs = list(0)
		if(!target || !CanAttack(target))
			smash_dirs |= alldirs //if no target, attack everywhere
		else
			var/targdir = get_dir(src, target)
			smash_dirs |= widen_dir(targdir) //otherwise smash towards the target
		for(var/dir in smash_dirs)
			var/turf/T = get_step(src, dir)
			if(istype(T, /turf/simulated/wall) && Adjacent(T))
				T.attack_animal(src)
			for(var/atom/A in T)
				if((istype(A, /obj/structure/window) || istype(A, /obj/structure/closet) || istype(A, /obj/structure/table) || istype(A, /obj/structure/grille) || istype(A, /obj/structure/rack)) && Adjacent(A))
					A.attack_animal(src)
	return

/mob/living/simple_animal/hostile/proc/EscapeConfinement()
	if(locked_to)
		locked_to.attack_animal(src)
	if(!isturf(src.loc) && src.loc != null)//Did someone put us in something?
		var/atom/A = src.loc
		A.attack_animal(src)//Bang on it till we get out
	return

/mob/living/simple_animal/hostile/proc/FindHidden(var/atom/hidden_target)
	if(istype(target.loc, /obj/structure/closet) || istype(target.loc, /obj/machinery/disposal) || istype(target.loc, /obj/machinery/sleeper))
		return 1
	else
		return 0

//Let players use mobs' ranged attacks
/mob/living/simple_animal/hostile/Stat()
	..()

	if(ranged && statpanel("Status"))
		stat(null, "Ranged Attack: [ranged_cooldown <= 0 ? "READY" : "[100 - round((ranged_cooldown / ranged_cooldown_cap) * 100)]%"]")

/mob/living/simple_animal/hostile/RangedAttack(atom/A, params)
	if(ranged && ranged_cooldown <= 0)
		OpenFire(A)

	return ..()
