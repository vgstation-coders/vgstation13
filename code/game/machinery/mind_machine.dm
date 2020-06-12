/obj/machinery/mind_machine
	name = "Mind Machine"
	icon = 'icons/obj/mind_machine.dmi'
	density = 1
	anchored = 1.0
	use_power = 1
	idle_power_usage = 50
	active_power_usage = 2000
	light_range_on = 1
	light_power_on = 1
	machine_flags = SCREWTOGGLE | CROWDESTROY | EMAGGABLE | FIXED2WORK | WRENCHMOVE

/obj/machinery/mind_machine/mind_machine_hub
	name = "Mind Machine Hub"
	icon_state = "mind_hub"
	desc = "The main hub of a complete mind machine setup. Placed between two mind pods and used to control and manage the transfer. Houses an experimental bluespace conduit which uses bluespace crystals for charge."
	var/bluespaceConduit = 0 //Swap ammo
	var/soulShardSafety = FALSE	//Day ruin insurance
	var/obj/machinery/mind_machine/mind_machine_pod/connectOne //All "variableNameOne" refer to information about the connectOne pod
	var/obj/machinery/mind_machine/mind_machine_pod/connectTwo //Likewise for variableNameTwo for connectTwo
	var/podsConnected = FALSE
	var/occupantOne = null
	var/occupantTwo = null
	var/occupantNameOne = "None"
	var/occupantNameTwo = "None"
	var/occupantStatOne = "None"
	var/occupantStatTwo = "None"
	var/mindTypeOne = "None" //Player mind, simple mob, silicon, etc
	var/mindTypeTwo = "None"
	var/lockedPods = FALSE
	var/currentlySwapping = FALSE
	var/swapProgress = 0
	var/list/theFly = list() //If more than one creature enters a pod, ie: human with borer carrying a carp in his bag
	var/occupantScan = FALSE
	var/manipRating = 4 //Determines speed of swap/malfunction chance on delay swap
	var/scanRatingOne = 6 //Determines if you can swap silicons
	var/scanRatingTwo = 6
	var/errorMessage = "No errors"
	var/badSwap = FALSE
	var/malfSwap = FALSE //Triggers malfunction if true
	var/list/illegalSwap = list() //Might break the game/remove the player from the round. If you get mechahitler in there you deserve your round, though

//////Parts and connection/////////

/obj/machinery/mind_machine/mind_machine_hub/New()
	illegalSwap = boss_mobs + blacklisted_mobs - list(/mob/living/simple_animal/hostile/mechahitler, /mob/living/simple_animal/hostile/alien/queen/large, /mob/living/simple_animal/hostile/retaliate/cockatrice)
	component_parts = newlist(
		/obj/item/weapon/circuitboard/mind_machine_hub,
		/obj/item/weapon/stock_parts/console_screen,
		/obj/item/weapon/stock_parts/manipulator/nano,
		/obj/item/weapon/stock_parts/manipulator/nano,
		/obj/item/weapon/stock_parts/subspace/analyzer,
		/obj/item/weapon/stock_parts/subspace/filter,
		/obj/item/weapon/stock_parts/subspace/amplifier
	)

/obj/machinery/mind_machine/mind_machine_hub/RefreshParts()
	var/manipCount = 0
	for(var/obj/item/weapon/stock_parts/SP in component_parts)
		if(istype(SP, /obj/item/weapon/stock_parts/manipulator))
			manipCount += SP.rating
	manipRating = manipCount

/obj/machinery/mind_machine/mind_machine_hub/proc/findConnections() //Finds and links the hub with the pods on either side
	connectOne = findConnectOne()
	if(connectOne)
		connectOne.connectedHub = src
		connectOne.podNumber = 1
	connectTwo = findConnectTwo()
	if(connectTwo)
		connectTwo.connectedHub = src
		connectTwo.podNumber = 2
	if ((connectOne) && (connectTwo))
		podsConnected = TRUE

/obj/machinery/mind_machine/mind_machine_hub/proc/findConnectOne()
	for(var/obj/machinery/mind_machine/mind_machine_pod/CO in orange(1,src))
		if(CO != connectTwo)
			return CO
/obj/machinery/mind_machine/mind_machine_hub/proc/findConnectTwo()
	for(var/obj/machinery/mind_machine/mind_machine_pod/CT in orange(1,src))
		if(CT != connectOne)
			return CT

