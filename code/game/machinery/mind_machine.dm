/obj/machinery/mind_machine
	name = "\improper Mind Machine"
	icon = 'icons/obj/mind_machine.dmi'
	density = 1
	anchored = 1
	use_power = MACHINE_POWER_USE_IDLE
	idle_power_usage = 50
	active_power_usage = 2000
	light_power_on = 1
	machine_flags = SCREWTOGGLE | CROWDESTROY | EMAGGABLE | FIXED2WORK | WRENCHMOVE

#define MINDMACHINE_CURRENTLY_ACTIVE "Currently active: please wait"
#define MINDMACHINE_PODS_UNLOCKED "Pods already unlocked"
#define MINDMACHINE_PODS_LOCKED "Pods are locked"
#define MINDMACHINE_REQ_SCAN "Require scan"
#define MINDMACHINE_DELAY_CAUTION "Proceed with caution: supervisor advised"
#define MINDMACHINE_MISSING_OCC "Missing occupant"
#define MINDMACHINE_CONDUIT_CHARGE "Conduit requires charge"
#define MINDMACHINE_SHIELD_ERROR "Critical error, aborting"
#define MINDMACHINE_LIVING_REQUIRED "Living mind required"
#define MINDMACHINE_SHARD_REACTION "Warning: Unknown internal reaction"
#define MINDMACHINE_SCANNER_INSUFF "Scanners insufficient"
#define MINDMACHINE_UNKNOWN_INT "Unknown interruption"
#define MINDMACHINE_SUM_TOO_LOW "Sum intelligence too low"
#define MINDMACHINE_DELIVERY_ERROR "Error in mind delivery"
#define MINDMACHINE_MIND_DAMAGED "Mind sustained damage"
#define MINDMACHINE_SAFETY_CONSUMED "Safety consumed"
#define MINDMACHINE_TRANSPORT_ANOM "Mind transport anomaly"
#define MINDMACHINE_NOERROR "No errors"

#define MINDMACHINE_LOWER "Lower"
#define MINDMACHINE_HIGHER "Higher"
#define MINDMACHINE_SILICON "Artificial"
#define MINDMACHINE_SHIELDED "Shielded"

/obj/machinery/mind_machine/mind_machine_hub
	name = "\improper Mind Machine Hub"
	icon_state = "mind_hub"
	desc = "The main hub of a complete mind machine setup. Placed between two mind pods and used to control and manage the transfer. Houses an experimental bluespace conduit which uses bluespace crystals for charge."
	var/bluespaceConduit = 0 //Swap ammo
	var/soulShardSafety = FALSE	//Day ruin insurance
	var/obj/machinery/mind_machine/mind_machine_pod/connectOne //All "variableNameOne" refer to information about the connectOne pod
	var/obj/machinery/mind_machine/mind_machine_pod/connectTwo //Likewise for variableNameTwo for connectTwo
	var/podsConnected = FALSE
	var/mob/living/occupantOne = null
	var/mob/living/occupantTwo = null
	var/occupantStatOne = null
	var/occupantStatTwo = null
	var/mindTypeOne = null	//Player mind, simple mob, silicon, etc
	var/mindTypeTwo = null
	var/lockedPods = FALSE
	var/currentlySwapping = FALSE
	var/swapProgress = 0
	var/list/theFly = list() //If more than one creature enters a pod, ie: human with borer carrying a carp in his bag
	var/occupantScan = FALSE
	var/manipRating = 4 //Determines speed of swap/malfunction chance on delay swap
	var/scanRatingOne = 6 //Determines if you can swap silicons
	var/scanRatingTwo = 6
	var/errorMessage = MINDMACHINE_NOERROR
	var/beenSwapped = FALSE
	var/malfSwap = FALSE //Triggers malfunction if true
	var/list/illegalSwap = list() //Might break the game/remove the player from the round. If you get mechahitler in there you deserve your round, though

//////Parts and connection/////////

