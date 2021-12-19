/mob/living/simple_animal/hostile/fishing/stonegulper
	name = "stonegulper"
	desc = "Stonegulpers are known to eats rocks to aid digestion. They're a favorite of many space anglers as although they grow larger the more rock they consume, they can't actually digest them, resulting in bellies full of potentially precious stones"
	icon_state = "stonegulper"
	icon_living = "stonegulper"
	icon_dead = "stonegulper_dead"
	size = SIZE_SMALL
	melee_damage_lower = 5
	melee_damage_upper = 10
	minCatchSize = 6
	maxCatchSize = 15
	var/list/possibleEatenOre = list()
	var/list/bellyOre = list()
	var/beenKicked = FALSE

/mob/living/simple_animal/hostile/fishing/stonegulper/New()
	..()
	var/oresMeal = catchSize/3
	for(var/i=1, i<oresMeal, i++)
		var/eatenOre = pick(possibleEatenOre)
		bellyOre += eatenOre

/mob/living/simple_animal/hostile/fishing/stonegulper/proc/coughUpOre()
	visible_message("<span class='notice'>\The [src]'s belly splits open as it dies.</span>")
	for(var/O in bellyOre)
		O.forceMove(loc)

/mob/living/simple_animal/hostile/fishing/stonegulper/death(var/gibbed = FALSE)
	coughUpOre()
	..(gibbed)

/mob/living/simple_animal/hostile/fishing/stonegulper/kick_act(mob/living/carbon/human/K)
	if(beenKicked)
		..()
		return
	if(!prob(catchSize))
		..()
		return
	beenKicked = TRUE
	if(!stat)
		visible_message("<span class='notice'>The [src]'s coughs up some ore.</span>")
		var/kickOre = pick(bellyOre)
		new kickOre(loc)	//Not removing it from the list is intentional
	else
		to_chat(K, "<span class='notice'>Looks like there was a little left in there</span>")
		var/leftOverOre = pick(possibleEatenOre)
		new leftOverOre(src.loc)
//do the one line if here, you gotta remember how to do that god damn. Condense it to just the one thing after the if(!)'s'


/mob/living/simple_animal/hostile/fishing/stonegulper/common
	possibleEatenOre = list(
			/obj/item/stack/ore/iron,
			/obj/item/stack/ore/iron,
			/obj/item/stack/ore/iron,
			/obj/item/stack/ore/silver,
			/obj/item/stack/ore/uranium
	)

/mob/living/simple_animal/hostile/fishing/stonegulper/uncommon
	possibleEatenOre = list(
			/obj/item/stack/ore/silver,
			/obj/item/stack/ore/silver,
			/obj/item/stack/ore/gold,
			/obj/item/stack/ore/gold,
			/obj/item/stack/ore/uranium,
	)

/mob/living/simple_animal/hostile/fishing/stonegulper/rare
	possibleEatenOre = list(
			/obj/item/stack/ore/gold,
			/obj/item/stack/ore/diamond,
			/obj/item/stack/ore/diamond,
	)

/mob/living/simple_animal/hostile/fishing/stonegulper/plasma
	desc = "While plasma is not poisonous to stonegulpers, it's not exactly healthy either."
	icon_state = "stonegulper_plasma"
	icon_living = "stonegulper_plasma"
	icon_dead = "stonegulper_plasma_dead"
	melee_damage_lower = 7
	melee_damage_upper = 15
	minCatchSize = 9
	maxCatchSize = 18
	possibleEatenOre = list(
		/obj/item/stack/ore/plasma,
		/obj/item/stack/ore/plasma,
		/obj/item/stack/ore/iron
	)

/mob/living/simple_animal/hostile/fishing/stonegulper/ultraRare
	desc = "This one has been eating well"
	icon_state "stonegulper_phazon"
	icon_living "stonegulper_phazon"
	icon_dead = "stonegulper_dead"
	melee_damage_lower = 15
	melee_damage_higher = 25
	minCatchSize = 12
	maxCatchSize = 24
	possibleEatenOre = list(
		/obj/item/stack/ore/phazon,
		/obj/item/stack/ore/phazon,
		/obj/item/stack/ore/clown,
		/obj/item/stack/ore/diamond
	)
