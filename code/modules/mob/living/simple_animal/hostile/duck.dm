/mob/living/simple_animal/hostile/roboduck
	name = "robot duck"
	desc = "A strange automaton in the shape of a rubber duck."
	icon_state = "Duck_lord"
	icon_living = "Duck_lord_friendly"
	response_help = "hugs"
	icon_dead = null //Explodes on death
	health = 1000
	maxHealth = 1000
	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0
	ranged = 1
	ranged_cooldown_cap = 10
	projectiletype = /obj/item/projectile/bullet/midbullet/lawgiver
	projectilesound = 'sound/weapons/gatling_fire.ogg'
	friendly_fire = TRUE
	melee_damage_lower = 10
	melee_damage_upper = 20
	attack_sound = 'sound/weapons/circsawhit.ogg'
	stat_attack = DEAD
	vision_range = 12
	var/angered
	var/list/enemies = list()
	var/dying

/mob/living/simple_animal/hostile/roboduck/examine(mob/user)
	..()
	to_chat(user, angered?"<span class = 'warning'>It is actively hunting something, and seems to be malfunctioning.</span>":"<span class = 'notice'>It looks incredibly friendly!</span>")

/mob/living/simple_animal/hostile/roboduck/New()
	..()
	update_icon()

/mob/living/simple_animal/hostile/roboduck/update_icon()
	if(angered)
		icon_state = "[initial(icon_state)]_hostile"
	else
		icon_state = "[initial(icon_state)]_friendly"

/mob/living/simple_animal/hostile/roboduck/Aggro()
	..()
	if(!angered && do_flick(src, "[initial(icon_state)]_angered"))
		playsound(src, 'sound/misc/quacktivated.ogg', 40, TRUE)
		angered = TRUE
		update_icon()

/mob/living/simple_animal/hostile/roboduck/LoseAggro()
	..()
	if(angered && do_flick(src, "[initial(icon_state)]_calming"))
		playsound(src, 'sound/misc/roboquack.ogg', 40, TRUE)
		angered = FALSE
		update_icon()

/mob/living/simple_animal/hostile/roboduck/bullet_act(var/obj/item/projectile/Proj)
	if(dying)
		return
	do_teleport(src, get_turf(src), 3, asoundout = 'sound/misc/roboquack.ogg')
	.=..()
	if(Proj.firer)
		enemies.Add(Proj.firer)

/mob/living/simple_animal/hostile/roboduck/attackby(obj/W, mob/user)
	.=..()
	if(user)
		enemies.Add(user)

/mob/living/simple_animal/hostile/roboduck/attack_hand(mob/user)
	.=..()
	if(user && user.a_intent != I_HELP)
		enemies.Add(user)

/mob/living/simple_animal/hostile/roboduck/ex_act()
	return

/mob/living/simple_animal/hostile/roboduck/ListTargets()//Only returns those who have made themselves our enemies
	return enemies

/mob/living/simple_animal/hostile/roboduck/CanAttack(var/atom/the_target) //This should only be passed the contents of enemies, so we'll use it for filtering
	if(the_target.gcDestroyed)
		enemies.Remove(the_target)
		return 0
	.=..()
	if(!.)
		enemies.Remove(the_target)

/mob/living/simple_animal/hostile/roboduck/MoveToTarget()
	if(dying)
		return
	if(isturf(loc))
		if(get_dist(src, target) >= vision_range)
			var/list/L = view(get_turf(target), 4)
			var/list/LL = list()
			for(var/turf/T in L)
				if(T.density || (locate(/obj/machinery/door) in T.contents) || (locate(/obj/structure/window) in T.contents))
					continue
				LL.Add(T)
			if(LL.len)
				var/turf/T = get_turf(pick(LL)) //Gets a turf in view of the target, that does not have dense structures on it that could impede movement
				do_teleport(src, T, 1, asoundout = 'sound/misc/roboquack.ogg')
	..()

/mob/living/simple_animal/hostile/roboduck/OpenFire()
	set waitfor = 0
	if(dying)
		return
	playsound(src, 'sound/misc/quacktivated.ogg', 40, 5, 4)
	do_flick(src, "[initial(icon_state)]_gunfetti_start", 5)
	icon_state = "[initial(icon_state)]_gunfetti_loop"
	var/volleys = rand(2,5)
	for(var/i = 0,i < volleys, i++)
		for(var/direction in alldirs)
			sleep(1)
			if(gcDestroyed || dying)
				return
			var/turf/destination = get_ranged_target_turf(get_turf(src), direction, 10)
			TryToShoot(destination)
	do_flick(src, "[initial(icon_state)]_gunfetti_end", 5)
	update_icon()

/mob/living/simple_animal/hostile/roboduck/AttackingTarget()
	if(isliving(target))
		var/mob/living/L = target
		if(!L.isDead())
			return ..()
		do_flick(src, "[initial(icon_state)]_dinnertime_start", 6)
		icon_state = "[initial(icon_state)]_dinnertime_loop"
		playsound(src, 'sound/effects/gib2.ogg', 50, 1)
		L.forceMove(get_turf(src))
		if(ishuman(L))
			var/mob/living/carbon/human/H = L
			var/datum/organ/external/head/head_organ = H.get_organ(LIMB_HEAD) //So they're not permanently removed from the game
			if(head_organ)
				head_organ.explode()
		for(var/i = 0 to L.size)
			if(prob(20))
				new /obj/item/weapon/bikehorn/rubberducky/quantum(get_turf(L))
			else
				new /obj/item/weapon/bikehorn/rubberducky(get_turf(L))
		adjustBruteLoss(-50*L.size)
		enemies.Remove(L)
		L.gib()
		do_flick(src, "[initial(icon_state)]_dinnertime_end", 6)
		return
	..()

/mob/living/simple_animal/hostile/roboduck/death(var/gibbed = 0)
	if(!dying)
		canmove = 0
		walk(src,0)
		dying = TRUE
		visible_message("<span class = 'warning'>Something cracks and breaks within \the [src], as it begins to implode!</span>")
		for(var/mob/living/M in view(src))
			M.playsound_local(get_turf(src), get_sfx("explosion"), 100, 1, get_rand_frequency(), falloff = 5)
			if(!M.client)
				continue
			var/int_distance = get_dist(M, src)
			shake_camera(M, 5, 2/int_distance)
		playsound(src, 'sound/misc/roboquack_death.ogg', 40, TRUE, falloff = 5)
		var/matrix/death_animation = matrix()
		death_animation.Scale(0,0)
		death_animation.Turn(120)
		animate(src, transform = death_animation, time = 5 SECONDS, easing = QUAD_EASING)
		spawn(5 SECONDS)
			..(TRUE)
			robogibs(get_turf(src))
			qdel(src)