/obj/machinery/mind_machine/mind_machine_hub/New()
	..()
	illegalSwap = boss_mobs + blacklisted_mobs - list(/mob/living/simple_animal/hostile/mechahitler,
		/mob/living/simple_animal/hostile/alien/queen/large,
		/mob/living/simple_animal/hostile/retaliate/cockatrice,
		/mob/living/simple_animal/hostile/asteroid/goliath/david/dave,
		/mob/living/simple_animal/hostile/bear/spare,
		/mob/living/simple_animal/hostile/asteroid/rockernaut/boss,
		/mob/living/simple_animal/hostile/mining_drone
		)
	component_parts = newlist(
		/obj/item/weapon/circuitboard/mind_machine_hub,
		/obj/item/weapon/stock_parts/console_screen,
		/obj/item/weapon/stock_parts/manipulator/nano,
		/obj/item/weapon/stock_parts/manipulator/nano,
		/obj/item/weapon/stock_parts/subspace/analyzer,
		/obj/item/weapon/stock_parts/subspace/filter,
		/obj/item/weapon/stock_parts/subspace/amplifier
	)
	RefreshParts()

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
		connectOne.RefreshParts()
		connectTwo.RefreshParts()

/obj/machinery/mind_machine/mind_machine_hub/proc/findConnectOne()
	for(var/obj/machinery/mind_machine/mind_machine_pod/CO in orange(1,src))
		if(CO != connectTwo && CO.anchored)
			return CO
/obj/machinery/mind_machine/mind_machine_hub/proc/findConnectTwo()
	for(var/obj/machinery/mind_machine/mind_machine_pod/CT in orange(1,src))
		if(CT != connectOne && CT.anchored)
			return CT

/obj/machinery/mind_machine/mind_machine_hub/Destroy()
	if(connectOne)
		connectOne.connectedHub = null
		connectOne.podNumber = 0
		connectOne = null
	if(connectTwo)
		connectTwo.connectedHub = null
		connectTwo.podNumber = 0
		connectTwo = null
	. = ..()


/obj/machinery/mind_machine/mind_machine_hub/attackby(var/obj/item/A, var/mob/user)
	..()
	if(istype(A, /obj/item/bluespace_crystal))
		var/obj/item/bluespace_crystal/B = A
		if(user.drop_item(B, src))
			bluespaceConduit += B.blueChargeValue
			B.playtoolsound(src, 50)
			to_chat(user, "<span class='notice'>[istype(B, /obj/item/bluespace_crystal/flawless) ? "The bluespace conduit flashes violently before calming to a glow!" : "\The [B.name] is assimilated into the conduit!"]</span>")
			qdel(B)
			nanomanager.update_uis(src)
			return
	if(istype(A, /obj/item/soulstone))
		if(soulShardSafety != FALSE)
			to_chat(user, "<span class='notice'>That slot is already full!</span>")
			return
		if(A.contents.len)
			to_chat(user, "<span class='notice'>The stone must be empty to function properly.</span>") //prevents deleting players in stones
			return
		if(user.drop_item(A, src))
			playsound(src,'sound/effects/bonebreak4.ogg', 25, 1)
			to_chat(user, "<span class='notice'>The stone is pulled into the machine. You can hear crunching and a quiet sizzle from inside.</span>")
			qdel(A)
			soulShardSafety = TRUE
			nanomanager.update_uis(src)

/obj/machinery/mind_machine/mind_machine_hub/attack_hand(mob/user)
	if(!podsConnected || !connectOne || !connectTwo)
		resetConnections(user)
	if(!currentlySwapping)
		if(!connectOne.Adjacent(src) || !connectTwo.Adjacent(src))
			resetConnections(user)
	if(!podsConnected)
		to_chat(user, "<span class='notice'>Pod connection error.</span>")
		return	//No UI without pods
	ui_interact(user)

/obj/machinery/mind_machine/mind_machine_hub/proc/resetConnections(mob/user)
		to_chat(user, "<span class='notice'>Establishing pod connections.</span>")
		podsConnected = FALSE
		connectOne = FALSE
		connectTwo = FALSE
		findConnections()


//////UI stuff/////////////


/obj/machinery/mind_machine/mind_machine_hub/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = NANOUI_FOCUS)
	if(errorMessage != MINDMACHINE_NOERROR)
		spawn(5 SECONDS)
			errorMessage = MINDMACHINE_NOERROR

	var/list/data = list(
			"occupantScan" = occupantScan,
			"lockedPods" = lockedPods,
			"bluespaceConduit" = bluespaceConduit,
			"soulShardSafety" = soulShardSafety,
			"manipRating" = manipRating,
			"swapProgress" = swapProgress,
			"errorMessage" = errorMessage
	)

	var/occData[0]
	if(occupantScan)
		occData["nameOne"] = occupantOne.name
		occData["nameTwo"] = occupantTwo.name
		occData["statOne"] = occupantStatOne
		occData["statTwo"] = occupantStatTwo
		occData["mindTypeOne"] = mindTypeOne
		occData["mindTypeTwo"] = mindTypeTwo
	data["occData"] = occData;


	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)

	if(!ui)
		ui = new(user, src, ui_key, "mind_machine.tmpl", "Mind Machine", 350,500)
		ui.set_initial_data(data)
		ui.open()
	ui.set_auto_update(1)

