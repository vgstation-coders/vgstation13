/mob/living/simple_animal/hostile/fishing/porpal
	name = "porpal"
	desc = "A symbiotic organism evolved to latch onto social groups within more successful species and make itself useful in order to gain their protection. They are genetically pre-disposed to loyalty, as well as being one of the most intelligent species of space fish."
	icon_state = "porpal"
	icon_living = "porpal"
	icon_dead = "porpal_dead"
	meat_type =
	size = SIZE_NORMAL
	faction = "friendly"
	possibleMutations = list()
	melee_damage_lower = 5
	melee_damage_upper = 10
	maxHealth = 65
	health = 65
	minCatchSize = 25
	maxCatchSize = 50
	flags = HEAR_ALWAYS
	var/mob/living/carbon/human/bestFriend = null
	var/helpingFriend = FALSE
	var/stayStill = FALSE
	var/obj/effect/decal/point/currentPoint = null	//Thank you wolf code
	var/list/parrotedPhrases = list()

/mob/living/simple_animal/hostile/fishing/porpal/fishTame(mob/user)
	..()
	bestFriend = user

/mob/living/simple_animal/hostile/fishing/porpal/Life()
	..()
	if(bestFriend)
		var/list/can_see = view(src, vision_range)
		if(!helpingFriend)
			friendPointCheck(can_see)
			parrotFriend(can_see)
			followFriend(can_see)

/mob/living/simple_animal/hostile/fishing/porpal/proc/followFriend(can_see)
	if((bestFriend in can_see) && (!stayStill))
		Goto(bestFriend, move_to_delay)
		if(bestFriend.isDead())
			tryToHelpFriend(can_see)

/mob/living/simple_animal/hostile/fishing/porpal/proc/parrotFriend(can_see)
	if(prob(catchSize/10)) //bigger fish, bigger bro
		helpingFriend = TRUE
		var/talkTargets = prune_list_to_type(can_see, mob/living)
		var/chatEmUp = pick(talkTargets)
		Goto(chatEmUp, move_to_delay)
		var/lineToSay = pick(parrotedPhrases)
		say("[lineToSay]!")
		if(mutation == COMMANDING)
			if(ishuman(chatEmUp))
				var/mob/living/carbon/human/C = chatEmUp
				C.Jittery(3)
				C.Stutter(3)
			if(isanimal(chatEmUp))
				var/mob/living/simple_animal/A = chatEmUp
				A.Stun(5)
		spawn(5)
			returnToBestie()

/mob/living/simple_animal/hostile/fishing/porpal/proc/friendPointCheck(var/list/can_see)
	for(var/obj/effect/decal/point/pointer in can_see)
		if(pointer == currentPoint)
			return
		if(pointer.pointer != bestFriend)
			return
		currentPoint = pointer	//Put this here to avoid checking type constantly
		if(!istype(/atom/movable, pointer.target))
			return
		friendPointDecide(pointer.target)

/mob/living/simple_animal/hostile/fishing/porpal/proc/friendPointDecide(var/atom/movable/porPoint)
	if(porPoint.anchored)
		return
	if(porPoint == src)
		porStay()
		return
	if(porPoint == bestFriend)
		if(pulling)
			stop_pulling()
		returnToBestie()
		return
	bringToFriend(porPoint)

/mob/living/simple_animal/hostile/fishing/porpal/proc/porStay()
	if(!stayStill)
		stayStill = TRUE
		stop_automated_movement = TRUE
	else
		stayStill = FALSE
		stop_automated_movement = FALSE

/mob/living/simple_animal/hostile/fishing/porpal/proc/bringToFriend(var/atom/movable/porPoint)
	helpingFriend = TRUE
	if(mutation == BLUESPACE)
		spawn(5)
			var/targloc = get_turf(get_step(porPoint, get_dir(porPoint, src)))
			do_teleport(src, targloc, 0)
	else
		Goto(porPoint, move_to_delay)
	if(!Adjacent(porPoint))
		helpingFriend = FALSE
		return
	if(mutation == CLOWN && ishuman(porPoint))
		var/mob/living/carbon/human/slipPoint = porPoint
		playsound(slipPoint, 'sound/misc/slip.ogg', 50, 1)
		slipPoint.Knockdown(2)
	start_pulling(porPoint)
	var/tooHeavy = 250/catchSize
	if(isitem(porPoint))
		var/obj/item/toGrab = porPoint
		if(toGrab.w_class < W_CLASS_MEDIUM)
			tooHeavy = 0
	if(mutation == STRONG | GRAVITY | TELEKINETIC)
		tooHeavy = 0
	returnToBestie(tooHeavy)
	stop_pulling()
	porPoint.forceMove(get_turf(src))

/mob/living/simple_animal/hostile/fishing/porpal/proc/returnToBestie(var/moveMod)
	Goto(bestFriend, move_to_delay + moveMod)
	helpingFriend = FALSE

/mob/living/simple_animal/hostile/fishing/porpal/Hear(var/datum/speech/speech, var/rendered_speech="")
	if(speech.speaker && speech.speaker == bestFriend)
		if(parrotedPhrases.len >= 10 && mutation != CHATTY) //Surely this won't be abused
			parrotedPhrases -= parrotedPhrases[1]
		parrotedPhrases += speech.message
		if(prob(catchSize/10))
			var/toSay = speech.message
			spawn(5)
				say("[toSay]!")

/mob/living/simple_animal/hostile/fishing/porpal/tryToHelpFriend()
	if(!pulling == bestFriend)
		Goto(bestFriend, move_to_delay)
		start_pulling(bestFriend)
