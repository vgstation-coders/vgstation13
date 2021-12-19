
//Common mutations///
#define FISH_SCRAWNY /datum/angler_mutation/scrawny
#define FISH_BULKY /datum/angler_mutation/bulky
#define FISH_FRIENDLY /datum/angler_mutation/friendly
#define FISH_HOSTILE /datum/angler_mutation/hostile
#define FISH_NEUTRAL /datum/angler_mutation/neutral
#define FISH_STRONG /datum/angler_mutation/strong
#define FISH_WEAK /datum/angler_mutation/weak
#define FISH_OBEDIENT /datum/angler_mutation/obedient
#define FISH_ROWDY /datum/angler_mutation/rowdy
#define FISH_POISON /datum/angler_mutation/poison
#define FISH_TRANSPARENT /datum/angler_mutation/transparent
#define FISH_GREEDY /datum/angler_mutation/greedy

//Uncommon mutations///
#define FISH_GLOWING /datum/angler_mutation/glowing
#define FISH_LIAR /datum/angler_mutation/liar
#define FISH_GRUE /datum/angler_mutation/grue
#define FISH_APEX /datum/angler_mutation/apex
#define FISH_EMP /datum/angler_mutation/emp
#define FISH_ALCHEMIC /datum/angler_mutation/alchemic
#define FISH_UNDYING /datum/angler_mutation/undying
#define FISH_CLOWN /datum/angler_mutation/clown
#define FISH_TELEKINETIC /datum/angler_mutation/telekinetic
#define FISH_FAST /datum/angler_mutation/fast
#define FISH_CHATTY /datum/angler_mutation/chatty
#define FISH_MUSICAL /datum/angler_mutation/musical
#define FISH_HUGE /datum/angler_mutation/huge
#define FISH_BLUESPACE /datum/angler_mutation/bluespace
#define FISH_FLUX /datum/angler_mutation/flux

//Rare mutations///
#define FISH_RADIOACTIVE /datum/angler_mutation/radioactive
#define FISH_WORMHOLE /datum/angler_mutation/wormhole
#define FISH_ROYAL /datum/angler_mutation/royal
#define FISH_GRAVITY /datum/angler_mutation/gravity
#define FISH_ILLUSIONARY /datum/angler_mutation/illusionary
#define FISH_HAUNTING /datum/angler_mutation/haunting
#define FISH_GARGANTUAN /datum/angler_mutation/gargantuan
#define FISH_SPLITTING  /datum/angler_mutation/splitting
#define FISH_COMMANDING /datum/angler_mutation/commanding
#define FISH_TIME /datum/angler_mutation/time
#define FISH_EXPLODING /datum/angler_mutation/exploding
#define FISH_CULT /datum/angler_mutation/cult
#define FISH_MEDICAL /datum/angler_mutation/medical
#define FISH_VAMPIRE /datum/angler_mutation/vampire

/proc/angler_mutateDecide(var/mob/living/simple_animal/hostile/fishing/theFish, var/obj/item/weapon/bait/baitUsed)
	for(var/mutation in subtypesof(/datum/angler_mutation))
		var/datum/angler_mutation/mut = mutation
		if(baitUsed.exclusiveMutations.len)
			if(!mut in baitUsed.exclusiveMutations)
				continue
		if(mut in theFish.illegalMutations)
			continue
		mutationChance[mut] = mut.baseMutChance + mut.getMutModifiers(baitUsed, mut)
	var/datum/angler_mutation/mutationChosen = pickweight(mutationChance)
	attachMutation(theFish, mutationChosen)

/datum/angler_mutation/proc/getMutModifiers(var/obj/item/bait/theBait, var/datum/angler_mutation/theMut)
	var/mutMod = 0
	if(theBait.favoredMutations.len && theMut in theBait.favoredMutations)
		mutMod += theBait.favoredMutations[theMut]
	else
		mutMod += theBait.mutPower
	return mutMod

/mob/living/simple_animal/hostile/fishing/proc/mutateBaitlessRoll(var/mob/living/simple_animal/hostile/fishing/theFish, var/datum/angler_mutation/toOmit)
	for(var/mutation in subtypesof(/datum/angler_mutation))
		var/datum/angler_mutation/mut = mutation
		if(mut.rerollOmit || mut in theFish.illegalMutations)
			continue
		mutationChance[mut] = mut.baseMutChance
	var/datum/angler_mutation/mutationChosen = pickweight(mutationChance)
	attachMutation(theFish, mutationChosen)

/mob/living/simple_animal/hostile/fishing/proc/attachMutation(mob/living/simple_animal/hostile/fishing/theFish, datum/angler_mutation/mutationChosen)
	theFish.mutation = mutationChosen
	theFish.mutateCooldown *= mutationChosen.cooldownMod

//Mutation procs - generic///////////////

/datum/angler_mutation/proc/mutateEffect()
	return

/datum/angler_mutation/proc/mutateActivate()
	if(world.time - hostFish.lastMutActivate >= hostFish.mutateCooldown)
		hostFish.lastMutActivate = world.time
		return TRUE
	return FALSE

/datum/angler_mutation/proc/onLife()
	return

/datum/angler_mutation/proc/onDeath()
	return

/datum/angler_mutation/proc/onAggro()
	return

/datum/angler_mutation/proc/onAttack(var/atom/movable/target)
	return

//>>Mutation Datums<<////////////////

/datum/angler_mutation
	var/mutName = ""	//What we call it
	var/baseMutChance = 0	//"Default" is 100 to give flexibility, numbers should be based off that
	var/cooldownMod = 1	//Multiplier for the fish's base cooldown
	var/rerollOmit = FALSE	//For mutations that roll a second mutation, makes it so they can't be picked, causing terrifying loops
	var/mob/living/simple_animal/hostile/fishing/hostFish = null

//Scrawny///

/datum/angler_mutation/scrawny
	mutName = "scrawny"
	baseMutChance = 100

/datum/angler_mutation/scrawny/mutateEffect()
	hostFish.catchSize *= 0.8
	if(hostFish.size > SIZE_TINY)
		size--	//Pocket pets

//Bulky///

/datum/angler_mutation/bulky
	mutName = "bulky"
	baseMutChance = 100