/obj/machinery/mind_machine/mind_machine_hub/Destroy()
	podsConnected = null
	currentlySwapping = null
	lockedPods = FALSE
	occupantScan = FALSE
	occupantOne = null
	occupantTwo = null
	swapProgress = 0
	if(connectOne || connectTwo || podsConnected)
		connectOne.connectedHub = null
		connectTwo.connectedHub = null
		connectOne.podNumber = 0
		connectTwo.podNumber = 0
		connectOne = null
		connectTwo = null
	. = ..()

/obj/machinery/mind_machine/mind_machine_hub/attackby(var/obj/item/A as obj, var/mob/user as mob)
	..()
	if(istype(A, /obj/item/bluespace_crystal/flawless))
		user.drop_item(A, src)
		bluespaceConduit += 300
		to_chat(user, "The bluespace conduit flashes violently before calming to a glow.")
		qdel(A)
		return
	if(istype(A, /obj/item/bluespace_crystal/artificial))
		user.drop_item(A, src)
		bluespaceConduit += 1
		to_chat(user, "The crystal is assimilated into the conduit!")
		qdel(A)
		return
	if(istype(A, /obj/item/bluespace_crystal))
		user.drop_item(A, src)
		bluespaceConduit += 3
		to_chat(user, "The crystal is assimilated into the conduit!")
		qdel(A)
		return
	if(istype(A, /obj/item/device/soulstone))
		if(soulShardSafety != FALSE)
			to_chat(user, "That slot is full!")
			return
		if(A.contents.len)
			to_chat(user, "The stone must be empty to function properly.") //prevents deleting players in stones
			return
		else
			user.drop_item(A, src)
			to_chat(user, "The stone is pulled into the machine. You can hear crunching and a quiet sizzle from inside.")
			qdel(A)
			soulShardSafety = TRUE

/obj/machinery/mind_machine/mind_machine_hub/attack_hand(user as mob)
	if(podsConnected == FALSE || connectOne == FALSE || connectTwo == FALSE)
		podsConnected = FALSE
		connectOne = FALSE
		connectTwo = FALSE
		findConnections() //No UI without pods
	if(!podsConnected)
		to_chat(user, "Pod connection error.")
		return
	ui_interact(user)

//////UI stuff///////////////

/obj/machinery/mind_machine/mind_machine_hub/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = NANOUI_FOCUS)
	var/list/data = list(
			"nameOne" = occupantNameOne,
			"nameTwo" = occupantNameTwo,
			"statOne" = occupantStatOne,
			"statTwo" = occupantStatTwo,
			"mindTypeOne" = mindTypeOne,
			"mindTypeTwo" = mindTypeTwo,
			"lockedPods" = lockedPods,
			"bluespaceConduit" = bluespaceConduit,
			"soulShardSafety" = soulShardSafety,
			"manipRating" = manipRating,
			"swapProgress" = swapProgress,
			"errorMessage" = errorMessage
	)

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)

	if(!ui)
		ui = new(user, src, ui_key, "mind_machine.tmpl", "Mind Machine", 350,500)
		ui.set_initial_data(data)
		ui.open()
	ui.set_auto_update(1)

/obj/machinery/mind_machine/mind_machine_hub/Topic(href, href_list)
	if(href_list["scan_start"])
		if(!currentlySwapping)
			scanOccupants()
			return TRUE
		else
			errorMessage = "Currently active: Please wait"
			return TRUE
	if(href_list["unlock_pods"])
		if(((!connectOne.contents.len) || (!connectTwo.contents.len)) && (currentlySwapping))
			unlockPods() //Safeguard against the pod getting trapped in infinite scan
			return TRUE
		if(lockedPods == FALSE)
			errorMessage = "Pods already unlocked"
			return TRUE
		if(currentlySwapping)
			errorMessage = "Currently active: Please wait"
			return TRUE
		else
			spawn(5)
				unlockPods()
				return TRUE
	if(href_list["eject_pods"])
		if((!currentlySwapping) && (lockedPods == FALSE))
			spawn(5)
				ejectPods()
				return TRUE
		if(lockedPods == TRUE)
			errorMessage = "Pods are locked"
			return TRUE
	if(href_list["mind_swap"])
		if((occupantScan) && (!currentlySwapping))
			spawn(5)
				swapOccupants()
				return TRUE
		if(!occupantScan)
			errorMessage = "Require scan"
			return TRUE
		if(currentlySwapping)
			errorMessage = "Currently active: Please wait"
			return TRUE
	if(href_list["delay_swap"])
		if(!currentlySwapping)
			currentlySwapping = TRUE
			spawn(5)
				delayedSwap()
				return TRUE

