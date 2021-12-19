/mob/living/simple_animal/hostile/fishing/fermurtle
	name = "keggerhead fermurtle"
	desc = "Anatomically the keggerhead fermurtle is extremely similar to an average tortoise, however physiologically and metabolically it is unique due to it's oblicate symbiotic connection to fruit baring plantlife."
	icon_state = "fermurtle"
	icon_living = "fermurtle"
	icon_dead = "fermurtle"
	turns_per_move = 15	//slow boy
	size = SIZE_NORMAL
	attacktext = "bites"
	faction = "neutral"
	melee_damage_lower = 10
	melee_damage_upper = 15
	maxHealth = 100
	health = 100
	minCatchSize = 30
	maxCatchSize = 50
	tameEase = 50
	healEat = TRUE
	healMin = 10
	healMax = 20
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/fermurtle
	illegalMutations = list()
	tameItem = list(/obj/item/weapon/reagent_containers/food/drinks, /obj/item/weapon/reagent_containers/glass)
	var/datum/seed/shellPlant = null
	var/shellPlantGrowth = 0
	var/obj/item/weapon/fermurtleKeg/turtKeg = null
	var/list/kegReg = list()
	var/kegState = null
	var/marinateAmount = 0

	#define TURT_GROWING 1
	#define TURT_FILLING 2

/mob/living/simple_animal/hostile/fishing/fermurtle/New()
	..()
	maxHealth += catchSize	//It's a turtle
	health = maxHealth
	turtKeg = new /obj/item/weapon/reagent_containers/glass/fermurtleKeg(src)
	turtKeg.volume = catchSize*5

/mob/living/simple_animal/hostile/fishing/fermurtle/fishFeed(obj/F, mob/user)
	var/obj/item/weapon/reagent_containers/D = F
	if(D.reagents)
		var/healthyGulp = 0
		for(var/datum/reagent/r in D.reagents)
			if(istype(r, /datum/reagent/ethanol))
				healthyGulp += r.volume
				D.reagents.remove(r, r.volume)
		if(healthyGulp)
			health = min(maxHealth, health + healthyGulp/2)
			if(healthyGulp >= catchSize/2 && (prob(tameEase)) && !beenTamed)	//Bigger boy thirstier boy, makes it so you can't tame with 1u beer
				fishTame()

/mob/living/simple_animal/hostile/fishing/fermurtle/Life()
	..()
	if(shellPlant)
		plantKegTime()

/mob/living/simple_animal/hostile/fishing/fermurtle/proc/plantKegTime()
	var/kegChance = health*0.05
		if(mutation == (FISH_FAST || FISH_TIME))
			kegChance *= 2
		if(prob(kegChance))
			switch(kegState)	//Healthy turtles produce faster
				if(TURT_GROWING)
					shellPlantGrowth++
					update_icon()
					health -= maxHealth*0.20
					if(shellPlantGrowth >= 3)
						kegState = TURT_FILLING
				if(TURT_FILLING)
					if(!turtKeg.is_full())
						kegFill()
					marinateAmount++

/mob/living/simple_animal/hostile/fishing/fermurtle/proc/kegFill()
	var/halfsies = rand(0,1)	//To decide if you get 1 or 0u from low reagent amounts
	for(var/datum/reagent/i in kegReg)
		var/amount = round(kegReg[i]/2, halfsies)
		turtKeg.reagents.add_reagent(i, amount)
	if(mutation)
		var/datum/reagent/mReg = mutRegFill()
		if(mReg)
			turtKeg.reagents.add_reagent(mReg, 3)

/mob/living/simple_animal/hostile/fishing/fermurtle/proc/mutRegFill()
	var/mutReg = null
	switch(mutation)
		if(FISH_CLOWN)
			mutReg = pick(BANANA, HONKSERUM) //Fuck mime curse
		if(FISH_CULT)
			mutreg = BLOOD
		if(FISH_ROYAL)
			mutreg = GOLD
		if(FISH_GLOWING)
			mutreg = LUMINOL
		if(FISH_GRAVITY)
			mutreg = CHEESYGLOOP
		if(FISH_POISON)
			mutreg = TOXIN
		if(FISH_RADIOACTIVE)
			mutreg = pick(RADIUM, URANIUM)
		if(FISH_CHATTY)
			mutreg = PICCOLYN
	return mutReg

/mob/living/simple_animal/hostile/fishing/fermurtle/attackby(var/obj/item/P, var/mob/user)
	..()
	if(istype(P, /datum/seed) && !stat)
		var/datum/seed/tS = P
		if(shellPlant))
			to_chat(user, "The [src] is already growing something.")
			return
		if(tS.products.len != 1) || (!istype(tS.products[1], /obj/item/weapon/reagent_containers/food/snacks/grown))	//Turtle can't juice Dionas
			to_chat(user, "The products aren't compatible with [src] biology.")
			return
		plantInShell(tS)

