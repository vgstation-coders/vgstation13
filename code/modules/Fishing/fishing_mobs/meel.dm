/mob/living/simple_animal/hostile/fishing/meel
	name = "meel"
	desc = "Many starving and void-stranded space anglers owe their lives to these egg laying creatures. In life their unique protein structure is in a constant state of flux, which is halted upon their death. This trait allows meel butchery to produce nearly any type of meat imaginable, and some unimaginable."
	icon_state = "meel"
	icon_living = "meel"
	icon_dead = "meel_dead"
	meat_amount = 1
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/meel
	melee_damage_lower = 5
	melee_damage_upper = 15
	maxHealth = 35
	health = 35
	minCatchSize = 15
	maxCatchSize = 25
	illegalMutations = list()
	tameItem = list() //What do meels eat? Maybe just bait in general or like, food?
	var/meelopause = 0		//This is a good variable name and I'm proud of it

/mob/living/simple_animal/hostile/fishing/meel/New()
	..()
	if(gender == MALE)
		meat_amount = catchSize/5
	if(gender == FEMALE)
		meelopause = catchSize
		if(mutation == FISH_ROYAL | FISH_SPLITTING)
			meelopause = catchSize*2

/mob/living/simple_animal/hostile/fishing/meel/Life()
	..()
	if(gender == FEMALE)
		if(prob(meelopause/10))
			meelEggLay()

/mob/living/simple_animal/hostile/fishing/meel/proc/meelEggLay()
	stun(3)
	playsound(src, 'sound/effects/splat.ogg', 50, 1)
	spawn(1 SECONDS)
		var/mob/living/simple_animal/hostile/fishing/meel/meelMate = null
		for(var/mob/living/simple_animal/hostile/fishing/meel/M in orange(2))
			if(M.gender == MALE)
				meelMate = M
		if(meelMate)
			var/obj/item/weapon/reagent_containers/food/snacks/egg/meel/fertile/E = new /obj/item/weapon/reagent_containers/food/snacks/egg/meel/fertile(loc)
		else
			var/obj/item/weapon/reagent_containers/food/snacks/egg/meel/E = new /obj/item/weapon/reagent_containers/food/snacks/egg/meel(loc)
		new /obj/effect/decal/cleanable/egg_smudge(loc)
		meelopause--
		if(mutation)
			mIngredientDecide()
			E.addMIngredient()

/mob/living/simple_animal/hostile/fishing/meel/proc/mIngredientDecide()
	switch(mutation)
		if(FISH_CLOWN)
			E.mutantIngredient = HONKSERUM
		if(FISH_POISON)
			E.mutantIngredient = CARPOTOXIN
		if(FISH_GLOWING)
			E.mutantIngredient = LUMINOL
		if(FISH_ILLUSIONARY)
			if(prob(50))
				E.remove_reagent(EGG_YOLK, 4)
				spawn(rand(30, 60))
					animate(E, alpha = 0, time = 1 SECONDS)
					qdel(E)
					meelopause++
		if(FISH_RADIOACTIVE)
			E.mutantIngredient = URANIUM
		if(FISH_EXPLODING)
			E.mutantIngredient = NITROGLYCERIN	//Oh noooo
			E.ingredAmount = 1
		if(FISH_CULT)
			E.mutantIngredient = BLOOD
			E.ingredAmount = 10
		if(FISH_ALCHEMIC)
			var/randgredient = pick(rainbowChems)	//to_do: change this
			E.mutantIngredient = randgredient
		if(FISH_GRAVITY)
			E.mutantIngredient = CORNOIL
			E.ingredAmount = 25
		if(FISH_ROYAL)
			var/royalIng = pick(ROYALJELLY, GOLD, SILVER)
			E.mutantIngredient = royalIng
		if(FISH_SPLITTING)
			if(isType(E, /obj/item/weapon/reagent_containers/food/snacks/egg/meel/fertile))
				E.babyChance = 5

/obj/item/weapon/reagent_containers/food/snacks/egg/meel
	name = "meel caviar"
	desc = "Although just as delicious as any other, meel caviar never caught on with the rich and powerful due to its abundance."
	icon_state = "meel_caviar"
	can_color = FALSE
	food_flags = FOOD_ANIMAL
	var/mutantIngredient = null
	var/ingredAmount = 5

/obj/item/weapon/reagent_containers/food/snacks/egg/meel/proc/addMIngredient()
	if(mutantIngredient)
		reagents.add_reagent(mutantIngredient, rand(0,ingredAmount))

/obj/item/weapon/reagent_containers/food/snacks/egg/meel/fertile
	var/babyChance = 1

/obj/item/weapon/reagent_containers/food/snacks/egg/meel/fertile/New()
	if(prob(babyChance))
		spawn(rand(60, 300))
			new /mob/living/simple_animal/hostile/fishing/meel(loc)
			qdel(src)

/obj/item/weapon/reagent_containers/food/snacks/meat/meel/New()
	var/meelForm = null
	if(prob(1))
		meelForm = pick(existing_typesof(/obj/item/weapon/reagent_containers/food/snacks/meat))	//Roughly 0.08% chance of wendigo meat
	meelForm = pick(meelMeats)
	new meelForm(loc)
	qdel(src)