//////Scan and Swap, other UI procs//////////////

/obj/machinery/mind_machine/mind_machine_hub/proc/unlockPods()
	occupantScan = FALSE
	mindTypeOne = "None"
	mindTypeTwo = "None"
	occupantNameOne = "None"
	occupantNameTwo = "None"
	occupantStatOne = "None"
	occupantStatTwo = "None"
	connectOne.icon_state = "mind_pod_open"
	connectTwo.icon_state = "mind_pod_open"
	playsound(connectTwo, 'sound/machines/door_unbolt.ogg', 35, 1)
	playsound(connectOne, 'sound/machines/door_unbolt.ogg', 35, 1)
	if(badSwap == FALSE)
		flick("mind_pod_opening", connectOne)
		flick("mind_pod_opening", connectTwo)
	else
		flick("mind_pod_thefly", connectOne)
		flick("mind_pod_thefly", connectTwo)
		badSwap = FALSE
	lockedPods = FALSE

/obj/machinery/mind_machine/mind_machine_hub/proc/ejectPods()
	connectOne.go_out()
	connectTwo.go_out()

/obj/machinery/mind_machine/mind_machine_hub/proc/delayedSwap()
	if(!occupantScan)
		errorMessage = "Proceed with caution: supervisor advised"
		sleep(5 SECONDS)
		currentlySwapping = FALSE
		if((occupantOne) && (occupantTwo))
			scanOccupants()
			if(prob(8-manipRating)) //A tiny bit risky with no upgrades, 0 risk with full xenoarch manipulators.
				malfSwap = TRUE
			swapOccupants()
			unlockPods()
		else
			errorMessage = "Missing occupant"

/obj/machinery/mind_machine/mind_machine_hub/proc/scanOccupants(var/mob/S)
	if((!locate(occupantOne,connectOne.contents)) || (!locate(occupantTwo, connectTwo.contents)))
		errorMessage = "Missing occupant"
		occupantOne = null
		occupantTwo = null
		return
	currentlySwapping = TRUE
	lockedPods = TRUE
	if((connectOne.icon_state != "mind_pod_closed") && (connectTwo.icon_state != "mind_pod_closed"))
		playsound(connectOne, 'sound/machines/poddoor.ogg', 55, 1)
		playsound(connectTwo, 'sound/machines/poddoor.ogg', 55, 1)
		flick("mind_pod_closing",connectOne)
		connectOne.icon_state = "mind_pod_closed"
		flick("mind_pod_closing",connectTwo)
		connectTwo.icon_state = "mind_pod_closed"
	sleep(2 SECONDS)
	playsound(connectOne, 'sound/effects/sparks4.ogg', 80, 1)
	playsound(connectTwo, 'sound/effects/sparks4.ogg', 80, 1)
	occupantScan = TRUE
	S = occupantOne
	occupantNameOne = S.name
	switch(S.stat)
		if(0)
			occupantStatOne = "Alive"
		if(1)
			occupantStatOne = "Unconscious"
		if(2)
			occupantStatOne = "Dead"
	if(!S.mind)
		mindTypeOne = "Lower" //Simple mob
	if(S.mind)
		if(isrobot(S))
			mindTypeOne = "Artificial" //Silicon player, obviously
		else
			mindTypeOne = "Higher" //Player controlled
	if(isvampire(S) || isanycultist(S) || ischangeling(S) || ismalf(S))
		mindTypeOne = "Shielded" //Mostly to fix spell bugs but also tinfoil
	if((ishigherbeing(S)) || (ismonkey(S)))
		var/mob/living/carbon/T = S
		if(T.is_wearing_item(/obj/item/clothing/head/tinfoil))
			mindTypeTwo = "Shielded"
	S = occupantTwo
	occupantNameTwo = S.name //and for pod two
	switch(S.stat)
		if(0)
			occupantStatTwo = "Alive"
		if(1)
			occupantStatTwo = "Unconscious"
		if(2)
			occupantStatTwo = "Dead"
	if(!S.mind)
		mindTypeTwo = "Lower"
	if(S.mind)
		if(isrobot(S))
			mindTypeTwo = "Artificial"
		else
			mindTypeTwo = "Higher"
	if(isvampire(S) || isanycultist(S) || ischangeling(S) || ismalf(S))
		mindTypeTwo = "Shielded"
	if((ishigherbeing(S)) || (ismonkey(S)))
		var/mob/living/carbon/T = S
		if(T.is_wearing_item(/obj/item/clothing/head/tinfoil))
			mindTypeTwo = "Shielded"
	currentlySwapping = FALSE

