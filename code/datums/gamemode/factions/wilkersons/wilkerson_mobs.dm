//REESE/////////

/mob/living/carbon/monkey/reese
	name = "Reese"
	voice_name = "Reese"
	icon = 'icons/mob/inthemiddle/reese.dmi'
	icon_state = "reese"
	gender = MALE
	pass_flags = 0
	can_butcher = 0
	attack_text = "punches"
	namenumbers = FALSE
	flag = NO_BREATHE
	canWearClothes = 0
	canWearHats = 0
	canWearGlasses = 0
	canWearMasks = 0
	canWearBack = 0
	size = SIZE_HUGE
	maxHealth = 1000
	health = 1000
	var/fistPower = 0

/mob/living/carbon/monkey/reese/get_unarmed_damage()
	var/punchPow = rand(5, 15) //Enough to seriously wound people but unlikely to kill if he's just chasing them around
	punchPow += fistPower
	return punchPow

/mob/living/carbon/monkey/reese/knockout_chance_modifier()
	return 10	//However he's very good at knocking them over

/mob/living/carbon/monkey/reese/bonusTackleForce(tF = 300)	//He's going to win tackles, they're going to hurt.
	..()

/mob/living/carbon/monkey/reese/gib(FALSE, FALSE)
	return

/mob/living/carbon/monkey/reese/dust()
	return

/mob/living/carbon/monkey/reese/death(gibbed)
	..()
	anchored = TRUE

/mob/living/carbon/monkey/reese/UnarmedAttack(atom/A)
	..()
	if(A.density)
		if(!isliving(A))
			A.ex_act(2)	//Punches like a siege cannon


//MALCOLM/////////
/mob/living/carbon/monkey/malcolm
	name = "Malcolm"
	voice_name = "Malcolm"
	icon = 'icons/mob/inthemiddle/malcolm.dmi'
	icon_state = "malcolm"
	gender = MALE
	pass_flags = 0
	can_butcher = 0
	attack_text = "middles"
	namenumbers = FALSE
	flag = NO_BREATHE
	canWearClothes = 0
	canWearHats = 0
	canWearGlasses = 0
	canWearMasks = 0
	canWearBack = 0
	size = SIZE_NORMAL
	canmove = FALSE
	flags = TIMELESS
	maxHealth = 1000
	health = 1000
	var/turf/theMiddle = null


/mob/living/carbon/monkey/malcolm/death(gibbed)
	health = maxHealth
	toggleMalcolmMovement(10)

/mob/living/carbon/monkey/malcolm/gib(FALSE, FALSE)
	return

/mob/living/carbon/monkey/malcolm/dust()
	return

/mob/living/carbon/monkey/malcolm/proc/toggleMalcolmMovement(var/togDuration = 1)
	timestop(src, togDuration SECONDS, 9)
	if(!canmove)
		canmove = TRUE
		spawn(togDuration SECONDS)
			canmove = FALSE

/mob/living/carbon/monkey/malcolm/supermatter_act(atom/source, severity)
	visible_message("<span class='warning'>[src] consumes \the [source]!</span>")
	toggleMalcolmMovement(30)
	qdel(source)

//DEWEY/////////

/mob/living/carbon/monkey/dewey
	name = "Dewey"
	voice_name = "Dewey"
	icon = 'icons/mob/inthemiddle/dewey.dmi'
	icon_state = "dewey"
	gender = MALE
	can_butcher = 0
	attack_text = "chomps"
	namenumbers = FALSE
	flag = NO_BREATHE
	canWearClothes = 0
	canWearHats = 0
	canWearGlasses = 0
	canWearMasks = 0
	canWearBack = 0
	size = SIZE_SMALL
	maxHealth = 500
	health = 500
	var/list/deweys = list()
	var/list/devouredItems = list()
	var/jumpingBeanActive = FALSE
	var/deweyEnrage = FALSE

/mob/living/carbon/monkey/dewey/gib(FALSE, FALSE)
	return

/mob/living/carbon/monkey/dewey/dust()
	return

/mob/living/carbon/monkey/dewey/death(gibbed)
	if(jumpingBeanActive)
		health = maxHealth
		visible_message("<font size='10' color='red'><b>Ole!</b></font>")
		jumpingBeanActive = FALSE
	else
		..()
		for(var/obj/item/ateStuff in devouredItems)
			ateStuff.forceMove(get_turf(src))
			devouredItems.Remove(ateStuff)
		anchored = TRUE

