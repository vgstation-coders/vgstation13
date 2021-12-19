/mob/living/simple_animal/hostile/fishing/kleptopus
	name = "kleptopus"
	desc = "A proven descendent of earth octopi, they are widely accepted to be the most intelligent species of space fish."
	icon_state = "kleptopus"
	icon_living = "kleptopus"
	icon_dead = "kleptopus_dead"
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/kleptopus
	attacktext = "slaps"
	minimum_distance = 2
	casingtype = null
	ranged = 1
	projectiletype = /obj/item/projectile/hookshot/whip/kleptopus
	projectilesound = 'sound/weapons/whip_crack.ogg'
	ranged_message = "throws"
	ranged_cooldown = 2
	size = SIZE_NORMAL
	search_objects = 2
	maxHealth = 75
	health = 75
	minCatchSize = 30
	maxCatchSize = 60
	var/list/suctionItems = list()
	var/list/caughtBullets = list()
	var/armsToHold = 8

	wanted_objects = list(/obj/item) //He just likes to steal, he doesn't care what
	unwanted_objects = list(/obj/item/device/assembly_holder, /obj/item/weapon/disk/nuclear/nukedisk)

/mob/living/simple_animal/hostile/fishing/kleptopus/openFire(var/atom/A)
	if(istype(target, /obj/item))
		var/obj/item/O = A
		if(O.loc == src || O.anchored || is_type_in_list(unwanted_objects))
			LoseTarget()
			return
		if(!armsToHold && search_objects)
			search_objects = 0
			LoseTarget() //Oh wait my hands are full, time to slap
			return
		if(I.w_class > W_CLASS_SMALL && mutation != FISH_STRONG | FISH_GRAVITY | FISH_TELEKINETIC)
			LoseTarget()
			return
		..()
		spawn(10)
			if(O.adjacent)
				visible_message("<span class='notice'>\The [src] picks up the [O] with its suction cups.</span>")
				O.forceMove(src)
				suctionItems += O
				armsToHold--
	else
		..()
		if(ishuman(target))
			var/mob/living/carbon/H = target
			if(mutation)
				switch(mutation)
					if(FISH_CLOWN)
						H.Knockdown(1)
					if(FISH_EMP)
						var/turf/T = get_turf(H)
						empulse(T, 0, 0)
					if(FISH_GREEDY)
						var/stealI = pick(get_contents_in_object(H)) //to-do: Does this steal organs?
						stealI.forcemove(H.loc)


/mob/living/simple_animal/hostile/fishing/kleptopus/Life()
	if(..())
		if(prob(catchSize/2))
			octoTinker()

/mob/living/simple_animal/hostile/fishing/kleptopus/death(var/gibbed = FALSE)
	if(suctionItems.len)
		for(var/i in suctionItems)
			i.forceMove(loc)
	..(gibbed)

/mob/living/simple_animal/hostile/fishing/kleptopus/bullet_act(var/obj/item/projectile/Proj)
	if(!armsToHold || !istype(Proj, /obj/item/projectile/bullet))
		..()
	else
		var/obj/item/projectile/bullet/B = Proj
		armsToHold--
		caughtBullets += B //KA KA KA KA KACHI DAZE
		visible_message("<span class='danger'>The [src] catches the [B]!</span>")
		qdel(B)

/mob/living/simple_animal/hostile/fishing/kleptopus/create_projectile(var/mob/user)
	if(!caughtBullets.len)
		projectiletype = /obj/item/projectile/hookshot/whip/kleptopus
		return
	var/bToThrow = caughtBullets[1]
	projectiletype = bToThrow
	caughtBullets -= bToThrow
	armsToHold++
	return new projectiletype(user.loc)

/mob/living/simple_animal/hostile/fishing/kleptopus/proc/octoTinker()
	var/tI = pick(suctionItems)
	if(isassembly(tI))
		octoAssemble(tI)
	if(istool(tI))
		octoGremlin(tI)
	if(istype(tI, /obj/item/weapon/reagent_containers/glass))
		octoChemist(tI)
	if(istype(tI, /obj/item/device/deskbell))
		var/obj/item/device/deskbell/B = tI
		B.ring()
	var/list/can_see = view(src, vision_range)
	var/cTarg = pick(can_see)
	tI.attack(cTarg)	//If it isn't in his list of interactions he'll just try "using" it. Might whack someone, might take their picture.
	if(tI.gcDestroyed)
		suctionItems -= tI

/mob/living/simple_animal/hostile/fishing/kleptopus/proc/octoAssemble(var/obj/item/tI)
	for(var/obj/item/device/assembly/A in suctionItems)
		if(A != tI)
			var/obj/item/device/assembly/B = tI
			A.secured = 0
			B.secured = 0
			B.attack(A, src)
			suctionItems -= A
			suctionItems -= B	//to-do: I am 90% sure this won't work
			break

/mob/living/simple_animal/hostile/fishing/kleptopus/proc/octoGremlin(var/obj/item/tI)
	for(var/obj/machinery/M in orange(4))
		goto(M)
		if(M.adjacent)
			visible_message("<span class='notice'>\The [src] is trying to use a [tI] on [M]!</span>")
			tI.attack(M)

/mob/living/simple_animal/hostile/fishing/kleptopus/proc/octoChemist(var/obj/item/tI)
	for(var/obj/item/weapon/reagent_containers/R in suctionItems)
		if(istype(R, /obj/item/weapon/reagent_containers/pill))
			R.attack(tI)
			suctionItems -= R
			visible_message("<span class='notice'>\The [src] adds [R] to [tI].</span>")
		if(istype(R, /obj/item/weapon/reagent_containers/glass))
			R.attack(tI)
			tI.attack(R)
			visible_message("<span class='notice'>\The [src] is mixing something.</span>")

/obj/item/weapon/gun/hookshot/whip/kleptopus
	name = "klentacle"
	icon = ''
	icon-state = "klentacle"
	force = 3
	maxlength = 3
	hooktype = /obj/item/weapon/projectile/hookshot/whip/kleptopus
	cant_drop = 1
	mech_flags = MECH_SCAN_ILLEGAL
	slot_flags = null
	whipitgood_bonus = null


/obj/item/weapon/projectile/hookshot/whip/kleptopus
	name = "klentacle"
	icon_state = "klentacle"
	icon_name = "klentacle"
	damage = 5
	kill_count = 3
	sharpness = 0
	failure_message = "Your suction cups stick together"
	can_tether = TRUE

//to-do: tentacle inventory on small items