/obj/machinery/mind_machine/mind_machine_hub/proc/swapOccupants(var/mob/living/M)
	if(occupantScan != TRUE || lockedPods != TRUE || badSwap == TRUE)
		return
	if((!locate(occupantOne,connectOne.contents)) || (!locate(occupantTwo, connectTwo.contents)))
		errorMessage = "Occupants missing" //sanity and wizards exist
		occupantOne = null
		occupantTwo = null
		unlockPods()
		return
	if(bluespaceConduit == 0)
		errorMessage = "Conduit requires charge"
		return
	if(mindTypeOne == "Shielded" || mindTypeTwo == "Shielded")
		errorMessage = "Critical error, aborting"
		spark(src)
		spark(connectOne)
		spark(connectTwo)
		unlockPods()
		return
	if(occupantStatOne == "Dead" || occupantStatTwo == "Dead")
		if(!soulShardSafety) //Secrets
			errorMessage = "Living mind required"
			return
		soulShardSafety = FALSE
		errorMessage = "Warning: Unknown internal reaction"
	currentlySwapping = TRUE
	bluespaceConduit -= 1
	icon_state = "mind_hub_active"
	connectOne.icon_state = "mind_pod_active"
	connectTwo.icon_state = "mind_pod_active"
	if(is_type_in_list(occupantOne, illegalSwap) || is_type_in_list(occupantTwo, illegalSwap))
		malfSwap = TRUE //fun sanity check. Can't send their mind into the illegal body.
	M = occupantOne //First we check if they have any pocket-pets
	for(var/obj/item/weapon/holder/i in get_contents_in_object(M))  //Carp in pack? Outta luck, Jack
		theFly += i
	var/list/borers = M.get_brain_worms()
	for(var/mob/living/simple_animal/borer/B in borers) //borers in the body are counted
		theFly += B
	M = occupantTwo
	for(var/obj/item/weapon/holder/i in get_contents_in_object(M))
		theFly += i
	borers += M.get_brain_worms()
	for(var/mob/living/simple_animal/borer/B in borers)
		theFly += B
	for(var/prog in 1 to 40/manipRating) //Counts up 5 to 10 seconds, checks if we lost power each time and ruins your day if so. Otherwise just for UI progress bar
		if(stat & NOPOWER)
			malfSwap = TRUE
		sleep(1 SECONDS)
		swapProgress += 1
	if((!locate(occupantOne,connectOne.contents)) || (!locate(occupantTwo, connectTwo.contents))) //10 whole seconds for jaunt to cooldown
		errorMessage = "Occupants missing"
		swapProgress = 0
		currentlySwapping = FALSE
		occupantOne = null
		occupantTwo = null
		unlockPods()
		return
	if(malfSwap == TRUE) ///////////Swaps begin///////
		malfunction()
		return
	if(mindTypeOne == "Lower" && mindTypeTwo == "Lower")
		lowerSwap()
		return
	if(theFly.len > 0)
		theFlySwap()
		return
	if(mindTypeOne == "Higher" && mindTypeTwo == "Higher")
		higherSwap()
		return
	if(mindTypeOne =="Higher" && mindTypeTwo == "Lower" || mindTypeOne == "Lower" && mindTypeTwo == "Higher")
		animorphsSwap()
		return
	if(mindTypeOne == "Artificial" && mindTypeTwo == "Artificial")
		if(scanRatingOne >=7 && scanRatingTwo >=7)
			higherSwap() //Silicon swaps, checks if their pod is upgraded enough then performs normal swap
			return
		else
			errorMessage = "Scanners insufficient"
			swapProgress = 0
			currentlySwapping = FALSE
			connectOne.icon_state = "mind_pod_closed"
			connectTwo.icon_state = "mind_pod_closed"
			icon_state = "mind_hub"
			return
	if(mindTypeOne == "Artificial" && mindTypeTwo != "Artificial")
		if(scanRatingOne <7)
			errorMessage = "Scanners insufficient"
			swapProgress = 0
			currentlySwapping = FALSE
			connectOne.icon_state = "mind_pod_closed"
			connectTwo.icon_state = "mind_pod_closed"
			icon_state = "mind_hub"
			return
		if(mindTypeTwo == "Lower")
			animorphsSwap()
			return
		if(mindTypeTwo == "Higher" && theFly.len == 0)
			higherSwap()
			return
	if(mindTypeTwo == "Artificial" && mindTypeOne != "Artificial")
		if(scanRatingTwo <7)
			errorMessage = "Scanners insufficient"
			swapProgress = 0
			currentlySwapping = FALSE
			connectOne.icon_state = "mind_pod_closed"
			connectTwo.icon_state = "mind_pod_closed"
			icon_state = "mind_hub"
			return
		if(mindTypeTwo == "Lower")
			animorphsSwap()
			return
		if(mindTypeOne == "Higher" && theFly.len == 0)
			higherSwap()
			return
	else
		errorMessage = "Unknown interruption"
		currentlySwapping = FALSE
		swapProgress = 0
		unlockPods()

