

//////////////////////BEE DATUMS///////////////////////////////////////

/datum/fly
	var/mob/living/simple_animal/fly/mob = null
	var/health = 10
	var/maxHealth = 10
	var/corpse = /obj/effect/decal/cleanable/fly

/datum/fly/proc/Die()
	if (mob)
		new corpse(get_turf(mob))
		mob.flies.Remove(src)
		mob = null
	qdel(src)

//////////////////////BEE CORPSES///////////////////////////////////////

/obj/effect/decal/cleanable/fly
	name = "dead fly"
	desc = "Annoying piece of shit."
	gender = PLURAL
	icon = 'icons/obj/apiary_bees_etc.dmi'
	icon_state = "bee_dead"
	anchored = 0
	mouse_opacity = 1
	plane = LYING_MOB_PLANE

/obj/effect/decal/cleanable/fly/New()
	..()
	dir = pick(cardinal)
	pixel_x = rand(-10,10)
	pixel_y = rand(-4,4)

//////////////////////FLY EGGS//////////////////////////////////////
/obj/item/weapon/reagent_containers/food/snacks/fly_eggs
	name = "fly eggs"
	desc = "You're not thinking of eating these... are you?"
	icon = 'icons/mob/mob.dmi'
	icon_state = "borer egg-growing"
	bitesize = 3
	var/time_left_to_hatch = 0
	var/grown = 0
	var/hatching = 0 // So we don't spam ghosts.

/obj/item/weapon/reagent_containers/food/snacks/fly_eggs/New()
	..()
	time_left_to_hatch = rand(10,20)
	processing_objects.Add(src)

/obj/item/weapon/reagent_containers/food/snacks/fly_eggs/process()
	if(!istype(src.loc, /atom/movable)) //we want them INSIDE rotten food/corpses
		return
	if(time_left_to_hatch<=0)
		time_left_to_hatch = 0
		var/atom/movable/M = src.loc
		M.desc += " You can see tiny worms moving around. Gross."
		var/turf/T = get_turf(src)
		new /mob/living/simple_animal/fly(T, M, rand(1,4))
		Destroy()
	time_left_to_hatch--

/obj/item/weapon/reagent_containers/food/snacks/fly_eggs/Destroy()
	processing_objects.Remove(src)
	..()
//////////////////////FLY MOB///////////////////////////////////////

/mob/living/simple_animal/fly
	name = "swarm of flies"
	icon = 'icons/obj/apiary_bees_etc.dmi'
	icon_state = "flies1"
	icon_dead = "bee_dead"

	mob_property_flags = MOB_SWARM
	size = SIZE_TINY
	can_butcher = 0

	var/atom/destination = null
	var/list/flies = list()
	var/atom/target = null
	pass_flags = PASSTABLE
	turns_per_move = 6
	density = 0
	gender = PLURAL

	// Allow final solutions.
	min_oxy = 5
	max_oxy = 0
	min_tox = 0
	max_tox = 1
	min_co2 = 0
	max_co2 = 5
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0
	maxbodytemp = 360

	holder_type = null //Can't pick them up!
	flying = 1
	meat_type = 0

	held_items = list()

/mob/living/simple_animal/fly/New(loc, var/atom/new_target, var/amount_of_flies)
	..()
	var/matrix/M = matrix()
	M.Scale(0.5,0.5)
	animate(src, transform = M)
	target = new_target
	if(amount_of_flies <= 0)
		amount_of_flies = 3
	for (var/i = 1 to amount_of_flies)
		var/datum/fly/F = new()
		addFly(F)
	update_icon()

/mob/living/simple_animal/fly/Destroy()
	..()


/mob/living/simple_animal/fly/Die()
	returnToPool(src)

/mob/living/simple_animal/fly/gib()
	death(1)
	monkeyizing = 1
	canmove = 0
	icon = null
	invisibility = 101

	dead_mob_list -= src

	qdel(src)

/mob/living/simple_animal/fly/Cross(atom/movable/mover, turf/ttarget, height=1.5, air_group = 0)
	if(istype(mover, /obj/item/projectile))

		if (prob(min(100,flies.len * 4)))
			return 0
	return 1



//DEALING WITH DAMAGE
/mob/living/simple_animal/fly/attackby(var/obj/item/O as obj, var/mob/user as mob)
	user.delayNextAttack(8)
	if (istype(O,/obj/item/weapon/bee_net)) return
	if(O.force)
		var/damage = O.force
		if (O.damtype == HALLOSS)
			damage = 0
		adjustBruteLoss(damage)
		user.visible_message("<span class='danger'>[src] has been attacked with [O] by [user]. </span>")

/mob/living/simple_animal/fly/ex_act(severity)
	switch(severity)
		if (1)
			qdel(src)
		if (2)
			adjustBruteLoss(100)
		if (3)
			adjustBruteLoss(20)

/mob/living/simple_animal/fly/adjustBruteLoss(var/amount)
	if(status_flags & GODMODE)
		return 0

	while (amount > 0 && flies.len)
		var/datum/fly/F = pick(flies)
		if (F.health > amount)
			F.health -= amount
			amount = 0
		else
			amount -= F.health
			F.Die()

	if (flies.len <= 0)
		qdel(src)
	update_icon()


//CUSTOM PROCS
/mob/living/simple_animal/fly/proc/addFly(var/datum/fly/F)
	flies.Add(F)
	F.mob = src

////////////////////////////////LIFE////////////////////////////////////////

/mob/living/simple_animal/fly/Life()
	if(timestopped)
		return 0

	..()

	if (!flies || flies.len <= 0)
		qdel(src)
		return

	if(stat != DEAD)

		if(target)
			var/target_turf = get_turf(target)
			if(src.loc == target_turf)
				return
			else if(target in view(src, 10))
				var/tdir = get_dir(src,target_turf)
				var/turf/move_to = get_step(src, tdir)
				walk_to(src,move_to)

	update_icon()


////////////////////////////////UPDATE ICON/////////////////////////////////

/mob/living/simple_animal/fly/update_icon()
	overlays.len = 0

	if(flies.len <= 0)
		return

	for (var/D in flies)
		if (flies.len >= 15)
			icon_state = "flies-swarm"
		else
			icon_state = "flies[min(flies.len,10)]"

	animate(src, pixel_x = rand(-12,12) * PIXEL_MULTIPLIER, pixel_y = rand(-12,12) * PIXEL_MULTIPLIER, time = 10, easing = SINE_EASING)

	if(flies.len <= 1)
		gender = NEUTER
		name = "lonely fly"
	else
		gender = PLURAL
		name = "swarm of flies"