/datum/angler_mutation/bulky/mutateEffect()
	hostFish.catchSize *= 1.2

//Friendly///

/datum/angler_mutation/friendly
	mutName = "friendly"
	baseMutChance = 100

/datum/angler_mutation/friendly/mutateEffect()
	if(hostFish.faction == "friendly")
		hostFish.tameEase *= 1.5
	else
		hostFish.faction = "friendly"

//Hostile///

/datum/angler_mutation/hostile
	mutName = "hostile"
	baseMutChance = 100

/datum/angler_mutation/hostile/mutateEffect()
	if(hostFish.faction == "hostile")
		hostFish.melee_damage_upper += 5
		hostFish.melee_damage_lower += 5
	else
		hostFish.faction = "hostile"

//Neutral///

/datum/angler_mutation/neutral
	mutName = "neutral"
	baseMutChance = 100

/datum/angler_mutation/neutral/mutateEffect()
	if(hostFish.faction == "neutral")
		hostFish.tameEase *= 1.1
		hostFish.melee_damage_upper += 3
		hostFish.melee_damage_lower += 3
	else
		hostFish.faction == "neutral"

//Strong///

/datum/angler_mutation/strong
	mutName = "strong"
	baseMutChance = 100

/datum/angler_mutation/strong/mutateEffect()
	hostFish.melee_damage_upper *= 1.3
	hostFish.melee_damage_lower *= 1.2

//Weak///

/datum/angler_mutation/weak
	mutName = "weak"
	baseMutChance = 100

/datum/angler_mutation/weak/mutateEffect()
	hostFish.melee_damage_lower *= 0.7
	hostFish.melee_damage_upper *= 0.8

//Obedient///

/datum/angler_mutation/obedient
	mutName = "obedient"
	baseMutChance = 100

/datum/angler_mutation/obedient/mutateEffect()
	hostFish.tameEase *= 2

//Rowdy///

/datum/angler_mutation/rowdy
	mutName = "rowdy"
	baseMutChance = 100

/datum/angler_mutation/rowdy/mutateEffect()
	hostFish.tameEase *= 0.5
	if(hostFish.environment_smash_flags < 2)
		hostFish.environment_smash_flags++

//Poison///

/datum/angler_mutation/poison
	mutName = "poison"
	baseMutChance = 90

/datum/angler_mutation/poison/onAttack(target)
	if(isliving(target))
		var/mob/living/A = target
		A.reagents.add_reagents(FISHTOXIN, mutantPower)

//Transparent///

/datum/angler_mutation/transparent
	mutName = "transparent"
	baseMutChance = 90

/datum/angler_mutation/transparent/mutateEffect()
	hostFish.alpha = rand(50, 200)

//Greedy///

/datum/angler_mutation/greedy
	mutName = "greedy"
	baseMutChance = 85

/datum/angler_mutation/greedy/mutateEffect()
	if(hostFish.healeat)
		hostFish.healEat = FALSE
	if(hostFish.tameChance)
		hostFish.tameChance += hostFish.mutatePower
		hostFish.tameItem = /obj/item/weapon/spacecash/c100

//Glowing///

/datum/angler_mutation/glowing
	mutName = "glowing"
	baseMutChance = 85

/datum/angler_mutation/glowing/mutateEffect()
	var/glowColor = pick("#FFFF00", "#FF00FF", "#68E8FF", "#00FF00", "#FF0000", "#0000FF")
	hostFish.set_light(hostFish.mutantPower, 1, glowColor)

//Liar///

/datum/angler_mutation/liar
	mutName = "liar"
	baseMutChance = 60
	rerollOmit = TRUE

/datum/angler_mutation/liar/mutateEffect()
	hostFish.isLiar = TRUE
	hostFish.mutateBaitlessRoll()

//Grue///

/datum/angler_mutation/grue
	mutName = "grue"
	baseMutChance = 50

/datum/angler_mutation/grue/mutateEffect()
	hostFish.set_light(hostFish.mutantPower, -20)

/datum/angler_mutation/grue/onLife()
	if(prob(hostFish.mutantPower/2))
		mutateActivate()

/datum/angler_mutation/grue/onAggro()
	mutateActivate()

/datum/angler_mutation/grue/onAttack(target)
	if(ishuman(target))
		hostFish.health = min(hostFish.health + hostFish.mutantPower, hostFish.maxHealth)
		if(target.mind)
			hostFish.maxHealth += hostFish.mutantPower
			hostFish.catchSize++

/datum/angler_mutation/grue/mutateActivate()
	playsound(hostFish, 'sound/misc/grue_growl.ogg' , 100, 1)
	for(var/obj/machinery/light/L in hostFish.range(hostFish.mutantPower)) //Should be weaker than a normal Grue's
		L.broken()


//Apex///

/datum/angler_mutation/apex
	mutName = "apex"
	baseMutChance = 15
	cooldownMod = 0.8
	rerollOmit = TRUE

/datum/angler_mutation/apex/mutateEffect()
	hostFish.name = "apex" + hostFish.name
	hostFish.catchSize *= 1.1
	hostFish.maxHealth *= 1.2
	hostFish.health = hostFish.maxHealth
	if(hostFish.size < SIZE_BIG)
		hostFish.size++
	hostFish.mutateBaitlessRoll()

//EMP///

/datum/angler_mutation/emp
	mutName = "EMP"
	baseMutChance = 15
	cooldownMod = 1.5

/datum/angler_mutation/emp/onDeath()
	empulse(hostFish,1,2)

/datum/angler_mutation/emp/onAttack(target)
	mutateActivate()

/datum/angler_mutation/emp/mutateActivate()
	if(!..())
		return
	empulse(hostFish,2,4)

//Alchemic///

/datum/angler_mutation/alchemic
	mutName = "alchemic"
	baseMutChance = 15

/datum/angler_mutation/alchemic/onLife()
	if(prob(hostFish.mutantPower))
		mutateActivate()

/datum/angler_mutation/alchemic/onAttack(target)
	if(isliving(target))
		var/mob/living/A = target
		A.reagents.add_reagents(GOLD, hostFish.mutantPower)
		var/transmuteChance = A.reagents.get_reagent_amount(GOLD)
		if(prob(transmuteChance))
			A.turn_into_statue

