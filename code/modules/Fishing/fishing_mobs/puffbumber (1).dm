/mob/living/simple_animal/hostile/fishing/puffbumper
	name = "puffbumper"
	desc = "In order to combat depressurization some creatures evolved dense shells or invented space suits. These fish instead evolved ridiculous, cartoonish levels of elasticisty."
	icon_state = "puffbumper"
	icon_living = "puffbumper"
	icon_dead = "puffbumper_dead"
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/puffbumper
	attacktext = list("pokes", "quills")
	size = SIZE_TINY
	melee_damage_type = TOXIC
	minCatchSize = 2
	maxCatchSize = 8
	mutantPower = 1
	var/puffedUp = FALSE

/mob/living/simple_animal/hostile/fishing/puffbumper/Aggro()
	..()
	puffUp()

/mob/living/simple_animal/hostile/fishing/puffbumper/proc/puffUp()
	var/turf/T = get_turf(src)
	var/puffThrowForce = catchSize*5 + 30
	for(var/mob/living/M in range(src,catchSize/6))	//Just the tile they're on if catchSize is below 6, extra 1 around that above it. If you get it to 12+ you get a big knockback
		var/puffDir = get_dir(src, M)
		endLocation = get_ranged_target_turf(src, puffDir, catchSize)
		M.throw_at(endLocation, catchSize, puffThrowForce)
		M.Knockdown(1)
		if(mutation == GRAVITY)
			spawn(10)
				M.throw_at(src, catchSize, puffThrowForce)
				M.Knockdown(mutantPower)
	if(mutation)
		switch(mutation)
			if(EXPLODING)
				explosion(get_turf(src.loc), 0, mutantPower, mutantPower*2)
			if(EMP)
				empulse(get_turf(src.loc), 0, mutantPower, mutantPower*2)
			if(TIME)
				timestop(src, mutantPower, mutantPower)
	bigPuff()

/mob/living/simple_animal/hostile/fishing/puffbumper/proc/bigPuff()
	icon_state = "puffbumper_wall"
	puffedUp = TRUE
	size += 3	//Not setting to a define because of size change mutations
	anchored = 1
	visible_message("<span class='warning'>The [src] puffs up!</span>")
	spawn(catchSize SECONDS)
		if(!stat)
			littlePuff()

/mob/living/simple_animal/hostile/fishing/puffbumper/proc/littlePuff()
	icon_state = "puffbumper"
	puffedUp = FALSE
	size -= 3
	anchored = 0
	visible_message("<span class='notice'>The [src] deflates.</span>")

/mob/living/simple_animal/hostile/fishing/puffbumper/death(var/gibbed = FALSE)
	if(puffedUp)
		sleep(1 SECOND)
		littlePuff()
		playsound(src, "sound/misc/balloon_pop" , 100)
	..(gibbed)


/mob/living/simple_animal/hostile/fishing/puffbumper/modMeat(mob/user)
	if(ishuman(user))
		theMeat.getChefness(user)


//As a holder/in hand item//////////////

/obj/item/weapon/holder/animal/pufferFish
	name = "pufferfish holder"
	desc = "Not pocket sized for long"
	item_state = "pufferHand"

/obj/item/weapon/holder/animal/pufferFish/throw_impact(atom/hit_atom)
	var/mob/living/simple_animal/hostile/fishing/puffbumper/P = stored_mob
	..()
	spawn(rand(1,catchSize))
		P.puffUp()

/obj/item/weapon/holder/animal/pufferFish/attack_self(mob/user)
	..()
	visible_message("[user] squeezes and pinches the [src]")
	if(prob(50))
		var/mob/living/simple_animal/hostile/fishing/puffbumper/P = stored_mob
		spawn(5)
			user.drop_item(src, 1)
			P.puffUp()






//Meat///////////

/obj/item/weapon/reagent_containers/food/snacks/meat/puffbumper
	name = "puffbumper fillet"
	desc = "Seen as a delicacy because of the inherent danger in eating it. An ill-prepared puffbumper fillet may still have active enzymes responsible for the fish's expansion. The result is less subtle than any thematically similar earth dishes may have been."
	icon_state = ""
	var/puffPower = 0
	var/prepPower = 0

/obj/item/weapon/reagent_containers/food/snacks/meat/puffbumper/proc/getChefness(var/mob/living/carbon/human/ourChef)
	var/chefPower = 0	//Just about stolen from funk boots.
	var/list/cHead = list(
		/obj/item/weapon/holder/animal/mouse = 4,	//Shh secrets
		/obj/item/clothing/head/chefhat = 2,
		/obj/item/clothing/head/helmet/samurai = 3,
		/obj/item/clothing/head/helmet/space/ninja = 5,
	)
	for(var/cH in cHead)
		if(H.head == cH)
			chefPower += cHead[cH]


/obj/item/weapon/reagent_containers/food/snacks/meat/puffbumper/proc/prepSushi()



/obj/item/weapon/reagent_containers/food/snacks/meat/puffbumper/after_consume(mob/user)
	..()
	if(!puffPower)
		puffPower = rand(1, 4)
	var/puffTime = rand(5, 300)
	spawn(puffTime SECONDS)
		puffUp()

/obj/item/weapon/reagent_containers/food/snacks/meat/puffbumper/proc/puffUp()



