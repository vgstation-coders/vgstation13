#define CL_BASE_SHAPE 0
#define CL_ITEM_SHAPE 1
#define CL_PERSON_SHAPE 2

/mob/living/simple_animal/hostile/fishing/change-ling
	name = "Change-ling"
	desc = "It's commonly believed that these fish are the direct ancestor of changelings. Due to the transient nature of both changeling and change-ling genomes we may never have proof of that claim."
	icon_state = "change_ling"
	icon_living = "change_ling"
	icon_dead = "change_ling_dead"
	meat_type =
	size = SIZE_NORMAL
	maxHealth = 50
	health = 50
	minCatchSize = 25
	maxCatchSize = 40
	mutantPower = 6
	illegalMutations = list()
	tameItem = list()
	tameEase = 10
	var/shapeShifted = CL_BASE_SHAPE
	var/shapeJob = null
	var/firstName = null
	var/inConversation = FALSE
	var/list/responsePhrase = list()
	var/list/greetingPhrase = list()


/mob/living/simple_animal/hostile/fishing/change_ling/attackby(obj/W, mob/user)
	..()
	if(istype(W, /obj/item/weapon/photo))
		var/obj/item/weapon/photo/P = W
		if(!P.info)
			return
		var/mob/living/newForm = pick(P.info)	//Note: make super sure info is only a collection of mobs
		icon = newForm.icon
		icon_state = newForm.icon_state
		name = newForm.name
		desc = newForm.desc
		if(ishuman(newForm))
			crewShift(newForm)
	else if(istype(W, /obj/item))
		spawn(1 SECONDS)
			icon = W.icon
			icon_state = W.icon_state
			name = W.name
			desc = W.desc
			wander = 0
			shapeShifted = CL_ITEM_SHAPE

/mob/living/simple_animal/hostile/fishing/change_ling/proc/crewShift(var/mob/living/targetForm)
	var/mob/living/carbon/human/crewForm = targetForm
	if(crewForm.mind)
		shapeJob = crewForm.mind.assigned_role
	var/image/I = image('icons/effects/32x32.dmi', "blank")
	I.overlays |= crewForm.overlays
	for(var/L in name)
		if(L == " ")
			break
		firstName += L
	shapeShifted = CL_PERSON_SHAPE

/mob/living/simple_animal/hostile/fishing/change_ling/Hear(var/datum/speech/speech, var/rendered_speech="")
	if(shapeShifted == CL_ITEM_SHAPE)
		return
	if(!speech.speaker || speech.speaker == src)
		return FALSE
	if(is_type_in_list(speaker, friends))
		gainPersonality(speech)
	fakePersonality(speaker, speech)

/mob/living/simple_animal/hostile/fishing/Change-ling/proc/gainPersonality(var/phraseLearn)
	if(findtext(phraseLearn, "?" |"Yes" | "yes" | "No" | "no" | "Maybe" | "maybe" | "I'm"))
		responsePhrase += phraseLearn
	if(findtext(phraseLearn, "Hello" | "hello" | "Howdy" | "howdy" | "Hey" | "hey"))
		greetingPhrase += phraseLearn
	var/list/forgetPhrase = list()
	forgetPhrase = responsePhrase + greetingPhrase
	if(forgetPhrase.len > catchSize)
		if(responsePhrase.len > greetingPhrase.len)
			responsePhrase -= pick(responsePhrase)
		else
			greetingPhrase -= pick(greetingPhrase)

/mob/living/simple_animal/hostile/fishing/Change-ling/proc/fakePersonality(var/mob/chatMan, var/phraseHeard)
	spawn(rand(5,15))
		dir = get_dir(src, chatMan)
	if(get_dist(src, chatMan > 4))
		return
	if(!inConversation)
		var/shortName = "[name[1]]+[name[2]]+[name[3]]"
		if(findtext(phraseHeard, "[shortName]" || "[firstName]" || "[shapeJob]"))
			var/respondWith = pick(greetingPhrase)
			spawn(respondWith.len + 10)	//Longer phrase longer response time plus 1 second for realism
				say("[respondWith]")
				if((mutation == FISH_CLOWN) && (prob(20)))
					say("Honk!")
			inConversation = TRUE
	if(inConversation)
		var/replyWith = pick(responsePhrase)
		spawn(replyWith.len +10)
			say("[replyWith]")
			if(mutation == FISH_CHATTY && (prob(20)))
				var/replyAgain = pick(responsePhrase)
				say("also, [replyAgain]")
			if(mutation == FISH_CLOWN && (prob(20)))
				say("Honk!")
		spawn(5 SECONDS)
			for(chatMan in orange(4))	//Did he leave?
				return
			inConversation = FALSE

/mob/living/simple_animal/hostile/fishing/Change-ling/attack_hand(mob/user)
	if(!shapeShifted || is_type_in_list(user, friends))
		..()
		return
	if(ishuman(user))
		var/mob/living/carbon/human/theRube = user
	theRube.Knockdown(catchSize/10)
	theRube.Stun(catchSize/10)
	if(Adjacent(theRube))
		unarmedAttack(theRube)
	if(shapeShifted == 2)
		crewShift(theRube)
		wander = 1
		spawn(5)
			var/list/helpCalls = list(
			"Help! We've got a shapeshifter!",
			"Trying to replace me? Help!",
			"Ah! Clone, help! Help!",
			"Security! Help me, there's a shapeshifter!",
			"Clone! Help! Help me!",
			"Someone help, he's trying to impersonate me!",
			"We've got an identity thief, help!",
			"I got him! I got the guy shapeshifting into people!",
			)
			say(pick(helpCalls))
		if(mutation == (ILLUSIONARY || HAUNTING))
			var/list/secondMimic = list()
			for(var/mob/living/carbon/human/M in mob_list)
				secondMimic += M
			var/mob/living/simple_animal/hostile/fishing/fishlusion/F = new /mob/living/simple_animal/hostile/fishing/fishlusion(src)
			var/mob/living/backUpMimic = pick(secondMimic)
			F.fishMimic(backUpMimic)
			var/image/I = image('icons/effects/32x32.dmi', "blank")
			I.overlays |= backUpMimic.overlays
			F.try_move_adjacent(src)
			spawn(2 SECONDS)
				say("Help! We've caught a shapeshifter!")
			spawn(catchSize/2 SECONDS)
				animate(F, alpha = 0, time = 1 SECONDS)
				qdel(F)
