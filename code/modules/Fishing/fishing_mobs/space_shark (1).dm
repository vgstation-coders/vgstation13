/mob/living/simple_animal/hostile/fishing/space_shark
	name = "space shark"
	desc = "Also known as 'star devourers', 'spaceman rippers', and 'angler's regret'. These ferocious creatures lurk the cosmos, as well as the memories of the few who have survived their hunger."
	icon_state = "spess_shark"
	icon_living = "spess_shark"
	icon_dead = "spess_shark_dead"
	meat_type =
	attacktext = list("chomps", "bites", "mauls")
	faction = "spessshark"
	stat_attack = 2
	size = SIZE_BIG
	melee_damage_lower = 10
	melee_damage_upper = 25
	minCatchSize = 70
	maxCatchSize = 160
	tameEase = 5
	healEat = TRUE
	tameItem = list(/obj/item/weapon/reagent_containers/food/snacks/meat, /obj/item/organ/external, /obj/item/weapon/holder)
	var/feedingFrenzy = FALSE

/mob/living/simple_animal/hostile/fishing/space_shark/New()
	..()
	maxHealth = catchSize
	health = maxHealth
	if(mutation == ROYAL)	//to-do: GREYTIDE
		var/mob/living/simple_animal/hostile/fishing/space_shark/rShark = new /mob/living/simple_animal/hostile/fishing/space_shark(src.loc)
		rShark.catchSize =/2
		rShark.health =/2
		rShark.maxHealth = rShark.health
		friends += rShark
	for(var/mob/living/simple_animal/hostile/fishing/sf in friends)	//So the second shark will also befriend the normal royal mobs
		sf.friends = friends.copy

/mob/living/simple_animal/hostile/fishing/space_shark/fishFeed(obj/W, mob/user)
	..()
	if(feedingFrenzy && beenTamed)
		sharkWeekOver()
	if(prob(5))
		if(beenTamed && prob(50))
			return
		chumInTheWater()	//Equal chances between taming and the shark just going nuts. These are meant for bragging rights. Way too strong to consistently give to players.

/mob/living/simple_animal/hostile/fishing/space_shark/UnarmedAttack(var/atom/A)
	..()
	if(issilicon(target) || target.mob_property_flags & (MOB_CONSTRUCT | MOB_ROBOTIC | MOB_HOLOGRAPHIC))
		LoseTarget()	//They take one nibble and realize they aren't into it
		return
	if(iscarbon(target) && !feedingFrenzy)
		var/mob/living/carbon/T = target
		if(T.check_bodypart_bleeding(FULL_TORSO))	//to-do: Maybe change this to a loop through all external organs
			prob(25)
				chumInTheWater()
	if(isanimal(target) && !feedingFrenzy)
		prob(10)
			chumInTheWater()
	if(feedingFrenzy)
		health += rand(0,5)
		if(mutation == FISH_GREEDY)
			health += rand(0,5)

/mob/living/simple_animal/hostile/fishing/space_shark/proc/chumInTheWater()
	if(feedingFrenzy)
		return
	visible_message("<span class='danger'>\The [src] begins drooling, its eyes focus and its muscles bulge! It looks very, very hungry.</span>")
	feedingFrenzy = TRUE
	melee_damage_lower += catchSize/10
	melee_damage_upper += catchSize/10
	speed = 0.8
	icon_state = "spess_shark_frenzied"
	environment_smash_flags = 1
	if(lastMutActivate && catchSize > 150)	//Big sharks are for bragging rights
		lastMutActivate = 0
		spawn(2 SECONDS)
			mutateActivate()
	faction = "spessshark"
	friends.len = 0
	beenTamed = FALSE
	if(mutation == FISH_GRUE)	//He HUNGRY
		return
	spawn(catchSize SECONDS)
		sharkWeekOver()

/mob/living/simple_animal/hostile/fishing/space_shark/proc/sharkWeekOver()
	if(isDead())
		return
	visible_message("<span class='notice'>\The [src] regains its composure.</span>")
	feedingFrenzy = FALSE
	speed = 1
	melee_damage_lower -= catchSize/10
	melee_damage_upper -= catchSize/10
	environment_smash_flags = 0
	icon_state = "spess_shark"