/obj/machinery/mind_machine/mind_machine_hub/Topic(href, href_list)
	if(..())
		return
	if(!connectOne.Adjacent(src) || !connectTwo.Adjacent(src) || !connectOne.anchored || !connectTwo.anchored)
		return
	if(podsConnected)
		if(href_list["scan_start"])
			if(!currentlySwapping)
				playsound(src, 'sound/machines/twobeep.ogg', 35, 1)
				scanOccupants()
				return TRUE
			else
				errorMessage = MINDMACHINE_CURRENTLY_ACTIVE
				return TRUE
		if(href_list["unlock_pods"])
			if(((!connectOne.contents.len) || (!connectTwo.contents.len)) && (currentlySwapping))
				unlockPods() //Safeguard against the pod getting trapped in infinite scan
				return TRUE
			if(!lockedPods)
				errorMessage = MINDMACHINE_PODS_UNLOCKED
				return TRUE
			if(currentlySwapping)
				errorMessage = MINDMACHINE_CURRENTLY_ACTIVE
				return TRUE
			else
				unlockPods()
				return TRUE
		if(href_list["eject_pods"])
			if((!currentlySwapping) && (!lockedPods))
				playsound(src, 'sound/machines/twobeep.ogg', 35, 1)
				ejectPods()
				return TRUE
			if(lockedPods == TRUE)
				errorMessage = MINDMACHINE_PODS_LOCKED
				return TRUE
		if(href_list["mind_swap"])
			if((occupantScan) && (!currentlySwapping))
				log_admin("[key_name(usr)] mind swap at [formatJumpTo(get_turf(usr))]")
				playsound(src, 'sound/machines/twobeep.ogg', 35, 1)
				swapOccupants()
				return TRUE
			if(!occupantScan)
				errorMessage = MINDMACHINE_REQ_SCAN
				return TRUE
			if(currentlySwapping)
				errorMessage = MINDMACHINE_CURRENTLY_ACTIVE
				return TRUE
		if(href_list["delay_swap"])
			if(!currentlySwapping)
				log_admin("[key_name(usr)] delayed mind swap at [formatJumpTo(get_turf(usr))]")
				currentlySwapping = TRUE
				playsound(src, 'sound/machines/twobeep.ogg', 35, 1)
				delayedSwap()
				return TRUE


//////Scan and Swap, other UI procs//////////////

/obj/machinery/mind_machine/mind_machine_hub/proc/unlockPods()
	occupantScan = FALSE
	mindTypeOne = "None"
	mindTypeTwo = "None"
	connectOne.icon_state = "mind_pod_open"
	connectTwo.icon_state = "mind_pod_open"
	playsound(connectTwo, 'sound/machines/door_unbolt.ogg', 35, 1)
	playsound(connectOne, 'sound/machines/door_unbolt.ogg', 35, 1)
	if(!beenSwapped)
		flick("mind_pod_opening", connectOne)
		flick("mind_pod_opening", connectTwo)
	else
		flick("mind_pod_thefly", connectOne)
		flick("mind_pod_thefly", connectTwo)
		beenSwapped = FALSE
	lockedPods = FALSE

/obj/machinery/mind_machine/mind_machine_hub/proc/ejectPods()
	connectOne.go_out()
	connectTwo.go_out()

/obj/machinery/mind_machine/mind_machine_hub/proc/delayedSwap()
	if(!occupantScan)
		errorMessage = MINDMACHINE_DELAY_CAUTION
		nanomanager.update_uis(src)
		sleep(5 SECONDS)
		if(gcDestroyed)
			return
		currentlySwapping = FALSE
		if(occupantOne && occupantTwo)
			scanOccupants()
			if(prob(8-manipRating)) //A tiny bit risky with no upgrades, 0 risk with full xenoarch manipulators.
				malfSwap = TRUE
			swapOccupants()
			unlockPods()
		else
			errorMessage = MINDMACHINE_MISSING_OCC