/datum/angler_mutation/alchemic/mutateActivate()
	if(!..())
		return
/mob/living/simple_animal/hostile/fishing/alchemFish()
	var/list/transmuteResults = list(
		/obj/item/stack/ore/iron = 50,
		/obj/item/stack/ore/plasma = 50,
		/obj/item/stack/ore/uranium = 15,
		/obj/item/stack/ore/silver = 15,
		/obj/item/stack/ore/gold = 10,
		/obj/item/stack/ore/mythril = 1,
		/obj/item/stack/ore/diamond = 5,
		/obj/item/stack/ore/clown = 1,
		/obj/item/stack/ore/phazon = 1,
		/obj/item/stack/sheet/mineral/plastic = 30,
		/obj/item/stack/sheet/cardboard = 5,
		/obj/item/stack/sheet/wood = 5,
		/obj/item/stack/sheet/brass = 5,
		/obj/item/stack/sheet/mineral/sandstone = 5,
	)
	var/list/transmuteOres = list()
	for(var/obj/item/stack/ore/O in orange(hostFish.mutantPower, hostFish))
		transmuteOres += O
	for(var/obj/item/stack/sheet/mineral/M in orange(hostFish.mutantPower, hostFish))
		transmuteOres += M
	for(var/i=1 to hostFish.mutantPower; i++)
		sleep(i*3)	//0.3 seconds between each
		var/oreToAlch = pick_n_take(transmuteOres)
		var/tLoc = oreToAlch.loc
		if(oreToAlch.use(1)
			var/tResult = pickweight(transmuteResults)
			new tResult(tLoc)
			playsound(tResult, 'sound/instruments/glockenspiel/Dn4', 50, 1)
			visible_message("<span class='notice'>\The [hostFish] transmutes \the [oreToAlch] into some [tResult]!</span>"))

//Undying///

/datum/angler_mutation/undying
	mutName = "undying"
	baseMutChance = 20

/datum/angler_mutation/undying/mutateEffect()
	hostFish.canRegenerate = 1

//Clown///

/datum/angler_mutation/clown
	mutName = "clown"
	baseMutChance = 55

/datum/angler_mutation/clown/mutateEffect()
	hostFish.attacktext = "honks"
	hostFish.speak_emote = list("honks")

/datum/angler_mutation/clown/onLife()
	if(prob(hostFish.mutantPower*2))
		playsound(hostFish, 'sound/items/bikehorn.ogg', 100, 1)
	if(prob(hostFish.mutantPower/2))
		new /obj/item/weapon/bananapeel(hostFish.loc)

/datum/angler_mutation/clown/onAttack(target)
	if(isliving(target))
		var/mob/living/A = target
		playsound(hostFish, "clownstep, 50, 1")
		if(prob(hostFish.mutantPower*2))
			playsound(A, 'sound/misc/slip.ogg', 50, 1)
			A.Knockdown(3)
			A.visible_message("<span class= 'danger'>\The [hostFish] slips \the [A]!")

//Fast///

/datum/angler_mutation/fast
	mutName = "fast"
	baseMutChance = 70

/datum/angler_mutation/fast/mutateEffect()
	hostFish.speed *= 0.9

//Chatty///

/datum/angler_mutation/chatty
	mutName = "chatty"
	baseMutChance = 35

/datum/angler_mutation/chatty/mutateEffect()
	hostFish.speak_chance += hostFish.mutantPower

/datum/angler_mutation/chatty/onLife()
	if(prob(hostFish.mutantPower*2))
		chattyFish()