/mob/living/simple_animal/hostile/fishing/fermurtle/proc/plantInShell(var/datum/seed/S)
	var/obj/item/weapon/reagent_containers/food/snacks/grown/G = S.products[1]
	shellPlant = S
	if(is_type_in_list(G, juice_items))
		var/jType = getJuiceType(G)	//First we simulate the fruit growing in the turtle, juice comes out.
		var/jAmount = getJuiceAmount(S)
		kegReg += jType[jAmount]
	for(var/sR in S.chems)
		if(sR != NUTRIMENT)	//Can't be putting the chef out of work
			var/list/reagent_data = S.chems[sR]
			var/rTotal = reagent_data[1]
			if(reagent_data.len >1 && potency > 0)
				rtotal += round(potency/reagent_data[2])
			kegReg += sR[rTotal]	//Same equation for potency -> chems used when growing fruit in a tray.

/mob/living/simple_animal/hostile/fishing/fermurtle/proc/getJuiceType(var/obj/item/weapon/reagent_containers/food/snacks/T)
	for(var/i in juice_items)	//Stolen directly from reagent grinders
		if(istype(T, i))
			return juice_items[i]

/mob/living/simple_animal/hostile/fishing/fermurtle/proc/getJuiceAmount(var/datum/seed/J)
	var/sPot = J.potency
	if(sPot == -1)		//Thank you reagent grinder
		return 5
	else
		if(mutation == RADIOACTIVE)
			sPot *= 1.2
		return round(5*sqrt(sPot))

/mob/living/simple_animal/hostile/fishing/fermurtle/update_icon()
	//to-do: *****figure out how the fuck this works***********

/mob/living/simple_animal/hostile/fishing/fermurtle/examine(mob/user)
	..()
	to_chat(user, "The [src] appears to have some [shellPlant.product[1].name] growing on its shell.")
	if(mutation == TRANSPARENT)
		to_chat(user, "You can see its shell has about [turtKeg.reagents.total_volume]u of juice stored.")

/mob/living/simple_animal/hostile/fishing/fermurtle/modMeat(mob/user, theMeat)
	var/obj/item/weapon/reagent_containers/food/snacks/meat/fermurtle/fM = theMeat
	fM.marinated = marinateAmount
	fM.becomeDelicious()

	#undef GROWING
	#undef FILLING
	#undef FERMENTING

/obj/item/weapon/reagent_container/glass/fermurtleKeg
	name = "fermurtle shell"
	desc = "The shell of a barrelhead fermurtle. It's quite hefty. Would make a kingly mug with the right handle."
	icon_state = "fermurtle_shell"
	w_class = W_CLASS_MEDIUM
	volume = 50
	mech_flags = MECH_SCAN_FAIL
	opaque = TRUE

/obj/item/weapon/reagent_container/glass/fermurtleKeg/attackby(/obj/item/S, mob/user)
	if(istype(W, /obj/item/stack/sheet/mineral/gold || /obj/item/stack/sheet/mineral/silver || /obj/item/stack/sheet/mineral/mythril))
		var/obj/item/stack/sheet/tMat = S
		if(tMat.use(5))
			to_chat(user,"<span class='notice'>The shell has been given a handle.</span>")
			var/obj/item/weapon/reagent_container/glass/fermurtleKeg/kinglyTankard/kt = new /obj/item/weapon/reagent_container/glass/fermurtleKeg/kinglyTankard(src.loc)
			/obj/item/weapon/reagent_container/glass/kinglyTankard.volume = volume
			reagents.trans_to(kt, reagents.total_volume)
			qdel(src)
			user.put_in_hands(kt)

/obj/item/weapon/reagent_container/glass/fermurtleKeg/kinglyTankard
	name = "kingly tankard"
	desc = "Larger than a grown man's head and adorned with precious metals, this tankard created from the shell of a fermurtle is truly luxurious. Just looking at it makes you thirsty."
	icon_state = "fermurtle_kingly_tankard"
	volume = 50

/obj/item/weapon/reagent_containers/food/snacks/meat/fermurtle
	name = "fermurtle meat"
	desc = "Meat from a keggerhead fermurtle."
	icon_state = "meat"
	var/marinated = 0


/obj/item/weapon/reagent_containers/food/snacks/meat/fermurtle/proc/becomeDelicious()
	if(marinated > 150) //Very roughly 15-25 minute old fermurtle
		name = "fermurtle jewel meat"
		desc = "Jewel meat from a keggerhead fermurtle. Fermurtles quite literally spend their entire lives marinating themselves. The meat of long lived fermurtles was dubbed 'jewel meat' for its gem-like glisten. Jewel meat is impossibly delicious and when prepared by a skilled chef has been known to bring grown spacemen to tears."
		icon_state = "fermurtle_jewel_meat"

/datum/organ/internal/liver/fermurtle
	name = "fermurtle liver"
	removed_type = /datum/organ/internal/liver/fermurtle

/datum/organ/internal/liver/fermurtle/process()
	..()
	for(var/datum/reagent/eth in owner.reagents.reagent_list)
		if(istype(eth, /datum/reagent/ethanol))
			owner.adjustFireLoss(-1)
			owner.adjustBruteLoss(-1)
			owner.reagents.add_reagent(NUTRIMENT, 1)