/obj/machinery/mind_machine/mind_machine_hub/proc/scanOccupants()
	if((!locate(occupantOne,connectOne.contents)) || (!locate(occupantTwo, connectTwo.contents)))
		errorMessage = MINDMACHINE_MISSING_OCC
		return
	currentlySwapping = TRUE
	lockedPods = TRUE
	if(!occupantScan && !beenSwapped)
		playsound(connectOne, 'sound/machines/poddoor.ogg', 55, 1)
		playsound(connectTwo, 'sound/machines/poddoor.ogg', 55, 1)
		flick("mind_pod_closing",connectOne)
		connectOne.icon_state = "mind_pod_closed"
		flick("mind_pod_closing",connectTwo)
		connectTwo.icon_state = "mind_pod_closed"
	sleep(2 SECONDS)
	if(gcDestroyed)
		return
	if(!locate(occupantOne,connectOne.contents) || !locate(occupantTwo, connectTwo.contents) || !connectOne || !connectTwo)
		errorMessage = MINDMACHINE_MISSING_OCC
		currentlySwapping = FALSE
		occupantOne = null
		occupantTwo = null
		return
	occupantScan = TRUE
	playsound(connectOne, 'sound/effects/sparks4.ogg', 80, 1)
	playsound(connectTwo, 'sound/effects/sparks4.ogg', 80, 1)
	scanPod(occupantOne)
	scanPod(occupantTwo)
	currentlySwapping = FALSE

/obj/machinery/mind_machine/mind_machine_hub/proc/scanPod(var/mob/living/S)
	var/MT
	var/OS
	switch(S.stat)
		if(CONSCIOUS)
			OS = "Alive"
		if(UNCONSCIOUS)
			OS = "Unconscious"
		if(DEAD)
			OS = "Dead"
	if(!S.mind)
		MT = MINDMACHINE_LOWER//Simple mob
	if(S.mind)
		if(isrobot(S))
			MT = MINDMACHINE_SILICON //Silicon player, obviously
		else
			MT = MINDMACHINE_HIGHER //Player controlled
	if(isvampire(S) || isanycultist(S) || ischangeling(S) || ismalf(S))
		MT = MINDMACHINE_SHIELDED //Mostly to fix spell bugs but also tinfoil
	if(is_type_in_list(S, illegalSwap) || is_type_in_list(S, illegalSwap))
		MT = MINDMACHINE_SHIELDED
	if((ishigherbeing(S)) || (ismonkey(S)))
		if(S.is_wearing_any(list(/obj/item/clothing/head/tinfoil,/obj/item/clothing/head/helmet/stun), slot_head))
			MT = MINDMACHINE_SHIELDED
	if(S == occupantOne)
		mindTypeOne = MT
		occupantStatOne = OS
	if(S == occupantTwo)
		mindTypeTwo = MT
		occupantStatTwo = OS