/datum/angler_mutation/chatty/mutateActivate() //This is my favorite
	var/mob/living/hiGuy = pick(var/mob/living/L in orange(hostFish.mutantPower, hostFish))
	hostFish.say(pick(
		"Hi [hiGuy].",
		"Looking good, [hiGuy].",
		"[hiGuy] I heard the news, that's so great!",
		"[hiGuy] how could you do it? I can't believe we trusted you!",
		"How dare you show your face here, [hiGuy], after what you did.",
		"Oh, [hiGuy] was it? I don't believe we've been aquainted.",
		"[hiGuy], quickly there's no time to explain! I need your help!",
		"[hiGuy]! [hiGuy]! Holy shit where have you been?",
		"[hiGuy] you're never going to believe what happened!",
		"[hiGuy] did you find it? Tell me you found it!",
		"[hiGuy] don't listen to him. He's a liar.",
		"Oh I see how it is. Big shot [hiGuy] gets everything they want, and me? Stuck with nothing as usual.",
		"Oh man is that [hiGuy]? Ha, look everyone! It's [hiGuy]!",
		"Put some clothes on, [hiGuy], have you no decency?",
		"[hiGuy] you get out of here. If I see you again I'll kill you.",
		"[hiGuy] have I ever told you you're my best friend?",
		"So where's that stuff you promised me, [hiGuy]?",
		"[hiGuy] do that thing again, you know that thing you showed me with the blood.",
		"Walking pretty confidently for a murderer, [hiGuy].",
		"[hiGuy] call up your department and get them over here. We've things to discuss.",
		"I won't fall for your tricks again [hiGuy].",
		"[hiGuy] is a fish in disguise! Get them!",
		"Thanks for busting me out earlier, [hiGuy].",
		"So [hiGuy], at last it's just you and me.",
		"[hiGuy] I'm tired. I'm so tired.",
		"One more step [hiGuy], just take one more step and I'll kill you dead!",
		"Hey [hiGuy], saw you with, well you know. Niiiice.",
		"[hiGuy] I hate you I hate you I hate you I hate you so much!",
		"[hiGuy] my love! I love you and only you, you are my everything. I love you!",
		"Face me [hiGuy]. Accept my challenge and die with dignity!",
		"Please don't hurt me [hiGuy], not like you hurt the others.",
		"Who want's to hear [hiGuy]'s big secret?",
		"[hiGuy] is a liar.",
		"I would trust [hiGuy] with my life.",
		"Oh [hiGuy], still playing those childish games? You never change.",
		"Congratulations [hiGuy]!",
		"You'll never get it back from me [hiGuy], it's mine now. All mine!",
		"Wish you were here, [hiGuy].",
		"Dig deep [hiGuy], I know you can do it!",
		"Sing with me [hiGuy], sing!",
		"I can finally tell you, [hiGuy], I think you are a gross, disgusting sack of garbage and I never liked you.",
		"I hate to admit it [hiGuy], but great work on the project. We're all very impressed.",
		"Yes [hiGuy] I agree.",
		"No [hiGuy] that's a stupid idea."
	)
	if(hiGuy && prob(hostFish.mutantPower))
		spawn(rand(60 SECONDS, 600 SECONDS)) //Fish brings up how you embarrassed yourself 10 minutes later, horrifying
			hostFish.speak += pick(
				"Man, [hiGuy] sucked.",
				"I miss [hiGuy].",
				"Do you think [hiGuy] liked me?",
				"Anyone seen [hiGuy]?",
				"I hope I never have to speak to [hiGuy] again.",
				"[hiGuy] really embarrassed themselves before.",
				"I think [hiGuy] might be up to no good. They told me some things.",
				"What a shining beacon of good that [hiGuy] is, we could all learn from their example.",
				"[hiGuy] disgusts me. What a terrible individual.",
				"[hiGuy] really thinks they're all that huh? Ha!",
				"[hiGuy] sure is cool. I hope I can be that cool some day."
			)


//Huge///

/datum/angler_mutation/huge
	mutName = "huge"
	baseMutChance = 35

/datum/angler_mutation/huge/mutateEffect()
	hostFish.catchSize *= 1.5

//Bluespace///

/datum/angler_mutation/bluespace
	mutName = "bluespace"
	baseMutChance = 25

/datum/angler_mutation/bluespace/onLife()
	if(prob(hostFish.mutantPower))
		do_teleport(hostFish, get_turf(hostFish), hostFish.mutantPower)


//Flux///

/datum/angler_mutation/flux
	mutName = "flux"
	baseMutChance = 20
	rerollOmit = TRUE

/datum/angler_mutation/flux/mutateEffect()
	hostFish.catchSize *= rand(1, 20)
	hostFish.catchSize /= round(10,1)
	hostFish.maxHealth *= rand(1,20)
	hostFish.maxHealth /= round(10,1)
	hostFish.health = hostFish.maxHealth
	if(prob(50))
		hostFish.mutateBaitlessRoll()
	if(prob(10))
		hostFish.mutateBaitlessRoll()

//Radioactive///

/datum/angler_mutation/radioactive
	mutName = "radioactive"
	baseMutChance = 10

/datum/angler_mutation/radioactive/onLife()
	var/radPow = hostFish.catchSize + hostFish.mutantPower
	for(var/mob/living/L in orange(hostFish.mutantPower, hostFish))
		L.apply_radiation(hostFish.mutantPower, RAD_EXTERNAL)
	emitted_harvestable_radiation(get_turf(hostFish), radPow, range = mutantPower)	//Fish engine 2

//Wormhole///

/datum/angler_mutation/wormhole
	mutName = "wormhole"
	baseMutChance = 5

//Royal///

/datum/angler_mutation/royal
	mutName = "royal"
	baseMutChance = 10

/datum/angler_mutation/royal/mutateEffect()
	//Something something catch pools

//Gravity///

/datum/angler_mutation/gravity
	mutName = "gravity"
	baseMutChance = 10

/datum/angler_mutation/gravity/onLife()
	if(prob(hostFish.mutantPower/5))
		gravFishPulse()

/datum/angler_mutation/gravity/mutateActivate()
	if(!..())
		return
	for(var/atom/movable/T in orange(hostFish.mutantPower, hostFish)
		if(!T.anchored)
			if(ishuman(T))
				var/mob/living/carbon/human/H = T
				H.Knockdown(hostFish.mutantPower/2)
			T.throw_at(hostFish)

//Illusionary///

/datum/angler_mutation/illusionary
	mutName = "illusionary"
	baseMutChance = 15

/datum/angler_mutation/illusionary/onLife()
	if(prob(hostFish.mutantPower))
		illusionFish(1)

/datum/angler_mutation/illusionary/onAggro()
	mutateActivate()

/datum/angler_mutation/illusionary/mutateActivate()
	illusionFish(hostFish.mutatePower)

/datum/angler_mutation/illusionary/illusionFish(var/Iamount)
	for(var/i=1 to Iamount; i++)
		var/mob/living/simple_animal/hostile/fishing/fishlusion/G = new (/mob/living/simple_animal/hostile/fishing/fishlusion(hostFish.loc))
		G.try_move_adjacent(hostFish)
		G.fishMimic(hostFish)

//Haunting///

/datum/angler_mutation/haunting
	mutName = "haunting"
	baseMutChance = 15

/datum/angler_mutation/haunting/onDeath()
	mutateActivate()

/datum/angler_mutation/haunting/mutateActivate()
	if(!..())
		return
	var/list/liveCrew = list()
	for(var/C in data_core.general)	//to-do maybe replace this with living players list, I think that exists.
		if(C.stat != DEAD)
			liveCrew += C
	var/hauntGrudge = pick(liveCrew)
	to_chat(hauntGrudge, "<span class='warning'>You feel a sudden chill. Something smells like [hostFish]?</span>")
	for(var/i=1 to hostFish.mutantPower)
		spawn(rand(10,200))
			var/mob/living/simple_animal/hostile/fishing/fishlusion/G = new (/mob/living/simple_animal/hostile/fishing/fishlusion(hauntGrudge.loc))
			G.fishMimic(hostFish)
			G.alpha = hostFish.alpha/2
			G.melee_damage_lower = hostFish.mutantPower
			G.melee_damage_upper = hostFish.mutantPower
			G.try_move_adjacent(hauntGrudge)
			spawn(hostFish.mutantPower SECONDS)
				qdel(G)

//Gargantuan///

/datum/angler_mutation/gargantuan
	mutName = "gargantuan"
	baseMutChance = 10

/datum/angler_mutation/gargantuan/mutateEffect()
	hostFish.catchSize *= 2.2

//Splitting///

/datum/angler_mutation/splitting
	mutName = "splitting"
	baseMutChance = 15

/datum/angler_mutation/splitting/onLife()
	if((prob(hostFish.mutantPower/5) && (prob(50)))
		new hostFish(hostFish.loc)
		hostFish.visible_message("<span class='notice'>\The [hostFish] splits, creating new life!</span>")
		playsound(hostFish, 'sound/effects/flesh_squelch.ogg', 100, 1)
		if(istype(get_area(hostFish), /area/chapel))
			new /obj/item/weapon/reagent_containers/food/snacks/sliceable/bread(src.loc)	//Aaaaaameeeeen

/datum/angler_mutation/splitting/onDeath()
	if(prob(hostFish.mutantPower*hostFish.mutantPower))
		spawn(rand(5 SECONDS, 25 SECONDS))
			new hostFish(hostFish.loc)

//Commanding///

/datum/angler_mutation/commanding
	mutName = "commanding"
	baseMutChance = 5

/datum/angler_mutation/commanding/onLife()
	if(prob(hostFish.mutantPower/2))
		mutateActivate()

/datum/angler_mutation/commanding/onAggro()
	mutateActivate()

/datum/angler_mutation/commanding/mutateActivate()
	var/simonSays = pick("Fall", "Burn", "Dance", "Beg", "Rejoice", "Fear", "Be well", "Move", "Scream", "Explore", "Hunger", "Drool", "Stumble")
	hostFish.say("[simonSays]!")
	sleep(10)
	for(var/mob/living/carbon/human/H in orange(hostFish.mutantPower, hostFish)
		if(H.is_deaf)
			continue
		switch(simonSays)
			if("Fall")
				H.Knockdown(hostFish.mutantPower)
			if("Burn")
				H.fire_act()
			if("Dance")
				spawn for(var/i=1, i<=8, i++)
					H.dir = turn(user.dir, 45)
			if("Beg")
				H.Knockdown(1)
				if(!issilent(H))
					H.say("Please, please!")
			if("Rejoice")
				new /obj/item/weapon/spacecash/c100(H.loc)
			if("Fear")
				var/spookToSpawn = pick(
					/mob/living/simple_animal/hostile/necro/skeleton,
					/mob/living/simple_animal/hostile/humanoid/skellington,
					/mob/living/carbon/monkey/vox/skeletal,
					/obj/structure/skele_stand,
					/mob/living/carbon/monkey/skellington
					)
				var/theSpook = new spookToSpawn(hostFish.loc)
				theSpook.throw_at(H)
				break
			if("Be well")
				H.adjustBruteLoss(-25)
				H.adjustToxicLoss(-25)
				H.adjustBurnLoss(-25)
				H.adjustOxyLoss(-25)
			if("Move")
				do_teleport(H, get_turf(H), hostFish.mutantPower)
			if("Explore")
				var/turf/T = get_turf(H)
				var/E = locate(rand(TRANSITIONEDGE, world.maxx - TRANSITIONEDGE), rand(TRANSITIONEDGE, world.maxy - TRANSITIONEDGE), pick(1,3,4,5,6))
				do_teleport(H, E, 1)
				spawn(rand(10,100))
					do_teleport(H, T, 0)
			if("Hunger")
				H.overeatduration -= H.overeatduration*0.9
				H.nutrition -= H.nutrition*0.9
			if("Drool")
				H.adjustBrainLoss(5)
			if("Stumble")
				H.reagents.add_reagent(WHISKEY, 20)

//Time///

/datum/angler_mutation/time
	mutName = "time"
	baseMutChance = 1

/datum/angler_mutation/time/mutateEffect()
	hostFish.flags |= TIMELESS

/datum/angler_mutation/time/onLife()
	if(prob(hostFish.mutantPower/5))
		mutateActivate()

/datum/angler_mutation/time/onDeath()
	if(world.time - hostFish.lastMutActivate >= hostFish.mutateCooldown/hostFish.mutantPower)
		lastMutActivate = world.time
		health = maxHealth
		timestop(hostFish, hostFish.mutantPower, hostFish.mutantPower)

/datum/angler_mutation/time/onAggro()
	mutateActivate()

/datum/angler_mutation/time/onAttack(target)
	if(prob(mutantPower*2))
		timestop(target, 0, 1)

/datum/angler_mutation/time/mutateActivate()
	if(!..())
		return
	timestop(hostFish, hostfish.mutantPower, hostFish.mutantPower)

//Cult///

/datum/angler_mutation/cult
	mutName = "cult"
	baseMutChance = 5

/datum/angler_mutation/cult/onLife()
	if(prob(hostFish.mutantPower))
		cultFish()

//Telekinetic///

/datum/angler_mutation/telekinetic
	mutName = "telekinetic"
	baseMutChance = 20
	cooldownMod = 0.3

/datum/angler_mutation/telekinetic/onLife()
	if(prob(hostFish.mutantPower/2))
		telekinFish()

/datum/angler_mutation/telekinetic/onAttack(target)
	mutateActivate(target)

/datum/angler_mutation/telekinetic/mutateActivate(target)
	if(!..())
		return
	if(ishuman(target))
		var/mob/living/carbon/human/A = target
		A.Knockdown(hostFish.mutantPower)
		endLocation = get_ranged_target_turf(hostFish, rand(1,8), hostFish.mutantPower)
		A.throw_at(endLocation, hostFish.mutantPower, 4)

/datum/angler_mutation/telekinetic/proc/telekinFish()
	var/list/possTargets = circlerangeturfs(hostFish, hostFish.mutantPower)
	for(var/atom/movable/T in orange(hostFish.mutantPower, hostFish)
		if((!T.anchored) && (prob(hostFish.mutantPower*3)))
			var/obj/effect/overlay/O = new /obj/effect/overlay(T.loc) //Copy pasted right from telekinesis
			O.name = "sparkles"
			O.anchored = 1
			O.setDensity(FALSE)
			O.layer = FLY_LAYER
			O.plane = EFFECTS_PLANE
			O.dir = pick(cardinal)
			O.icon = 'icons/effects/effects.dmi'
			O.icon_state = "nothing"
			flick("empdisable",O)
			spawn(5)
				qdel(O)
			T.throw_at(pick(possTargets))

//Exploding///

/datum/angler_mutation/exploding
	mutName = "exploding"
	baseMutChance = 5

/datum/angler_mutation/exploding/onDeath()
	explosion(hostFish, hostFish.mutantPower/5, hostFish.mutantPower/3, hostFish.mutantPower/2)
















//OLD BAD VERSION STARTS HERE/////////////////////





/mob/living/simple_animal/hostile/fishing/proc/mutateEffect()
	switch(mutation)
		if(SCRAWNY)
			catchSize *= 0.8
			if(size > SIZE_TINY)
				size--	//Pocket pets
		if(BULKY)
			catchSize *= 1.2
		if(FRIENDLY)
			if(faction == "friendly")
				tameEase *= 1.5
			else
				faction = "friendly"
		if(HOSTILE)
			if(faction == "hostile")
				melee_damage_upper += 5
				melee_damage_lower += 5
			else
				faction = "hostile"
		if(NEUTRAL)
			if(faction == "neutral")
				tameEase *= 1.1
				melee_damage_upper += 3
				melee_damage_lower += 3
			else
				faction = "neutral"
		if(STRONG)
			melee_damage_upper *= 1.3
			melee_damage_lower *= 1.2
		if(WEAK)
			melee_damage_upper *= 0.8
			melee_damage_lower *= 0.7
		if(OBEDIENT)
			tameEase *= 2
		if(ROWDY)
			tameEase *= 0.5
			if(environment_smash_flags < 2)
				environment_smash_flags++
		if(TRANSPARENT)
			alpha = rand(50,200)
		if(GREEDY)
			if(healEat)
				healEat = FALSE
			if(tameChance)
				tameChance += mutatePower
				tameItem = /obj/item/weapon/spacecash/c100
		if(GLOWING)
			var/glowColor = pick("#FFFF00", "#FF00FF", "#68E8FF", "#00FF00", "#FF0000", "#0000FF")
			set_light(mutantPower, 1, glowColor)
		if(LIAR)
			isLiar = TRUE
			mutateBaitlessRoll(src)
			mutateEffect()
		if(GRUE)
			set_light(mutantPower,-20)
		if(APEX)
			name = "apex" + name
			catchSize *= 1.1
			maxHealth *= 1.2
			health = maxHealth
			if(size < SIZE_BIG)
				size++
			mutateBaitlessRoll(src)
			mutateEffect()
		if(UNDYING)
			canRegenerate = 1
		if(CLOWN)
			attacktext = "honks"
			speak_emote = list("honks")
		if(FAST)
			speed *= 0.9
		if(CHATTY)
			speak_chance += mutantPower
		if(HUGE)
			catchSize *= 1.5
		if(FLUX)
			catchSize *= rand(1,20)
			catchSize /= round(10,1)
			maxHealth *= rand(1,20)
			maxHealth /= round(10,1)
			health = maxHealth
			if(prob(50))
				mutateBaitlessRoll(src)
				mutateEffect()
			if(prob(10))
				mutateBaitlessRoll(src)
				mutateEffect()
		if(GARGANTUAN)
			catchSize *= 2.2
		if(ROYAL)
			//pick from the catch list in the area
		if(TIME)
			flags += TIMELESS


/mob/living/simple_animal/hostile/fishing/Life()
	..()
	if((mutation) && (!specMutateTrigger))
		switch(mutation)
			if(GRUE)
				if(prob(mutantPower/2))
					mutateActivate()
			if(BLUESPACE)
				if(prob(mutantPower))
					do_teleport(src, get_turf(src), mutantPower)
			if(SPLITTING)
				if((prob(mutantPower/5) && (prob(50)))
					new src(src.loc)
					src.visible_message("<span class='notice'>\The [src] splits, creating new life!</span>")
					playsound(src, 'sound/effects/flesh_squelch.ogg', 100, 1)
					if(istype(get_area(src), /area/chapel))
						new /obj/item/weapon/reagent_containers/food/snacks/sliceable/bread(src.loc)	//Aaaaaameeeeen
			if(ALCHEMIC)
				if(prob(mutantPower))
					mutateActivate()
			if(CLOWN)
				if(prob(mutantPower*2))
					playsound(src, 'sound/items/bikehorn.ogg', 100, 1)
				if(prob(mutantPower/2))
					new /obj/item/weapon/bananapeel(src.loc)
			if(CHATTY)
				if(prob(mutantPower*2))
					chattyFish()
			if(RADIOACTIVE)
				for(var/mob/living/L in orange(mutantPower,src)
					L.apply_radiation(mutantPower, RAD_EXTERNAL)
			if(CULT)
				if(prob(mutantPower))
					cultFish()
			if(GRAVITY)
				if(prob(mutantPower/5))
					gravFishPulse()
			if(ILLUSIONARY)
				if(prob(mutantPower))
					illusionFish(1)
			if(COMMANDING)
				if(prob(mutantPower/2))
					mutateActivate()
			if(TELEKINETIC)
				if(prob(mutantPower/2))
					telekinFish()
			if(TIME)
				if(prob(mutantPower/5))
					mutateActivate()


/mob/living/simple_animal/hostile/fishing/death(var/gibbed = FALSE)
	if((mutation) && (!specMutateTrigger))
		switch(mutation)
			if(EXPLODING)
				explosion(T, 1, mutantPower/3, mutantPower/2)
			if(HAUNTING)
				ghostFishBoo()
			if(SPLITTING)
				if(prob(mutantPower*2))
					spawn(rand(50,250))
						new src(src.loc)
			if(EMP)
				empulse(src,1,2)
			if(TIME)
				if(world.time - lastMutActivate >= mutateCooldown/mutantPower)	//On death they "reverse time" and timestop the area. Cooldown is much, much lower than normal.
					lastMutActivate = world.time
					health = maxHealth
					timestop(src, mutantPower, mutantPower)
					return
	..()


/mob/living/simple_animal/hostile/fishing/Aggro()
	..()
	if((mutation) && (!specMutateTrigger))
		switch(mutation)
			if(GRUE)
				mutateAtivate()
			if(ILLUSIONARY)
				mutateActivate()
			if(COMMANDING)
				mutateActivate()
			if(GRAVITY)
				mutateActivate()
			if(COMMANDING)
				mutateActivate()
			if(TIME)
				mutateActivate()

/mob/living/simple_animal/hostile/fishing/AttackingTarget()
	..()
	if((mutation) && (!specMutateTrigger))
		if(isliving(target))
			var/mob/living/A = target
		switch(mutation)
			if(POISON)
				A.reagents.add_reagents(CARPOTOXIN, mutantPower) //Placeholder chem, may make a generic space fish toxin different from carp
			if(ALCHEMIC)
				A.reagents.add_reagents(GOLD, mutantPower)
				var/transmuteChance = A.reagents.get_reagent_amount(GOLD)
				if(prob(transmuteChance))
					A.turn_into_statue
			if(EMP)
				mutateActivate()
			if(CLOWN)
				playsound(src, "clownstep", 50, 1)
				if(prob(mutantPower*2))
					playsound(A, 'sound/misc/slip.ogg', 50, 1)
					A.Knockdown(3)
					A.visible_message("<span class='danger'>\The [src] slips [A]!</span>")
			if(TELEKINETIC)
				mutateActivate(A)
			if(TIME)
				if(prob(mutantPower*2))
					timestop(target, 0, 1)	//Timestop just their target for 1 second
			if(GRUE)
				if(ishuman(target))
					health = min(health + mutantPower, maxHealth)
					if(target.mind)
						maxHealth += mutantPower
						catchSize++



//Run activateable mutations through a generic timer then activate them//////

/mob/living/simple_animal/hostile/fishing/mutateActivate()
	if(world.time - lastMutActivate >= mutateCooldown)
		lastMutActivate = world.time
		switch(mutation)
			if(GRUE)
				grueFish()
			if(ILLUSIONARY)
				illusionFish(mutatePower)
			if(COMMANDING)
				commandFish()
			if(EMP)
				empulse(src,2,4)
			if(ALCHEMIC)
				alchemFish()
			if(GRAVITY)
				gravFishPulse()
			if(TELEKINETIC)
				A.Knockdown(mutantPower)
				endLocation = get_ranged_target_turf(src, rand(1,8), mutantPower)
				A.throw_at(endLocation, mutantPower, 4)
			if(TIME)
				timestop(src, mutantPower, mutantPower)


//Individual fish's mutation procs//////

/mob/living/simple_animal/hostile/fishing/alchemFish()
	var/list/transmuteResults = list(
		/obj/item/stack/ore/iron = 50,
		/obj/item/stack/ore/plasma = 50,
		/obj/item/stack/ore/uranium = 15,
		/obj/item/stack/ore/silver = 15,
		/obj/item/stack/ore/gold = 10,
		/obj/item/stack/ore/mythril = 1,
		/obj/item/stack/ore/diamond = 5,
		/obj/item/stack/ore/clown = 1,
		/obj/item/stack/ore/phazon = 1,
		/obj/item/stack/sheet/mineral/plastic = 30,
		/obj/item/stack/sheet/cardboard = 5,
		/obj/item/stack/sheet/wood = 5,
		/obj/item/stack/sheet/brass = 5,
		/obj/item/stack/sheet/mineral/sandstone = 5,
	)
	var/list/transmuteOres = list()
	for(var/obj/item/stack/ore/O in orange(mutantPower))
		transmuteOres += O
	for(var/obj/item/stack/sheet/mineral/M in orange(mutantPower))
		transmuteOres += M
	for(var/i=1 to mutantPower)
		sleep(5)
		var/oreToAlch = pick(transmuteOres)
		var/tLoc = oreToAlch.loc
		if(oreToAlch.use(1)
			var/tResult = pickweight(transmuteResults)
			new tResult(tLoc)
			playsound(tResult, 'sound/instruments/glockenspiel/Dn4', 50, 1)
			visible_message("<span  class='notice'>\The [src] transmutes \the [oreToAlch] into some [tResult]!</span>"))

/mob/living/simple_animal/hostile/fishing/telekinFish()
	var/list/possTargets = circlerangeturfs(src,mutantPower)
	for(var/atom/movable/T in orange(mutantPower,src)
		if((!T.anchored) && (prob(mutantPower*3)))
			var/obj/effect/overlay/O = new /obj/effect/overlay(T.loc) //Copy pasted right from telekinesis
			O.name = "sparkles"
			O.anchored = 1
			O.setDensity(FALSE)
			O.layer = FLY_LAYER
			O.plane = EFFECTS_PLANE
			O.dir = pick(cardinal)
			O.icon = 'icons/effects/effects.dmi'
			O.icon_state = "nothing"
			flick("empdisable",O)
			spawn(5)
				qdel(O)
			T.throw_at(pick(possTargets))


/mob/living/simple_animal/hostile/fishing/illusionFish(var/Iamount)
	for(var/i=1 to Iamount)
		var/mob/living/simple_animal/hostile/fishing/fishlusion/G = new (/mob/living/simple_animal/hostile/fishing/fishlusion(src.loc))
		G.try_move_adjacent(src)
		G.fishMimic(src)

/mob/living/simple_animal/hostile/fishing/grueFish()
	playsound(src, 'sound/misc/grue_growl.ogg' , 100, 1)
	for(var/obj/machinery/light/L in range(mutantPower)) //Should be weaker than a normal Grue's
		L.broken()

/mob/living/simple_animal/hostile/fishing/chattyFish() //This is my favorite
	var/mob/living/hiGuy = pick(var/mob/living/L in orange(mutantPower,src))
	src.say(pick(
		"Hi [hiGuy].",
		"Looking good, [hiGuy].",
		"[hiGuy] I heard the news, that's so great!",
		"[hiGuy] how could you do it? I can't believe we trusted you!",
		"How dare you show your face here, [hiGuy], after what you did.",
		"Oh, [hiGuy] was it? I don't believe we've been aquainted.",
		"[hiGuy], quickly there's no time to explain! I need your help!",
		"[hiGuy]! [hiGuy]! Holy shit where have you been?",
		"[hiGuy] you're never going to believe what happened!",
		"[hiGuy] did you find it? Tell me you found it!",
		"[hiGuy] don't listen to him. He's a liar.",
		"Oh I see how it is. Big shot [hiGuy] gets everything they want, and me? Stuck with nothing as usual.",
		"Oh man is that [hiGuy]? Ha, look everyone! It's [hiGuy]!",
		"Put some clothes on, [hiGuy], have you no decency?",
		"[hiGuy] you get out of here. If I see you again I'll kill you.",
		"[hiGuy] have I ever told you you're my best friend?",
		"So where's that stuff you promised me, [hiGuy]?",
		"[hiGuy] do that thing again, you know that thing you showed me with the blood.",
		"Walking pretty confidently for a murderer, [hiGuy].",
		"[hiGuy] call up your department and get them over here. We've things to discuss.",
		"I won't fall for your tricks again [hiGuy].",
		"[hiGuy] is a fish in disguise! Get them!",
		"Thanks for busting me out earlier, [hiGuy].",
		"So [hiGuy], at last it's just you and me.",
		"[hiGuy] I'm tired. I'm so tired.",
		"One more step [hiGuy], just take one more step and I'll kill you dead!",
		"Hey [hiGuy], saw you with, well you know. Niiiice.",
		"[hiGuy] I hate you I hate you I hate you I hate you so much!",
		"[hiGuy] my love! I love you and only you, you are my everything. I love you!",
		"Face me [hiGuy]. Accept my challenge and die with dignity!",
		"Please don't hurt me [hiGuy], not like you hurt the others.",
		"Who want's to hear [hiGuy]'s big secret?",
		"[hiGuy] is a liar.",
		"I would trust [hiGuy] with my life.",
		"Oh [hiGuy], still playing those childish games? You never change.",
		"Congratulations [hiGuy]!",
		"You'll never get it back from me [hiGuy], it's mine now. All mine!",
		"Wish you were here, [hiGuy].",
		"Dig deep [hiGuy], I know you can do it!",
		"Sing with me [hiGuy], sing!",
		"I can finally tell you, [hiGuy], I think you are a gross, disgusting sack of garbage and I never liked you.",
		"I hate to admit it [hiGuy], but great work on the project. We're all very impressed.",
		"Yes [hiGuy] I agree.",
		"No [hiGuy] that's a stupid idea."
	)
	if(prob(mutantPower))
		spawn(rand(60 SECONDS, 600 SECONDS)) //Fish brings up how you embarrassed yourself 10 minutes later, horrifying
			speak += pick(
				"Man, [hiGuy] sucked.",
				"I miss [hiGuy].",
				"Do you think [hiGuy] liked me?",
				"Anyone seen [hiGuy]?",
				"I hope I never have to speak to [hiGuy] again.",
				"[hiGuy] really embarrassed themselves before.",
				"I think [hiGuy] might be up to no good. They told me some things.",
				"What a shining beacon of good that [hiGuy] is, we could all learn from their example.",
				"[hiGuy] disgusts me. What a terrible individual.",
				"[hiGuy] really thinks they're all that huh? Ha!",
				"[hiGuy] sure is cool. I hope I can be that cool some day."
			)

/mob/living/simple_animal/hostile/fishing/ghostFishBoo()
	var/list/liveCrew = list()
	for(var/C in data_core.general)
		if(C.stat != DEAD)
			liveCrew += C
	var/hauntGrudge = pick(liveCrew)
	to_chat(hauntGrudge, "<span class='warning'>You feel a sudden chill. Something smells like [src]?</span>"))
	for(var/i=1 to mutantPower)
		spawn(rand(10,200))
			var/mob/living/simple_animal/hostile/fishing/fishlusion/G = new (/mob/living/simple_animal/hostile/fishing/fishlusion(hauntGrudge.loc))
			G.fishMimic(src)
			G.alpha = src.alpha/2
			G.melee_damage_lower = src.mutantPower
			G.melee_damage_upper = src.mutantPower
			G.try_move_adjacent(hauntGrudge)
			spawn(mutantPower SECONDS)
				qdel(G)

/mob/living/simple_animal/hostile/fishing/gravFishPulse()
	for(var/atom/movable/T in orange(mutantPower,src)
		if(!T.anchored)
			if(ishuman(T))
				var/mob/living/carbon/human/H = T
				H.Knockdown(mutantPower/2)
			T.throw_at(src)

/mob/living/simple_animal/hostile/fishing/commandFish()
	var/simonSays = pick("Fall", "Burn", "Dance", "Beg", "Rejoice", "Fear", "Be well", "Move", "Scream", "Explore", "Hunger", "Drool", "Stumble")
	say("[simonSays]!")
	sleep(10)
	for(var/mob/living/carbon/human/H in orange(mutantPower,src)
		if(H.is_deaf)
			continue
		switch(simonSays)
			if("Fall")
				H.Knockdown(mutantPower)
			if("Burn")
				H.fire_act()
			if("Dance")
				spawn for(var/i=1, i<=8, i++)
					H.dir = turn(user.dir, 45)
			if("Beg")
				H.Knockdown(1)
				if(!issilent(H))
					H.say("Please, please!")
			if("Rejoice")
				new /obj/item/weapon/spacecash/c100(H.loc)
			if("Fear")
				var/spookToSpawn = pick(
					/mob/living/simple_animal/hostile/necro/skeleton,
					/mob/living/simple_animal/hostile/humanoid/skellington,
					/mob/living/carbon/monkey/vox/skeletal,
					/obj/structure/skele_stand,
					/mob/living/carbon/monkey/skellington
					)
				var/theSpook = new spookToSpawn(src.loc)
				theSpook.throw_at(H)
				break
			if("Be well")
				H.adjustBruteLoss(-25)
				H.adjustToxicLoss(-25)
				H.adjustBurnLoss(-25)
				H.adjustOxyLoss(-25)
			if("Move")
				do_teleport(H, get_turf(H), mutantPower)
			if("Explore")
				var/turf/T = get_turf(H)
				var/E = locate(rand(TRANSITIONEDGE, world.maxx - TRANSITIONEDGE), rand(TRANSITIONEDGE, world.maxy - TRANSITIONEDGE), pick(1,3,4,5,6))
				do_teleport(H, E, 1)
				spawn(rand(10,100))
					do_teleport(H, T, 0)
			if("Hunger")
				H.overeatduration -= H.overeatduration*0.9
				H.nutrition -= H.nutrition*0.9
			if("Drool")
				H.adjustBrainLoss(5)
			if("Stumble")
				H.reagents.add_reagent(WHISKEY, 20)

