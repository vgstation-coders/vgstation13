/mob/living/simple_animal/hostile/fishing/snitchfish
	name = "snitch fish"
	desc = "These delicate, chitin covered organisms are able to see a previously unknown spectrum of light, giving them seemingly psychic awareness. They have also learned to document their visions for use by their whole colony."
	icon_state = "snitch_fish"
	icon_living = "snitch_fish"
	icon_dead = "snitch_fish_dead"
	size = SIZE_TINY
	search_objects = 2
	maxHealth = 10
	health = 10
	minCatchSize = 3
	maxCatchSize = 6
	var/snitchCooldown = 1200
	var/lastSnitch = 0

	possibleMutations = list()
	wanted_objects = list(/obj/item/weapon/paper)

/mob/living/simple_animal/hostile/fishing/snitchfish/New()
	..()
	snitchCooldown = 12000/catchSize //Two minutes at max catch size pre-mutation/bait increases
	if(mutation == FISH_TELEKINETIC)
		snitchCooldown /= 2

/mob/living/simple_animal/hostile/fishing/snitchfish/AttackingTarget()
	if(istype(target, /obj/item/weapon/paper))
		if(world.time - lastSnitch >= snitchCooldown)
			decideSnitch(target)
		else
			LoseTarget()
	..()

/mob/living/simple_animal/hostile/fishing/snitchfish/proc/decideSnitch()
	var/snitchType = pick(itemSnitch, mobSnitch, otherSnitch)
	var/toSnitch = null
	switch(snitchType)
		if(itemSnitch)
			toSnitch = snitchOnItems()
		if(mobSnitch)
			var/mob/living/mobS = pick(mob_list)
			if(mobS == src)
				visible_message("<span class='warning'>\The [src] twitches violently.</span>")
				sleep(2 SECONDS)
				explosion(get_turf(src.loc),-1,0,2)
				return
			if(ishuman(mobS) && mobS.mind)
				toSnitch = snitchOnCrew(mobS)
			else
				toSnitch = snitchOnMobs(mobS)
		if(otherSnitch)
			toSnitch = snitchOnOther()
	if(toSnitch)
		writeSnitch(toSnitch, target)