/obj/machinery/mind_machine/mind_machine_hub/proc/swapOccupants(var/mob/living/M)
	if(!occupantScan || !lockedPods)
		return
	if(!locate(occupantOne,connectOne.contents) || (!locate(occupantTwo, connectTwo.contents)))
		errorMessage = MINDMACHINE_MISSING_OCC //sanity and wizards exist
		occupantOne = null
		occupantTwo = null
		unlockPods()
		return
	if(bluespaceConduit <= 0)
		errorMessage = MINDMACHINE_CONDUIT_CHARGE
		return
	if(mindTypeOne == MINDMACHINE_SHIELDED || mindTypeTwo == MINDMACHINE_SHIELDED)
		errorMessage = MINDMACHINE_SHIELD_ERROR
		spark(src)
		spark(connectOne)
		spark(connectTwo)
		unlockPods()
		return
	if(occupantStatOne == "Dead" || occupantStatTwo == "Dead")	//Being able to swap if they die between scan and swap is intentional
		if(!soulShardSafety) //Secrets
			errorMessage = MINDMACHINE_LIVING_REQUIRED
			return
		soulShardSafety = FALSE
		errorMessage = MINDMACHINE_SHARD_REACTION
	if(isobserver(occupantOne.mind) || isobserver(occupantTwo.mind))	//Probably safest
		return
	currentlySwapping = TRUE
	icon_state = "mind_hub_active"
	connectOne.icon_state = "mind_pod_active"
	connectTwo.icon_state = "mind_pod_active"
	flyTally(occupantOne)
	flyTally(occupantTwo)
	for(var/prog in 1 to 40/manipRating) //Counts up 5 to 10 seconds, checks if we lost power each time and ruins your day if so. Otherwise just for UI progress bar
		if(stat & (FORCEDISABLE|NOPOWER))
			malfSwap = TRUE
		if(!connectOne.Adjacent(src) || !connectTwo.Adjacent(src))
			malfSwap = TRUE
		sleep(1 SECONDS)
		if(gcDestroyed)
			return
		if(!locate(occupantOne,connectOne.contents) || !locate(occupantTwo, connectTwo.contents) || !connectOne || !connectTwo)
			errorMessage = MINDMACHINE_MISSING_OCC
			swapProgress = 0
			currentlySwapping = FALSE
			occupantOne = null
			occupantTwo = null
			return
		swapProgress += 1
		nanomanager.update_uis(src)
	log_admin("Mind machine swap: [occupantOne] and [occupantTwo] at [formatJumpTo(get_turf(src))]")
	if(malfSwap) ///////////Swaps begin///////
		malfunction()
		return
	if(mindTypeOne == MINDMACHINE_LOWER && mindTypeTwo == MINDMACHINE_LOWER)
		lowerSwap()
		return
	if(theFly.len > 0)
		theFlySwap()
		return
	if(mindTypeOne == MINDMACHINE_HIGHER && mindTypeTwo == MINDMACHINE_HIGHER)
		higherSwap()
		return
	if(mindTypeOne ==MINDMACHINE_HIGHER && mindTypeTwo == MINDMACHINE_LOWER || mindTypeOne == MINDMACHINE_LOWER && mindTypeTwo == MINDMACHINE_HIGHER)
		animorphsSwap()
		return
	if(mindTypeOne == MINDMACHINE_SILICON && scanRatingOne <7 || mindTypeTwo == MINDMACHINE_SILICON && scanRatingTwo <7)
		errorMessage = MINDMACHINE_SCANNER_INSUFF
		swapProgress = 0
		currentlySwapping = FALSE
		iconReset()
		return
	if(mindTypeOne == MINDMACHINE_SILICON && mindTypeTwo == MINDMACHINE_SILICON)
		higherSwap() //Silicon swaps, checks if their pod is upgraded enough then performs normal swap
		return
	if(mindTypeOne == MINDMACHINE_SILICON && mindTypeTwo != MINDMACHINE_SILICON)
		if(mindTypeTwo == MINDMACHINE_LOWER)
			animorphsSwap()
			return
		if(mindTypeTwo == MINDMACHINE_HIGHER && theFly.len == 0)
			higherSwap()
			return
	if(mindTypeTwo == MINDMACHINE_SILICON && mindTypeOne != MINDMACHINE_SILICON)
		if(mindTypeOne == MINDMACHINE_LOWER)
			animorphsSwap()
			return
		if(mindTypeOne == MINDMACHINE_HIGHER && !theFly.len)
			higherSwap()
			return
	else
		errorMessage = MINDMACHINE_UNKNOWN_INT
		currentlySwapping = FALSE
		swapProgress = 0
		unlockPods()

/obj/machinery/mind_machine/mind_machine_hub/proc/flyTally(var/mob/living/M)
	for(var/obj/item/weapon/holder/i in get_contents_in_object(M))  //Carp in pack? Outta luck, Jack
		theFly += i
	var/list/borers = M.get_brain_worms()
	for(var/mob/living/simple_animal/borer/B in borers) //borers in the body are counted
		theFly += B

/obj/machinery/mind_machine/mind_machine_hub/emp_act(severity)
	..()
	if(currentlySwapping)
		malfSwap = TRUE

/obj/machinery/mind_machine/mind_machine_hub/emag_act()
	if(currentlySwapping)
		spark(src)
		malfSwap = TRUE

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
		bluespaceConduit -= 1
	else
		errorMessage = MINDMACHINE_SUM_TOO_LOW //There's just nothing to swap for monkeymen
		playsound(src, 'sound/machines/buzz-sigh.ogg', 50, 1)
	mainReset()

/obj/machinery/mind_machine/mind_machine_hub/proc/higherSwap()
	var/mob/living/HO = occupantOne
	var/mob/living/HT = occupantTwo
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
	var/mob/living/dummy = new(src)
	HO.mind.transfer_to(dummy)
	HT.mind.transfer_to(HO)
	dummy.mind.transfer_to(HT)
	qdel(dummy)
	for(var/spell/S in HO_spells)
		HT.add_spell(S)
	for(var/spell/S in HT_spells)
		HO.add_spell(S)
	HO.confused += 8
	HO.dizziness += 8
	HT.confused += 8
	HT.dizziness += 8
	bluespaceConduit -= 1
	mainReset()