/obj/machinery/mind_machine/mind_machine_hub/emp_act()
	if(currentlySwapping)
		malfSwap = TRUE
		return

/obj/machinery/mind_machine/mind_machine_hub/emag_act()
	if(currentlySwapping)
		spark(src)
		malfSwap = TRUE
		return

//Procs for the mind swap//////////

/obj/machinery/mind_machine/mind_machine_hub/proc/lowerSwap(var/mob/living/LO, var/mob/living/LT)
	LO = occupantOne
	LT = occupantTwo
	if(isanimal(LO) && isanimal(LT))
		var/mob/living/simple_animal/SO = LO
		var/mob/living/simple_animal/ST = LT
		var/occOneFaction = SO.faction
		var/occTwoFaction = ST.faction
		SO.faction = occTwoFaction //Make friendly spiders and angry corgis
		ST.faction = occOneFaction
		var/occOneSpeakChance = SO.speak_chance
		var/occTwoSpeakChance = ST.speak_chance
		SO.speak_chance = occTwoSpeakChance
		ST.speak_chance = occOneSpeakChance
		var/occOneName = SO.name
		var/occTwoName = ST.name
		SO.name = occTwoName
		ST.name = occOneName
		var/list/occOneSpeak = list()
		var/list/occTwoSpeak = list()
		for(var/V in SO.speak)
			occOneSpeak += V
			SO.speak -= V
		for(var/V in ST.speak)
			occTwoSpeak += V
			ST.speak -= V
		for(var/V in occTwoSpeak)
			SO.speak += V
		for(var/V in occOneSpeak)
			ST.speak += V
		var/occOnePet = ST.is_pet
		var/occTwoPet = SO.is_pet
		SO.is_pet = occTwoPet
		ST.is_pet = occOnePet
	else
		errorMessage = "Sum intelligence too low" //There's just nothing to swap for monkeymen
		bluespaceConduit += 1
	currentlySwapping = FALSE
	occupantScan = FALSE
	connectOne.icon_state = "mind_pod_closed"
	connectTwo.icon_state = "mind_pod_closed"
	icon_state = "mind_hub"
	swapProgress = 0

/obj/machinery/mind_machine/mind_machine_hub/proc/higherSwap(var/mob/HO, var/mob/HT)
	HO = occupantOne
	HT = occupantTwo
	if(HO.mind.special_verbs.len)	//Swapping players, stolen from mind transfer
		for(var/V in HO.mind.special_verbs)
			HO.verbs -= V
	if(HT.mind.special_verbs.len)
		for(var/V in HT.mind.special_verbs)
			HT.verbs -= V //Simple animals can't have special verbs so we just remove them without re-adding. Admins fear the machine.
	var/list/HO_spells = HO.spell_list.Copy()
	var/list/HT_spells = HT.spell_list.Copy()
	for(var/spell/S in HO.spell_list)
		HO.remove_spell(S)
	for(var/spell/S in HT.spell_list)
		HT.remove_spell(S)
	var/mob/living/dummy = new(src.loc)
	HO.mind.transfer_to(dummy)
	HT.mind.transfer_to(HO)
	dummy.mind.transfer_to(HT)
	qdel(dummy)
	for(var/spell/S in HO_spells)
		HT.add_spell(S)
	for(var/spell/S in HT_spells)
		HO.add_spell(S)
	HO.confused = 8
	HO.dizziness = 8
	HT.confused = 8
	HT.dizziness = 8
	currentlySwapping = FALSE
	occupantScan = FALSE
	connectOne.icon_state = "mind_pod_closed"
	connectTwo.icon_state = "mind_pod_closed"
	icon_state = "mind_hub"
	swapProgress = 0