/mob/living/carbon/monkey/dewey/bonusTackleRange(var/tR = 6)
	..()

/mob/living/carbon/monkey/dewey/bonusTackleForce(var/tF = 50)
	tF += devouredItems.len*5
	..()

/mob/living/carbon/monkey/dewey/bullet_act(var/obj/item/projectile/P, var/def_zone)
	..()
	splitDewey()

/mob/living/carbon/monkey/dewey/proc/splitDewey()
	var/mob/living/simple_animal/hostile/dewey/deweyPolyp = new /mob/living/simple_animal/hostile/dewey(get_turf(src))
	deweys.Add(deweyPolyp)
	deweyPolyp.deweyPrime = src

/mob/living/carbon/monkey/dewey/UnarmedAttack(atom/A)
	..()
	if(iscarbon(A))
		deweySnatch(A)

/mob/living/carbon/monkey/dewey/proc/deweySnatch(var/mob/living/carbon/C)
	var/obj/item/ateItem = pick(C.held_items)
	if(ateItem)
		C.drop_item(ateItem, src, TRUE)
		devouredItems.Add(ateItem)
		maxHealth += 5
		health = min(health + 10, maxHealth)
		visible_message("<span class='warning'>[src] consumes \the [ateItem]!</span>")
	if(deweyEnrage)
		C.adjustBruteLoss(5)
		maxHealth += 5
		health = min(health + 5, maxHealth)


/mob/living/carbon/monkey/dewey/proc/deweyEnrageToggle()
	if(!deweyEnrage)
		for(var/mob/living/simple_animal/hostile/dewey/D in deweys)
			if(!D.deweyEnrage)
				D.deweyEnrage = TRUE
				D.icon_state = "dewey_enraged"
		deweyEnrage = TRUE
		icon_state = "dewey_enraged"
	else
		for(var/mob/living/simple_animal/hostile/dewey/D in deweys)
			if(D.deweyEnrage)
				D.deweyEnrage = FALSE
				D.icon_state = "dewey"
		deweyEnrage = FALSE
		icon_state = "dewey"

/mob/living/simple_animal/hostile/dewey
	name = "Dewey"
	icon = 'icons/mob/inthemiddle/dewey.dmi'
	icon_state = "dewey"
	icon_living = "dewey"
	faction = "malcolm"
	maxHealth = 10
	health = 10
	melee_damage_lower = 3
	melee_damage_upper = 8
	move_to_delay = 1
	speed = 0.5
	can_ventcrawl = TRUE
	var/list/devouredItems = list()
	var//mob/living/carbon/monkey/dewey/deweyPrime = null
	var/deweyEnrage = FALSE

/mob/living/simple_animal/hostile/dewey/New()
	..()
	var/randSize = rand(5, 20)
	transform = matrix*(randSize/10)
	maxHealth += randSize
	health += randSize

/mob/living/simple_animal/hostile/dewey/UnarmedAttack(atom/A)
	..()
	if(!deweyEnrage)
		deweySnatch(A)
	else
		deweyKidnap(A)

/mob/living/simple_animal/hostile/dewey/proc/deweySnatch(var/mob/living/carbon/C)
	var/obj/item/ateItem = pick(C.held_items)
	if(ateItem)
		C.drop_item(ateItem, src, TRUE)
		devouredItems.Add(ateItem)
		maxHealth += 5
		health = min(health + 10, maxHealth)
		melee_damage_upper++
		visible_message("<span class='warning'>[src] consumes \the [ateItem]!</span>")

/mob/living/simple_animal/hostile/dewey/proc/deweyKidnap(var/mob/living/carbon/C)
	C.Knockdown(3)
	visible_message("<span class='warning'>[src] grabs hold of [C]!</span>")
	do_teleport(C, deweyPrime, 1)
	do_teleport(src, C, 0)

/mob/living/simple_animal/hostile/dewey/death(var/gibbed = FALSE)
	for(var/obj/item/ateStuff in devouredItems)
		ateStuff.forceMove(get_turf(src))
	if(deweyPrime)
		deweyPrime.deweys.Remove(src)
	..()
	gib()