/obj/machinery/mind_machine/mind_machine_hub/proc/animorphsSwap()
	var/mob/animorph = null //Our player
	var/mob/simpleMob = null
	var/mob/living/MO = occupantOne
	var/mob/living/MT = occupantTwo
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
	bluespaceConduit -= 1
	mainReset()

/obj/machinery/mind_machine/mind_machine_hub/proc/malfunction()
	malfSwap = FALSE
	if(!soulShardSafety) //If there's no safety and it's emagged or an EMP goes off mid-scan, throws minds into a mindless mob within 50 tiles
		malfSwap(occupantOne, mindTypeOne)
		malfSwap(occupantTwo, mindTypeTwo)
		beenSwapped = TRUE
	else
		soulShardSafety = FALSE
		errorMessage = MINDMACHINE_SAFETY_CONSUMED
	bluespaceConduit -= 1
	scanSwapReset()
	iconReset()
	swapProgress = 0

/obj/machinery/mind_machine/mind_machine_hub/proc/malfSwap(var/mob/living/M, var/MT)
	if(MT == MINDMACHINE_HIGHER || MT == MINDMACHINE_SILICON)
		var/list/woopsMobs = list()
		var/mob/woopsTarget = null
		for(var/mob/living/R in mob_list)
			if((!R.mind) && (R.stat != 2) && (get_dist(src, R) < 50) && (connectOne.z == R.z) && (!is_type_in_list(R, illegalSwap)))
				woopsMobs += R
		if(woopsMobs.len)
			woopsTarget = pick(woopsMobs)
			var/list/M_spells = list()
			M_spells = M.spell_list.Copy()
			if(M.mind.special_verbs.len)	//All the safeties in higher swap.
				for(var/V in M.mind.special_verbs)
					M.verbs -= V
			for(var/spell/S in M.spell_list)
				M.remove_spell(S)
			M.mind.transfer_to(woopsTarget)
			log_admin("Mind machine malfunction: [M] sent into [woopsTarget] at [formatJumpTo(get_turf(woopsTarget))]")
			for(var/spell/S in M_spells)
				woopsTarget.add_spell(S)
			woopsMobs.len = 0	//Just to be safe
			to_chat(M, "<span class='bdanger'>Your mind is thrown out of the machine and forced into a nearby vessel!</span>")
			playsound(M, "sound/effects/phasein.ogg", 50, 1)
			errorMessage = MINDMACHINE_DELIVERY_ERROR
		else
			to_chat(M, "<span class='bdanger'>Your mind is severely damaged by the feedback!</span>")
			playsound(M, "sound/misc/balloon_pop.ogg", 50, 1)
			if(ishuman(M))
				M.adjustBrainLoss(75)
			errorMessage = MINDMACHINE_MIND_DAMAGED
	if(MT == MINDMACHINE_LOWER)
		var/list/randFaction = list("hostile", "neutral", "carp", "necro", "wizard", "syndicate", "cult")
		M.faction = pick(randFaction)


/obj/machinery/mind_machine/mind_machine_hub/proc/theFlySwap()
	var/list/mindFly = list()
	var/list/simpFly = list()
	var/mob/living/MO = occupantOne
	var/mob/living/MT = occupantTwo
	for(var/obj/item/weapon/holder/D in theFly)
		for(var/mob/M in D.contents)
			theFly += M //Gets the mob stored in the holder, adds it to the list
		qdel(D)
	theFly += MO
	theFly += MT
	for(var/mob/living/q in theFly)
		if(q.mind)
			mindFly += q
		else
			simpFly += q
	var/mob/living/dummy = new(src)
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
	bluespaceConduit -= 1
	mainReset()
	theFly.len = 0
	simpFly.len = 0
	mindFly.len = 0
	errorMessage = MINDMACHINE_TRANSPORT_ANOM

/obj/machinery/mind_machine/mind_machine_hub/proc/mainReset()
	scanSwapReset()
	iconReset()
	postSwapReset()

/obj/machinery/mind_machine/mind_machine_hub/proc/iconReset()
	connectOne.icon_state = "mind_pod_closed"
	connectTwo.icon_state = "mind_pod_closed"
	icon_state = "mind_hub"