/obj/machinery/mind_machine/mind_machine_hub/proc/animorphsSwap(var/mob/MO, var/mob/MT)
	var/mob/animorph = null //Our player
	var/mob/simpleMob = null
	MO = occupantOne
	MT = occupantTwo
	if(MO.mind)
		animorph = MO
		simpleMob = MT
	if(MT.mind)
		animorph = MT
		simpleMob = MO
	if(animorph.mind.special_verbs.len)
		for(var/V in animorph.mind.special_verbs)
			animorph.verbs -= V
	var/list/animorph_spells = animorph.spell_list.Copy()
	for(var/spell/S in animorph.spell_list)
		animorph.remove_spell(S)
	animorph.mind.transfer_to(simpleMob)
	for(var/spell/S in animorph_spells)
		animorph.add_spell(S)
	currentlySwapping = FALSE
	occupantScan = FALSE
	connectOne.icon_state = "mind_pod_closed"
	connectTwo.icon_state = "mind_pod_closed"
	icon_state = "mind_hub"
	swapProgress = 0

/obj/machinery/mind_machine/mind_machine_hub/proc/malfunction(var/mob/living/M)
	malfSwap = FALSE
	if(!soulShardSafety) //If there's no safety and it's emagged or an EMP goes off mid-scan, throws minds into a mindless mob within 50 tiles
		badSwap = TRUE
		var/list/randFaction = list("hostile", "neutral", "carp", "necro", "wizard", "syndicate", "cult")
		var/mob/woopsTarget = null
		if(mindTypeOne == "Higher" || mindTypeOne == "Artificial")
			var/list/woopsOne = list()
			M = occupantOne
			for(var/mob/living/R in mob_list)
				if((!R.mind) && (R.stat != 2) && (get_dist(src, R) < 50) && (connectOne.z == R.z) && (!is_type_in_list(R, illegalSwap)))
					woopsOne += R
			if(woopsOne.len)
				woopsTarget = pick(woopsOne)
				var/list/M_spells = list()
				M_spells = M.spell_list.Copy()
				if(M.mind.special_verbs.len)	//All the safeties in higher swap. Prevents people from getting cult spells via swap
					for(var/V in M.mind.special_verbs)
						M.verbs -= V
				for(var/spell/S in M.spell_list)
					M.remove_spell(S)
				M.mind.transfer_to(woopsTarget)
				for(var/spell/S in M_spells)
					woopsTarget.add_spell(S)
				to_chat(M, "<span class='danger'>Your mind is thrown out of the machine and forced into a nearby vessel</span>")
				playsound(M, "sound/effects/phasein.ogg", 50, 1)
				errorMessage = "Error in mind delivery"
			else
				to_chat(M, "<span class='danger'>Your mind is severely damaged by the feedback</span>")
				playsound(M, "sound/misc/balloon_pop.ogg", 50, 1)
				if(ishuman(M))
					M.adjustBrainLoss(75)
				errorMessage = "Mind sustained damage"
		if(mindTypeTwo == "Higher" || mindTypeTwo == "Artificial")
			var/list/woopsTwo = list()
			M = occupantTwo
			for(var/mob/living/R in mob_list)
				if((!R.mind) && (R.stat != 2) && (get_dist(src, R) <50) && (connectTwo.z == R.z) && (!is_type_in_list(R, illegalSwap)))
					woopsTwo += R
			if(woopsTwo.len)
				var/list/M_spells = list()
				M_spells = M.spell_list.Copy()
				woopsTarget = pick(woopsTwo)
				if(M.mind.special_verbs.len)
					for(var/V in M.mind.special_verbs)
						M.verbs -= V
				for(var/spell/S in M.spell_list)
					M.remove_spell(S)
				M.mind.transfer_to(woopsTarget)
				for(var/spell/S in M_spells)
					woopsTarget.add_spell(S)
				to_chat(M, "<span class='danger'>Your mind is thrown out of the machine and forced into a nearby vessel</span>")
				playsound(M, "sound/effects/phasein.ogg", 50, 1)
				errorMessage = "Error in mind delivery"
			else
				to_chat(M, "<span class='danger'>Your mind is severely damaged by the feedback</span>")
				playsound(M, "sound/misc/balloon_pop.ogg", 50, 1)
				if(ishuman(M))
					M.adjustBrainLoss(75)
				errorMessage = "Mind sustained damage"
		if(mindTypeOne == "Lower")
			M = occupantOne
			M.faction = pick(randFaction)
		if(mindTypeTwo == "Lower")
			M = occupantTwo
			M.faction = pick(randFaction)
	else
		soulShardSafety = FALSE
		errorMessage = "Safety consumed"
	currentlySwapping = FALSE
	occupantScan = FALSE
	connectOne.icon_state = "mind_pod_closed"
	connectTwo.icon_state = "mind_pod_closed"
	icon_state = "mind_hub"
	swapProgress = 0