/mob/living/simple_animal/hostile/fishing/snitchfish/proc/snitchOnItems()
	var/theSnitch = ""
	var/snitchArea = pick(area)
	var/list/sItems = list()
	for(var/obj/item/i in snitchArea)
		sItems += i
	if(!sItems.len)
		visible_message("<span class='notice'>\The [src] looks disappointed.</span>")
		return FALSE
	var/obj/item/itemS = pick(sItems)
	if(mutation == FISH_BLUESPACE)
		if(prob(catchSize))
			do_teleport(itemS, get_turf(src), 10 - catchSize)
	var/sRoll = rand(1,10)
	switch(sRoll)
		if(1)
			theSnitch = "[itemS] is at [itemS.x], [itemS.y], [itemS.z]."
		if(2)
			if(itemS.w_class > W_CLASS_MEDIUM)
				theSnitch = "[itemS] is heavy."
			else
				theSnitch = "[itemS] is light."
		if(3)
			var/itemHeldBy = itemS.loc
			if(ishuman(itemHeldBy))
				theSnitch = "[itemS] is being carried by [itemHeldBy.name]."
			if(isitem(itemHeldBy))
				theSnitch = "[itemS] is inside the [itemHeldBy.name]."
			else
				theSnitch = "[itemS] is in [itemS.area.name]."
		if(4)
			var/list/byItemS = list()
			for(var/atom/movable/A in orange(itemS, 2))
				byItemS += A
			if(!byItemS.len)
				theSnitch = "[itemS] isn't near anything at all."
			var/adjItemS = pick(byItemS)
			theSnitch = "[itemS] is near \the [adjItemS.name]"
		if(5)
			if(itemS.reagents)
				var/itemSreag = itemS.reagents[1]
				theSnitch = "[itemS] has some [itemSreag.name] in it."
			else
				theSnitch = "[itemS] doesn't have any chemicals in it."
		if(6)
			if(itemS.contents)
				var/itemInside = pick(itemS.contents)
				theSnitch = "[itemInside] is inside [itemS]."
			else
				theSnitch = "[itemS] doesn't contain anything."
		if(7)
			theSnitch = "[itemS] is in [ItemS.area.name] which is in zeta sector [ItemS.z]."
		if(8)
			var/turf/T = get_turf(itemS)
			spawn(10)
				if(get_turf(itemS != T))
					theSnitch = "[itemS] is moving."
				else
					theSnitch = "[itemS] is not moving."
		if(9)
			if(itemS.had_blood)
				theSnitch = "[itemS] has been covered in blood."
			else
				theSnitch = "[itemS] has never been covered in blood."
		if(10)
			if(itemS.damtype)
				if((itemS.damtype == "brute" || (itemS.damtype == BRUTE))
					theSnitch = "[itemS] would probably leave a bruise."
				if((itemS.damtype == "burn") || (itemS.damtype == BURN) || (itemS.damtype == "fire"))
					theSnitch = "[itemS] would probably leave a burn."
				else
					theSnitch = "[itemS] probably isn't too dangerous to swing around."
	return(theSnitch)


/mob/living/simple_animal/hostile/fishing/snitchfish/proc/snitchOnMobs(mob/living/mobS)
	var/theSnitch = ""
	var/sRoll = rand(1,10)
	switch(sRoll)
		if(1)
			if(mobS.mind)
				theSnitch = "[mobS] is fully sentient."
			else
				theSnitch = "[mobS] doesn't have much of a mind to speak of."
		if(2)
			if(mobS.isDead())
				theSnitch = "[mobS] is dead."
			else
				theSnitch = "[mobS] is alive."
		if(3)
			theSnitch = "[mobS] is at [mobS.x], [mobS.y], [mobS.z]."
		if(4)
			theSnitch = "[mobS] is in [mobS.area.name]."
		if(5)
			theSnitch = "[mobS] is in [mobS.area.name], which is in zeta sector [mobS.z]."
		if(6)
			var/list/bymobS = list()
			for(var/atom/movable/A in orange(mobS, 2))
				bymobS += A
			if(!bymobS.len)
				theSnitch = "[mobS] isn't near anything at all."
			var/adjmobS = pick(bymobS)
			theSnitch = "[mobS] is near \the [adjmobS.name]"
		if(7)
			if(mobS.size > SIZE_SMALL)
				theSnitch = "[mobS] is big."
			else
				theSnitch = "[mobS] is small."
		if(8)
			theSnitch = "[mobS] could be described as [mobS.faction]." //Yes, zombie could be described as zombie, thank you snitchfish
		if(9)
			if(mobS.speak_chance)
				theSnitch = "[mobS] is a talker."
			else
				theSnitch = "[mobS] is the quiet type."
		if(10)
			if(mobS.health == mobS.maxHealth)
				theSnitch = "[mobS] is completely healthy."
			else
				theSnitch = "[mobS] is hurt."
	return(theSnitch)


/mob/living/simple_animal/hostile/fishing/snitchfish/proc/snitchOnCrew(/mob/living/mobS)
	var/theSnitch = ""
	var/mob/living/carbon/human/crewS = mobS
	if(mutation == FISH_HAUNTING | FISH_ILLUSIONARY)	//Spooky
		var/turf/T = get_turf(crewS)
		var/mob/living/simple_animal/hostile/fishing/fishlusion/G = new /mob/living/simple_animal/hostile/fishing/fishlusion(T)
		G.fishMimic(src)
		G.try_move_adjacent(T)
		G.alpha =/ 2
		G.wander = 0
		spawn(2 SECONDS)
			qdel(G)
	var/sRoll = rand(1, 20)
	switch(sRoll)
		if(1)
			if(crewS.assigned_role)
				theSnitch = "[crewS]'s works as [crewS.assigned_role]."
			else
				theSnitch = "[crewS] doesn't have a job."
		if(2)
			if(crewS.assigned_role)
				theSnitch = "The [crewS.assigned_role]'s name is [crewS].'"
			else
				theSnitch = "[crewS] doesn't work here."
		if(3)
			theSnitch = "[crewS]'s age is [crewS.age]."
		if(4)
			theSnitch = "[crewS]'s blood type is [crewS.dna.b_type]."
		if(5)
			var/cS = crewS.get_species()
			theSnitch = "[crewS] is a [cS]."
		if(6)
			if(crewS.mind.initial_account)
				theSnitch = "[crewS]'s account number is [crewS.mind.initial_account.account_number]."
			else
				theSnitch = "[crewS] does not have a bank account."
		if(7)
			if(crewS.mind.initial_account)
				theSnitch = "[crewS]'s account pin is [crewS.mind.initial_account.remote_access_pin]."
			else
				theSnitch = "[crewS] does not have an account pin."
		if(8)
			theSnitch = "[crewS] is a [crewS.gender]."
		if(9)
			theSnitch = "[crewS] is in [crewS.area.name]."
		if(10)
			if(crewS.dead)
				theSnitch = "[crewS] is dead."
			else
				theSnitch = "[crewS] is alive."
		if(11)
			if(!crewS.contents.len)
				theSnitch = "[crewS] isn't carrying anything."
			else
				var/ci = pick(crewS.contents)
				theSnitch = "[crewS] is carrying a [ci]."
		if(12)
			var/list/bycrewS = list()
			for(var/atom/movable/A in orange(crewS, 2))
				bycrewS += A
			if(!bycrewS.len)
				theSnitch = "[crewS] isn't near anything at all."
			var/adjcrewS = pick(bycrewS)
			theSnitch = "[crewS] is near \the [adjcrewS.name]"
		if(13)
			theSnitch = "[crewS] is at [crewS.x], [crewS.y], [crewS.z]."
		if(14)
			theSnitch = "[crewS] is in [crewS.area.name] which is zeta sector [crewS.z]."
		if(15)
			if((crewS.l_store) || (crewS.r_store))
				theSnitch = "[crewS] has something in their pockets."
			else
				theSnitch = "[crewS]'s pockets are empty."
		if(16)
			if(crewS.shoes)
				theSnitch = "[crewS] is wearing shoes." //Thank you fish
			else
				theSnitch = "[crewS] is not wearing shoes."
		if(17)
			theSnitch = "[crewS] has been cloned [crewS.times_cloned] times."
		if(18)
			var/cw = crewS.time_last_speech/10
			theSnitch = "[crewS] last spoke [cw] seconds ago."
		if(19)
			if(crewS.virus2.len)
				theSnitch = "[crewS] is sick."
			else
				theSnitch = "[crewS] is not sick."
		if(20)
			if(crewS.reagents.len)
				theSnitch = "[crewS] is metabolizing chemicals."
			else
				theSnitch = "[crewS] is not metabolizing anything."
	return(theSnitch)



/mob/living/simple_animal/hostile/fishing/snitchfish/proc/snitchOnOther()
	var/sRoll = rand(1,10)	//A lot of this is scoreboard or global list stuff
	switch(sRoll)
		if(1)
			theSnitch = "The time is [worldtime2text()]."
		if(2)
			var/theAI = null
			for(var/mob/living/silicon/ai/A in mob_list)
				theAI = A
			if(theAI)
				var/lawNumber = theAI.inherent.len + theAI.supplied.len + theAI.ion.len
				theSnitch = "\The AI has [lawNumber] laws."
			else
				theSnitch = "There is no AI"
		if(3)
			var/eventNumber = score["eventsendured"]
			theSnitch = "Something eventful has happened [eventNumber] times today."
		if(4)
			var/boomNumber = score["explosions"]
			theSnitch = "There have been [boomNumber] explosions today."
		if(5)
			theSnitch = "The year is [game_year]"
		if(6)
			if(polarstar > 0)
				theSnitch = "The Polarstar has been found."
			else
				theSnitch = "The Polarstar is still out there."
		if(7)
			if(mode.dead_players.len >= mode.living_players.len)
				theSnitch = "This place is haunted."
			else
				theSnitch = "It's not that spooky, yet."
		if(8)
			if(mode.starting_threat_level > 50)
				theSnitch = "Today might be rough."
			else
				theSnitch = "Today might not be too bad."
		if(9)
			if(mode.threat > 20)
				theSnitch = "Something is about to happen."
			else
				theSnitch = "Should be calm for a while."
		if(10)
			var/oreMined = score["oremined"]
			theSnitch = "[oreMined] rocks have been mined today."
	return(theSnitch)

/mob/living/simple_animal/hostile/fishing/snitchfish/proc/writeSnitch(var/snitchPhrase, var/target)
	if((!Adjacent(target) && (mutation != FISH_TELEKINETIC | FISH_BLUESPACE))
		Goto(target)
	visible_message("<span class='info'>\The [src] begins scribbling on \the [target] with its tail.</span>")
	sleep(2 SECONDS)
	if(!Adjacent(target))
		return
	if(!istype(target, /obj/item/weapon/paper))
		return
	var/obj/item/weapon/paper/P = target
	if(mutation == FISH_CLOWN)
		if(prob(50))
			snitchPhrase = "Honk!"
	P.info += snitchPhrase
	snitchCooldown = world.time
	if(mutation == FISH_CHATTY)
		say(snitchPhrase)