/obj/machinery/mind_machine/mind_machine_hub/proc/scanSwapReset()
	currentlySwapping = FALSE
	occupantScan = FALSE

/obj/machinery/mind_machine/mind_machine_hub/proc/postSwapReset()
	swapProgress = 0
	beenSwapped = TRUE


//Swaps over///////////////
//Pod stuff//////////

/obj/machinery/mind_machine/mind_machine_pod
	name = "Mind Machine Pod"
	icon_state = "mind_pod_open"
	desc = "A large pod used for mind transfers. Contains two locking systems: One for ensuring occupants do not disturb the transfer process, and another that prevents lower minded creatures from leaving on their own."
	var/mob/living/occupant = null
	var/podNumber = 0
	var/obj/machinery/mind_machine/mind_machine_hub/connectedHub

/obj/machinery/mind_machine/mind_machine_pod/New()
	..()
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
	RefreshParts()

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
		connectedHub.podsConnected = FALSE
		switch(podNumber)
			if(1)
				connectedHub.connectOne = null
			if(2)
				connectedHub.connectTwo = null
	..()

/obj/machinery/mind_machine/mind_machine_pod/crowbarDestroy(mob/user, obj/item/tool/crowbar/I)
	if(occupant)
		to_chat(user, "<span class='warning'>[occupant] is inside the [src]!</span>")
		return FALSE
	return ..()

/obj/machinery/mind_machine/mind_machine_pod/MouseDropTo(atom/movable/O, mob/user)
	if(connectedHub.lockedPods)
		to_chat(user, "<span class='notice'>The pod is locked tight!</span>")
		return
	if(!ismob(O))
		return
	if(!isturf(O.loc) || !isturf(user.loc) || !user.Adjacent(O)) //I stole all this from DNA scanners
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
		to_chat(user, "<span class='notice'>The pod is already occupied!</span>")
		return
	if(panel_open)
		to_chat(user, "<span class='notice'>Close the maintenance panel first.</span>")
		return
	var/mob/L = O
	if(!istype(L))
		return
	if(iscluwnebanned(L))
		to_chat(user, "<span class='notice'>You consider loading the pod, but something tells you that would be a bad idea.</span>")
		return
	for(var/mob/living/carbon/slime/M in range(1,L))
		if(M.Victim == L)
			to_chat(usr, "<span class='notice'>[L] will not fit into the pod because they have a slime latched onto their head.</span>")
			return
	if(L == user)
		visible_message("<span class='notice'>[user] climbs into \the [src].</span>")
	else
		visible_message("<span class='notice'>[user] puts [L.name] into \the [src].</span>")
	if(user.pulling == L)
		user.stop_pulling()
	put_in(L)

/obj/machinery/mind_machine/mind_machine_pod/MouseDropFrom(over_object, src_location, var/turf/over_location, src_control, over_control, params)
	if(connectedHub.lockedPods)
		to_chat(usr, "<span class='notice'>The pod is locked tight!</span>")
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
		visible_message("<span class='notice'>[usr] climbs out of the \the [src]</span>")
	else
		visible_message("<span class='notice'>[usr] pulls [occupant.name] out of \the [src].</span>")
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

/obj/machinery/mind_machine/mind_machine_pod/relaymove(mob/user)
	if(user.stat)
		return
	if(connectedHub.currentlySwapping)
		to_chat(user, "<span class='warning'>Your head feels fuzzy and your body is limp. You can't properly focus on getting out.</span>")
		if(do_after(user, src, 90 SECONDS)) //More of a safety than a feature
			connectedHub.currentlySwapping = FALSE
			connectedHub.beenSwapped = FALSE
			connectedHub.malfSwap = FALSE
			connectedHub.swapProgress = 0
			connectedHub.theFly.len = 0
			connectedHub.unlockPods()
			return
	if(connectedHub.lockedPods)
		to_chat(user, "<span class='info'>You begin pushing and prying at the door.</span>")
		if(do_after(user, src, 10 SECONDS))
			connectedHub.unlockPods()
			return
	src.go_out(ejector = user)

/obj/machinery/mind_machine/mind_machine_pod/Exited(var/atom/movable/O)
	if (O == occupant)
		occupant = null
		switch(podNumber)
			if(1)
				connectedHub.occupantOne = null
			if(2)
				connectedHub.occupantTwo = null