/obj/machinery/mind_machine/mind_machine_hub/proc/theFlySwap(var/mob/living/MO, var/mob/living/MT)
	var/list/mindFly = list()
	var/list/simpFly = list()
	MO = occupantOne
	MT = occupantTwo
	for(var/obj/item/weapon/holder/D in theFly)
		for(var/mob/M in D.contents)
			theFly += M //Gets the mob stored in the holder, adds it to the list
		D.Destroy() //Turns them from holder to mob
	theFly += MO
	theFly += MT
	for(var/mob/living/q in theFly)
		if(q.mind)
			mindFly += q
			theFly -= q
		else
			simpFly += q
			theFly -=q
	var/mob/living/dummy = new(src.loc)
	simpFly += dummy
	var/mob/nuYou = null
	for(var/mob/living/flies in mindFly)
		nuYou = pick(simpFly)
		if(flies.mind.special_verbs.len)
			for(var/V in flies.mind.special_verbs)
				flies.verbs -= V
		for(var/spell/S in flies.spell_list)
			flies.remove_spell(S)
		flies.mind.transfer_to(nuYou)
		simpFly += flies
		simpFly -= nuYou
	if(dummy.mind)
		nuYou = pick(simpFly)
		dummy.mind.transfer_to(nuYou)
	qdel(dummy)
	currentlySwapping = FALSE
	occupantScan = FALSE
	theFly.len = 0
	simpFly.len = 0
	mindFly.len = 0
	connectOne.icon_state = "mind_pod_closed"
	connectTwo.icon_state = "mind_pod_closed"
	icon_state = "mind_hub"
	badSwap = 1
	swapProgress = 0
	errorMessage = "Mind transport anomaly"

//Swaps over///////////////
//Pod stuff//////////

/obj/machinery/mind_machine/mind_machine_pod
	name = "Mind Machine Pod"
	icon_state = "mind_pod_open"
	desc = "A large pod used for mind transfers. Contains two locking systems: One for ensuring occupants do not disturb the transfer process, and another that prevents lower minded creatures from leaving on their own."
	density = 1
	anchored = 1.0
	var/mob/living/occupant = null
	var/podNumber = 0
	var/obj/machinery/mind_machine/mind_machine_hub/connectedHub

/obj/machinery/mind_machine/mind_machine_pod/New()
	component_parts = newlist(
		/obj/item/weapon/circuitboard/mind_machine_pod,
		/obj/item/weapon/stock_parts/scanning_module/adv/phasic,
		/obj/item/weapon/stock_parts/scanning_module/adv/phasic,
		/obj/item/weapon/stock_parts/subspace/treatment,
		/obj/item/weapon/stock_parts/subspace/ansible,
		/obj/item/weapon/stock_parts/subspace/amplifier,
		/obj/item/weapon/stock_parts/subspace/crystal,
		/obj/item/weapon/stock_parts/subspace/transmitter
		)

/obj/machinery/mind_machine/mind_machine_pod/RefreshParts()
	var/scanCount = 0
	for(var/obj/item/weapon/stock_parts/SC in component_parts)
		if(istype(SC, /obj/item/weapon/stock_parts/scanning_module))
			scanCount += SC.rating
			switch(podNumber)
				if(1)
					connectedHub.scanRatingOne = scanCount
				if(2)
					connectedHub.scanRatingTwo = scanCount

/obj/machinery/mind_machine/mind_machine_pod/Destroy()
	go_out()
	if(connectedHub)
		switch(podNumber)
			if(1)
				connectedHub.connectOne = null
			if(2)
				connectedHub.connectTwo = null
		connectedHub.podsConnected = null
		podNumber = 0
		connectedHub = null

