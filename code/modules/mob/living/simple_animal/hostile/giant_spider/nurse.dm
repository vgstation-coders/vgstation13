#define MAX_SQUEENS 5

//nursemaids - these create webs and eggs
// Slower
/mob/living/simple_animal/hostile/giant_spider/nurse
	desc = "Furry and black, it makes you shudder to look at it. This one has brilliant green eyes."
	icon_state = "nurse"
	icon_living = "nurse"
	icon_dead = "nurse_dead"
	maxHealth = 75 // 40
	health = 75
	melee_damage_lower = 5
	melee_damage_upper = 10
	poison_per_bite = 10
	poison_type = STOXIN
	species_type = /mob/living/simple_animal/hostile/giant_spider/nurse/queen_spider
	search_objects = TRUE
	stat_attack = 2
	var/fed = 0

/mob/living/simple_animal/hostile/giant_spider/nurse/initialize_rules()
	target_rules.Add(new /datum/fuzzy_ruling/is_mob)
	target_rules.Add(new /datum/fuzzy_ruling/is_obj{weighting = 0.01})
	var/datum/fuzzy_ruling/distance/D = new /datum/fuzzy_ruling/distance
	D.set_source(src)
	target_rules.Add(D)

/mob/living/simple_animal/hostile/giant_spider/nurse/proc/check_evolve()
	if(animal_count[species_type] < MAX_SQUEENS && !key)	//don't evolve if there's a player inside
		grow_up()
		return 1
	return 0

/mob/living/simple_animal/hostile/giant_spider/nurse/Life()
	if(timestopped || istype(loc,/obj/item/device/mobcapsule))
		return
	..()
	if(!stat && stance == HOSTILE_STANCE_IDLE)
		if(check_evolve())
			return
		if(spin_web(get_turf(src)) && fed > 0)
			lay_eggs()

/mob/living/simple_animal/hostile/giant_spider/nurse/CanAttack(var/atom/the_target)
	if(isitem(the_target))
		return TRUE
	return ..()

/mob/living/simple_animal/hostile/giant_spider/nurse/AttackingTarget()
	if(isitem(target))
		return spin_cocoon(target)
	if(isliving(target))
		var/mob/living/L = target
		if(L.stat) //Unconscious, or dead
			return spin_cocoon(target)
	return ..()

/mob/living/simple_animal/hostile/giant_spider/nurse/proc/spin_web(var/turf/T)
	if(!T.has_gravity(src))
		return 0
	if(!locate(/obj/effect/spider/stickyweb) in T)
		new /obj/effect/spider/stickyweb(T)
	return 1

/mob/living/simple_animal/hostile/giant_spider/nurse/proc/lay_eggs()
	var/obj/effect/spider/eggcluster/E = locate() in get_turf(src)
	if(!E)
		src.visible_message("<span class='notice'>\the [src] begins to lay a cluster of eggs.</span>")
		stop_automated_movement = 1
		spawn(50)
			E = locate() in get_turf(src)
			if(!E)
				new /obj/effect/spider/eggcluster(src.loc)
				fed--
			stop_automated_movement = 0

/mob/living/simple_animal/hostile/giant_spider/nurse/proc/spin_cocoon(var/atom/cocoon_target)
	if(locate(/obj/effect/spider/cocoon) in cocoon_target.loc)
		return
	src.visible_message("<span class='notice'>\the [src] begins to secrete a sticky substance around \the [cocoon_target].</span>")
	spawn(50)
		if(cocoon_target && istype(cocoon_target.loc, /turf) && get_dist(src,cocoon_target) <= 1)
			var/obj/effect/spider/cocoon/C = new(cocoon_target.loc)
			var/large_cocoon = 0
			C.pixel_x = cocoon_target.pixel_x
			C.pixel_y = cocoon_target.pixel_y
			for(var/mob/living/M in C.loc)
				if(istype(M, /mob/living/simple_animal/hostile/giant_spider))
					continue
				large_cocoon = 1
				if(M.getCloneLoss() < 125)
					fed++
					src.visible_message("<span class='warning'>\the [src] sticks a proboscis into \the [cocoon_target] and sucks a viscous substance out.</span>")
					M.adjustCloneLoss(30 * size)
				M.forceMove(C)
				C.pixel_x = M.pixel_x
				C.pixel_y = M.pixel_y
				break
			for(var/obj/item/I in C.loc)
				I.forceMove(C)
			for(var/obj/structure/S in C.loc)
				if(!S.anchored)
					S.forceMove(C)
					large_cocoon = 1
			for(var/obj/machinery/M in C.loc)
				if(!M.anchored)
					M.forceMove(C)
					large_cocoon = 1
			if(large_cocoon)
				C.icon_state = pick("cocoon_large1","cocoon_large2","cocoon_large3")
				C.health = initial(C.health)*2
		stop_automated_movement = 0


/mob/living/simple_animal/hostile/giant_spider/nurse/queen_spider
	name = "spider queen"
	desc = "Massive, dark, and very furry. This is an absolutely massive spider. Its fangs are almost as big as you!"
	icon = 'icons/mob/giantmobs.dmi'			//Both the alien queen sprite and the queen spider sprite are 64x64, it seemed pointless to make a new file for two new states
	icon_state = "spider_queen1"
	icon_living = "spider_queen1"
	icon_dead = "spider_queen_dead"
	pixel_x = -16 * PIXEL_MULTIPLIER
	maxHealth = 500
	health = 500
	melee_damage_lower = 30
	melee_damage_upper = 40
	speed = 6
	projectiletype = /obj/item/projectile/web
	projectilesound = 'sound/weapons/pierce.ogg'
	ranged = 1
	size = SIZE_HUGE
	delimbable_icon = FALSE

/mob/living/simple_animal/hostile/giant_spider/nurse/queen_spider/check_evolve()
	return 0

/obj/item/projectile/web
	icon_state = "web"
	damage = 5
	damage_type = BRUTE

/obj/item/projectile/web/to_bump(atom/A)
	if(!(locate(/obj/effect/spider/stickyweb) in get_turf(src)))
		new /obj/effect/spider/stickyweb(get_turf(src))
	qdel(src)