/obj/machinery/mind_machine/mind_machine_pod/MouseDropTo(atom/movable/O as mob|obj, mob/user as mob)
	if(connectedHub.lockedPods)
		to_chat(user, "<span class='bnotice'>The pod is locked tight!</span>")
		return
	if(!ismob(O))
		return
	if(O.loc == user || !isturf(O.loc) || !isturf(user.loc) || !user.Adjacent(O)) //I stole all this from DNA scanners
		return
	if(user.incapacitated() || user.lying)
		return
	if(!Adjacent(user) || !user.Adjacent(src) || user.contents.Find(src))
		return
	if(O.anchored)
		return
	if(!ishigherbeing(user) && !isrobot(user))
		return
	if(occupant)
		to_chat(user, "<span class='bnotice'>The pod is already occupied!</span>")
		return
	if(panel_open)
		to_chat(user, "<span class='bnotice'>Close the maintenance panel first.</span>")
		return
	var/mob/L = O
	if(!istype(L))
		return
	for(var/mob/living/carbon/slime/M in range(1,L))
		if(M.Victim == L)
			to_chat(usr, "[L.name] will not fit into the pod because they have a slime latched onto their head.")
			return
	if(L == user)
		visible_message("[user] climbs into \the [src].")
	else
		visible_message("[user] puts [L.name] into \the [src].")
	if(user.pulling == L)
		user.stop_pulling()
	put_in(L)

/obj/machinery/mind_machine/mind_machine_pod/MouseDropFrom(over_object, src_location, var/turf/over_location, src_control, over_control, params)
	if(connectedHub.lockedPods)
		to_chat(usr, "<span class='bnotice'>The pod is locked tight!</span>")
		return
	if(!ishigherbeing(usr) && !isrobot(usr) || usr.incapacitated() || usr.lying)
		return
	if(!occupant)
		to_chat(usr, "<span class='warning'>\The [src] is unoccupied!</span>")
		return
	over_location = get_turf(over_location)
	if(!istype(over_location) || over_location.density)
		return
	if(!Adjacent(over_location) || !Adjacent(usr) || !usr.Adjacent(over_location))
		return
	for(var/atom/movable/A in over_location.contents)
		if(A.density)
			if((A == src) || istype(A, /mob))
				continue
			return
	if(occupant == usr)
		visible_message("[usr] climbs out of the \the [src]")
	else
		visible_message("[usr] pulls [occupant.name] out of \the [src].")
	go_out(over_location, ejector = usr)

/obj/machinery/mind_machine/mind_machine_pod/proc/put_in(var/mob/M)
	M.forceMove(src)
	M.reset_view()
	src.occupant = M
	switch(podNumber)
		if(1)
			connectedHub.occupantOne = occupant
		if(2)
			connectedHub.occupantTwo = occupant
		else
			return

/obj/machinery/mind_machine/mind_machine_pod/proc/go_out(var/exit = src.loc, var/mob/ejector)
	if(!occupant)
		for(var/atom/movable/M in contents)
			M.forceMove(get_turf(src))
		return 0
	if(!occupant.gcDestroyed)
		occupant.forceMove(exit)
		occupant.reset_view()
	occupant = null
	switch(podNumber)
		if(1)
			connectedHub.occupantOne = null
		if(2)
			connectedHub.occupantTwo = null

/obj/machinery/mind_machine/mind_machine_pod/relaymove(mob/user as mob)
	if(user.stat)
		return
	if(connectedHub.currentlySwapping)
		to_chat(user, "<span class='warning'>Your head is fuzzy and your body is limp. You can't properly focus on getting out.</span>")
		if(do_after(user, src, 90 SECONDS)) //More of a safety than a feature
			connectedHub.currentlySwapping = FALSE
			connectedHub.badSwap = FALSE
			connectedHub.malfSwap = FALSE
			connectedHub.swapProgress = 0
			connectedHub.theFly.len = 0
			connectedHub.unlockPods()
			connectedHub.errorMessage = "Emergency reset activated"
			return
	if(connectedHub.lockedPods)
		to_chat(user, "<span class='info'>You begin pushing and prying at the door.</span>")
		if(do_after(user, src, 10 SECONDS))
			connectedHub.unlockPods()
			connectedHub.errorMessage = "Emergency unlock activated"
			return
	src.go_out(ejector = user)
	return
